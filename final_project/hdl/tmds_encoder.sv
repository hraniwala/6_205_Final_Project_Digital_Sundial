`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module tmds_encoder(
  input wire clk_in,
  input wire rst_in,
  input wire [7:0] data_in,  // video data (red, green or blue)
  input wire [1:0] control_in, //for blue set to {vs,hs}, else will be 0
  input wire ve_in,  // video data enable, to choose between control or video signal
  output logic [9:0] tmds_out
);
 
  logic [8:0] q_m;

  logic [4:0] cnt_old;
  logic [4:0] ones;
  logic [4:0] zeros;
  logic [1:0] error_state;
  logic [4:0] num1;
  logic [4:0] diff;
 
  tmds_choice mtm(
    .data_in(data_in),
    .qm_out(q_m));

  always_comb begin
    ones = 0;
    for (int i=0; i<$bits(q_m[7:0]); i=i+1) begin
      ones = ones + q_m[i];
    end
    zeros = 8 - ones;
  end
 
  //your code here.
  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      cnt_old <= 5'b0000_0;
      tmds_out <= 10'b0000_0000_00;
      num1 <= 5'b0000_0;
      diff <= 5'b0000_0;
    end
    else if (ve_in) begin
      if (cnt_old == 0 || ones==zeros) begin
        tmds_out[9] <= ~q_m[8];
        tmds_out[8] <= q_m[8];
        tmds_out[7:0] <= (q_m[8])? q_m[7:0] : ~q_m[7:0];
        if (q_m[8]==0) begin
          error_state <= 2'b00;
          num1 <= 0;
          diff <= zeros - ones;
          cnt_old <= cnt_old + zeros - ones;//(~(zeros - ones)+1);
        end else begin
          error_state <= 2'b01;
          num1 <= 0;
          diff <= ones - zeros;
          cnt_old <= cnt_old + ones - zeros;//(~(ones - zeros)+1);
        end
      end else begin
        if ((cnt_old[4] == 0 && ones > zeros) || (cnt_old[4] == 1 && zeros > ones)) begin
          tmds_out[9] <= 1;
          tmds_out[8] <= q_m[8];
          tmds_out[7:0] <= ~q_m[7:0];
          error_state <= 2'b10;
          num1 <= {q_m[8], 1'b0};
          diff <= zeros - ones;
          cnt_old <= cnt_old + {q_m[8], 1'b0} + (zeros - ones);//(~(2*q_m[8] + (zeros-ones))+1);//(~(2*q_m[8])+1) + (~(zeros - ones)+1);
        end else begin
          tmds_out[9] <= 0;
          tmds_out[8] <= q_m[8];
          tmds_out[7:0] <= q_m[7:0];         
          error_state <= 2'b11;
          num1 <= {q_m[8], 1'b0};
          diff <= ones - zeros;
          cnt_old <= cnt_old - {~q_m[8], 1'b0} + (ones - zeros);//(~(2*(~q_m[8]) + (ones-zeros))+1);//(~(2*(~q_m[8]))+1) + (~(ones - zeros)+1);
        end
      end
    end else begin
      cnt_old <= 5'b0000_0;
      case(control_in)
        2'b00: tmds_out <= 10'b1101010100;
        2'b01: tmds_out <= 10'b0010101011;
        2'b10: tmds_out <= 10'b0101010100;
        2'b11: tmds_out <= 10'b1010101011;
      endcase
    end
  end
 
endmodule
 
`default_nettype wire