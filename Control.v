// Control.v
module Control(OpCode, Funct,
    PCSrc, Sign, RegWrite, RegDst, 
    MemRead, MemWrite, MemtoReg, 
    ALUSrc1, ALUSrc2, ExtOp, LuOp, ALUFun);
    input [5:0] OpCode;
    input [5:0] Funct;
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
    output [5:0] ALUFun;

    assign PCSrc[2:0] =
        (OpCode == 6'h04)? 3'b001: // beq
        (OpCode == 6'h05)? 3'b001: // bne
        (OpCode == 6'h06)? 3'b001: // blez
        (OpCode == 6'h07)? 3'b001: // bgtz
        (OpCode == 6'h01)? 3'b001: // bltz
        (OpCode == 6'h02)? 3'b010: // j
        (OpCode == 6'h03)? 3'b010: // jal
        (OpCode == 6'h00 && Funct == 6'h08)? 3'b011: // jr
        (OpCode == 6'h00 && Funct == 6'h09)? 3'b110: // jalr
        3'b000;

    assign Sign = 
    	(OpCode == 6'h00 && Funct == 6'h2b)? 1'b0: // sltu
    	(OpCode == 6'h0b)? 1'b0: // sltiu
    	1'b1;

    assign RegWrite =
        (OpCode == 6'h2b)? 1'b0: // sw
        (OpCode == 6'h04)? 1'b0: // beq
        (OpCode == 6'h05)? 1'b0: // bne
        (OpCode == 6'h06)? 1'b0: // blez
        (OpCode == 6'h07)? 1'b0: // bgtz
        (OpCode == 6'h01)? 1'b0: // bltz
        (OpCode == 6'h02)? 1'b0: // j
        (OpCode == 6'h00 && Funct == 6'h08)? 1'b0: // jr
        1'b1;

    assign RegDst[1:0] =
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
        (OpCode == 6'h23)? 2'b01: // lw
        (OpCode == 6'h03)? 2'b10: // jal
        (OpCode == 6'h00 && Funct == 6'h09)? 2'b10: // jalr
        2'b00;

    assign ALUSrc1 = 
        (OpCode == 6'h00 && Funct == 6'h00)? 1'b1: // sll
        (OpCode == 6'h00 && Funct == 6'h02)? 1'b1: // srl
        (OpCode == 6'h00 && Funct == 6'h03)? 1'b1: // sra
        1'b0;

    assign ALUSrc2 =
        (OpCode == 6'h00)? 1'b0: // R type, jr, jalr
        (OpCode == 6'h04)? 1'b0: // beq
        1'b1;

    assign ExtOp =
        (OpCode == 6'h0c)? 1'b0: // andi
        1'b1;

    assign LuOp =
        (OpCode == 6'h0f)? 1'b1: // lui
        1'b0;

    // Your code above
    
    assign ALUFun[5:0] = 
        // (OpCode == 6'h00 && Funct == 6'h20)? 6'b000000: // add
        // (OpCode == 6'h00 && Funct == 6'h21)? 6'b000000: // addu
        (OpCode == 6'h00 && Funct == 6'h22)? 6'b000001: // sub
        (OpCode == 6'h00 && Funct == 6'h23)? 6'b000001: // subu
        (OpCode == 6'h00 && Funct == 6'h24)? 6'b011000: // and
        (OpCode == 6'h00 && Funct == 6'h25)? 6'b011110: // or
        (OpCode == 6'h00 && Funct == 6'h26)? 6'b010110: // xor
        (OpCode == 6'h00 && Funct == 6'h27)? 6'b010001: // nor
        (OpCode == 6'h00 && Funct == 6'h00)? 6'b100000: // sll
        (OpCode == 6'h00 && Funct == 6'h02)? 6'b100001: // srl
        (OpCode == 6'h00 && Funct == 6'h03)? 6'b100011: // sra
        (OpCode == 6'h00 && Funct == 6'h2a)? 6'b110101: // slt
        (OpCode == 6'h00 && Funct == 6'h2b)? 6'b110101: // sltu
        // (OpCode ==+ 6'h00 && Funct == 6'h08)? 6'b000000: // jr
        // (OpCode == 6'h00 && Funct == 6'h09)? 6'b000000: // jalr
        // (OpCode == 6'h23)? 6'b000000: // lw
        // (OpCode == 6'h2b)? 6'b000000: // sw
        // (OpCode == 6'h0f)? 6'b000000: // lui
        // (OpCode == 6'h08)? 6'b000000: // addi
        // (OpCode == 6'h09)? 6'b000000: // addiu
        (OpCode == 6'h0c)? 6'b011000: // andi
        (OpCode == 6'h0a)? 6'b110101: // slti
        (OpCode == 6'h0b)? 6'b110101: // sltiu
        (OpCode == 6'h04)? 6'b110011: // beq
        (OpCode == 6'h05)? 6'b110001: // bne
        (OpCode == 6'h06)? 6'b111101: // blez
        (OpCode == 6'h07)? 6'b111111: // bgtz
        (OpCode == 6'h01)? 6'b111011: // bltz
        // (OpCode == 6'h02)? 6'b000000: // j
        // (OpCode == 6'h03)? 6'b000000: // jal
        6'b000000;

endmodule