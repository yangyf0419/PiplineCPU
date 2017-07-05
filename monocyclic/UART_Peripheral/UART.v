//UART.v
`timescale 1ns/1ps

//UART

module UART (reset,clk,rxd,uart_txd,,uart_rxd,txd,UART_con,uart_con);
input reset,clk,rxd;
input [7:0] uart_txd;
output txd;
output [7:0] uart_rxd;
input [4:0] UART_con;
output [4:0] uart_con;
assign uart_con = UART_con;

wire BaudRate;

BaudRateGenerator baud(.sysclk(clk),.BaudRate(BaudRate));

Receiver rec(.reset(reset),
			.RXEn(UART_con[1]),
			.UARTRx(rxd),
			.BaudRate(BaudRate),
			.RXData(uart_rxd),
			.RX_Status(UART_con[3]));

Transmitter trans(
	.reset(reset),
	.BaudRate(BaudRate),
	.TXData(uart_txd),
	.TXEn(UART_con[0]),
	.TXStatus(UART_con[4]),
	.UARTTx(txd),
	.TX_Stop_Status(UART_con[2]));

endmodule