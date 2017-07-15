module pipelineTest;
	reg clk;
	reg reset;
	reg UART_RX;
	
	pipeline_system sys(
		.sysclk(clk),
		.reset(reset),
		.rxd(UART_RX),
		.txd(),
		.led(),
		.digi_out1(), 
		.digi_out2(), 
		.digi_out3(), 
		.digi_out4());

	
	initial begin
		reset = 1;
        #1 reset = 0;
		clk = 0;
		#1 reset = 1;
	end

	initial begin
        UART_RX <= 1;

        #10416 UART_RX <= 0;
        #10416 UART_RX <= 1;//输入 8'hb9
        #10416 UART_RX <= 0;//输出 8'h46
        #10416 UART_RX <= 0;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 0;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;

        #10416 UART_RX <= 0;
        #10416 UART_RX <= 0;//输入 8'h96
        #10416 UART_RX <= 1;//输出 8'h69 
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 0;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 0;
        #10416 UART_RX <= 0;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        

        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;

        #10416 UART_RX <= 0;
        #10416 UART_RX <= 0;//输入 8'h1e
        #10416 UART_RX <= 1;//输出 8'h1e
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 1;
        #10416 UART_RX <= 0;
        #10416 UART_RX <= 0;
        #10416 UART_RX <= 0;
        #10416 UART_RX <= 1;
    end
	
	always #1 clk = ~clk;

endmodule