module BaudRateGenerator(sysclk,BaudRate);
input sysclk;
output BaudRate;
reg BaudRate;
integer counter;

initial begin
	BaudRate <= 1;
	counter <= 1;
end

always @(posedge sysclk) begin
	if(counter < 163) counter <= counter + 1;
	else begin
		BaudRate <= ~BaudRate;
		counter <= 1;
	end
end

endmodule