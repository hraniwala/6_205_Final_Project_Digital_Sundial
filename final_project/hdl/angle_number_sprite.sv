`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */

module angle_number_sprite #(
  parameter NUMWIDTH=32,NUMBERS=3,HEIGHT=32) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  input wire [9:0] num_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
  );

  // calculate rom address
  // calculate rom address
  logic [$clog2(10*NUMWIDTH*HEIGHT)-1:0] image_addr_1, image_addr_2, image_addr_3;
  logic [3:0] num_1;
  logic [3:0] num_2;
  logic [3:0] num_3;
  logic in_num_1, in_num_2, in_num_3, in_sprite;

  // determine the hundreds, tens, and ones place digits to display
  always_comb begin
    num_1 = (num_in - (num_in % 10'd100)) / 10'd100;
    num_2 = ((num_in % 10'd100) - (num_in % 10'd10)) / 10'd10;
    num_3 = num_in % 10'd10;
  end

  assign image_addr_1 = (hcount_in - x_in) + ((vcount_in - y_in) * NUMWIDTH) + num_1*NUMWIDTH*HEIGHT;
  assign image_addr_2 = (hcount_in - x_in) + ((vcount_in - y_in) * NUMWIDTH) + num_2*NUMWIDTH*HEIGHT;
  assign image_addr_3 = (hcount_in - x_in) + ((vcount_in - y_in) * NUMWIDTH) + num_3*NUMWIDTH*HEIGHT;

  logic [10:0] hcount_in_pipe [1:0];
  logic [9:0] vcount_in_pipe [1:0];
  logic [10:0] x_in_pipe [1:0];
  logic [9:0] y_in_pipe [1:0];

  always_ff @(posedge pixel_clk_in) begin
    hcount_in_pipe[0] <= hcount_in;
    vcount_in_pipe[0] <= vcount_in;
    x_in_pipe[0] <= x_in;
    y_in_pipe[0] <= y_in;
    hcount_in_pipe[1] <= hcount_in_pipe[0];
    vcount_in_pipe[1] <= vcount_in_pipe[0];
    x_in_pipe[1] <= x_in_pipe[0];
    y_in_pipe[1] <= y_in_pipe[0];
  end

  assign in_num_1 = ((hcount_in_pipe[1] >= x_in_pipe[1] && hcount_in_pipe[1] < (x_in_pipe[1] + NUMWIDTH)) &&
                      (vcount_in_pipe[1] >= y_in_pipe[1] && vcount_in_pipe[1] < (y_in_pipe[1] + HEIGHT)));
  assign in_num_2 = ((hcount_in_pipe[1] >= x_in_pipe[1]+NUMWIDTH && hcount_in_pipe[1] < (x_in_pipe[1] + 2*NUMWIDTH)) &&
                      (vcount_in_pipe[1] >= y_in_pipe[1] && vcount_in_pipe[1] < (y_in_pipe[1] + HEIGHT)));
  assign in_num_3 = ((hcount_in_pipe[1] >= x_in_pipe[1]+2*NUMWIDTH && hcount_in_pipe[1] < (x_in_pipe[1] + 3*NUMWIDTH)) &&
                      (vcount_in_pipe[1] >= y_in_pipe[1] && vcount_in_pipe[1] < (y_in_pipe[1] + HEIGHT)));    
  assign in_sprite = in_num_1 || in_num_2 || in_num_3;
  // BROM parameters
  logic dina;
  logic wea;
  logic ena;
  logic regcea;
  logic [1:0] dout_image_1, dout_image_2, dout_image_3;
  logic [23:0] colors_out_1, colors_out_2, colors_out_3, colors_out;

  assign dina = 0;
  assign wea = 0;
  assign ena = 1;
  assign regcea = 1;

  // Modify the module below to use your BRAMs!
  // assign red_out =    in_sprite ? 8'hF0 : 0;
  // assign green_out =  in_sprite ? 8'hF0 : 0;
  // assign blue_out =   in_sprite ? 8'hF0 : 0;
  always_comb begin
    if (in_num_1) begin
      colors_out = colors_out_1;
    end else if (in_num_2) begin
      colors_out = colors_out_2;
    end else if (in_num_3) begin
      colors_out = colors_out_3;
    end else begin
      colors_out = 8'h00;
    end
  end
  // assign colors_out = colors_out_1 + colors_out_2 + colors_out_3;

  assign red_out =    in_sprite ? colors_out[23:16] : 0; // 8'hF0 : 0;
  assign green_out =  in_sprite ? colors_out[15:8] : 0; // 8'hF0 : 0;
  assign blue_out =   in_sprite ? colors_out[7:0] : 0; // 8'hF0 : 0;
  

  //  Xilinx Single Port Read First RAM (image)
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(2'd2),                       // Specify RAM data width
    .RAM_DEPTH(10*NUMWIDTH*HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(num_image.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) num1 (
    .addra(image_addr_1),     // Address bus, width determined from RAM_DEPTH
    .dina(dina),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(wea),         // Write enable
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(regcea),   // Output register enable
    .douta(dout_image_1)      // RAM output data, width determined from RAM_WIDTH
  );

  //  Xilinx Single Port Read First RAM (palette)
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(5'd24),// Specify RAM data width
    .RAM_DEPTH(2'd2),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(word_palette.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) num1_palette (
    .addra(dout_image_1),     // Address bus, width determined from RAM_DEPTH
    .dina(dina),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(wea),         // Write enable
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(regcea),   // Output register enable
    .douta(colors_out_1)      // RAM output data, width determined from RAM_WIDTH
  );

 xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(2'd2),                       // Specify RAM data width
    .RAM_DEPTH(10*NUMWIDTH*HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(num_image.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) num2 (
    .addra(image_addr_2),     // Address bus, width determined from RAM_DEPTH
    .dina(dina),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(wea),         // Write enable
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(regcea),   // Output register enable
    .douta(dout_image_2)      // RAM output data, width determined from RAM_WIDTH
  );

  //  Xilinx Single Port Read First RAM (palette)
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(5'd24),// Specify RAM data width
    .RAM_DEPTH(2'd2),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(word_palette.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) num2_palette (
    .addra(dout_image_2),     // Address bus, width determined from RAM_DEPTH
    .dina(dina),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(wea),         // Write enable
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(regcea),   // Output register enable
    .douta(colors_out_2)      // RAM output data, width determined from RAM_WIDTH
  );

 xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(2'd2),                       // Specify RAM data width
    .RAM_DEPTH(10*NUMWIDTH*HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(num_image.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) num3 (
    .addra(image_addr_3),     // Address bus, width determined from RAM_DEPTH
    .dina(dina),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(wea),         // Write enable
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(regcea),   // Output register enable
    .douta(dout_image_3)      // RAM output data, width determined from RAM_WIDTH
  );

  //  Xilinx Single Port Read First RAM (palette)
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(5'd24),// Specify RAM data width
    .RAM_DEPTH(2'd2),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(word_palette.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) num3_palette (
    .addra(dout_image_3),     // Address bus, width determined from RAM_DEPTH
    .dina(dina),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(wea),         // Write enable
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(regcea),   // Output register enable
    .douta(colors_out_3)      // RAM output data, width determined from RAM_WIDTH
  );

endmodule






`default_nettype none
