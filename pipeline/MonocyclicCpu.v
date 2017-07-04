//MonocyclicCpu.v
`timescale 1ns/1ns

module MonocyclicCpu (reset, clk, led, switch, digi_out1, digi_out2, digi_out3, digi_out4);
    input reset;
    input clk;
    output [7:0] led;
    input [7:0] switch;
    output [6:0] digi_out1, digi_out2, digi_out3, digi_out4;

    //peripheral data
    wire [31:0] PerData;

    reg [31:0] PC;
    wire [31:0] PC_next;
    always @(posedge clk or negedge reset) begin
        if (~reset)
            PC <= 32'h80000000;
        else 
            PC <= PC_next;
    end

    // instruction memory part
    wire [31:0] Instruction;
    ROM rom(
        .Address({1'b0, PC[30:0]}), // PC[31] can't be index
        .data(Instruction));

    wire [31:0] DataBusA;
    wire [31:0] DataBusB;
    wire [31:0] DataBusC;

    wire [4:0] Rd;
    wire [4:0] Rt;
    wire [4:0] Rs;
    wire [4:0] Shamt;
    wire [15:0] Imm16;
    wire [25:0] JT;
    wire [5:0] OpCode;
    wire [5:0] Funct;

    assign Rd = Instruction[15:11];
    assign Rt = Instruction[20:16];
    assign Rs = Instruction[25:21];
    assign Imm16 = Instruction[15:0];
    assign JT = Instruction[25:0];
    assign Shamt = Instruction[10:6];
    assign OpCode = Instruction[31:26];
    assign Funct = Instruction[5:0];

    parameter Xp = 5'd26; // exception register
    parameter Ra = 5'd31; // function breakpoint register

    // control part
    wire IRQ;
    wire [2:0] PCSrc;
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

    // There is no need to put "ExtOp" signal into any register,
    // for it works just at "ID" stage

    wire [2:0] WB_ctrlSignal;
    wire [1:0] MEM_ctrlSignal;
    wire [14:0] EX_ctrlSignal;
    wire [19:0] whole_ctrlSignal;

    // EX_ctrlSignal[0]=ALUSrc1, EX_ctrlSignal[1]=ALUSrc2, EX_ctrlSignal[3:2]=RegDst, EX_ctrlSignal[9:4]=ALUFun
    // EX_ctrlSignal[10]=Sign, EX_ctrlSignal[11]=LUOp, EX_ctrlSignal[14:12]=PCSrc
    assign EX_ctrlSignal = {PCSrc,LUOp,Sign,ALUFun,RegDst,ALUSrc2,ALUSrc1};

    // MEM_ctrlSignal[0]=MemWrite, MEM_ctrlSignal[1]=MemRead 
    assign MEM_ctrlSignal = {MemRead,MemWrite};

    // WB_ctrlSignal[0]=RegWrite, WB_ctrlSignal[2:1]=MemtoReg
    assign WB_ctrlSignal = {MemtoReg,RegWrite};

    // whole_ctrlSignal[19:17]=WB_ctrlSignal, whole_ctrlSignal[16:15]=MEM_ctrlSignal, whole_ctrlSignal[14:0]=EX_ctrlSignal
    assign whole_ctrlSignal = {WB_ctrlSignal,MEM_ctrlSignal,EX_ctrlSignal};

    /******************** end ********************/

    // register part
    wire [4:0] AddrC;
    assign AddrC = 
        (RegDst == 2'b00)? Rt : 
        (RegDst == 2'b01)? Rd :
        (RegDst == 2'b10)? Ra :
        Xp;

    RegFile rgf(
        .reset(reset),
        .clk(clk),
        .addr1(Rs),
        .data1(DataBusA),
        .addr2(Rt),
        .data2(DataBusB),
        .wr(RegWrite),
        .addr3(AddrC),
        .data3(DataBusC));

    // immediate number process parts
    wire [31:0] Ext_out; // output of EXTOp module
    assign Ext_out = {ExtOp? {16{Imm16[15]}} : 16'h0000, Imm16};

    wire [31:0] LU_out; // output of LUOp mux
    assign LU_out = (LUOp)? {Imm16, 16'h0000} : Ext_out;

    // input of ALU
    wire [31:0] input_A;
    wire [31:0] input_B;

    assign input_A = (ALUSrc1)? {27'b0, Shamt} : DataBusA;
    assign input_B = (ALUSrc2)? LU_out : DataBusB;

    // program counter part
    wire [31:0] PC_plus_4;
    wire [31:0] ConBA;
    parameter ILLOP = 32'h80000004; // Interruption
    parameter XADR = 32'h80000008; // Exception
    wire [31:0] Branch; // output of ALUOut[0] mux
    wire [31:0] ALUOut;

    assign PC_plus_4 = {1'b0, PC[30:0] + 31'd4};
    assign Branch = ALUOut[0]? ConBA : PC_plus_4;
    assign ConBA = {PC[31], PC_plus_4[30:0] + {Ext_out[28:0], 2'b00}};

    assign PC_next = 
        (PCSrc == 3'b000)? PC_plus_4 :
        (PCSrc == 3'b001)? Branch :
        (PCSrc == 3'b010)? {PC_plus_4[31:28], JT, 2'b00} :
        (PCSrc == 3'b011)? DataBusA :
        (PCSrc == 3'b100)? ILLOP :
        XADR;

    // alu part
    ALU alu(
    	.A(input_A),
    	.B(input_B),
    	.ALUFun(ALUFun),
    	.Sign(Sign),
    	.Z(ALUOut));

    // data memory part
    wire MemWr;
    wire PerWr; // PeripheralWrite

    wire [31:0] MemData;
    wire [31:0] DataOut;
    wire [11:0] digi_in;

    assign MemWr = (MemWrite && ~ALUOut[30]); // waiting to confirm
    assign PerWr = (MemWrite && ALUOut[30]);

    DataMem mem(
    	.reset(reset),
    	.clk(clk),
    	.rd(MemRead),
    	.wr(MemWr),
    	.addr(ALUOut),
    	.wdata(DataBusB),
    	.rdata(MemData));

    Peripheral prph(
        .reset(reset),
        .clk(clk),
        .rd(MemRead),
        .wr(PerWr),
        .addr(ALUOut),
        .wdata(DataBusB),
        .rdata(PerData),
        .led(led),
        .switch(switch),
        .digi(digi_in),
        .irqout(IRQ));

    digitube_scan dgt_sc(
        .digi_in(digi_in),
        .digi_out4(digi_out4),
        .digi_out3(digi_out3),
        .digi_out2(digi_out2),
        .digi_out1(digi_out1));

    assign DataOut = ALUOut[30]? PerData : MemData;

    assign DataBusC = 
    	(MemtoReg[1:0] == 2'b00)? ALUOut :
    	(MemtoReg[1:0] == 2'b01)? DataOut :
    	PC_plus_4;

endmodule