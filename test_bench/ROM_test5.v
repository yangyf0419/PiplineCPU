// rom_test5.v
// test Timer
//`timescale 1ns/1ps

module ROM_5 (addr,data);
    input [31:0] addr;
    output [31:0] data;
    reg [31:0] data;
    localparam ROM_SIZE = 32;
    reg [31:0] ROM_DATA[ROM_SIZE-1:0];

    always@(*)
        case(addr[17:2])   //Address Must Be Word Aligned.
            16'd0: data <= {6'b000010, 26'b00000000000000000000010110};
            16'd1: data <= {6'b000010, 26'b00000000000000000000111110};
            16'd2: data <= {6'b000010, 26'b00000000000000000000111111};
            16'd3: data <= {6'b001000, 5'b00000, 5'b01000, 16'b1011010011000000};
            16'd4: data <= {6'b101011, 5'b11001, 5'b01000, 16'b0000000000000000};
            16'd5: data <= {6'b001000, 5'b00000, 5'b01000, 16'b1111111111111111};
            16'd6: data <= {6'b101011, 5'b11001, 5'b01000, 16'b0000000000000100};
            16'd7: data <= {6'b101011, 5'b11001, 5'b10101, 16'b0000000000001000};
            16'd8: data <= {6'b100011, 5'b11001, 5'b00100, 16'b0000000000010000};
            16'd9: data <= {6'b101011, 5'b11001, 5'b00100, 16'b0000000000001100};
            16'd10: data <= {6'b001100, 5'b00100, 5'b01000, 16'b0000000000001111};
            16'd11: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000010000000};
            16'd12: data <= {6'b000000, 5'b00000, 5'b00100, 5'b01000, 5'b00100, 6'b000010};
            16'd13: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000100000000};
            16'd14: data <= {6'b100011, 5'b10100, 5'b11011, 16'b0000000000000000};
            16'd15: data <= {6'b100011, 5'b11011, 5'b11011, 16'b0000000000000000};
            16'd16: data <= {6'b000000, 5'b11011, 5'b10100, 5'b11011, 5'b00000, 6'b100000};
            16'd17: data <= {6'b101011, 5'b11001, 5'b11011, 16'b0000000000010100};
            16'd18: data <= {6'b000000, 5'b00000, 5'b10100, 5'b10100, 5'b00001, 6'b000000};
            16'd19: data <= {6'b000101, 5'b10100, 5'b10011, 16'b0000000000000001};
            16'd20: data <= {6'b000000, 5'b00000, 5'b10100, 5'b10100, 5'b00010, 6'b000010};
            16'd21: data <= {6'b000010, 26'b00000000000000000000001000};
            16'd22: data <= {6'b001000, 5'b00000, 5'b11111, 16'b0000000000001100};
            16'd23: data <= {6'b001111, 5'b00000, 5'b11011, 16'b1000000000000000};
            16'd24: data <= {6'b001111, 5'b00000, 5'b11001, 16'b0100000000000000};
            16'd25: data <= {6'b001000, 5'b00000, 5'b10111, 16'b0000000000000010};
            16'd26: data <= {6'b001000, 5'b00000, 5'b10110, 16'b0000000000000001};
            16'd27: data <= {6'b001000, 5'b00000, 5'b10101, 16'b0000000000000011};
            16'd28: data <= {6'b001000, 5'b00000, 5'b10100, 16'b0000000010000000};
            16'd29: data <= {6'b001000, 5'b00000, 5'b10011, 16'b0000001000000000};
            16'd30: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000001000000};
            16'd31: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000000000};
            16'd32: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000001111001};
            16'd33: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000000100};
            16'd34: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000100100};
            16'd35: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000001000};
            16'd36: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000110000};
            16'd37: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000001100};
            16'd38: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000011001};
            16'd39: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000010000};
            16'd40: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000010010};
            16'd41: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000010100};
            16'd42: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000000010};
            16'd43: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000011000};
            16'd44: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000001111000};
            16'd45: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000011100};
            16'd46: data <= {6'b101011, 5'b00000, 5'b00000, 16'b0000000000100000};
            16'd47: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000010000};
            16'd48: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000100100};
            16'd49: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000001000};
            16'd50: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000101000};
            16'd51: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000000011};
            16'd52: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000101100};
            16'd53: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000001000110};
            16'd54: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000110000};
            16'd55: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000100001};
            16'd56: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000110100};
            16'd57: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000000110};
            16'd58: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000111000};
            16'd59: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000001110};
            16'd60: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000111100};
            16'd61: data <= {6'b000000, 5'b11111, 5'b00000, 5'b00000, 5'b00000, 6'b001000};
            16'd62: data <= {6'b000000, 5'b11010, 5'b00000, 5'b00000, 5'b00000, 6'b001000};
            16'd63: data <= {6'b000000, 5'b11010, 5'b00000, 5'b00000, 5'b00000, 6'b001000};
            default: data <= 32'h80000000;
        endcase
endmodule

