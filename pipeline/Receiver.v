module Receiver(reset,RXEn,UARTRx,BaudRate,RXData,RXStatus);
input reset;
input UARTRx;	//the input of the whole system
input BaudRate;		//baudrate
input RXEn;		//uart_con[1]
output [7:0] RXData;	//UART_RXD
output RXStatus;	//uart_con[3]
reg RXStatus;
reg [7:0] RXData;
reg start;
integer mark;
integer counter;

initial begin
	mark = 0;
	counter = 0;
	start = 0;
end

always @(negedge reset or posedge BaudRate) begin
	if(~reset) begin
		mark = 0;
		counter = 0;
		start = 0;
		RXData <= 8'b11111111;
	end
	else begin
		if(start) begin
			if(mark < 16) begin
				mark = mark + 1;
				RXStatus <= 0;
			end
			case(counter) 
				0: ;
				1: if(mark == 8)	RXData[0] <= UARTRx;
				2: if(mark == 8)	RXData[1] <= UARTRx;
				3: if(mark == 8)	RXData[2] <= UARTRx;
				4: if(mark == 8)	RXData[3] <= UARTRx;
				5: if(mark == 8)	RXData[4] <= UARTRx;
				6: if(mark == 8)	RXData[5] <= UARTRx;
				7: if(mark == 8)	RXData[6] <= UARTRx;
				8: if(mark == 8)	RXData[7] <= UARTRx;	
				9: begin
						if(mark == 8) begin
							RXStatus <= 1
							start = 0;
							mark = 0;
							counter = 0;
							RXData <= 8'b11111111;
						end
					end
			endcase
			if(mark == 16)	begin
				counter = counter + 1;
				mark = 0;
			end
		end
		else begin
			if(~UARTRx & RXEn) begin
				mark = 1;
				start = 1;
			end
			else begin
				RXData <= 8'b11111111;
			end
		end
	end
end


endmodule