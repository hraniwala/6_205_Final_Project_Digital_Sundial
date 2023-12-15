`timescale 1ns / 1ps
`default_nettype none

module clock_divider(
    input wire clk_in,
    input wire reset,      
    output reg clk_25MHz 
);

logic [4:0] counter;

// always @(posedge clk_in) begin
//     if (reset) begin
//         counter <= 0;
//         clk_25MHz <= 0;
//     end else begin
//         counter <= counter + 1'b1;
//         if (counter == 1'b1) begin
//             clk_25MHz <= ~clk_25MHz;
//             counter <= 1'b0;
//         end
//     end
// end
always @(posedge clk_in) begin
    if (reset) begin
        counter <= 0;
        clk_25MHz <= 0;
    end else begin
        counter <= counter + 1;
        if (counter == 5'd14) begin
            clk_25MHz <= ~clk_25MHz;
            counter <= 1'b0;
        end
    end
end

endmodule

`default_nettype wire
