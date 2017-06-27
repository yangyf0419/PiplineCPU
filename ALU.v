// ALU.v

module ALU(A, B, ALUFun, Sign, Z);
    input [31:0] A, B;
    input [5:0] ALUFun;
    input Sign;
    output [31:0] Z;

    wire heads;
    assign heads = {A[31], B[31]}; // sign bit of A & B

    wire tailCmp;
    assign tailCmp = (A[30:0] < B[30:0]); // comparisions of A & B without sign bit

    wire signCmp;
    assign signCmp = (A[31] ^ B[31])?
        ((heads == 2'b01)? 0 : 1) : tailCmp;

    always@(*)
        case (ALUFun)
            6'b000000: Z <= A + B; // add
            6'b000001: Z <= A + ~B + 1; // sub
            6'b011000: Z <= A & B; // and
            6'b011110: Z <= A | B; // or
            6'b010110: Z <= A ^ B; // xor
            6'b010001: Z <= ~(A | B); // nor
            6'b011010: Z <= A; // "A"
            6'b100000: Z <= (B << A[4:0]); // sll
            6'b100001: Z <= (B >> A[4:0]); // srl
            6'b100011: Z <= ({{32{B[31]}}, B} >> A[4:0]); // sra
            6'b110011: out <= (A == B); // eq
            6'b110001: out <= (A != B); // neq
            6'b110101: out <= {31'h00000000, Sign? signCmp : (A < B)}; // lt
            6'b110101: out <= {31'h00000000, (A[31] | (A == 0))}; // lez
            6'b111011: out <= {31'h00000000, A[31]}; // ltz
            6'b111111: out <= {31'h00000000, (~A[31] & (&A))}; // gtz
            default: Z <= 32'h00000000;
        endcase
endmodule