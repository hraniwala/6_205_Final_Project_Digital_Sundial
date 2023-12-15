`timescale 1ns / 1ps
`default_nettype none

module center_of_mass (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] x_out,
                         output logic [9:0] y_out,
                         output logic valid_out);

  //your design here!
  localparam XMAX = 1024;
  localparam YMAX = 768;
  logic [31:0] pixel_count; //total number of pixels in center of mass calculation
  logic [31:0] x_sum;
  logic [31:0] y_sum;
  logic divide_signal;
  logic [31:0] x_out_temp;
  logic [31:0] y_out_temp;
  logic [31:0] x_remainder;
  logic [31:0] y_remainder;
  logic x_valid;
  logic y_valid;
  logic x_busy;
  logic y_busy;
  logic x_error;
  logic y_error;
  logic x_done;
  logic y_done;

  typedef enum {ADDING=0, WAITING=1, DIVIDING=2} current_state;

  current_state state;

  divider x_CoM (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .dividend_in(x_sum),
    .divisor_in(pixel_count),
    .data_valid_in(divide_signal),
    .quotient_out(x_out_temp),
    .remainder_out(x_remainder),
    .data_valid_out(x_valid),
    .error_out(x_error),
    .busy_out(x_busy)
  );
    divider y_CoM (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .dividend_in(y_sum),
    .divisor_in(pixel_count),
    .data_valid_in(divide_signal),
    .quotient_out(y_out_temp),
    .remainder_out(y_remainder),
    .data_valid_out(y_valid),
    .error_out(y_error),
    .busy_out(y_busy)
  );

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      x_out <= 0;
      y_out <= 0;
      x_sum <= 0;
      y_sum <= 0;
      pixel_count <= 0;
      valid_out <= 1'b0;
      divide_signal <= 0;
      x_done <= 0;
      y_done <= 0;
    end else begin
      case(state)
        ADDING: begin
          if (valid_in) begin
            x_sum <= x_sum + x_in;
            y_sum <= y_sum + y_in;
            pixel_count <= pixel_count + 1;
            divide_signal <= 1'b0;
            valid_out <= 1'b0;
          end else begin // otherwise do nothing
            valid_out <= 1'b0;
            divide_signal <= 1'b0;
          end
          if (tabulate_in && pixel_count) begin
            state <= WAITING;
          end else if (tabulate_in) begin
            valid_out <= 1'b0;
            pixel_count <= 0;
            divide_signal <= 0;
            x_sum <= 0;
            y_sum <= 0;
            state <= ADDING;
          end else begin
            state <= ADDING;
          end
        end
        WAITING: begin
          if (~x_busy && ~y_busy) begin
            state <= DIVIDING;
            divide_signal <= 1'b1;
          end else if (valid_in) begin // if new signal starts, reset
            x_sum <= 1;
            y_sum <= 1;
            pixel_count <= 1;
            divide_signal <= 1'b0;
            valid_out <= 1'b0;
            state <= ADDING;
          end else begin
            state <= WAITING;
          end
        end
        DIVIDING: begin
          divide_signal <= 1'b0;
          if (x_valid) begin
            x_out <= x_out_temp;
            x_done <= 1'b1;
          end else begin
          end
          if (y_valid) begin
            y_out <= y_out_temp;
            y_done <= 1'b1;
          end else begin
          end
          if (x_error || y_error) begin // if there is an error in the division, reset
            valid_out <= 1'b0;
            pixel_count <= 0;
            divide_signal <= 0;
            x_sum <= 0;
            y_sum <= 0;
            x_done <= 0;
            y_done <= 0;
            state <= ADDING;
          end else if (x_done && y_done) begin // if two valid divisions achieved, send out center of mass data
            valid_out <= 1'b1;
            pixel_count <= 0;
            divide_signal <= 0;
            x_sum <= 0;
            y_sum <= 0;
            x_done <= 0;
            y_done <= 0;
            state <= ADDING;
          end else begin
            state <= DIVIDING;
          end
        end
      endcase
    end
  end

endmodule


`default_nettype wire