`timescale 1ns/1ns

//Interface

module Peripheral1 (reset,timer_clk,sysclk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout,rxd,txd,PC_31);
input reset,timer_clk;
input sysclk;   // 50M clk
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
input rxd;      //input data
output txd;     //output data
reg txd;
reg [7:0] UART_TXD;     //UART sending data
reg [7:0] UART_RXD;     //UART received data
reg [4:0] UART_CON;     //UART control signal

wire bclk;      //baudrate
wire clk9600;
baud_rate_generator baud(.sysclk(sysclk), .bclk(bclk), .clk9600(clk9600), .resetb(reset));
/************* end *************/
reg data_received; // 收到数据
reg [3:0] counter; // 对bclk进行计数
reg [3:0] labelrx; // 对数据进行计数

always @ (negedge reset or posedge bclk) begin 
    if (~reset) begin
        counter[3:0] <= 0;
        labelrx <= 4'h0;
        data_received <= 0;
        UART_RXD <= 8'h0;
    end
    else if (UART_CON[1]) begin
        counter <= counter + 1; 
        if (~rxd && ~data_received) begin
            counter[3:0] <= 4'h0;
            data_received <= 1;
            labelrx <= 4'h0;
        end 
        else if (counter == 4'h8 && data_received) begin
            if (labelrx == 4'h9) begin
                data_received <= 0;
                labelrx <= 0;
            end
            else begin
                if (labelrx != 0)
                    UART_RXD[labelrx[3:0] - 1] = rxd;
                labelrx <= labelrx + 4'h1;
            end
        end
    end
end

reg [3:0] labeltx;
always @ (negedge reset or posedge clk9600) begin
        if (~reset) begin
            txd <= 1;
            labeltx <= 4'hf;
            UART_CON[4] <= 0;
        end
        else if (~UART_CON[4] && UART_CON[0]) begin
            UART_CON[4] <= 1;
            txd <= 0;
            labeltx <= 4'h0;
        end
        else if (UART_CON[4]) begin
            if (labeltx == 8) begin
                txd <= 1;
                labeltx <= labeltx + 1;
            end
            else if (labeltx == 9) begin
                labeltx <= 4'hf;
                UART_CON[4] <= 0;
            end
            else if (labeltx == 4'hf);
            else begin
                txd <= UART_TXD[labeltx];
                labeltx <= labeltx + 1;
            end
        end
    end

reg flagtx, flagrx;
always@(negedge reset or posedge sysclk) begin
    if (~reset) begin
        UART_CON[3:2] <= 0;
        flagtx <= 0;
        flagrx <= 0;
    end
    else if (rd) begin
        if (addr == 32'h4000001C) UART_CON[3] <= 0;
        if (addr == 32'h40000018) UART_CON[2] <= 0;
    end
    else begin
        if (labelrx == 4'h9 && ~flagrx) begin
            UART_CON[3] <= 1;
            flagrx <= 1;
        end
        if (labeltx == 4'h9 && ~flagtx) begin
            UART_CON[2] <= 1;
            flagtx <= 1;
        end
        if (labelrx != 4'h9) flagrx <= 0;
        if (labeltx != 4'h9) flagtx <= 0;
    end
end

    

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
always@(negedge reset or posedge timer_clk) begin
    if(~reset) begin
        TH <= 32'b0;
        TL <= 32'b0;
        TCON <= 3'b0;   
    end
    else begin
        if(TCON[0]) begin   //timer is enabled
            if(TL==32'hffffffff) begin
                TL <= TH;
                if(TCON[1]) TCON[2] <= 1'b1;        //irq is enabled
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