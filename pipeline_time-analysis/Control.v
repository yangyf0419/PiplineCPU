// Control.v
// case based
module Control(OpCode, Funct, IRQ,
    PCSrc, Sign, RegWrite, RegDst, 
    MemRead, MemWrite, MemtoReg, 
    ALUSrc1, ALUSrc2, ExtOp, LuOp, B, J, ALUFun);
    input [5:0] OpCode;
    input [5:0] Funct;
    input IRQ; // external interruption

    output [2:0] PCSrc;
    output Sign;
    output RegWrite;
    output [1:0] RegDst;
    output MemRead;
    output MemWrite;
    output [1:0] MemtoReg;
    output ALUSrc1;
    output ALUSrc2;
    output ExtOp;
    output LuOp;
    output reg [5:0] ALUFun;
    output B;
    output J;

    wire exception;
    assign exception = 
        (OpCode == 6'h00 ||
         OpCode == 6'h01 ||
         OpCode == 6'h02 ||
         OpCode == 6'h03 ||
         OpCode == 6'h04 ||
         OpCode == 6'h05 ||
         OpCode == 6'h06 ||
         OpCode == 6'h07 ||
         OpCode == 6'h08 ||
         OpCode == 6'h09 ||
         OpCode == 6'h0a ||
         OpCode == 6'h0b ||
         OpCode == 6'h0c ||
         OpCode == 6'h0f ||
         OpCode == 6'h23 ||
         OpCode == 6'h2b) ? 1'b0 : 1'b1;

    assign PCSrc[2:0] =
        IRQ? 3'b100 :
        exception? 3'b101 :
        (OpCode == 6'h02 || // j
         OpCode == 6'h03)? 3'b010: // jal
        (OpCode == 6'h00 && (Funct == 6'h08 || // jr
                             Funct == 6'h09))? 3'b011: // jalr
        3'b000;

    assign B = 
        (OpCode == 6'h04 || // beq
         OpCode == 6'h05 || // bne
         OpCode == 6'h06 || // blez
         OpCode == 6'h07 || // bgtz
         OpCode == 6'h01);

    assign J = 
        (OpCode == 6'h02 || // j
         OpCode == 6'h03 || // jal
        (OpCode == 6'h00 && (Funct == 6'h08 || // jr
                             Funct == 6'h09))); // jalr

    assign Sign = 
    	((OpCode == 6'h00 && Funct == 6'h2b) || // sltu
    	 OpCode == 6'h0b)? 1'b0: // sltiu
    	1'b1;

    assign RegWrite =
        (IRQ || exception)? 1'b1:
        (OpCode == 6'h2b || // sw
         OpCode == 6'h04 || // beq
         OpCode == 6'h05 || // bne
         OpCode == 6'h06 || // blez
         OpCode == 6'h07 || // bgtz
         OpCode == 6'h01 || // bltz
         OpCode == 6'h02 || // j
        (OpCode == 6'h00 && Funct == 6'h08))? 1'b0: // jr
        1'b1;

    assign RegDst[1:0] =
        (IRQ || exception)? 2'b11:
        (OpCode == 6'h03)? 2'b10: // jal
        (OpCode == 6'h00)? 2'b01: // R type, jr, jalr
        2'b00;

    assign MemRead =
        (OpCode == 6'h23)? 1'b1: // lw
        1'b0;

    assign MemWrite =
        (OpCode == 6'h2b)? 1'b1: // sw
        1'b0;

    assign MemtoReg =
        IRQ? 2'b11 :
        (exception ||
        OpCode == 6'h03 || // jal
        (OpCode == 6'h00 && Funct == 6'h09))? 2'b10: // jalr
        (OpCode == 6'h23)? 2'b01: // lw
        2'b00;

    assign ALUSrc1 = 
        (OpCode == 6'h00 && (Funct == 6'h00 || // sll
                             Funct == 6'h02 || // srl
                             Funct == 6'h03))? 1'b1: // sra
        1'b0;

    assign ALUSrc2 =
        (OpCode == 6'h00 || // R type, jr, jalr
         OpCode == 6'h04 || // beq
         OpCode == 6'h05 || // bne
         OpCode == 6'h06 || // blez
         OpCode == 6'h07 || // bgtz
         OpCode == 6'h01)? 1'b0: // bltz
        1'b1;

    assign ExtOp =
        (OpCode == 6'h0c)? 1'b0: // andi
        1'b1;

    assign LuOp =
        (OpCode == 6'h0f)? 1'b1: // lui
        1'b0;

    reg [5:0] ALUFunTmp;

    always@(*)
        case(Funct)
            6'h22: ALUFunTmp[5:0] <= 6'b000001; // sub
            6'h23: ALUFunTmp[5:0] <= 6'b000001; // subu
            6'h24: ALUFunTmp[5:0] <= 6'b011000; // and
            6'h25: ALUFunTmp[5:0] <= 6'b011110; // or
            6'h26: ALUFunTmp[5:0] <= 6'b010110; // xor
            6'h27: ALUFunTmp[5:0] <= 6'b010001; // nor
            6'h00: ALUFunTmp[5:0] <= 6'b100000; // sll
            6'h02: ALUFunTmp[5:0] <= 6'b100001; // srl
            6'h03: ALUFunTmp[5:0] <= 6'b100011; // sra
            6'h2a: ALUFunTmp[5:0] <= 6'b000011; // slt
            6'h2b: ALUFunTmp[5:0] <= 6'b000011; // sltu
            default: ALUFunTmp[5:0] <= 6'b000000;
        endcase

    always@(*)
        case(OpCode)
            6'h00: ALUFun[5:0] <= ALUFunTmp; // R type
            6'h0c: ALUFun[5:0] <= 6'b011000; // andi
            6'h0a: ALUFun[5:0] <= 6'b000011; // slti
            6'h0b: ALUFun[5:0] <= 6'b000011; // sltiu
            6'h04: ALUFun[5:0] <= 6'b110011; // beq
            6'h05: ALUFun[5:0] <= 6'b110001; // bne
            6'h06: ALUFun[5:0] <= 6'b111101; // blez
            6'h07: ALUFun[5:0] <= 6'b111111; // bgtz
            6'h01: ALUFun[5:0] <= 6'b111011; // bltz
            default: ALUFun[5:0] <= 6'b000000;
        endcase
        
endmodule