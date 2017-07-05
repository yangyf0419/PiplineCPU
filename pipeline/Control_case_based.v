// Control.v
// case_based
module Control_c(OpCode, Funct, IRQ, 
    PCSrc, Sign, RegWrite, RegDst, 
    MemRead, MemWrite, MemtoReg, 
    ALUSrc1, ALUSrc2, ExtOp, LuOp, ALUFun);
    input [5:0] OpCode;
    input [5:0] Funct;
    input IRQ; // external interruption
    output reg [2:0] PCSrc;
    output reg Sign;
    output reg RegWrite;
    output reg [1:0] RegDst;
    output MemRead;
    output MemWrite;
    output reg [1:0] MemtoReg;
    output reg ALUSrc1;
    output reg ALUSrc2;
    output ExtOp;
    output LuOp;
    output reg [5:0] ALUFun;

    reg exception;
    always@(*) begin
        case (OpCode)
            6'h00: exception <= 1'b0;
            6'h01: exception <= 1'b0;
            6'h02: exception <= 1'b0;
            6'h03: exception <= 1'b0;
            6'h04: exception <= 1'b0;
            6'h05: exception <= 1'b0;
            6'h06: exception <= 1'b0;
            6'h07: exception <= 1'b0;
            6'h08: exception <= 1'b0;
            6'h09: exception <= 1'b0;
            6'h0a: exception <= 1'b0;
            6'h0b: exception <= 1'b0;
            6'h0c: exception <= 1'b0;
            6'h0f: exception <= 1'b0;
            6'h23: exception <= 1'b0;
            6'h2b: exception <= 1'b0;
            default: exception <= 1'b1;
        endcase
    end

    always@(*) begin
        if (IRQ) begin
            PCSrc[2:0] <= 3'b100;
            RegDst[1:0] <= 2'b11;
            MemtoReg[1:0] <= 2'b11;
            RegWrite <= 1'b1;
        end
        else if (exception) begin
            PCSrc[2:0] <= 3'b101;
            RegDst[1:0] <= 2'b11;
            MemtoReg[1:0] <= 2'b10;
            RegWrite <= 1'b1;
        end
        else begin
            case ({OpCode, Funct})
                12'b000100??????: PCSrc[2:0] <= 3'b001; // beq
                12'b000101??????: PCSrc[2:0] <= 3'b001; // bne
                12'b000110??????: PCSrc[2:0] <= 3'b001; // blez
                12'b000111??????: PCSrc[2:0] <= 3'b001; // bgtz
                12'b000001??????: PCSrc[2:0] <= 3'b001; // bltz
                12'b000010??????: PCSrc[2:0] <= 3'b010; // j
                12'b000011??????: PCSrc[2:0] <= 3'b010; // jal
                12'b000000001000: PCSrc[2:0] <= 3'b011; // jr
                12'b000000001001: PCSrc[2:0] <= 3'b011; // jalr
                default: PCSrc[2:0] <= 3'b000;
            endcase
            case (OpCode)
                6'h03: RegDst[1:0] <= 2'b10; // jal
                6'h00: RegDst[1:0] <= 2'b01; // R type, jr, jalr
                default: RegDst[1:0] <= 2'b00;
            endcase
            case ({OpCode, Funct})
                12'b100011??????: MemtoReg[1:0] <= 2'b01; // lw
                12'b000011??????: MemtoReg[1:0] <= 2'b10; // jal
                12'b000000001001: MemtoReg[1:0] <= 2'b10; // jalr
                default: MemtoReg[1:0] <= 2'b00;
            endcase
            case ({OpCode, Funct})
                12'b101011??????: RegWrite <= 1'b0; // sw
                12'b000100??????: RegWrite <= 1'b0; // beq
                12'b000101??????: RegWrite <= 1'b0; // bne
                12'b000110??????: RegWrite <= 1'b0; // blez
                12'b000111??????: RegWrite <= 1'b0; // bgtz
                12'b000001??????: RegWrite <= 1'b0; // bltz
                12'b000010??????: RegWrite <= 1'b0; // j
                12'b000000001000: RegWrite <= 1'b0; // jr
                default: RegWrite <= 1'b1;
            endcase
        end
    end

    always@(*) begin
        case ({OpCode, Funct})
            12'b000000101011: Sign <= 1'b0; // sltu
            12'b001011??????: Sign <= 1'b0; // sltiu
            default: Sign <= 1'b1;
        endcase
        case ({OpCode, Funct})
            12'b000000000000: ALUSrc1 <= 1'b1; // sll
            12'b000000000010: ALUSrc1 <= 1'b1; // srl
            12'b000000000011: ALUSrc1 <= 1'b1; // sra
            default: ALUSrc1 <= 1'b0;
        endcase
        case (OpCode)
            6'h00: ALUSrc2 <= 1'b0; // R type, jr, jalr
            6'h04: ALUSrc2 <= 1'b0; // beq
            default: ALUSrc2 <= 1'b1;
        endcase
        case ({OpCode, Funct})
            12'b000000100010: ALUFun[5:0] <= 6'b000001; // sub
            12'b000000100011: ALUFun[5:0] <= 6'b000001; // subu
            12'b000000100100: ALUFun[5:0] <= 6'b011000; // and
            12'b001100??????: ALUFun[5:0] <= 6'b011000; // andi
            12'b000000100101: ALUFun[5:0] <= 6'b011110; // or
            12'b000000100110: ALUFun[5:0] <= 6'b010110; // xor
            12'b000000100111: ALUFun[5:0] <= 6'b010001; // nor
            12'b000000000000: ALUFun[5:0] <= 6'b100000; // sll
            12'b000000000010: ALUFun[5:0] <= 6'b100001; // srl
            12'b000000000011: ALUFun[5:0] <= 6'b100011; // sra
            12'b000000101010: ALUFun[5:0] <= 6'b110101; // slt
            12'b000000101011: ALUFun[5:0] <= 6'b110101; // sltu
            12'b001010??????: ALUFun[5:0] <= 6'b110101; // slti
            12'b001011??????: ALUFun[5:0] <= 6'b110101; // sltiu
            12'b000100??????: ALUFun[5:0] <= 6'b110011; // beq
            12'b000101??????: ALUFun[5:0] <= 6'b110001; // bne
            12'b000110??????: ALUFun[5:0] <= 6'b111101; // blez
            12'b000111??????: ALUFun[5:0] <= 6'b111111; // bgtz
            12'b000001??????: ALUFun[5:0] <= 6'b111011; // beq
            default: ALUFun[5:0] <= 6'b000000;
        endcase
    end

    assign MemRead =
        (OpCode == 6'h23)? 1'b1: // lw
        1'b0;

    assign MemWrite =
        (OpCode == 6'h2b)? 1'b1: // sw
        1'b0;

    assign ExtOp =
        (OpCode == 6'h0c)? 1'b0: // andi
        1'b1;

    assign LuOp =
        (OpCode == 6'h0f)? 1'b1: // lui
        1'b0;

endmodule