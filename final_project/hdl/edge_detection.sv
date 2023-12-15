`timescale 1ns / 1ps
`default_nettype none

module edge_detection (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] x_out,
                         output logic [9:0] y_out,
                         output logic [31:0] mass_out,
                         output logic valid_out);

  //your design here!
  // NOTE: you will always detect from the top left corner if you are rastering over the hdmi image
  //logic [31:0] pixel_count; // NOTE: not needed as long as x/y_max/min have been detected
  logic [31:0] x_max, x_min, y_max, y_min; // edge detection variables
  //logic [31:0] x_center, y_center; // true center variables, determined from edges
  //logic divide_signal; // NOTE: not needed because division by 2 is simply a bit shift
  //logic [31:0] x_remainder;
  //logic [31:0] y_remainder;
  logic x_done; // NOTE: might not be needed
  logic y_done; // NOTE: might not be needed

  //typedef enum {ADDING=0, WAITING=1, DIVIDING=2} current_state;
  typedef enum {DETECTING=0, CENTERING=1, OUTPUTTING=2} current_state;
  current_state state;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      x_max <= 32'b0; // set to lowest value so min will be detected
      x_min <= 32'b1111_1111_1111_1111_1111_1111_1111_1111; // set to highest value so min will be detected
      x_out <= 32'b0;
      y_max <= 32'b0; // set to lowest value so min will be detected
      y_min <= 32'b1111_1111_1111_1111_1111_1111_1111_1111; // set to highest value so min will be detected
      y_out <= 32'b0;
      valid_out <= 1'b0;
      x_done <= 1'b0;
      y_done <= 1'b0;
      mass_out <= 32'b0;
    end else begin
      case(state)
        DETECTING: begin
          if (valid_in) begin
            if (x_max < x_in) begin
              x_max <= x_in;
            end else begin // otherwise do nothing
            end
            if (x_min > x_in) begin
              x_min <= x_in;
            end else begin // otherwise do nothing
            end
            if (y_max < y_in) begin
              y_max <= y_in;
            end else begin // otherwise do nothing
            end
            if (y_min > y_in) begin
              y_min <= y_in;
            end else begin // otherwise do nothing
            end
            valid_out <= 1'b0;
          end else begin // otherwise do nothing
            valid_out <= 1'b0;
          end
          if (tabulate_in && (x_max && y_max)) begin // conditional on having received a pixel higher than zero
            state <= CENTERING;
          end else if (tabulate_in) begin
            valid_out <= 1'b0;
            x_max <= 32'b0; // reset
            x_min <= 32'b1111_1111_1111_1111_1111_1111_1111_1111; // reset
            y_max <= 32'b0; // reset
            y_min <= 32'b1111_1111_1111_1111_1111_1111_1111_1111; // reset
            state <= DETECTING;
          end else begin
            state <= DETECTING;
          end
        end
        CENTERING: begin
          x_out <= (x_max + x_min) >> 1;
          y_out <= (y_max + y_min) >> 1;
          mass_out <= ((x_max - x_min) * (y_max - y_min) * 201) >> 6; // pi estimate of 201/64
          valid_out <= 1'b0;
          state <= OUTPUTTING;
        end
        OUTPUTTING: begin
          valid_out <= 1'b1;
          x_max <= 32'b0; // reset
          x_min <= 32'b1111_1111_1111_1111_1111_1111_1111_1111; // reset
          y_max <= 32'b0; // reset
          y_min <= 32'b1111_1111_1111_1111_1111_1111_1111_1111; // reset
          state <= DETECTING;
        end
      endcase
    end
  end

endmodule


`default_nettype wire