// clkGenerator.v

// CPU clk generator
module clkGenerator (sysclk,reset,clk);
input sysclk,reset;
output reg clk;
// integer counter;

initial begin
    clk <= 0;
end

always @(posedge sysclk) begin
            clk <= ~clk;
end
endmodule