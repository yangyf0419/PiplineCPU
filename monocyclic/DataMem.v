`timescale 1ns/1ns

module DataMem (reset,clk,rd,wr,addr,wdata,rdata);
input reset,clk;
input rd,wr;
input [31:0] addr;	//Address Must be Word Aligned
output [31:0] rdata;
input [31:0] wdata;

parameter RAM_SIZE = 4096;
reg [31:0] RAMDATA [RAM_SIZE-1:0];

assign rdata=(rd && (addr < RAM_SIZE))?RAMDATA[addr[31:2]]:32'b0;

//忘了对reset信号进行处理
integer i;
always@(posedge clk or negedge reset) begin
	if (~reset)
		for (i = 0; i < RAM_SIZE; i = i + 1)
			RAMDATA[i] <= 32'h00000000;
    else if(wr && (addr < RAM_SIZE)) 
    	RAMDATA[addr[31:2]]<=wdata;
end

endmodule
