// system.v
// led, switch, digi_out1, digi_out2, digi_out3, digi_out4

/*Peripheral prph(
        .reset(reset),
        .clk(clk),
        .rd(MemRead),
        .wr(PerWr),
        .addr(ALUOut),
        .wdata(DataBusB),
        .rdata(PerData),
        .led(led),
        .switch(switch),
        .digi(digi_in),
        .irqout(IRQ));
*/

/*
    digitube_scan dgt_sc(
        .digi_in(digi_in),
        .digi_out4(digi_out4),
        .digi_out3(digi_out3),
        .digi_out2(digi_out2),
        .digi_out1(digi_out1));
*/

module pipeline_system(sysclk, reset,
				rxd,txd,
				led, digi_out1, digi_out2, digi_out3, digi_out4);

input sysclk,reset;

// UART
input rxd;
output txd;

// display part
output [7:0] led;
// input [7:0] switch;
wire [11:0] digi_in; //AN3,AN2,AN1,AN0,DP,CG,CF,CE,CD,CC,CB,CA
output [6:0] digi_out1;	//0: CG,CF,CE,CD,CC,CB,CA
output [6:0] digi_out2;	//1: CG,CF,CE,CD,CC,CB,CA
output [6:0] digi_out3;	//2: CG,CF,CE,CD,CC,CB,CA
output [6:0] digi_out4;	//3: CG,CF,CE,CD,CC,CB,CA

// Peripheral wire
wire MemRead;
wire IRQ;
wire [31:0] PerData;
wire PerWr;
wire [31:0] ALUOut;
wire [31:0] DataBusB;
wire PC_31;

PipelineCpu PCPU(.reset(reset),
				  .clk(sysclk),
				  .PerData(PerData),
				  .IRQ(IRQ),
				  .MEM_MemRead(MemRead),
				  .PerWr(PerWr),
				  .MEM_ALUOut(ALUOut),
				  .MEM_DataBusB(DataBusB),
                  .PC_31(PC_31));

Peripheral prph(
        .reset(reset),
        .timer_clk(sysclk),
        .sysclk(sysclk),
        .rd(MemRead),
        .wr(PerWr),
        .addr(ALUOut),
        .wdata(DataBusB),
        .rdata(PerData),
        .led(led),
        .digi(digi_in),
        .irqout(IRQ),
        .rxd(rxd),
        .txd(txd),
        .PC_31(PC_31));

digitube_scan dgt_sc(
        .digi_in(digi_in),
        .digi_out4(digi_out4),
        .digi_out3(digi_out3),
        .digi_out2(digi_out2),
        .digi_out1(digi_out1));

endmodule