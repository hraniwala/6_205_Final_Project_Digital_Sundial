`timescale 1ns / 1ps
`default_nettype none
module simple_counter(  input wire          clk_in,
                        input wire          rst_in,
                        input wire          evt_in,
                        output logic[15:0]  count_out
                    );
 
  always_ff @(posedge clk_in) begin
    if (rst_in == 1'b1) begin
      count_out <= 16'b0;
    end else if (evt_in == 1'b1) begin
      /* your code here */
      count_out <= count_out + 1;
    end
  end
endmodule
`default_nettype wire

