module UART(sysclk,reset,rxd,txd);
input sysclk,reset,rxd;
output txd;
wire BaudRate,RXStatus,TXStatus,TXEn;
wire [7:0] RXData;
wire [7:0] TXData;

BaudRateGenerator baud(sysclk,BaudRate);
Receiver rec(rxd,BaudRate,RXData,RXStatus);
controller ctr(BaudRate,RXStatus,RXData,TXStatus,TXData,TXEn);
Transmitter trans(BaudRate,TXData,TXEn,TXStatus,txd);

endmodule
