`timescale 1ns / 1ps
`default_nettype none

module fir31(
    input wire clk_in,
    input wire rst_in,
    input wire ready_in,
    input wire signed [7:0] x_in,
    output logic signed [17:0] y_out
);

logic signed [7:0] sample[31:0];  
logic [4:0] offset;               
logic [4:0] index;               
logic signed [17:0] accumulator;  
logic signed [9:0] coeff;        
coeffs31 myCoeffs(.index_in(index), .coeff_out(coeff));

always_ff @(posedge clk_in) begin
    if (rst_in) begin
        offset <= 0;
        index <= 0;
        accumulator <= 0;
    end else if (ready_in) begin
        sample[offset] <= x_in;
        offset <= offset + 1;
        index <= 0;
        accumulator <= 0;
    end else if (index < 31) begin
        accumulator <= accumulator + (sample[(offset - 1 - index) % 32] * coeff);
        index <= index + 1;
    end
    if (index == 31) begin
        y_out <= accumulator;
    end
end
endmodule

module coeffs31(
  input wire  [4:0] index_in,
  output logic signed [9:0] coeff_out
);
  logic signed [9:0] coeff;
  assign coeff_out = coeff;
  always_comb begin
    case (index_in)
      // 5'd0:  coeff = -10'sd1;
      // 5'd1:  coeff = -10'sd1;
      // 5'd2:  coeff = -10'sd3;
      // 5'd3:  coeff = -10'sd5;
      // 5'd4:  coeff = -10'sd6;
      // 5'd5:  coeff = -10'sd7;
      // 5'd6:  coeff = -10'sd5;
      // 5'd7:  coeff = 10'sd0;
      // 5'd8:  coeff = 10'sd10;
      // 5'd9:  coeff = 10'sd26;
      // 5'd10: coeff = 10'sd46;
      // 5'd11: coeff = 10'sd69;
      // 5'd12: coeff = 10'sd91;
      // 5'd13: coeff = 10'sd110;
      // 5'd14: coeff = 10'sd123;
      // 5'd15: coeff = 10'sd128;
      // 5'd16: coeff = 10'sd123;
      // 5'd17: coeff = 10'sd110;
      // 5'd18: coeff = 10'sd91;
      // 5'd19: coeff = 10'sd69;
      // 5'd20: coeff = 10'sd46;
      // 5'd21: coeff = 10'sd26;
      // 5'd22: coeff = 10'sd10;
      // 5'd23: coeff = 10'sd0;
      // 5'd24: coeff = -10'sd5;
      // 5'd25: coeff = -10'sd7;
      // 5'd26: coeff = -10'sd6;
      // 5'd27: coeff = -10'sd5;
      // 5'd28: coeff = -10'sd3;
      // 5'd29: coeff = -10'sd1;
      // 5'd30: coeff = -10'sd1;
        5'd0:  coeff = 12'sd0; //filtering 5khz signals for 50khz sampling rate coeffs
        5'd1:  coeff = 12'sd0;
        5'd2:  coeff = -12'sd1;
        5'd3:  coeff = -12'sd2;
        5'd4:  coeff = -12'sd2;
        5'd5:  coeff = 12'sd0;
        5'd6:  coeff = -12'sd4;
        5'd7:  coeff = -12'sd9;
        5'd8:  coeff = -12'sd12;
        5'd9:  coeff = -12'sd10;
        5'd10: coeff = 12'sd0;
        5'd11: coeff = 12'sd20;
        5'd12: coeff = 12'sd47;
        5'd13: coeff = 12'sd74;
        5'd14: coeff = 12'sd94;
        5'd15: coeff = 12'sd102;
        5'd16: coeff = 12'sd94;
        5'd17: coeff = 12'sd74;
        5'd18: coeff = 12'sd47;
        5'd19: coeff = 12'sd20;
        5'd20: coeff = 12'sd0;
        5'd21: coeff = -12'sd10;
        5'd22: coeff = -12'sd12;
        5'd23: coeff = -12'sd9;
        5'd24: coeff = -12'sd4;
        5'd25: coeff = 12'sd0;
        5'd26: coeff = -12'sd2;
        5'd27: coeff = -12'sd2;
        5'd28: coeff = -12'sd1;
        5'd29: coeff = 12'sd0;
        5'd30: coeff = 12'sd0;
        // 5'd0:  coeff = 12'sd0;
        // 5'd1:  coeff = 12'sd0;
        // 5'd2:  coeff = 12'sd0;
        // 5'd3:  coeff = 12'sd0;
        // 5'd4:  coeff = -12'sd2;
        // 5'd5:  coeff = -12'sd4;
        // 5'd6:  coeff = -12'sd7;
        // 5'd7:  coeff = -12'sd7;
        // 5'd8:  coeff = -12'sd5;
        // 5'd9:  coeff = 12'sd2;
        // 5'd10: coeff = 12'sd14;
        // 5'd11: coeff = 12'sd31;
        // 5'd12: coeff = 12'sd49;
        // 5'd13: coeff = 12'sd65;
        // 5'd14: coeff = 12'sd77;
        // 5'd15: coeff = 12'sd81;
        // 5'd16: coeff = 12'sd77;
        // 5'd17: coeff = 12'sd65;
        // 5'd18: coeff = 12'sd49;
        // 5'd19: coeff = 12'sd31;
        // 5'd20: coeff = 12'sd14;
        // 5'd21: coeff = 12'sd2;
        // 5'd22: coeff = -12'sd5;
        // 5'd23: coeff = -12'sd7;
        // 5'd24: coeff = -12'sd7;
        // 5'd25: coeff = -12'sd4;
        // 5'd26: coeff = -12'sd2;
        // 5'd27: coeff = 12'sd0;
        // 5'd28: coeff = 12'sd0;
        // 5'd29: coeff = 12'sd0;
        // 5'd30: coeff = 12'sd0;
      default: coeff = 10'hXXX;
    endcase
  end
endmodule

`default_nettype wire