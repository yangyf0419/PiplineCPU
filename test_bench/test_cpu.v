module test_cpu();
	
	reg reset;
	reg clk;
	
	CPU cpu1(reset, clk);
	
	initial begin
		reset = 0;
		clk = 1;
		#50 reset = 1;
	end
	
	always #50 clk = ~clk;
		
endmodule
