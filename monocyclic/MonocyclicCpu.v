//MonocyclicCpu.v
`timescale 1ns/1ns

// MonocyclicCpu
module MonocyclicCpu (reset, clk, PerData, IRQ, MemRead, PerWr, ALUOut, DataBusB, PC_31);
    input reset;
    input clk;
    output IRQ;
    output PC_31;


    //peripheral data
    input [31:0] PerData;

    reg [31:0] PC;
    wire [31:0] PC_next;
    always @(posedge clk or negedge reset) begin
        if (~reset)
            PC <= 32'h80000000;
        else 
            PC <= PC_next;
    end

    assign PC_31 = PC[31];

    // instruction memory part
    wire [31:0] Instruction;
    ROM rom(
        .addr({1'b0, PC[30:0]}), // PC[31] can't be index
        .data(Instruction));

    wire [31:0] DataBusA;
    output [31:0] DataBusB;
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
    output IRQ;
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
    output [31:0] ALUOut;

    assign PC_plus_4 = {PC[31], PC[30:0] + 31'd4};
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
    output PerWr; // PeripheralWrite

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

    assign DataOut = ALUOut[30]? PerData : MemData;

    assign DataBusC = 
    	(MemtoReg[1:0] == 2'b00)? ALUOut :
    	(MemtoReg[1:0] == 2'b01)? DataOut :
        (MemtoReg[1:0] == 2'b10)? PC_plus_4 :
    	PC;

endmodule