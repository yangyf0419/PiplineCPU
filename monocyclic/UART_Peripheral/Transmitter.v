module Transmitter(reset,BaudRate,TXData,TXEn,TXStatus,UARTTx,TX_Stop_Status);
input [7:0] TXData;		//uart_txd
input BaudRate;		//baudrate
input TXEn;		//uart_con[0]
input reset;
output TXStatus;	//uart_con[2]
output TX_Stop_Status;		//uart_con[4]
output UARTTx;		//output of the whole system
reg TX_Stop_Status;
reg TXStatus;
reg start;
reg UARTTx;
integer mark;
integer counter;

initial begin
	counter = 0;
	mark = 0;
	start <= 0;
	UARTTx <= 1;
	TXStatus <= 0;
	TX_Stop_Status <= 0;
end

always @(negedge reset or posedge BaudRate) begin
	if(~reset) begin
		counter = 0;
		mark = 0;
		start <= 0;
		UARTTx <= 1;
		TXStatus <= 0;
		TX_Stop_Status <= 0;
	end
	else begin
		if(start) begin
			TX_Stop_Status <= 1;
			if(mark < 16) begin
				mark = mark + 1;
				TXStatus <= 0;
			end
			case(counter)
				0: UARTTx <= 0;
				1: UARTTx <= TXData[0];
				2: UARTTx <= TXData[1];
				3: UARTTx <= TXData[2];
				4: UARTTx <= TXData[3];
				5: UARTTx <= TXData[4];
				6: UARTTx <= TXData[5];
				7: UARTTx <= TXData[6];
				8: UARTTx <= TXData[7];
				9: begin
						TX_Stop_Status <= 0;
						counter = 0;
						TXStatus <= 1;
						start = 0;
						mark = 0;
					end
			endcase
			if(mark == 16)  begin
				counter = counter + 1;
				mark = 0;
			end
		end
		else  begin
			if(TXEn) begin
				start <= 1;
				TX_Stop_Status <= 1;
			end
			else	begin
				UARTTx <= 1;
				TX_Stop_Status <= 0;
			end
		end
	end
end

endmodule