module jpeg_recovery
#(
  parameter ACTIVE_H_PIXELS = 320,
  parameter ACTIVE_LINES = 240)
  (
  input wire clka,
  input wire clkb,
  input wire wea,
  input wire ena,
  input wire regcea,
  input wire rsta,
  input wire addrb,

  input wire [15:0] x_pixel_in, //The current horizontal count on the screen
  input wire [15:0] y_pixel_in, //The current vertical count on the screen
  input wire [7:0] r_in,
  input wire [7:0] g_in,
  input wire [7:0] b_in,
  input wire dinb,
  input wire web,
  input wire enb,
  input wire rstb,
  input wire regceb,
  output logic [15:0] pixel_out);


    logic [5:0] rgb_reduced; // save very little RGB information from the incoming pixel
    logic [5:0] rgb_reduced_out; // output from the RAM
    assign rgb_reduced[1:0] = b_in >> 6;
    assign rgb_reduced[3:2] = g_in >> 6;
    assign rgb_reduced[5:4] = r_in >> 6;

    assign pixel_out[4:0] = rgb_reduced_out << 2;
    assign pixel_out[10:5] = rgb_reduced_out << 3;
    assign pixel_out[15:11] = rgb_reduced_out << 2;

    xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(6), //each entry in this memory is 6 bits
    .RAM_DEPTH(ACTIVE_H_PIXELS*ACTIVE_LINES)) //there are 240*320 or 76800 entries for full frame
    frame_buffer (
    .addra(x_pixel_in + ACTIVE_LINES*y_pixel_in), //pixels are stored using this math
    .clka(clka),
    .wea(wea),
    .dina(rgb_reduced),
    .ena(ena),
    .regcea(regcea),
    .rsta(rsta),
    .douta(), //never read from this side
    .addrb(addrb),//transformed lookup pixel
    .dinb(dinb),
    .clkb(clkb),
    .web(web),
    .enb(enb),
    .rstb(rstb),
    .regceb(regceb),
    .doutb(rgb_reduced_out)
    );

endmodule