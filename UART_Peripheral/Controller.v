module controller(BaudRate,RXStatus,RXData,TXStatus,TXData,TXEn);
input RXStatus,TXStatus;
input BaudRate;
input [7:0] RXData;
output [7:0] TXData;
output TXEn;
reg tip;
reg [7:0] TXData;
reg TXEn;

initial begin
	tip = 0;
	TXEn <= 0;
	TXData <= 8'b11111111;
end

always @(posedge BaudRate) begin
	if(TXEn)		TXEn <= 0;
	if(RXStatus)	tip = 1;
	if(TXStatus)	begin
		if(tip)	begin
			if(RXData[7]) TXData = ~RXData;
			else TXData = RXData;
			TXEn <= 1;
			tip = 0;
		end
		/*else begin
			TXData = 8'b11111111;
			TXEn <= 0;
		end*/
	end
end

endmodule
