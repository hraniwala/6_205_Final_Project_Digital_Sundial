`timescale 1ns / 1ps
`default_nettype none

module length # (parameter WIDTH=1000) (
          input wire clk_in,
          input wire rst_in,
          input wire data_valid_in,
          input wire [10:0] x0_in,
          input wire [9:0]  y0_in,
          input wire [10:0] x_in,
          input wire [9:0] y_in,
          input wire [31:0] mass_in,
          output logic [31:0] length_out,
          output logic valid_out);

  //your design here!
  // input x0_in, y0_in should be the true center;
  // input x_in, y_in should be the shifted center of mass;
  logic [31:0] x, y; // edge detection variables
  //logic [31:0] x_center, y_center; // true center variables, determined from edges
  //logic divide_signal; // NOTE: not needed because division by 2 is simply a bit shift
  //logic [31:0] x_remainder;
  //logic [31:0] y_remainder;
  logic x_done; // NOTE: might not be needed
  logic y_done; // NOTE: might not be needed
  logic divide_valid_in;
  logic divide_valid_out;
  logic divide_error_out;
  logic divide_busy_out;
  logic invert;
  assign invert = x < y;

  // length calculation components of quadratic formula
  logic [31:0] r;
  logic [31:0] r_sqrt_arg;
  logic [31:0] neg_b;
  logic [31:0] b_squared;
  logic [31:0] min_four_ac;
  logic [31:0] min_four_ac_div;
  logic [31:0] min_four_ac_div_temp;

  logic [31:0] sqrt_input;
  logic [31:0] sqrt_output;

  assign sqrt_input = b_squared + min_four_ac_div;

  logic [31:0] numerator;
  always_comb begin
    if (sqrt_output <= neg_b) begin // the smallest value of the numerator should be zero
      numerator = 0;
    end else begin
      numerator = r*sqrt_output - neg_b;
    end
  end

  Sqrt_Finer_Lookup sqrt (
    .sqrt_input(sqrt_input),
    .sqrt_output(sqrt_output));

  Sqrt_Fine_Lookup r_val (
    .sqrt_input(r_sqrt_arg),
    .sqrt_output(r));


  divider #(.WIDTH(32)) division(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .dividend_in(min_four_ac),
    .divisor_in(WIDTH*r),
    .data_valid_in(divide_valid_in),
    .quotient_out(min_four_ac_div_temp),
    //.remainder_out(),
    .data_valid_out(divide_valid_out),
    .error_out(divide_error_out),
    .busy_out(divide_busy_out));

  //typedef enum {ADDING=0, WAITING=1, DIVIDING=2} current_state;
  typedef enum {IDLE=0, 
                COMPARING=1, 
                R_CALC=2,
                NUMERATOR_CALC=3,
                DIVIDING=4, 
                FINAL_CALC=5,
                OUTPUTTING=6} current_state;
  current_state state;

  logic [1:0] quadrant; // 2'b00: posLR/posTB; 2'b01: negLRposTB; 2'b10: posLRnegTB; 2'b11: negLRnegTB

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      x <= 32'b0; // set to lowest value so min will be detected
      y <= 32'b0; // set to highest value so min will be detected
      valid_out <= 1'b0;
      length_out <= 32'b0;
    end else begin
      case(state)
        IDLE: begin
          valid_out <= 1'b0;
          if (data_valid_in) begin
            state <= COMPARING;
          end else begin
            state <= IDLE;
          end
        end
        COMPARING: begin
          if (x_in == x0_in && y_in == y0_in) begin     
            length_out <= 0;
            state <= OUTPUTTING;    
          end else if (x_in > x0_in && y_in == y0_in) begin 
            x <= x_in - x0_in;
            y <= 0;      
          end else if (x_in < x0_in && y_in == y0_in) begin   
            x <= x0_in - x_in;
            y <= 0;
          end else if (x_in == x0_in && y_in > y0_in) begin      
            x <= 0;
            y <= y_in - y0_in;     
          end else if (x_in == x0_in && y_in < y0_in) begin     
            x <= 0;
            y <= y0_in - y_in;  
          end else if (x_in > x0_in && y_in > y0_in) begin
            quadrant <= 2'b01;
            x <= x_in - x0_in;
            y <= y_in - y0_in;
          end else if (x_in < x0_in && y_in > y0_in) begin
            quadrant <= 2'b00;
            y <= x0_in - x_in;
            x <= y_in - y0_in;
          end else if (x_in < x0_in && y_in < y0_in) begin
            quadrant <= 2'b11; 
            x <= x0_in - x_in;
            y <= y0_in - y_in;
          end else begin
            quadrant <= 2'b10;
            y <= x_in - x0_in;
            x <= y0_in - y_in;
          end
          state <= R_CALC;
        end
        R_CALC: begin
          r_sqrt_arg <= x*x + y*y;
          state <= NUMERATOR_CALC;
        end
        NUMERATOR_CALC: begin
          if (r == 0) begin
            length_out <= 0;
            state <= OUTPUTTING;
          end else if (r > 300) begin // if r is too long, just output a "max" value instead of dividing
            length_out <= 9999;
            state <= OUTPUTTING;
          end else begin
            b_squared <= 1;
            neg_b <= r;
            min_four_ac <= 2*mass_in;
            divide_valid_in <= 1'b1;
            state <= DIVIDING;
          end
        end
        DIVIDING: begin
          divide_valid_in <= 1'b0;
          if (divide_busy_out) begin
            state <= DIVIDING;
          end else if (divide_error_out) begin
            state <= IDLE;
          end else if (divide_valid_out) begin
            min_four_ac_div <= min_four_ac_div_temp;
            state <= FINAL_CALC;
          end
        end
        FINAL_CALC: begin
          length_out <= sqrt_output;//(numerator >> 2);
          state <= OUTPUTTING;
        end
        OUTPUTTING: begin
          valid_out <= 1'b1;
          state <= IDLE;
          end
      endcase
    end
  end

endmodule

`default_nettype wire