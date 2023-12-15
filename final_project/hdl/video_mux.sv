`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)

module video_mux (
  input wire [1:0] bg_in, //regular video
  input wire [1:0] target_in, //regular video
  input wire [23:0] camera_pixel_in, //16 bits from camera 5:6:5
  input wire [7:0] camera_y_in,  //y channel of ycrcb camera conversion
  input wire [7:0] channel_in, //the channel from selection module
  input wire thresholded_pixel_in, //
  input wire [23:0] com_sprite_pixel_in,
  input wire [23:0] crosshair1_in,
  input wire [23:0] crosshair2_in,
  input wire [23:0] word_sprite_pixel_in,
  input wire [23:0] angle_number_sprite_pixel_in,
  input wire [23:0] length_number_sprite_pixel_in,

  input wire [23:0] alarm1_number_sprite_pixel_in,
  input wire [23:0] alarm2_number_sprite_pixel_in,
  input wire [23:0] alarm3_number_sprite_pixel_in,
  input wire [23:0] alarm4_number_sprite_pixel_in,

  output logic [23:0] pixel_out
);
  localparam X0 = 800;
  localparam Y0 = 600;

  /*
  00: normal camera out
  01: channel image (in grayscale)
  10: (thresholded channel image b/w)
  11: y channel with magenta mask

  upper bits:
  00: nothing:
  01: crosshair
  10: sprite on top
  11: nothing (orange test color)
  */

  logic [23:0] l_1;
  always_comb begin
    case (bg_in)
      2'b00: l_1 = camera_pixel_in;
      2'b01: l_1 = {channel_in, channel_in, channel_in};
      2'b10: l_1 = (thresholded_pixel_in !=0)?24'hFFFFFF:24'h000000;
      2'b11: l_1 = (thresholded_pixel_in != 0) ? 24'hFF77AA : {camera_y_in,camera_y_in,camera_y_in};
    endcase
  end

  logic [23:0] l_2;
  always_comb begin
    case (target_in)
      2'b00: l_2 = l_1;
      2'b01: begin
        if (crosshair1_in) begin
          l_2 = 24'h00FF00;
        end else if (crosshair2_in) begin
          l_2 = 24'h0000FF;
        end else begin
          l_2 = l_1;
        end
      end
      2'b10: l_2 = (com_sprite_pixel_in >0)?com_sprite_pixel_in:l_1;
      2'b11: l_2 = 24'hFF7700; //test color
    endcase
  end

  logic [23:0] l_3; // handle angle display
  always_comb begin
    l_3 = (word_sprite_pixel_in > 0)?word_sprite_pixel_in+l_2:l_2;
  end
  logic [23:0] l_4; // handle angle number display
  always_comb begin
    l_4 = (angle_number_sprite_pixel_in > 0)?angle_number_sprite_pixel_in+l_3:l_3;
  end
  logic [23:0] l_5; // handle length number display
  always_comb begin
    l_5 = (length_number_sprite_pixel_in > 0)?length_number_sprite_pixel_in+l_4:l_4;
  end
  // handle alarm displays
  logic [23:0] l_6; // handle length number display
  always_comb begin
    l_6 = (alarm1_number_sprite_pixel_in > 0)?alarm1_number_sprite_pixel_in+l_5:l_5;
  end
  logic [23:0] l_7; // handle length number display
  always_comb begin
    l_7 = (alarm2_number_sprite_pixel_in > 0)?alarm2_number_sprite_pixel_in+l_6:l_6;
  end
  logic [23:0] l_8; // handle length number display
  always_comb begin
    l_8 = (alarm3_number_sprite_pixel_in > 0)?alarm3_number_sprite_pixel_in+l_7:l_7;
  end
  logic [23:0] l_9; // handle length number display
  always_comb begin
    l_9 = (alarm4_number_sprite_pixel_in > 0)?alarm4_number_sprite_pixel_in+l_8:l_8;
  end

  assign pixel_out = l_9;
endmodule

`default_nettype wire
