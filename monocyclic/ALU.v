// ALU.v

module ALU(A, B, ALUFun, Sign, Z);
    input [31:0] A, B;
    input [5:0] ALUFun;
    input Sign;
    output reg [31:0] Z;

    wire [31:0] add_out, logic_out, shift_out;
    wire cmp_out;
    wire z, lt;
    ADD add(A, B, ALUFun[0], Sign, z, lt, add_out);
    CMP cmp(A[31], z, lt, ALUFun[3:1], cmp_out);
    LOGIC logic(A, B, ALUFun[3:2], logic_out);
    SHIFT shift(A[4:0], B, ALUFun[1:0], shift_out);

    always@*
        case (ALUFun[5:4])
            2'b00: Z <= add_out;
            2'b00: Z <= logic_out;
            2'b00: Z <= shift_out;
            default: Z <= {31'b0, cmp_out};
        endcase
    // assign Z =
    //     (ALUFun[5:4] == 2'b00)? add_out:
    //     (ALUFun[5:4] == 2'b01)? logic_out:
    //     (ALUFun[5:4] == 2'b10)? shift_out:
    //     {31'b0, cmp_out};

endmodule

module ADD(A, B, Fun, Sign, Z, LT, out);
    input [31:0] A, B;
    input Fun; // ALUFun[0]
    input Sign;
    output Z;
    output LT;
    output [31:0] out;
    assign out = Fun? A - B : A + B;
    assign Z = ~(|out);
    assign LT = (~Sign & (A[31] ^ B[31]))? B[31] : out[31];
endmodule

module CMP(A_31, Z, LT, Fun, out);
    input A_31;
    input Z;
    input LT;
    input [2:0] Fun; // ALUFun[3:1]
    output reg out;

    always@*
        case (Fun[2:0])
            3'b001: out <= Z; // eq
            3'b000: out <= ~Z; // neq
            3'b010: out <= LT; // LT
            3'b110: out <= A_31 | Z; // lez
            3'b101: out <= A_31; // ltz
            default: out <= ~ (A_31 | Z); // gtz
        endcase     
    // assign out =
    //     (Fun[2:0] == 3'b001)? Z : // eq
    //     (Fun[2:0] == 3'b000)? ~Z : // neq
    //     (Fun[2:0] == 3'b010)? LT:
    //     (Fun[2:0] == 3'b110)? A_31 | Z :
    //     (Fun[2:0] == 3'b101)? A_31 :
    //     ~ (A_31 | Z);
    // case statement is slightly better
    // 3 more logic eliments - 0.27M more Frequency
endmodule

module LOGIC(A, B, Fun, out);
    input [31:0] A, B;
    input [1:0] Fun; // ALUFun[3:2]
    output [31:0] out;
    // always @*
    //     case (Fun[1:0])
    //         2'b10: out <= A & B;
    //         2'b11: out <= A | B;
    //         2'b01: out <= A ^ B;
    //         default: out <= ~(A | B);
    //     endcase
    assign out =
        (Fun[1:0] == 2'b10)? A & B :
        (Fun[1:0] == 2'b11)? A | B :
        (Fun[1:0] == 2'b01)? A ^ B :
        ~(A | B);
    // 此处综合没有区别
endmodule

module SHIFT(Shamt, B, Fun, out);
    input [4:0] Shamt; // A[4:0]
    input [31:0] B;
    input [1:0] Fun; // ALUFun[1:0]
    output [31:0] out;
    wire [31:0] sll_1, sll_2, sll_4, sll_8, sll_16;
    wire [31:0] srl_1, srl_2, srl_4, srl_8, srl_16;
    wire [31:0] sra_1, sra_2, sra_4, sra_8, sra_16;

    assign sll_1 = Shamt[0]? {B[30:0], 1'b0} : B;
    assign sll_2 = Shamt[1]? {sll_1[29:0], 2'b0} : sll_1;
    assign sll_4 = Shamt[2]? {sll_2[27:0], 4'b0} : sll_2;
    assign sll_8 = Shamt[3]? {sll_4[23:0], 8'b0} : sll_4;
    assign sll_16 = Shamt[4]? {sll_8[15:0], 16'b0} : sll_8;

    assign srl_1 = Shamt[0]? {1'b0, B[31:1]} : B;
    assign srl_2 = Shamt[1]? {2'b0, srl_1[31:2]} : srl_1;
    assign srl_4 = Shamt[2]? {4'b0, srl_2[31:4]} : srl_2;
    assign srl_8 = Shamt[3]? {8'b0, srl_4[31:8]} : srl_4;
    assign srl_16 = Shamt[4]? {16'b0, srl_8[31:16]} : srl_8;

    assign sra_1 = Shamt[0]? {{1{B[31]}}, B[31:1]} : B;
    assign sra_2 = Shamt[1]? {{2{B[31]}}, sra_1[31:2]} : sra_1;
    assign sra_4 = Shamt[2]? {{4{B[31]}}, sra_2[31:4]} : sra_2;
    assign sra_8 = Shamt[3]? {{8{B[31]}}, sra_4[31:8]} : sra_4;
    assign sra_16 = Shamt[4]? {{16{B[31]}}, sra_8[31:16]} : sra_8;

    // always@*
    //     case (Fun[1:0])
    //         2'b00: out <= sll_16;
    //         2'b01: out <= srl_16;
    //         default: out <= sra_16;
    //     endcase
    assign out =
        (Fun[1:0] == 2'b00)? sll_16 :
        (Fun[1:0] == 2'b01)? srl_16 :
        sra_16;
    // 此处综合没有区别
endmodule
