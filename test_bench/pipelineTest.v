module pipelineTest;
	reg clk;
	reg reset;

	PipelineCpu test(.reset(reset),
					 .clk(clk),
					 .PerData(),
					 .IRQ(0), 
					 .MEM_MemRead(), 
					 .PerWr(), 
					 .MEM_ALUOut(), 
					 .MEM_DataBusB(), 
					 .PC_31());

	initial begin
		reset = 0;
		clk = 0;
		#30 reset = ~reset;
	end

	always #20 clk = ~clk;

endmodule