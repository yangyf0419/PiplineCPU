// clkGenerator.v

// CPU clk generator
module clkGenerator (sysclk,reset,clk);
input sysclk,reset;
output reg clk;
integer counter;

initial begin
    counter = 0;
    clk <= 0;
end

always @(posedge sysclk or negedge reset) begin
    if(~reset)  begin
        counter = 0;
    end
    else begin
        if(counter == 50)    begin
            clk <= ~clk;
        end
        if(counter != 50)    counter += 1;
        else    counter = 0;
    end
end
endmodule