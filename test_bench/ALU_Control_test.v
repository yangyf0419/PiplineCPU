// ALU_Control_test.v

module test;
    reg [5:0] OpCode;
    reg [5:0] Funct;
    reg [31:0] Data_A;
    reg [31:0] Data_B;

    wire [31:0] out;

    wire Sign;
    wire [5:0] ALUFun;

    Control ctrl(
        .OpCode(OpCode),
        .Funct(Funct),
        .Sign(Sign),
        .ALUFun(ALUFun));

    ALU_n alu(
        .ALUFun(ALUFun),
        .A(Data_A),
        .B(Data_B),
        .Sign(Sign),
        .Z(out));

    integer a = 3;
    integer b = 5;
    integer c = -3;
    integer d = -5;
    integer e = 2147483647; //32'd7fff_ffff
    parameter zero = 32'h0000_0000;

    initial begin
        // nop
        #10 OpCode = 6'h00; Funct = 6'h00; 
            Data_A = zero; Data_B = zero; // 32'd0
        // add
        #10 OpCode = 6'h00; Funct = 6'h20; 
            Data_A = a; Data_B = b; // 32'd8
        // addu
        #10 OpCode = 6'h00; Funct = 6'h21; 
            Data_A = a; Data_B = d; // -32'd2
        // addi
        #10 OpCode = 6'h08; Funct = 6'h27; 
            Data_A = d; Data_B = c; // -32'd8
        // addiu
        #10 OpCode = 6'h09; Funct = 6'h19; 
            Data_A = e; Data_B = b; // -32'd2,147,483,644
        // lw
        #10 OpCode = 6'h23; Funct = 6'h3a;
            Data_A = b; Data_B = c; // 32'd2
        // sw
        #10 OpCode = 6'h2b; Funct = 6'h07;
            Data_A = a; Data_B = d; // -32'd2
        // lui
        #10 OpCode = 6'h2b; Funct = 6'h1b;
            Data_A = zero; Data_B = 32'h9fc3_0000; // -32'd1,614,610,432
        // sub
        #10 OpCode = 6'h00; Funct = 6'h22;
            Data_A = a; Data_B = b; // -32'd2
        #10 OpCode = 6'h00; Funct = 6'h22;
            Data_A = a; Data_B = d; // 32'd8
        // subu
        #10 OpCode = 6'h00; Funct = 6'h23;
            Data_A = d; Data_B = c; // -32'd2
        #10 OpCode = 6'h00; Funct = 6'h23;
            Data_A = e; Data_B = d; // -32'd2,147,483,644
        // beq
        #10 OpCode = 6'h04; Funct = 6'h18;
            Data_A = 32'hfe8b_67a4; Data_B = 32'hfe8b_67a4; // 1
        #10 OpCode = 6'h04; Funct = 6'h25;
            Data_A = 32'hfe8b_67a4; Data_B = 32'h0174_985c; // 0
        // bne
        #10 OpCode = 6'h05; Funct = 6'h1c;
            Data_A = 32'hfe8b_67a4; Data_B = 32'hfe8b_67a4; // 0
        #10 OpCode = 6'h05; Funct = 6'h0a;
            Data_A = 32'hfe8b_67a4; Data_B = 32'h0174_985c; // 1
        // blez
        #10 OpCode = 6'h06; Funct = 6'h24;
            Data_A = zero; Data_B = zero; // 1
        #10 OpCode = 6'h06; Funct = 6'h17;
            Data_A = 32'hc672_e58a; Data_B = zero; // 1
        #10 OpCode = 6'h06; Funct = 6'h33;
            Data_A = 32'h5672_e58a; Data_B = zero; // 0
        // bgtz
        #10 OpCode = 6'h07; Funct = 6'h24;
            Data_A = zero; Data_B = zero; // 0
        #10 OpCode = 6'h07; Funct = 6'h17;
            Data_A = 32'hc672_e58a; Data_B = zero; // 0  
        #10 OpCode = 6'h07; Funct = 6'h33;
            Data_A = 32'h5672_e58a; Data_B = zero; // 1
        // bltz
        #10 OpCode = 6'h01; Funct = 6'h24;
            Data_A = zero; Data_B = zero; // 0
        #10 OpCode = 6'h01; Funct = 6'h17;
            Data_A = 32'hc672_e58a; Data_B = zero; // 1   
        #10 OpCode = 6'h01; Funct = 6'h33;
            Data_A = 32'h5672_e58a; Data_B = zero; // 0
        // and
        #10 OpCode = 6'h00; Funct = 6'h24;
            Data_A = 32'ha85e_9cd0; Data_B = 32'h2ec9_0029; // 32'h2848_0000
        // or
        #10 OpCode = 6'h00; Funct = 6'h25;
            Data_A = 32'ha85e_9cd0; Data_B = 32'h2ec9_0029; // 32'haedf_9cf9
        // xor
        #10 OpCode = 6'h00; Funct = 6'h26;
            Data_A = 32'ha85e_9cd0; Data_B = 32'h2ec9_0029; // 32'h8697_9cf9
        // nor
        #10 OpCode = 6'h00; Funct = 6'h27;
            Data_A = 32'ha85e_9cd0; Data_B = 32'h2ec9_0029; // 32'h5120_6306
        // andi
        #10 OpCode = 6'h0c; Funct = 6'h18;
            Data_A = 32'ha85e_9cd0; Data_B = 32'h2ec9_0029; // 32'h2848_0000
        // slt
        #10 OpCode = 6'h00; Funct = 6'h2a;
            Data_A = a; Data_B = b; // 1
        #10 OpCode = 6'h00; Funct = 6'h2a;
            Data_A = a; Data_B = d; // 0
        #10 OpCode = 6'h00; Funct = 6'h2a;
            Data_A = d; Data_B = c; // 1
        #10 OpCode = 6'h00; Funct = 6'h2a;
            Data_A = d; Data_B = a; // 1
        // slti
        #10 OpCode = 6'h0a; Funct = 6'h35;
            Data_A = a; Data_B = b; // 1
        #10 OpCode = 6'h0a; Funct = 6'h2a;
            Data_A = a; Data_B = d; // 0
        #10 OpCode = 6'h0a; Funct = 6'h16;
            Data_A = d; Data_B = c; // 1
        #10 OpCode = 6'h0a; Funct = 6'h2e;
            Data_A = d; Data_B = a; // 1
        // sltu
        #10 OpCode = 6'h00; Funct = 6'h2b;
            Data_A = a; Data_B = b; // 1
        #10 OpCode = 6'h00; Funct = 6'h2b;
            Data_A = a; Data_B = d; // 1
        #10 OpCode = 6'h00; Funct = 6'h2b;
            Data_A = d; Data_B = c; // 1
        #10 OpCode = 6'h00; Funct = 6'h2b;
            Data_A = d; Data_B = a; // 0
        // sltiu
        #10 OpCode = 6'h0b; Funct = 6'h35;
            Data_A = a; Data_B = b; // 1
        #10 OpCode = 6'h0b; Funct = 6'h2a;
            Data_A = a; Data_B = d; // 1
        #10 OpCode = 6'h0b; Funct = 6'h16;
            Data_A = d; Data_B = c; // 1
        #10 OpCode = 6'h0b; Funct = 6'h2e;
            Data_A = d; Data_B = a; // 0
        // sll
        #10 OpCode = 6'h00; Funct = 6'h00;
            Data_A = b; Data_B = 32'hea6c_50bb; // 32'h4d8a_1760
        #10 OpCode = 6'h00; Funct = 6'h00;
            Data_A = d; Data_B = 32'hea6c_50bb; // 32'hd800_0000
        // srl
        #10 OpCode = 6'h00; Funct = 6'h02;
            Data_A = b; Data_B = 32'hea6c_50bb; // 32'h0753_6285
        #10 OpCode = 6'h00; Funct = 6'h02;
            Data_A = d; Data_B = 32'hea6c_50bb; // 32'h0000_001d
        // sra
        #10 OpCode = 6'h00; Funct = 6'h03;
            Data_A = b; Data_B = 32'hea6c_50bb; // 32'hff53_6285
        #10 OpCode = 6'h00; Funct = 6'h03;
            Data_A = d; Data_B = 32'hea6c_50bb; // 32'hffff_fffd
        #10 OpCode = 6'h00; Funct = 6'h03;
            Data_A = b; Data_B = 32'h6a6c_50bb; // 32'h0353_6285
    end
endmodule