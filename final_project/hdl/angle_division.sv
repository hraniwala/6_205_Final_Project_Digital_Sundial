`timescale 1ns / 1ps
`default_nettype none

module angle_division (
          input wire clk_in,
          input wire rst_in,
          input wire data_valid_in,
          input wire [10:0] x0_in,
          input wire [9:0]  y0_in,
          input wire [10:0] x_in,
          input wire [9:0] y_in,
          output logic [8:0] sun_angle_out,
          output logic [8:0] clock_angle_out,
          output logic valid_out);

  //your design here!
  // input x0_in, y0_in should be the true center;
  // input x_in, y_in should be the shifted center of mass;
  logic [63:0] x, y; // edge detection variables
  logic [63:0] oppsquared;
  logic [63:0] adjsquared;
  logic [63:0] divide_out;
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
  logic [63:0] lookup_val;
  logic [8:0] sun_angle_out_temp;
  logic [8:0] clock_angle_out_temp;
  logic invert;
  assign invert = x < y;

  divider #(.WIDTH(64)) division(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .dividend_in(oppsquared),
    .divisor_in(adjsquared),
    .data_valid_in(divide_valid_in),
    .quotient_out(divide_out),
    //.remainder_out(),
    .data_valid_out(divide_valid_out),
    .error_out(divide_error_out),
    .busy_out(divide_busy_out));

  Angles_Lookup lookup(
    .ratio(lookup_val),
    .sun_angle_val(sun_angle_out_temp),
    .clock_angle_val(clock_angle_out_temp));
  //typedef enum {ADDING=0, WAITING=1, DIVIDING=2} current_state;
  typedef enum {IDLE=0, COMPARING=1, MULTIPLYING=2, DIVIDING=3, LOOKUP=4, OUTPUTTING=5} current_state;
  current_state state;

  logic [1:0] quadrant; // 2'b00: posLR/posTB; 2'b01: negLRposTB; 2'b10: posLRnegTB; 2'b11: negLRnegTB

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      x <= 32'b0; // set to lowest value so min will be detected
      y <= 32'b0; // set to highest value so min will be detected
      valid_out <= 1'b0;
      sun_angle_out <= 0;
      clock_angle_out <= 0;
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
            sun_angle_out <= 0;
            clock_angle_out <= 0;            
            state <= OUTPUTTING;
          end else if (x_in > x0_in && y_in == y0_in) begin
            sun_angle_out <= 0;
            clock_angle_out <= 0;            
            state <= OUTPUTTING;
          end else if (x_in < x0_in && y_in == y0_in) begin
            sun_angle_out <= 9'd180;
            clock_angle_out <= 9'd180;            
            state <= OUTPUTTING;
          end else if (x_in == x0_in && y_in > y0_in) begin
            sun_angle_out <= 9'd90;
            clock_angle_out <= 9'd90;            
            state <= OUTPUTTING;
          end else if (x_in == x0_in && y_in < y0_in) begin
            sun_angle_out <= 9'd270;
            clock_angle_out <= 9'd270;            
            state <= OUTPUTTING;
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
          state <= MULTIPLYING;
        end
        MULTIPLYING: begin
            if (x > y) begin
              oppsquared <= (y*64'd100);
              adjsquared <= x;
            end else begin
              oppsquared <= (x*64'd100);
              adjsquared <= y;
            end
            divide_valid_in <= 1'b1;
            state <= DIVIDING;
        end
        DIVIDING: begin
          divide_valid_in <= 1'b0;
          if (divide_busy_out) begin
            state <= DIVIDING;
          end else if (divide_error_out) begin
            state <= IDLE;
          end else if (divide_valid_out) begin
            lookup_val <= divide_out;
            state <= LOOKUP;
          end
        end
        LOOKUP: begin
          case(quadrant)
          2'b00: begin
            if (x < y) begin
              sun_angle_out <= sun_angle_out_temp;
              clock_angle_out <= clock_angle_out_temp;
            end else begin
              sun_angle_out <= 64'd90 - sun_angle_out_temp;
              clock_angle_out <= 64'd90 - clock_angle_out_temp;   
            end           
          end
          2'b01: begin
            if (x < y) begin
              sun_angle_out <= 64'd90 + sun_angle_out_temp;
              clock_angle_out <= 64'd90 + clock_angle_out_temp;
            end else begin
              sun_angle_out <= 64'd180 - sun_angle_out_temp;
              clock_angle_out <= 64'd180 - clock_angle_out_temp;   
            end      
          end
          2'b10: begin
           if (x < y) begin
              sun_angle_out <= 64'd180 + sun_angle_out_temp;
              clock_angle_out <= 64'd180 + clock_angle_out_temp;
            end else begin
              sun_angle_out <= 64'd270 - sun_angle_out_temp;
              clock_angle_out <= 64'd270 - clock_angle_out_temp;   
            end    
          end
          2'b11: begin
           if (x < y) begin
              sun_angle_out <= 64'd270 + sun_angle_out_temp;
              clock_angle_out <= 64'd270 + clock_angle_out_temp;
            end else begin
              sun_angle_out <= 64'd360 - sun_angle_out_temp;
              clock_angle_out <= 64'd360 - clock_angle_out_temp;   
            end    
          end
          endcase 
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