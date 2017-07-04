// rom_test2.v

module ROM_2 (addr,data);
    input [31:0] addr;
    output [31:0] data;
    reg [31:0] data;
    localparam ROM_SIZE = 32;
    reg [31:0] ROM_DATA[ROM_SIZE-1:0];

    always@(*)
        case(addr[9:2])   //Address Must Be Word Aligned.
            // addi $a0, $zero, 3 #(0x0003)
            8'd0:    data <= {6'h08, 5'd0 , 5'd4 , 16'h0003};
            // addi $sp, $sp, 256 #(0x0100)
            8'd1:    data <= {6'h08, 5'd29 , 5'd29 , 16'h0100};
            // jal sum
            8'd2:    data <= {6'h03, 26'd4};
            // Loop:
            // beq $zero, $zero, Loop 
            8'd3:    data <= {6'h04, 5'd0 , 5'd0 , 16'hffff};
            // sum: 
            // addi $sp, $sp, -8 #(0xfff8)
            8'd4:    data <= {6'h08, 5'd29 , 5'd29 , 16'hfff8};
            // sw $ra, 4($sp)
            8'd5:    data <= {6'h2b, 5'd29 , 5'd31 , 16'h0004};
            // sw $a0, 0($sp) 
            8'd6:    data <= {6'h2b, 5'd29 , 5'd4 , 16'h0000};
            // slti $t0, $a0, 1 #(0x0001)
            8'd7:    data <= {6'h0a, 5'd4 , 5'd8 , 16'h0001};
            // beq $t0, $zero, L1 
            8'd8:    data <= {6'h04, 5'd8 , 5'd0 , 16'h0003};
            // xor $v0, $zero, $zero 
            8'd9:    data <= {6'h00, 5'd0 , 5'd0 , 5'd2 , 5'd0 , 6'h26};
            // addi $sp, $sp, 8 
            8'd10:    data <= {6'h08, 5'd29 , 5'd29 , 16'h0008};
            // jr $ra 
            8'd11:   data <= {6'h00, 5'd31 , 15'd0 , 6'h08};
            // L1:
            // addi $a0, $a0, -1 
            8'd12:   data <= {6'h08, 5'd4 , 5'd4 , 16'hffff};
            // jal sum 
            8'd13:   data <= {6'h03, 26'd4};
            // lw $a0, 0($sp)  
            8'd14:   data <= {6'h23, 5'd29 , 5'd4 , 16'h0000};
            // lw $ra, 4($sp) 
            8'd15:   data <= {6'h23, 5'd29 , 5'd31 , 16'h0004};
            // addi $sp, $sp, 8 
            8'd16:   data <= {6'h08, 5'd29 , 5'd29 , 16'h0008};
            // add $v0, $a0, $v0 
            8'd17:   data <= {6'h00, 5'd4 , 5'd2 , 5'd2 , 5'd0 , 6'h20};
            // jr $ra 
            8'd18:   data <= {6'h00, 5'd31 , 15'd0 , 6'h08};
            
            default: data <= 32'h00000000;
        endcase
endmodule

