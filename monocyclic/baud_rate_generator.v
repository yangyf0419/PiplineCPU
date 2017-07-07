// baud_rate_generator.v

module baud_rate_generator(sysclk, bclk, clk9600, resetb);
    input sysclk, resetb;
    output reg bclk, clk9600;
    reg [8:0] count;
    reg [3:0] count16;

    always @ (negedge resetb or posedge bclk) begin
        if (~resetb) begin
            count16 <= 4'h0;
            clk9600 <= 1;
        end
        else begin
            count16 <= count16 + 1;
            if (count16 == 7) begin
                clk9600 = ~clk9600;
                count16 <= 4'h0;
            end
        end
    end

    always @ (negedge resetb or posedge sysclk) begin
        if (~resetb) begin
            count <= 9'h0;
            bclk <= 1;
        end
        else begin
            count <= count + 1;
            if (count == 163) begin
                bclk = ~bclk;
                count <= 9'h0;
            end
        end
    end
endmodule