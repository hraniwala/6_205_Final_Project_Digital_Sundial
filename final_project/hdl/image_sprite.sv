`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */

module image_sprite #(
  parameter WIDTH=256, HEIGHT=256) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  output logic [7:0] red_out,
  output logic [7:0] green_out,
  output logic [7:0] blue_out
  );

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;

  logic [10:0] hcount_in_pipe [3:0];
  logic [9:0] vcount_in_pipe [3:0];
  logic [10:0] x_in_pipe [3:0];
  logic [9:0] y_in_pipe [3:0];

  always_ff @(posedge pixel_clk_in) begin
    hcount_in_pipe[0] <= hcount_in;
    vcount_in_pipe[0] <= vcount_in;
    x_in_pipe[0] <= x_in;
    y_in_pipe[0] <= y_in;
    for (int i = 1; i < 4; i = i + 1) begin
      hcount_in_pipe[i] <= hcount_in_pipe[i-1];
      vcount_in_pipe[i] <= vcount_in_pipe[i-1];
      x_in_pipe[i] <= x_in_pipe[i-1];
      y_in_pipe[i] <= y_in_pipe[i-1];
    end
  end

  assign in_sprite = ((hcount_in_pipe[3] >= x_in_pipe[3] && hcount_in_pipe[3] < (x_in_pipe[3] + WIDTH)) &&
                      (vcount_in_pipe[3] >= y_in_pipe[3] && vcount_in_pipe[3] < (y_in_pipe[3] + HEIGHT)));

  // Modify the module below to use your BRAMs!
  // assign red_out =    in_sprite ? 8'hF0 : 0;
  // assign green_out =  in_sprite ? 8'hF0 : 0;
  // assign blue_out =   in_sprite ? 8'hF0 : 0;
  assign red_out =    in_sprite ? colors_out[23:16] : 0; // 8'hF0 : 0;
  assign green_out =  in_sprite ? colors_out[15:8] : 0; // 8'hF0 : 0;
  assign blue_out =   in_sprite ? colors_out[7:0] : 0; // 8'hF0 : 0;

  // BROM parameters
  logic dina;
  logic wea;
  logic ena;
  logic regcea;
  logic [7:0] dout_image;
  logic [23:0] colors_out;

  assign dina = 0;
  assign wea = 0;
  assign ena = 1;
  assign regcea = 1;
  

  //  Xilinx Single Port Read First RAM (image)
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(4'd8),                       // Specify RAM data width
    .RAM_DEPTH(WIDTH*HEIGHT),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(image.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) image (
    .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
    .dina(dina),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(wea),         // Write enable
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(regcea),   // Output register enable
    .douta(dout_image)      // RAM output data, width determined from RAM_WIDTH
  );

  //  Xilinx Single Port Read First RAM (palette)
  xilinx_single_port_ram_read_first #(
    .RAM_WIDTH(25'b1_0000_0000_0000_0000),                       // Specify RAM data width
    .RAM_DEPTH(9'd256),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    .INIT_FILE(`FPATH(palette.mem))          // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) palette (
    .addra(dout_image),     // Address bus, width determined from RAM_DEPTH
    .dina(dina),       // RAM input data, width determined from RAM_WIDTH
    .clka(pixel_clk_in),       // Clock
    .wea(wea),         // Write enable
    .ena(ena),         // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rst_in),       // Output reset (does not affect memory contents)
    .regcea(regcea),   // Output register enable
    .douta({colors_out})      // RAM output data, width determined from RAM_WIDTH
  );

endmodule






`default_nettype none
