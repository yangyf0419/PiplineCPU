`timescale 1ns/1ns

//指令存储器

module ROM (addr,data);
input [31:0] addr;
output [31:0] data;
reg [31:0] data;

always@(*)
	case(addr[8:2])	//Address Must Be Word Aligned.
		7'd0: data <= {6'b000010, 26'b00000000000000000000101111};
		7'd1: data <= {6'b000010, 26'b00000000000000000001011101};
		7'd2: data <= {6'b000010, 26'b00000000000000000001101101};
		7'd3: data <= {6'b101011, 5'b11001, 5'b10111, 16'b0000000000100000};
		7'd4: data <= {6'b100011, 5'b11001, 5'b01000, 16'b0000000000100000};
		7'd5: data <= {6'b001100, 5'b01000, 5'b01001, 16'b0000000000001000};
		7'd6: data <= {6'b000100, 5'b01001, 5'b00000, 16'b1111111111111101};
		7'd7: data <= {6'b101011, 5'b11001, 5'b00000, 16'b0000000000100000};
		7'd8: data <= {6'b100011, 5'b11001, 5'b00100, 16'b0000000000011100};
		7'd9: data <= {6'b001100, 5'b00100, 5'b01000, 16'b0000000000001111};
		7'd10: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000001001000};
		7'd11: data <= {6'b000000, 5'b00000, 5'b00100, 5'b01000, 5'b00100, 6'b000010};
		7'd12: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000001001100};
		7'd13: data <= {6'b101011, 5'b11001, 5'b10111, 16'b0000000000100000};
		7'd14: data <= {6'b100011, 5'b11001, 5'b01000, 16'b0000000000100000};
		7'd15: data <= {6'b001100, 5'b01000, 5'b01001, 16'b0000000000001000};
		7'd16: data <= {6'b000100, 5'b01001, 5'b00000, 16'b1111111111111101};
		7'd17: data <= {6'b101011, 5'b11001, 5'b00000, 16'b0000000000100000};
		7'd18: data <= {6'b100011, 5'b11001, 5'b00101, 16'b0000000000011100};
		7'd19: data <= {6'b001100, 5'b00101, 5'b01000, 16'b0000000000001111};
		7'd20: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000001000000};
		7'd21: data <= {6'b000000, 5'b00000, 5'b00101, 5'b01000, 5'b00100, 6'b000010};
		7'd22: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000001000100};
		7'd23: data <= {6'b001000, 5'b00000, 5'b01000, 16'b1111111111001110};
		7'd24: data <= {6'b101011, 5'b11001, 5'b01000, 16'b0000000000000000};
		7'd25: data <= {6'b001000, 5'b00000, 5'b01000, 16'b1111111111111111};
		7'd26: data <= {6'b101011, 5'b11001, 5'b01000, 16'b0000000000000100};
		7'd27: data <= {6'b101011, 5'b11001, 5'b10101, 16'b0000000000001000};
		7'd28: data <= {6'b000100, 5'b00100, 5'b00000, 16'b0000000000001001};
		7'd29: data <= {6'b000100, 5'b00101, 5'b00000, 16'b0000000000000111};
		7'd30: data <= {6'b000100, 5'b00100, 5'b00101, 16'b0000000000000111};
		7'd31: data <= {6'b000000, 5'b00100, 5'b00101, 5'b01000, 5'b00000, 6'b100010};
		7'd32: data <= {6'b000001, 5'b01000, 5'b00000, 16'b0000000000000010};
		7'd33: data <= {6'b000000, 5'b00100, 5'b00101, 5'b00100, 5'b00000, 6'b100010};
		7'd34: data <= {6'b000010, 26'b00000000000000000000011110};
		7'd35: data <= {6'b000000, 5'b00101, 5'b00100, 5'b00101, 5'b00000, 6'b100010};
		7'd36: data <= {6'b000010, 26'b00000000000000000000011110};
		7'd37: data <= {6'b000000, 5'b00000, 5'b00000, 5'b00100, 5'b00000, 6'b100000};
		7'd38: data <= {6'b101011, 5'b11001, 5'b00100, 16'b0000000000001100};
		7'd39: data <= {6'b101011, 5'b11001, 5'b00100, 16'b0000000000011000};
		7'd40: data <= {6'b101011, 5'b11001, 5'b10110, 16'b0000000000100000};
		7'd41: data <= {6'b100011, 5'b11001, 5'b01000, 16'b0000000000100000};
		7'd42: data <= {6'b001100, 5'b01000, 5'b01001, 16'b0000000000000100};
		7'd43: data <= {6'b000100, 5'b01001, 5'b00000, 16'b1111111111111101};
		7'd44: data <= {6'b100011, 5'b11001, 5'b01000, 16'b0000000000011000};
		7'd45: data <= {6'b101011, 5'b11001, 5'b00000, 16'b0000000000100000};
		7'd46: data <= {6'b000010, 26'b00000000000000000000000011};
		7'd47: data <= {6'b001000, 5'b00000, 5'b11111, 16'b0000000000001100};
		7'd48: data <= {6'b001111, 5'b00000, 5'b11001, 16'b0100000000000000};
		7'd49: data <= {6'b001000, 5'b00000, 5'b10111, 16'b0000000000000010};
		7'd50: data <= {6'b001000, 5'b00000, 5'b10110, 16'b0000000000000001};
		7'd51: data <= {6'b001000, 5'b00000, 5'b10101, 16'b0000000000000011};
		7'd52: data <= {6'b001000, 5'b00000, 5'b10100, 16'b0000000000010000};
		7'd53: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000001000000};
		7'd54: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000000000};
		7'd55: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000001111001};
		7'd56: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000000100};
		7'd57: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000100100};
		7'd58: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000001000};
		7'd59: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000110000};
		7'd60: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000001100};
		7'd61: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000011001};
		7'd62: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000010000};
		7'd63: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000010010};
		7'd64: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000010100};
		7'd65: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000000010};
		7'd66: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000011000};
		7'd67: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000001111000};
		7'd68: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000011100};
		7'd69: data <= {6'b101011, 5'b00000, 5'b00000, 16'b0000000000100000};
		7'd70: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000010000};
		7'd71: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000100100};
		7'd72: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000001000};
		7'd73: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000101000};
		7'd74: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000000011};
		7'd75: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000101100};
		7'd76: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000001000110};
		7'd77: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000110000};
		7'd78: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000100001};
		7'd79: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000110100};
		7'd80: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000000110};
		7'd81: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000111000};
		7'd82: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000000001110};
		7'd83: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000000111100};
		7'd84: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000000100000000};
		7'd85: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000001010000};
		7'd86: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000001000000000};
		7'd87: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000001010100};
		7'd88: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000010000000000};
		7'd89: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000001011000};
		7'd90: data <= {6'b001000, 5'b00000, 5'b01000, 16'b0000100000000000};
		7'd91: data <= {6'b101011, 5'b00000, 5'b01000, 16'b0000000001011100};
		7'd92: data <= {6'b000000, 5'b11111, 5'b00000, 5'b00000, 5'b00000, 6'b001000};
		7'd93: data <= {6'b100011, 5'b11001, 5'b11011, 16'b0000000000001000};
		7'd94: data <= {6'b001100, 5'b11011, 5'b11011, 16'b1111111111111001};
		7'd95: data <= {6'b101011, 5'b11001, 5'b11011, 16'b0000000000001000};
		7'd96: data <= {6'b100011, 5'b10100, 5'b10011, 16'b0000000001001100};
		7'd97: data <= {6'b100011, 5'b10100, 5'b11011, 16'b0000000000111100};
		7'd98: data <= {6'b000000, 5'b00000, 5'b11011, 5'b11011, 5'b00010, 6'b000000};
		7'd99: data <= {6'b100011, 5'b11011, 5'b11011, 16'b0000000000000000};
		7'd100: data <= {6'b000000, 5'b11011, 5'b10011, 5'b11011, 5'b00000, 6'b100000};
		7'd101: data <= {6'b101011, 5'b11001, 5'b11011, 16'b0000000000010100};
		7'd102: data <= {6'b001000, 5'b10100, 5'b10100, 16'b1111111111111100};
		7'd103: data <= {6'b000101, 5'b10100, 5'b00000, 16'b0000000000000001};
		7'd104: data <= {6'b001000, 5'b10100, 5'b10100, 16'b0000000000010000};
		7'd105: data <= {6'b100011, 5'b11001, 5'b11011, 16'b0000000000001000};
		7'd106: data <= {6'b000000, 5'b11011, 5'b10111, 5'b11011, 5'b00000, 6'b100101};
		7'd107: data <= {6'b101011, 5'b11001, 5'b11011, 16'b0000000000001000};
		7'd108: data <= {6'b000000, 5'b11010, 5'b00000, 5'b00000, 5'b00000, 6'b001000};
		7'd109: data <= {6'b000000, 5'b11010, 5'b00000, 5'b00000, 5'b00000, 6'b001000};
	   default:	data <= 32'h0000_0000;
	endcase
endmodule
