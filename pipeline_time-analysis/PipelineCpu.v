//PipelineCpu.v
`timescale 1ns/1ns

// PipelineCpu
module PipelineCpu (reset, clk, PerData, IRQ, MEM_MemRead, PerWr, MEM_ALUOut, MEM_DataBusB, PC_31);
    input reset;
    input clk;
    input IRQ;

    output [31:0] MEM_ALUOut;

    parameter ILLOP = 32'h80000004; // Interruption
    parameter XADR = 32'h80000008; // Exception
    
    wire ID_Flush,IF_Flush,EX_Flush;

    //  The peripheral signal is at MEM stage.

    /******************** IF part ********************/
    /******************** begin ********************/
    wire PC_Write;
    reg [31:0] PC;
    wire [31:0] PC_next;
    always @(posedge clk or negedge reset) begin
        if (~reset)
            PC <= 32'h80000000;
        else if(PC_Write)
            PC <= PC_next;
    end

    output PC_31;
    assign PC_31 = PC[31];

    wire [31:0] PC_plus_4;
    assign PC_plus_4 = {PC[31], PC[30:0] + 31'd4};

    //assign PC_31 = PC[31];
    // instruction memory part
    wire [31:0] IF_Instruction;
    ROM rom(
        .addr({1'b0, PC[30:0]}), // PC[31] can't be index
        .data(IF_Instruction));
    /******************** end ********************/


    /******************** IF/ID joint *******************/
    wire [31:0] ID_Instruction;
    wire [31:0] ID_PC_plus_4;
    wire IF_ID_Write;
    IF_ID_Register RegisterI(.sysclk(clk),
                            .reset(reset),
                            .IF_Flush(IF_Flush | IRQ),
                            .IF_ID_Write(IF_ID_Write),
                            .IF_PC_plus_4(PC_plus_4),
                            .IF_Instruction(IF_Instruction),
                            // output
                            .ID_Instruction(ID_Instruction),
                            .ID_PC_plus_4(ID_PC_plus_4));
    /******************** end ********************/


    /******************** ID part ********************/
    /******************** begin ********************/
    wire [31:0] DataBusA;
    wire [31:0] DataBusB;
    wire [31:0] DataBusC;

    wire [4:0] Rd;
    wire [4:0] Rt;
    wire [4:0] Rs;
    wire [4:0] Shamt;
    wire [15:0] Imm16;
    wire [25:0] ID_JT;
    wire [5:0] OpCode;
    wire [5:0] Funct;

    assign Rd = ID_Instruction[15:11];
    assign Rt = ID_Instruction[20:16];
    assign Rs = ID_Instruction[25:21];
    assign Imm16 = ID_Instruction[15:0];
    assign ID_JT = ID_Instruction[25:0];
    assign Shamt = ID_Instruction[10:6];
    assign OpCode = ID_Instruction[31:26];
    assign Funct = ID_Instruction[5:0];

    // control part
    wire [2:0] Initial_PCSrc;
    wire [1:0] RegDst;
    wire RegWrite;
    wire ALUSrc1;
    wire ALUSrc2;
    wire [5:0] ALUFun;
    wire Sign;
    wire MemWrite;
    wire MemRead;
    wire [1:0] MemtoReg;
    wire ExtOp;
    wire LUOp;


    Control ctrl(
        .OpCode(OpCode),
        .Funct(Funct),
        .IRQ(IRQ),
        .PCSrc(Initial_PCSrc),
        .ALUSrc1(ALUSrc1),
        .ALUSrc2(ALUSrc2),
        .RegDst(RegDst),
        .RegWrite(RegWrite),
        .ALUFun(ALUFun),
        .Sign(Sign),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ExtOp(ExtOp),
        .LuOp(LUOp));

    wire [2:0] PCSrc;
    assign PCSrc = (~reset) ? 3'b0 : Initial_PCSrc;

    /***** Integrating the control signals according to the stages where they work ****/
    /******************** begin ********************/
    wire [2:0] WB_ctrlSignal;
    wire [1:0] MEM_ctrlSignal;
    wire [11:0] EX_ctrlSignal;
    wire [16:0] whole_ctrlSignal;

    // LUOp, ExtOp, ALUSrc1, ALUSrc2 should be discarded.
    // EX_ctrlSignal[1:0]=RegDst, EX_ctrlSignal[7:2]=ALUFun
    // EX_ctrlSignal[8]=Sign, EX_ctrlSignal[11:9]=PCSrc
    assign EX_ctrlSignal = {PCSrc,Sign,ALUFun,RegDst};

    // MEM_ctrlSignal[0]=MemWrite, MEM_ctrlSignal[1]=MemRead 
    assign MEM_ctrlSignal = {MemRead,MemWrite};

    // WB_ctrlSignal[0]=RegWrite, WB_ctrlSignal[2:1]=MemtoReg
    assign WB_ctrlSignal = {MemtoReg,RegWrite};

    // whole_ctrlSignal[16:14]=WB_ctrlSignal, whole_ctrlSignal[13:12]=MEM_ctrlSignal, whole_ctrlSignal[11:0]=EX_ctrlSignal
    assign whole_ctrlSignal = {WB_ctrlSignal,MEM_ctrlSignal,EX_ctrlSignal};
    /******************** end ********************/

    wire ctrl_Mux;
    wire [16:0] sent_to_Register_ctrlSignal;
    wire [4:0] ID_EX_RegisterRt;
    wire ID_EX_MemRead;

    hazard_detection_unit hazard_unit(.ID_EX_MemRead(ID_EX_MemRead),
                                    .ID_EX_RegisterRt(ID_EX_RegisterRt),
                                    .IF_ID_RegisterRs(Rs),
                                    .IF_ID_RegisterRt(Rt),
                                    // output
                                    .IF_ID_Write(IF_ID_Write),
                                    .PC_Write(PC_Write),
                                    .ctrl_Mux(ctrl_Mux));

    assign sent_to_Register_ctrlSignal = (~ctrl_Mux | ID_Flush | IRQ)?  17'b0 : whole_ctrlSignal;

    wire [4:0] MEM_WB_RegisterRd;
    wire MEM_WB_RegWrite;
    wire WB_IRQ;
    // register part
    RegFile rgf(
        .reset(reset),
        .clk(clk),
        .addr1(Rs),
        .data1(DataBusA),
        .addr2(Rt),
        .data2(DataBusB),
        .wr(MEM_WB_RegWrite | WB_IRQ),
        .addr3(MEM_WB_RegisterRd),
        .data3(DataBusC));

    wire [31:0] Ext_out; // output of EXTOp module
    assign Ext_out = {ExtOp? {16{Imm16[15]}} : 16'h0000, Imm16};

    wire [31:0] LUOut; // output of LUOp mux
    assign LUOut = (LUOp)? {Imm16, 16'h0000} : Ext_out;

    wire [31:0] ID_ConBA;
    assign ID_ConBA = {ID_PC_plus_4[31], ID_PC_plus_4[30:0] + {Ext_out[28:0], 2'b00}};

    wire [31:0] ID_processed_DataBusA;//,ID_processed_DataBusB;
    assign ID_processed_DataBusA = (ALUSrc1)? {27'b0, Shamt} : DataBusA;
    //assign ID_processed_DataBusB = (ALUSrc2)? LUOut : DataBusB;

    wire [31:0] Branch; // output of ALUOut[0] mux

    wire [2:0] EX_PCSrc;
    assign PC_next = 
        (PCSrc == 3'b100)? ILLOP :                  // interruption should be tested first
        (EX_PCSrc == 3'b001)? Branch :
        ( (PCSrc == 3'b000) | (PCSrc == 3'b001) )? PC_plus_4 :
        (PCSrc == 3'b010)? {PC_plus_4[31:28], ID_JT, 2'b00} :
        (PCSrc == 3'b011)? DataBusA :
        XADR;

    wire [31:0] ALUOut;

    wire [1:0] ID_branchIRQ;
    // if EX branch will happen, ID_branchIRQ = 01, else ID_branchIRQ = 00
    // if EX instruction is jump or MEM instruction is branch_happens, ID_ranchIRQ = 10
    wire [2:0] MEM_PCSrc;
    assign ID_branchIRQ = (EX_PCSrc == 3'b001 & ALUOut[0]) ? 2'b01 :
    						(EX_PCSrc == 3'b010 | EX_PCSrc == 3'b011 | (MEM_PCSrc == 3'b001 & MEM_ALUOut[0]) )? 2'b10 : 2'b00;

    /******************** end ********************/

    /******************** ID/EX joint *******************/
    wire [11:0] EX_EX_ctrlSignal;
    wire [1:0] EX_MEM_ctrlSignal;
    wire [2:0] EX_WB_ctrlSignal;
    wire [31:0] EX_processed_DataBusA;//,EX_processed_DataBusB;
    wire [4:0] ID_EX_RegisterRs,ID_EX_RegisterRd;
    wire [31:0] EX_ConBA,EX_PC_plus_4;
    wire [31:0] EX_DataBusA,EX_DataBusB;
    wire EX_ALUSrc2;
    wire [31:0] EX_LUOut;
    wire EX_IRQ;
    wire [1:0] EX_branchIRQ;
    ID_EX_Register RegisterII(.sysclk(clk),
                              .reset(reset),
                              .wholeSignal(sent_to_Register_ctrlSignal),
                              .IF_ID_RegisterRs(Rs),
                              .IF_ID_RegisterRt(Rt),
                              .IF_ID_RegisterRd(Rd),
                              .input_DataBusA(ID_processed_DataBusA),
                              //.input_DataBusB(ID_processed_DataBusB),
                              .ID_ConBA(ID_ConBA),
                              .ID_PC_plus_4(ID_PC_plus_4),
                              .ID_DataBusB(DataBusB),
                              .ID_ALUSrc2(ALUSrc2),     // deliver ALUSrc2 to judge immediate number or forwarding number
                              .ID_LUOut(LUOut),
                              .ID_IRQ(IRQ),
                              .ID_branchIRQ(ID_branchIRQ),
                              // output part
                              .EX_ctrlSignal(EX_EX_ctrlSignal),
                              .WB_ctrlSignal(EX_WB_ctrlSignal),
                              .MEM_ctrlSignal(EX_MEM_ctrlSignal),
                              .Rs(ID_EX_RegisterRs),
                              .Rt(ID_EX_RegisterRt),
                              .Rd(ID_EX_RegisterRd),
                              .output_DataBusA(EX_processed_DataBusA),
                              //.output_DataBusB(EX_processed_DataBusB),
                              .EX_ConBA(EX_ConBA),
                              .EX_PC_plus_4(EX_PC_plus_4),
                              .EX_DataBusB(EX_DataBusB),
                              .EX_ALUSrc2(EX_ALUSrc2),
                              .EX_LUOut(EX_LUOut),
                              .EX_IRQ(EX_IRQ),
                              .EX_branchIRQ(EX_branchIRQ));

    /******************** end ********************/


    /******************** EX part ********************/
    /******************** begin ********************/

    // EX_ctrlSignal[1:0]=RegDst, EX_ctrlSignal[7:2]=ALUFun
    // EX_ctrlSignal[8]=Sign, EX_ctrlSignal[11:9]=PCSrc
    // EX_ctrlSignal = {PCSrc,Sign,ALUFun,RegDst};

    wire [1:0] EX_RegDst;
    assign EX_RegDst = EX_EX_ctrlSignal[1:0];
    wire [5:0] EX_ALUFun;
    assign EX_ALUFun = EX_EX_ctrlSignal[7:2];
    wire EX_Sign;
    assign EX_Sign = EX_EX_ctrlSignal[8];
    
    assign EX_PCSrc = EX_EX_ctrlSignal[11:9];
    // MEM_ctrlSignal[0]=MemWrite, MEM_ctrlSignal[1]=MemRead 
    assign ID_EX_MemRead = EX_MEM_ctrlSignal[1];

    wire [1:0] ForwardA,ForwardB;
    wire [4:0] EX_MEM_RegisterRd;
    wire EX_MEM_RegWrite;


    bypassing_unit Bypassing(.ID_EX_RegisterRs(ID_EX_RegisterRs),
                             .ID_EX_RegisterRt(ID_EX_RegisterRt),
                             .EX_MEM_RegisterRd(EX_MEM_RegisterRd),
                             .EX_MEM_RegWrite(EX_MEM_RegWrite),
                             .MEM_WB_RegisterRd(MEM_WB_RegisterRd),
                             .MEM_WB_RegWrite(MEM_WB_RegWrite),
                             .ForwardA(ForwardA),
                             .ForwardB(ForwardB));

    flush_detection_units flush_unit(.EX_PCSrc(EX_PCSrc),
                                     .EX_ALUOut(ALUOut),
                                     .ID_PCSrc(PCSrc),
                                     // output
                                     .IF_Flush(IF_Flush),
                                     .ID_Flush(ID_Flush),
                                     .EX_Flush(EX_Flush));

    // input of ALU
    wire [31:0] input_A;
    wire [31:0] input_B;

    assign input_A = 
        (ForwardA == 2'b00)? EX_processed_DataBusA:
        (ForwardA == 2'b01)? DataBusC:
        (ForwardA == 2'b10)? MEM_ALUOut:
        5'b0;

    wire [31:0] forwarding_DataBusB;
    assign forwarding_DataBusB = 
        (ForwardB == 2'b00)? EX_DataBusB:
        (ForwardB == 2'b01)? DataBusC:
        (ForwardB == 2'b10)? MEM_ALUOut:
        5'b0;

    assign input_B = (EX_ALUSrc2)? EX_LUOut : forwarding_DataBusB;

    // program counter part



    assign Branch = ALUOut[0]? EX_ConBA : PC_plus_4;


    // alu part
    ALU alu(
    	.A(input_A),
    	.B(input_B),
    	.ALUFun(EX_ALUFun),
    	.Sign(EX_Sign),
    	.Z(ALUOut));

    parameter Xp = 5'd26; // exception register
    parameter Ra = 5'd31; // function breakpoint register

    wire [4:0] EX_AddrC;
    assign EX_AddrC = 
        (EX_RegDst == 2'b00)? ( EX_IRQ? Xp : ID_EX_RegisterRt) : 
        (EX_RegDst == 2'b01)? ID_EX_RegisterRd :
        (EX_RegDst == 2'b10)? Ra :
        Xp;

    /******************** end ********************/

    /******************** EX/MEM joint *******************/
    wire [2:0] MEM_WB_ctrlSignal;
    wire [1:0] MEM_MEM_ctrlSignal;

    output [31:0] MEM_DataBusB;
    wire [31:0] MEM_PC_plus_4;
    wire MEM_IRQ;
    wire [1:0] MEM_branchIRQ;
    EX_MEM_Register RegisterIII(.sysclk(clk),
                                .reset(reset),
                                .ID_EX_WB_ctrlSignal(EX_WB_ctrlSignal),
                                .ID_EX_MEM_ctrlSignal(EX_MEM_ctrlSignal),
                                .EX_ALUOut(ALUOut),
                                .EX_AddrC(EX_AddrC),
                                .EX_DataBusB(forwarding_DataBusB),
                                .EX_PC_plus_4(EX_PC_plus_4),
                                .EX_IRQ(EX_IRQ),
                                .EX_branchIRQ(EX_branchIRQ),
                                .EX_PCSrc(EX_PCSrc),
                                // output
                                .MEM_ALUOut(MEM_ALUOut),
                                .WB_ctrlSignal(MEM_WB_ctrlSignal),
                                .MEM_ctrlSignal(MEM_MEM_ctrlSignal),
                                .EX_MEM_RegisterRd(EX_MEM_RegisterRd),      // AddrC delivered to EX_MEM_RegisterRd
                                .MEM_DataBusB(MEM_DataBusB),
                                .MEM_PC_plus_4(MEM_PC_plus_4),
                                .MEM_IRQ(MEM_IRQ),
                                .MEM_branchIRQ(MEM_branchIRQ),
                                .MEM_PCSrc(MEM_PCSrc));

    /******************** end ********************/

    /******************** MEM part ********************/
    /******************** begin ********************/

    // MEM_ctrlSignal[0]=MemWrite, MEM_ctrlSignal[1]=MemRead 
    // MEM_ctrlSignal = {MemRead,MemWrOite};

    wire MEM_MemWrite;
    assign MEM_MemWrite = MEM_MEM_ctrlSignal[0];
    output MEM_MemRead;
    assign MEM_MemRead = MEM_MEM_ctrlSignal[1];

    assign EX_MEM_RegWrite = MEM_WB_ctrlSignal[0];

    // data memory part
    wire MemWr;
    output PerWr; // PeripheralWrite

    wire [31:0] MemData;
    wire [31:0] DataOut;

    assign MemWr = (MEM_MemWrite && ~MEM_ALUOut[30]); // waiting to confirm
    assign PerWr = (MEM_MemWrite && MEM_ALUOut[30]);

    DataMem mem(
    	.reset(reset),
    	.clk(clk),
    	.rd(MEM_MemRead),
    	.wr(MemWr),
    	.addr(MEM_ALUOut),
    	.wdata(MEM_DataBusB),
    	.rdata(MemData));

    //peripheral data
    input [31:0] PerData;

    assign DataOut = MEM_ALUOut[30]? PerData : MemData;

    /******************** end ********************/

    /******************** MEM/WB joint *******************/
    wire [2:0] WB_WB_ctrlSignal;
    wire [31:0] WB_DataOut;
    wire [31:0] WB_ALUOut;
    wire [31:0] WB_PC_plus_4;
    wire [1:0] WB_branchIRQ;

    MEM_WB_Register  RegisterIV(.sysclk(clk),
                                .reset(reset),
                                .MEM_ALUOut(MEM_ALUOut),
                                .MEM_PC_plus_4(MEM_PC_plus_4),
                                .EX_MEM_WB_ctrlSignal(MEM_WB_ctrlSignal),
                                .EX_MEM_RegisterRd(EX_MEM_RegisterRd),
                                .ReadData(DataOut),
                                .MEM_IRQ(MEM_IRQ),
                                .MEM_branchIRQ(MEM_branchIRQ),
                                // output
                                .WB_ctrlSignal(WB_WB_ctrlSignal),
                                .ReadData_Out(WB_DataOut),
                                .WB_ALUOut(WB_ALUOut),
                                .MEM_WB_RegisterRd(MEM_WB_RegisterRd),
                                .WB_PC_plus_4(WB_PC_plus_4),
                                .WB_IRQ(WB_IRQ),
                                .WB_branchIRQ(WB_branchIRQ));
    /******************** end ********************/

    /******************** WB part ********************/
    // WB_ctrlSignal[0]=RegWrite, WB_ctrlSignal[2:1]=MemtoReg
    // WB_ctrlSignal = {MemtoReg,RegWrite};
    wire [1:0] WB_MemtoReg;
    assign WB_MemtoReg = WB_WB_ctrlSignal[2:1];
    
    assign MEM_WB_RegWrite = WB_WB_ctrlSignal[0];

    /******************** interruption handling unit ********************/
    // We have two plans to handle interruption problem
    // Plan A: we make different assignments referring to different instruction
    // Plan B: we make a simple fallback: just return to the instruction where we are interrupted
    // and flush all the IF, ID signal

    // For easiness, I'd like to take Plan B first.

    wire [31:0] interruption_target;
    /*assign interruption_target = (WB_MemtoReg[1:0] == 2'b11)? 
                                () : 
                                32'b0;*/
    // schedule needed
    assign interruption_target = (WB_branchIRQ == 2'b00) ? (WB_PC_plus_4 - 32'd4) :
    							(WB_branchIRQ == 2'b01)? (WB_PC_plus_4 - 32'd8) :
    							(MEM_PC_plus_4 - 32'd4);

    assign DataBusC = 
    	(WB_MemtoReg[1:0] == 2'b00)? ( WB_IRQ? interruption_target : WB_ALUOut) :
    	(WB_MemtoReg[1:0] == 2'b01)? WB_DataOut :
        (WB_MemtoReg[1:0] == 2'b10)? WB_PC_plus_4 :
    	interruption_target;

    // When interruption happens, ID/EX.PC_plus_4 should be written to Register.

endmodule