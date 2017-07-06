`timescale 1ns/1ns

//Interface

module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout,rxd,txd,PC_31);
input reset,clk;
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
input PC_31;
output [31:0] rdata;
reg [31:0] rdata;

output [7:0] led;
reg [7:0] led;
input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output irqout;

reg [31:0] TH,TL;
reg [2:0] TCON;
assign irqout = TCON[2] && ~PC_31;

/**** UART Variable Statement ****/
/************ begin ************/
input rxd;		//input data
output txd;		//output data
reg txd;
reg [7:0] UART_TXD;		//UART sending data
reg [7:0] UART_RXD;		//UART received data
reg [4:0] UART_CON;		//UART control signal

wire baudRate;		//baudrate
BaudRateGenerator baud(.sysclk(clk),.BaudRate(baudRate));
/************* end *************/

//Because UART_TXD, UART_RXD and UART_CON signals shoudle be variables of reg type,
// I have to extract the code needed into the peripheral file instead of graphing them as interfaces.

/*** UART receiver part ***/
/********* begin **********/
reg start_receiver;
integer mark_receiver;
integer counter_receiver;

initial begin
	mark_receiver = 0;
	counter_receiver = 0;
	start_receiver = 0;
end

always @(negedge reset or posedge BaudRate) begin
	if(~reset) begin
		mark_receiver = 0;
		counter_receiver = 0;
		start_receiver = 0;
		UART_RXD <= 8'b11111111;
	end
	else begin
		if(rd & ( addr == 32'h4000001C ))
			UART_CON[3] <= 0;
		if(start_receiver) begin
			if(mark_receiver < 16) begin
				mark_receiver = mark_receiver + 1;
				UART_CON[3] <= 0;
			end
			case(counter_receiver) 
				0: ;
				1: if(mark_receiver == 8)	UART_RXD[0] <= rxd;
				2: if(mark_receiver == 8)	UART_RXD[1] <= rxd;
				3: if(mark_receiver == 8)	UART_RXD[2] <= rxd;
				4: if(mark_receiver == 8)	UART_RXD[3] <= rxd;
				5: if(mark_receiver == 8)	UART_RXD[4] <= rxd;
				6: if(mark_receiver == 8)	UART_RXD[5] <= rxd;
				7: if(mark_receiver == 8)	UART_RXD[6] <= rxd;
				8: if(mark_receiver == 8)	UART_RXD[7] <= rxd;	
				9: begin
						if(mark_receiver == 8) begin
							UART_CON[3] <= 1
							start_receiver = 0;
							mark_receiver = 0;
							counter_receiver = 0;
							UART_RXD <= 8'b11111111;
						end
					end
			endcase
			if(mark_receiver == 16)	begin
				counter_receiver = counter_receiver + 1;
				mark_receiver = 0;
			end
		end
		else begin
			if(~rxd & UART_CON[1]) begin
				mark_receiver = 1;
				start_receiver = 1;
			end
			else begin
				UART_RXD <= 8'b11111111;
			end
		end
	end
end
/********** end ***********/

/*** UART transimitter part ***/
/*********** begin ***********/
reg start_transmitter;
integer mark_transmitter;
integer counter_transmitter;

initial begin
	counter_transmitter = 0;
	mark_transmitter = 0;
	start_transmitter <= 0;
	txd <= 1;
	UART_CON[2] <= 0;
	UART_CON[4] <= 0;
end

always @(negedge reset or posedge BaudRate) begin
	if(~reset) begin
		counter_transmitter = 0;
		mark_transmitter = 0;
		start_transmitter <= 0;
		txd <= 1;
		UART_CON[2] <= 0;
		UART_CON[4] <= 0;
	end
	else begin
		if(rd & (addr == 32'h40000018))		UART_CON[2] <= 0;
		if(start_transmitter) begin
			UART_CON[4] <= 1;
			if(mark_transmitter < 16) begin
				mark_transmitter = mark_transmitter + 1;
				UART_CON[2] <= 0;
			end
			case(counter_transmitter)
				0: txd <= 0;
				1: txd <= UART_TXD[0];
				2: txd <= UART_TXD[1];
				3: txd <= UART_TXD[2];
				4: txd <= UART_TXD[3];
				5: txd <= UART_TXD[4];
				6: txd <= UART_TXD[5];
				7: txd <= UART_TXD[6];
				8: txd <= UART_TXD[7];
				9: begin
						UART_CON[4] <= 0;
						counter_transmitter = 0;
						UART_CON[2] <= 1;
						start_transmitter = 0;
						mark_transmitter = 0;
					end
			endcase
			if(mark_transmitter == 16)  begin
				counter_transmitter = counter_transmitter + 1;
				mark_transmitter = 0;
			end
		end
		else  begin
			if(UART_CON[0]) begin
				start_transmitter <= 1;
				UART_CON[4] <= 1;
			end
			else	begin
				txd <= 1;
				UART_CON[4] <= 0;
			end
		end
	end
end
/************ end ************/


//Read outside register
always@(*) begin
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;			
			32'h40000004: rdata <= TL;			
			32'h40000008: rdata <= {29'b0,TCON};				
			32'h4000000C: rdata <= {24'b0,led};			
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= {20'b0,digi};
			32'h40000018: rdata <= {24'b0,UART_TXD};
			32'h4000001C: rdata <= {24'b0,UART_RXD};
			32'h40000020: rdata <= {27'b0,UART_CON};
			default: rdata <= 32'b0;
		endcase
	end
	else
		rdata <= 32'b0;
end

//write outside register
always@(negedge reset or posedge clk) begin
	if(~reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;	
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end
		
		if(wr) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];		
				32'h4000000C: led <= wdata[7:0];			
				32'h40000014: digi <= wdata[11:0];
				32'h40000018: UART_TXD <= wdata[7:0];
				32'h40000020: UART_CON[1:0] <= wdata[1:0];
				default: ;
			endcase
		end
	end
end
endmodule