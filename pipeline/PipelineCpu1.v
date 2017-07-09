//PipelineCpu.v
`timescale 1ns/1ns

// PipelineCpu
module PipelineCpu (reset, clk, PerData, IRQ, MemRead, PerWr, ALUOut, DataBusB, PC_31);
    input reset;
    input clk;
    input IRQ;
    output PC_31;

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

    wire [31:0] PC_plus_4;
    assign PC_plus_4 = {PC[31], PC[30:0] + 31'd4};

    assign PC_31 = PC[31];
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
    output [31:0] DataBusB;
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
    wire [2:0] PCSrc;
    wire [1:0] RegDst;
    wire RegWrite;
    wire ALUSrc1;
    wire ALUSrc2;
    wire [5:0] ALUFun;
    wire Sign;
    wire MemWrite;
    output MemRead;
    wire [1:0] MemtoReg;
    wire ExtOp;
    wire LUOp;

    Control ctrl(
        .OpCode(OpCode),
        .Funct(Funct),
        .IRQ(IRQ),
        .PCSrc(PCSrc),
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

    hazard_detection_unit hazard_unit(.ID_EX_MemRead(ID_EX_MemRead),
                                    .ID_EX_RegisterRt(ID_EX_RegisterRt),
                                    .IF_ID_RegisterRs(Rs),
                                    .IF_ID_RegisterRt(Rt),
                                    // output
                                    .IF_ID_Write(IF_ID_Write),
                                    .PC_Write(PC_Write),
                                    .ctrl_Mux(ctrl_Mux));

    assign sent_to_Register_ctrlSignal = ctrl_Mux? whole_ctrlSignal: 17'b0;

    // register part
    RegFile rgf(
        .reset(reset),
        .clk(clk),
        .addr1(Rs),
        .data1(DataBusA),
        .addr2(Rt),
        .data2(DataBusB),
        .wr(MEM_WB_RegWrite),
        .addr3(MEM_WB_RegisterRd),
        .data3(DataBusC));

    wire [31:0] Ext_out; // output of EXTOp module
    assign Ext_out = {ExtOp? {16{Imm16[15]}} : 16'h0000, Imm16};

    wire [31:0] LU_out; // output of LUOp mux
    assign LU_out = (LUOp)? {Imm16, 16'h0000} : Ext_out;

    wire [31:0] ID_ConBA;
    assign ID_ConBA = {ID_PC[31], PC_plus_4[30:0] + {Ext_out[28:0], 2'b00}};

    wire [31:0] ID_processed_DataBusA,ID_processed_DataBusB;
    assign ID_processed_DataBusA = (ALUSrc1)? {27'b0, Shamt} : DataBusA;
    assign ID_processed_DataBusB = (ALUSrc2)? LU_out : DataBusB;

    /******************** end ********************/

    /******************** ID/EX joint *******************/
    wire [15:0] EX_EX_ctrlSignal;
    wire [1:0] EX_MEM_ctrlSignal;
    wire [2:0] EX_WB_ctrlSignal;
    wire [31:0] EX_processed_DataBusA,EX_processed_DataBusB;
    wire [4:0] ID_EX_RegisterRs,ID_EX_RegisterRt,ID_EX_RegisterRd;
    wire [31:0] EX_ConBA,EX_PC_plus_4;
    wire [25:0] EX_JT;
    wire [31:0] EX_DataBusA,EX_DataBusB;
    ID_EX_Register RegisterII(.sysclk(clk),
                              .reset(reset),
                              .wholeSignal(sent_to_Register_ctrlSignal),
                              .IF_ID_RegisterRs(Rs),
                              .IF_ID_RegisterRt(Rt),
                              .IF_ID_RegisterRd(Rd),
                              .input_DataBusA(ID_processed_DataBusA),
                              .input_DataBusB(ID_processed_DataBusB),
                              .ID_ConBA(ID_ConBA),
                              .ID_JT(ID_JT),
                              .ID_PC_plus_4(ID_PC_plus_4),
                              .ID_DataBusA(DataBusA),
                              .ID_DataBusB(DataBusB),
                              // output part
                              .EX_ctrlSignal(EX_EX_ctrlSignal),
                              .WB_ctrlSignal(EX_WB_ctrlSignal),
                              .MEM_ctrlSignal(EX_MEM_ctrlSignal),
                              .Rs(ID_EX_RegisterRs),
                              .Rt(ID_EX_RegisterRt),
                              .Rd(ID_EX_RegisterRd),
                              .output_DataBusA(EX_processed_DataBusA),
                              .output_DataBusB(EX_processed_DataBusB),
                              .EX_ConBA(EX_ConBA),
                              .EX_JT(EX_JT),
                              .EX_PC_plus_4(EX_PC_plus_4),
                              .EX_DataBusA(EX_DataBusA),
                              .EX_DataBusB(EX_DataBusB));

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
    wire [2:0] EX_PCSrc;
    assign EX_PCSrc = EX_EX_ctrlSignal[11:9];
    // MEM_ctrlSignal[0]=MemWrite, MEM_ctrlSignal[1]=MemRead 
    wire ID_EX_MemRead;
    assign ID_EX_MemRead = EX_MEM_ctrlSignal[1];

    wire [1:0] ForwardA,ForwardB;
    bypassing_unit Bypassing(.ID_EX_RegisterRs(ID_EX_RegisterRs),
                             .ID_EX_RegisterRt(ID_EX_RegisterRt),
                             .EX_MEM_RegisterRd(EX_MEM_RegisterRd),
                             .EX_MEM_RegWrite(EX_MEM_RegWrite),
                             .MEM_WB_RegisterRd(MEM_WB_RegisterRd),
                             .MEM_WB_RegWrite(MEM_WB_RegWrite),
                             .ForwardA(ForwardA),
                             .ForwardB(ForwardB))

    // input of ALU
    wire [31:0] input_A;
    wire [31:0] input_B;

    assign input_A = 
        (ForwardA == 2'b00)? EX_processed_DataBusA:
        (ForwardA == 2'b01)? MEM_WB_RegisterRd:
        (ForwardA == 2'b10)? EX_MEM_RegisterRd;

    assign input_B = 
        (ForwardB == 2'b00)? EX_processed_DataBusB:
        (ForwardB == 2'b01)? MEM_WB_RegisterRd:
        (ForwardB == 2'b10)? EX_MEM_RegisterRd;


    // program counter part
    
    parameter ILLOP = 32'h80000004; // Interruption
    parameter XADR = 32'h80000008; // Exception
    wire [31:0] Branch; // output of ALUOut[0] mux
    output [31:0] ALUOut;


    assign Branch = ALUOut[0]? EX_ConBA : EX_PC_plus_4;

    assign PC_next = 
        (EX_PCSrc == 3'b000)? EX_PC_plus_4 :
        (EX_PCSrc == 3'b001)? Branch :
        (EX_PCSrc == 3'b010)? {EX_PC_plus_4[31:28], EX_JT, 2'b00} :
        (EX_PCSrc == 3'b011)? EX_DataBusA :
        (EX_PCSrc == 3'b100)? ILLOP :
        XADR;

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
        (EX_RegDst == 2'b00)? ID_EX_RegisterRt : 
        (EX_RegDst == 2'b01)? ID_EX_RegisterRd :
        (EX_RegDst == 2'b10)? Ra :
        Xp;

    /******************** end ********************/

    /******************** EX/MEM joint *******************/
    wire [31:0] MEM_ALUOut;
    wire [2:0] MEM_WB_ctrlSignal;
    wire [1:0] MEM_MEM_ctrlSignal;
    wire [4:0] EX_MEM_RegisterRd;
    wire [31:0] MEM_DataBusB;
    wire [31:0] MEM_PC_plus_4;
    EX_MEM_Register RegisterIII(.sysclk(clk),
                                .reset(reset),
                                .ID_EX_WB_ctrlSignal(EX_WB_ctrlSignal),
                                .ID_EX_MEM_ctrlSignal(EX_MEM_ctrlSignal),
                                .EX_ALUOut(ALUOut),
                                .EX_AddrC(EX_AddrC),
                                .EX_DataBusB(EX_DataBusB),
                                .EX_PC_plus_4(EX_PC_plus_4),
                                // output
                                .MEM_ALUOut(MEM_ALUOut),
                                .WB_ctrlSignal(MEM_WB_ctrlSignal),
                                .MEM_ctrlSignal(MEM_MEM_ctrlSignal),
                                .EX_MEM_RegisterRd(EX_MEM_RegisterRd),      // AddrC delivered to EX_MEM_RegisterRd
                                .MEM_DataBusB(MEM_DataBusB)
                                .MEM_PC_plus_4(MEM_PC_plus_4));

    /******************** end ********************/

    /******************** MEM part ********************/
    /******************** begin ********************/

    // MEM_ctrlSignal[0]=MemWrite, MEM_ctrlSignal[1]=MemRead 
    // MEM_ctrlSignal = {MemRead,MemWrite};

    wire MEM_MEMWrite;
    assign MEM_MEMWrite = MEM_MEM_ctrlSignal[0];
    wire MEM_MEMRead;
    assign MEM_MEMRead = MEM_MEM_ctrlSignal[1];

    wire EX_MEM_RegWrite;
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
    wire [4:0] MEM_WB_RegisterRd;
    wire [31:0] WB_PC_plus_4;

    MEM_WB_Register  RegisterIV(.sysclk(clk),
                                .reset(reset),
                                .MEM_ALUOut(MEM_ALUOut),
                                .MEM_PC_plus_4(MEM_PC_plus_4),
                                .EX_MEM_WB_ctrlSignal(MEM_WB_ctrlSignal),
                                .EX_MEM_RegisterRd(EX_MEM_RegisterRd),
                                .ReadData(DataOut),
                                // output
                                .WB_ctrlSignal(WB_WB_ctrlSignal),
                                .ReadData_Out(WB_DataOut),
                                .WB_ALUOut(WB_ALUOut),
                                .MEM_WB_RegisterRd(MEM_WB_RegisterRd),
                                .WB_PC_plus_4(WB_PC_plus_4));
    /******************** end ********************/

    /******************** WB part ********************/
    // WB_ctrlSignal[0]=RegWrite, WB_ctrlSignal[2:1]=MemtoReg
    // WB_ctrlSignal = {MemtoReg,RegWrite};
    wire [1:0] WB_MemtoReg;
    assign WB_MemtoReg = WB_WB_ctrlSignal[2:1];
    wire MEM_WB_RegWrite;
    assign MEM_WB_RegWrite = WB_WB_ctrlSignal[0];
    wire [31:0] WB_PC;

    assign DataBusC = 
    	(WB_MemtoReg[1:0] == 2'b00)? WB_ALUOut :
    	(WB_MemtoReg[1:0] == 2'b01)? WB_DataOut :
        (WB_MemtoReg[1:0] == 2'b10)? WB_PC_plus_4 :
    	EX_PC_plus_4;

    // When interruption happens, ID/EX.PC_plus_4 should be written to Register.

endmodule