//MonocyclicCpu.v
`timescale 1ns/1ps

module MonocyclicCpu (reset, clk);
    input reset;
    input clk;

    reg [31:0] PC;
    wire [31:0] PC_next;
    always @(posedge clk or negedge reset) begin
        if (~reset)
            PC <= 32'h00000000;
        else 
            PC <= PC_next;
    end

    // instruction memory part
    wire [31:0] Instruction;
    ROM rom(
        .Address(PC),
        .Instruction(Instruction));

    wire [31:0] DataBusA;
    wire [31:0] DataBusB;
    wire [31:0] DataBusC;

    wire [4:0] Rd;
    wire [4:0] Rt;
    wire [4:0] Rs;
    wire [4:0] Shamt;
    wire [15:0] Imm16;
    wire [27:0] JT;
    wire [5:0] OpCode;
    wire [5:0] Funct;

    assign Rd = Instruction[15:11];
    assign Rt = Instruction[20:16];
    assign Rs = Instruction[25:21];
    assign Imm16 = Instruction[15:0];
    assign JT = {Instruction[25:0], 2'b00};
    assign Shamt = Instruction[10:6];
    assign OpCode = Instruction[31:26];
    assign Funct = Instruction[5:0];

    parameter Xp = 5'd26; // exception register
    parameter Ra = 5'd31; // function breakpoint register

    // control part
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
        .LUOp(LUOp));

    // register part
    wire [4:0] AddrC;
    assign AddrC = 
        (RegDst == 2'b00)? Rd : 
        (RegDst == 2'b01)? Rt :
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
    assign LU_out = (LUOp)? {Imm16, 16'b0} : Ext_out;

    // input of ALU
    wire [31:0] input_A;
    wire [31:0] input_B;

    assign input_A = (ALUSrc1)? {27'b0, Shamt} : DataBusA;
    assign input_B = (ALUSrc2)? LU_out : DataBusB;

    // program counter part
    wire [31:0] PC_plus_4;
    wire ConBA;
    parameter ILLOP = 32'h80000004; // Interruption
    parameter XADR = 32'h80000008; // Exception
    wire [31:0] Branch; // output of ALUout[0] mux

    assign PC_plus_4 = PC + 32'd4;
    assign Branch = (ALUOut[0])? ConBA : PC_plus_4;
    assign ConBA = PC_plus_4 + {Ext_out[29:0], 2'b00};

    assign PC_next = 
        (PCSrc == 3'b000)? PC_plus_4 :
        (PCSrc == 3'b001)? Branch :
        (PCSrc == 3'b010)? JT :
        (PCSrc == 3'b011)? DataBusA :
        (PCSrc == 3'b100)? ILLOP :
        (PCSrc == 3'b101)? XADR : 
        32'h00000000;

    // alu part
    wire [31:0] ALUOut;
    ALU alu(
    	.A(input_A),
    	.B(input_B),
    	.ALUFun(ALUFun),
    	.Sign(Sign),
    	.Z(ALUOut));

    // data memory part
    wire [31:0] MemData;
    DataMem mem(
    	.reset(reset),
    	.clk(clk),
    	.rd(MemRead),
    	.wr(MemWrite),
    	.addr(ALUout),
    	.wdata(DataBusB),
    	.rdata(MemData));

    assign DataBusC = 
    	(MemtoReg[1:0] == 2'b00)? ALUout :
    	(MemtoReg[1:0] == 2'b01)? MemData :
    	PC_plus_4;

endmodule