`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk_100mhz,
  input wire [15:0] sw, //all 16 input slide switches
  input wire [3:0] btn, //all four momentary button switches
  inout wire [3:0] sd_dat, // SD data for audio
  output logic [15:0] led, //16 green output LEDs (located right above switches)
  output logic spkl, spkr, // audio outputs (speaker left, speaker right)
  output logic sd_sck, // SD card inner clock
  output logic sd_cmd, // SD commands
  output logic [2:0] rgb0, //rgb led
  output logic [2:0] rgb1, //rgb led
  output logic [2:0] hdmi_tx_p, //hdmi output signals (blue, green, red)
  output logic [2:0] hdmi_tx_n, //hdmi output signals (negatives)
  output logic hdmi_clk_p, hdmi_clk_n, //differential hdmi clock
  output logic [6:0] ss0_c,
  output logic [6:0] ss1_c,
  output logic [3:0] ss0_an,
  output logic [3:0] ss1_an,
  input wire [7:0] pmoda,
  input wire [2:0] pmodb,
  output logic pmodbclk,
  output logic pmodblock
  );
  assign led = sw; //for debugging
  //shut up those rgb LEDs (active high):
  //assign rgb1= 0;
  //assign rgb0 = 0;

  //have btnd control system reset
  logic sys_rst;
  assign sys_rst = btn[0];

  //variable for seven-segment module
  logic [6:0] ss_c;

  //Clocking Variables:
  logic clk_pixel, clk_5x, clk_25mhz; //clock lines (pixel clock and 1/2 tmds clock)
  logic locked; //locked signal (we'll leave unused but still hook it up)

  //Signals related to driving the video pipeline
  logic [10:0] hcount; //horizontal count
  logic [9:0] vcount; //vertical count
  logic vert_sync; //vertical sync signal
  logic hor_sync; //horizontal sync signal
  logic active_draw; //active draw signal
  logic new_frame; //new frame (use this to trigger center of mass calculations)
  logic [5:0] frame_count; //current frame


  //camera module: (see datasheet)
  logic cam_clk_buff, cam_clk_in; //returning camera clock
  logic vsync_buff, vsync_in; //vsync signals from camera
  logic href_buff, href_in; //href signals from camera
  logic [7:0] pixel_buff, pixel_in; //pixel lines from camera
  logic [15:0] cam_pixel; //16 bit 565 RGB image from camera
  logic valid_pixel; //indicates valid pixel from camera
  logic frame_done; //indicates completion of frame from camera

  //outputs of the recover module
  logic [15:0] pixel_data_rec; // pixel data from recovery module
  logic [10:0] hcount_rec; //hcount from recovery module
  logic [9:0] vcount_rec; //vcount from recovery module
  logic  data_valid_rec; //single-cycle (74.25 MHz) valid data from recovery module

  //output of the scaled modules
  logic [10:0] hcount_scaled; //scaled hcount for looking up camera frame pixel
  logic [9:0] vcount_scaled; //scaled vcount for looking up camera frame pixel
  logic valid_addr_scaled; //whether or not two values above are valid (or out of frame)

  //outputs of the rotation module
  logic [16:0] img_addr_rot; //result of image transformation rotation
  logic valid_addr_rot; //forward propagated valid_addr_scaled
  logic [1:0] valid_addr_rot_pipe; //pipelining variables in || with frame_buffer

  //values from the frame buffer:
  logic [15:0] frame_buff_raw; //output of frame buffer (direct)
  logic [15:0] frame_buff; //output of frame buffer OR black (based on pipeline valid)

  //remapped frame_buffer outputs with 8 bits for r, g, b
  logic [7:0] fb_red, fb_green, fb_blue;

  //output of rgb to ycrcb conversion (10 bits due to module):
  logic [9:0] y_full, cr_full, cb_full; //ycrcb conversion of full pixel
  //bottom 8 of y, cr, cb conversions:
  logic [7:0] y, cr, cb; //ycrcb conversion of full pixel

  //channel select module (select which of six color channels to mask):
  logic [2:0] channel_sel;
  logic [7:0] selected_channel; //selected channels
  //selected_channel could contain any of the six color channels depend on selection

  //threshold module (apply masking threshold):
  logic [7:0] lower_threshold;
  logic [7:0] upper_threshold;
  logic mask; //Whether or not thresholded pixel is 1 or 0

  //Center of Mass variables (tally all mask=1 pixels for a frame and calculate their center of mass)
  logic [10:0] x_com, x_com_calc; //long term x_com and output from module, resp
  logic [9:0] y_com, y_com_calc; //long term y_com and output from module, resp
  logic new_com; //used to know when to update x_com and y_com ...

  // True Center variables (detect the edge pixels that are on and calculate the true center)
  logic [10:0] x_cen, x_cen_calc;
  logic [9:0] y_cen, y_cen_calc;
  logic [31:0] mass_out, mass_out_calc;
  logic new_cen;

  // Angle variables
  logic [8:0] sun_angle, sun_angle_calc;
  logic [8:0] clock_angle, clock_angle_calc;
  logic new_angle;

  // Length variables
  logic [31:0] shadow_length, shadow_length_calc;
  logic new_length;

  //image_sprite output:
  logic [7:0] img_red, img_green, img_blue;
  logic [7:0] word_red, word_green, word_blue;
  logic [7:0] angle_number_red, angle_number_green, angle_number_blue;
  logic [7:0] length_number_red, length_number_green, length_number_blue;
  logic [7:0] alarm1_number_red, alarm1_number_green, alarm1_number_blue;
  logic [7:0] alarm2_number_red, alarm2_number_green, alarm2_number_blue;
  logic [7:0] alarm3_number_red, alarm3_number_green, alarm3_number_blue;
  logic [7:0] alarm4_number_red, alarm4_number_green, alarm4_number_blue;


  //crosshair output:
  logic [7:0] ch_red, ch_green, ch_blue;
  // crosshair 2 output:
  logic [7:0] ch_red2, ch_green2, ch_blue2;


  //used with switches for display selections
  logic [1:0] display_choice;
  logic [1:0] target_choice;

  //final processed red, gren, blue for consumption in tmds module
  logic [7:0] red, green, blue;

  logic [9:0] tmds_10b [0:2]; //output of each TMDS encoder!
  logic tmds_signal [2:0]; //output of each TMDS serializer!

  //Clock domain crossing to synchronize the camera's clock
  //to be back on the 65MHz system clock, delayed by a clock cycle.
  always_ff @(posedge clk_pixel) begin
    cam_clk_buff <= pmodb[0]; //sync camera
    cam_clk_in <= cam_clk_buff;
    vsync_buff <= pmodb[1]; //sync vsync signal
    vsync_in <= vsync_buff;
    href_buff <= pmodb[2]; //sync href signal
    href_in <= href_buff;
    pixel_buff <= pmoda; //sync pixels
    pixel_in <= pixel_buff;
  end

  //clock manager...creates 74.25 Hz and 5 times 74.25 MHz for pixel and TMDS,respectively
  hdmi_clk_wiz_720p mhdmicw (
      .clk_pixel(clk_pixel),
      .clk_tmds(clk_5x),
      .clk_25mhz(clk_25mhz),
      .reset(0),
      .locked(locked),
      .clk_ref(clk_100mhz)
  );
  // clk_wiz_10 mhdmicw (
  //   .clk_in1(clk_100mhz),
  //   .clk_out1(clk_pixel),
  //   .clk_out2(clk_5x),
  //   .clk_out3(clk_25mhz),
  //   .reset(0),
  //   .locked(locked)
  // );

  //from week 04! (make sure you include in your hdl) (same as before)
  video_sig_gen mvg(
      .clk_pixel_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_out(hcount),
      .vcount_out(vcount),
      .vs_out(vert_sync),
      .hs_out(hor_sync),
      .ad_out(active_draw),
      .nf_out(new_frame),
      .fc_out(frame_count)
  );

  // //Controls and Processes Camera information
  camera camera_m(
    .clk_pixel_in(clk_pixel),
    .pmodbclk(pmodbclk), //data lines in from camera
    .pmodblock(pmodblock), //
    //returned information from camera (raw):
    .cam_clk_in(cam_clk_in),
    .vsync_in(vsync_in),
    .href_in(href_in),
    .pixel_in(pixel_in),
    //output framed info from camera for processing:
    .pixel_out(cam_pixel), //16 bit 565 RGB pixel
    .pixel_valid_out(valid_pixel), //pixel valid signal
    .frame_done_out(frame_done) //single-cycle indicator of finished frame
  );

  // //camera and recover module are kept separate since some users may eventually
  // //want to add pre-processing on signal prior to framing into hcount/vcount-based
  // //values.

  // //The recover module takes in information from the camera
  // // and sends out:
  // // * 5-6-5 pixels of camera information
  // // * corresponding hcount and vcount for that pixel
  // // * single-cycle valid indicator
  recover recover_m (
    .valid_pixel_in(valid_pixel),
    .pixel_in(cam_pixel),
    .frame_done_in(frame_done),
    .system_clk_in(clk_pixel),
    .rst_in(sys_rst),
    .pixel_out(pixel_data_rec), //processed pixel data out
    .data_valid_out(data_valid_rec), //single-cycle valid indicator
    .hcount_out(hcount_rec), //corresponding hcount of camera pixel
    .vcount_out(vcount_rec) //corresponding vcount of camera pixel
  );

  // //two-port BRAM used to hold image from camera.
  // //because camera is producing video for 320 by 240 pixels at ~30 fps
  // //but our display is running at 720p at 60 fps, there's no hope to have the
  // //production and consumption of information be synchronized in this system
  // //instead we use a frame buffer as a go-between. The camera places pixels in at
  // //its own rate, and we pull them out for display at the 720p rate/requirement
  // //this avoids the whole sync issue. It will however result in artifacts when you
  // //introduce fast motion in front of the camera. These lines/tears in the image
  // //are the result of unsynced frame-rewriting happening while displaying. It won't
  // //matter for slow movement
  // //also note the camera produces a 320*240 image, but we display it 240 by 320
  // //(taken care of by the rotate module below).
  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(16), //each entry in this memory is 16 bits
    .RAM_DEPTH(320*240)) //there are 240*320 or 76800 entries for full frame
    frame_buffer (
    .addra(hcount_rec + 320*vcount_rec), //pixels are stored using this math
    .clka(clk_pixel),
    .wea(data_valid_rec),
    .dina(pixel_data_rec),
    .ena(1'b1),
    .regcea(1'b1),
    .rsta(sys_rst),
    .douta(), //never read from this side
    .addrb(img_addr_rot),//transformed lookup pixel
    .dinb(16'b0),
    .clkb(clk_pixel),
    .web(1'b0),
    .enb(valid_addr_rot),
    .rstb(sys_rst),
    .regceb(1'b1),
    .doutb(frame_buff_raw)
  );

  //start of the full video pipeline is here...
  //hcount, vcount, etc... are used for coming up with what to draw.

  //first question, given an hcount,vcount, should we draw/not draw something from
  //the camera. Assume the camera image is normally a 240-by-320 (width, height)
  //image in the top left of the screen. Depending on inputs you may want to scale up
  // to either 480*640 or a horizontally stretched 960*640
  // valid_addr_out indicates if hcount/vcount within range of this scaling
  //scale_in specifies how much to scale up image:
  // * 'b00: factor of 1
  // * 'b01: undefined
  // * 'b10: factor of 4 in h and 2 in v
  // * 'b11: factor of 2
  scale(
    .scale_in(2'b10),
    .hcount_in(hcount),
    .vcount_in(vcount),
    .scaled_hcount_out(hcount_scaled),
    .scaled_vcount_out(vcount_scaled),
    .valid_addr_out(valid_addr_scaled)
  );


  //Rotates and mirror-images Image to render correctly (pi/2 CCW rotate):
  // The output address should be fed right into the frame buffer for lookup
  rotate rotate_m (
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .hcount_in(hcount_scaled),
    .vcount_in(vcount_scaled),
    .valid_addr_in(valid_addr_scaled),
    .pixel_addr_out(img_addr_rot),
    .valid_addr_out(valid_addr_rot)
    );

  //the Port B of the frame buffer would exist here.
  // The output of rotate is used to grab a pixel from it
  // however the output of the memory is always *something* even when we are
  // reading at address 0...so we need to know whether or not what we're getting
  // is legit data (within the bounds of the frame buffer's render)
  // we utilize valid_addr_rot for this, but have to pipeline it by two cycles
  // in order to make sure the valid signal is lined up in time with the signal
  // it is being used to validate:

  always_ff @(posedge clk_pixel)begin
    valid_addr_rot_pipe[0] <= valid_addr_rot;
    valid_addr_rot_pipe[1] <= valid_addr_rot_pipe[0];
  end
  assign frame_buff = valid_addr_rot_pipe[1]?frame_buff_raw:16'b0;

  //split fame_buff into 3 8 bit color channels (5:6:5 adjusted accordingly)
  assign fb_red = {frame_buff[15:11],3'b0};
  assign fb_green = {frame_buff[10:5], 2'b0};
  assign fb_blue = {frame_buff[4:0],3'b0};

  //Convert RGB of full pixel to YCrCb
  //See lecture 07 for YCrCb discussion.
  //Module has a 3 cycle latency
  rgb_to_ycrcb rgbtoycrcb_m(
    .clk_in(clk_pixel),
    .r_in(fb_red),
    .g_in(fb_green),
    .b_in(fb_blue),
    .y_out(y_full),
    .cr_out(cr_full),
    .cb_out(cb_full)
  );

  //take lower 8 of full outputs
  assign y = y_full[7:0];
  assign cr = cr_full[7:0];
  assign cb = cb_full[7:0];


  assign channel_sel = sw[3:1];
  // * 3'b000: green
  // * 3'b001: red
  // * 3'b010: blue
  // * 3'b011: not valid
  // * 3'b100: y (luminance)
  // * 3'b101: Cr (Chroma Red)
  // * 3'b110: Cb (Chroma Blue)
  // * 3'b111: not valid
  //Channel Select: Takes in the full RGB and YCrCb information and
  // chooses one of them to output as an 8 bit value


  // PS1(3) & PS2(4) PIPELINING
  logic [7:0] fb_red_pipe [3:0];
  logic [7:0] fb_green_pipe [3:0];
  logic [7:0] fb_blue_pipe [3:0];

  always_ff @(posedge clk_pixel)begin
    fb_red_pipe[0] <= fb_red;
    fb_green_pipe[0] <= fb_green;
    fb_blue_pipe[0] <= fb_blue;
    for (int i=1; i<4; i = i+1)begin
      fb_red_pipe[i] <= fb_red_pipe[i-1];
      fb_green_pipe[i] <= fb_green_pipe[i-1];
      fb_blue_pipe[i] <= fb_blue_pipe[i-1];
    end
  end

  // PS3(7) & PS8(7) PIPELINING
  logic [10:0] hcount_pipe [6:0];
  logic [9:0] vcount_pipe [6:0];
  logic vert_sync_pipe [6:0];
  logic hor_sync_pipe [6:0];
  logic active_draw_pipe [6:0];
  logic new_frame_pipe [6:0];
  logic [5:0] frame_count_pipe [6:0];

  logic [7:0] ch_red_pipe [6:0];
  logic [7:0] ch_green_pipe [6:0];
  logic [7:0] ch_blue_pipe [6:0];

  logic [7:0] ch_red2_pipe [6:0];
  logic [7:0] ch_green2_pipe [6:0];
  logic [7:0] ch_blue2_pipe [6:0];


  always_ff @(posedge clk_pixel)begin
    hcount_pipe[0] <= hcount;
    vcount_pipe[0] <= vcount;
    vert_sync_pipe[0] <= vert_sync;
    hor_sync_pipe[0] <= hor_sync;
    active_draw_pipe[0] <= active_draw;
    new_frame_pipe[0] <= new_frame;
    frame_count_pipe[0] <= frame_count;
    ch_red_pipe[0] <= ch_red;
    ch_green_pipe[0] <= ch_green;
    ch_blue_pipe[0] <= ch_blue;
    ch_red2_pipe[0] <= ch_red2;
    ch_green2_pipe[0] <= ch_green2;
    ch_blue2_pipe[0] <= ch_blue2;   
    for (int i=1; i<7; i = i+1)begin
      hcount_pipe[i] <= hcount_pipe[i-1];
      vcount_pipe[i] <= vcount_pipe[i-1];
      vert_sync_pipe[i] <= vert_sync_pipe[i-1];
      hor_sync_pipe[i] <= hor_sync_pipe[i-1];
      active_draw_pipe[i] <= active_draw_pipe[i-1];
      new_frame_pipe[i] <= new_frame_pipe[i-1];
      frame_count_pipe[i] <= frame_count_pipe[i-1];
      ch_red_pipe[i] <= ch_red_pipe[i-1];
      ch_green_pipe[i] <= ch_green_pipe[i-1];
      ch_blue_pipe[i] <= ch_blue_pipe[i-1];
      ch_red2_pipe[i] <= ch_red2_pipe[i-1];
      ch_green2_pipe[i] <= ch_green2_pipe[i-1];
      ch_blue2_pipe[i] <= ch_blue2_pipe[i-1];
    end
  end

  // NO PS4(0) PIPELINING

  // PS5(1) & PS6(1) PIPELINING
  logic [7:0] selected_channel_pipe;
  logic [7:0] y_pipe;

  always_ff @(posedge clk_pixel)begin
    selected_channel_pipe <= selected_channel;
    y_pipe <= y;
  end

  // NO PS7(0) PIPELINING

  // PS9(3) PIPELINING
  logic [7:0] img_red_pipe [2:0];
  logic [7:0] img_green_pipe [2:0];
  logic [7:0] img_blue_pipe [2:0];
  
  logic [7:0] word_red_pipe [2:0];
  logic [7:0] word_green_pipe [2:0];
  logic [7:0] word_blue_pipe [2:0];
  logic [7:0] angle_number_red_pipe [2:0];
  logic [7:0] angle_number_green_pipe [2:0];
  logic [7:0] angle_number_blue_pipe [2:0];
  logic [7:0] length_number_red_pipe [2:0];
  logic [7:0] length_number_green_pipe [2:0];
  logic [7:0] length_number_blue_pipe [2:0];

  logic [7:0] alarm1_number_red_pipe [2:0];
  logic [7:0] alarm1_number_green_pipe [2:0];
  logic [7:0] alarm1_number_blue_pipe [2:0];

  logic [7:0] alarm2_number_red_pipe [2:0];
  logic [7:0] alarm2_number_green_pipe [2:0];
  logic [7:0] alarm2_number_blue_pipe [2:0];

  logic [7:0] alarm3_number_red_pipe [2:0];
  logic [7:0] alarm3_number_green_pipe [2:0];
  logic [7:0] alarm3_number_blue_pipe [2:0];

  logic [7:0] alarm4_number_red_pipe [2:0];
  logic [7:0] alarm4_number_green_pipe [2:0];
  logic [7:0] alarm4_number_blue_pipe [2:0];  

  always_ff @(posedge clk_pixel)begin
    img_red_pipe[0] <= img_red;
    img_green_pipe[0] <= img_green;
    img_blue_pipe[0] <= img_blue;
    word_red_pipe[0] <= word_red;
    word_green_pipe[0] <= word_green;
    word_blue_pipe[0] <= word_blue;  
    angle_number_red_pipe[0] <= angle_number_red;
    angle_number_green_pipe[0] <= angle_number_green;
    angle_number_blue_pipe[0] <= angle_number_blue;   
    length_number_red_pipe[0] <= length_number_red;
    length_number_green_pipe[0] <= length_number_green;
    length_number_blue_pipe[0] <= length_number_blue; 

    alarm1_number_red_pipe[0] <= alarm1_number_red;
    alarm1_number_green_pipe[0] <= alarm1_number_green;
    alarm1_number_blue_pipe[0] <= alarm1_number_blue; 

    alarm2_number_red_pipe[0] <= alarm2_number_red;
    alarm2_number_green_pipe[0] <= alarm2_number_green;
    alarm2_number_blue_pipe[0] <= alarm2_number_blue;

    alarm3_number_red_pipe[0] <= alarm3_number_red;
    alarm3_number_green_pipe[0] <= alarm3_number_green;
    alarm3_number_blue_pipe[0] <= alarm3_number_blue; 

    alarm4_number_red_pipe[0] <= alarm4_number_red;
    alarm4_number_green_pipe[0] <= alarm4_number_green;
    alarm4_number_blue_pipe[0] <= alarm4_number_blue; 

    for (int i=1; i<3; i = i + 1)begin
      img_red_pipe[i] <= img_red_pipe[i-1];
      img_green_pipe[i] <= img_green_pipe[i-1];
      img_blue_pipe[i] <= img_blue_pipe[i-1];
      word_red_pipe[i] <= word_red_pipe[i-1];
      word_green_pipe[i] <= word_green_pipe[i-1];
      word_blue_pipe[i] <= word_blue_pipe[i-1];
      angle_number_red_pipe[i] <= angle_number_red_pipe[i-1];
      angle_number_green_pipe[i] <= angle_number_green_pipe[i-1];
      angle_number_blue_pipe[i] <= angle_number_blue_pipe[i-1];
      length_number_red_pipe[i] <= length_number_red_pipe[i-1];
      length_number_green_pipe[i] <= length_number_green_pipe[i-1];
      length_number_blue_pipe[i] <= length_number_blue_pipe[i-1];

      alarm1_number_red_pipe[i] <= alarm1_number_red_pipe[i-1];
      alarm1_number_green_pipe[i] <= alarm1_number_green_pipe[i-1];
      alarm1_number_blue_pipe[i] <= alarm1_number_blue_pipe[i-1];

      alarm2_number_red_pipe[i] <= alarm2_number_red_pipe[i-1];
      alarm2_number_green_pipe[i] <= alarm2_number_green_pipe[i-1];
      alarm2_number_blue_pipe[i] <= alarm2_number_blue_pipe[i-1];

      alarm3_number_red_pipe[i] <= alarm3_number_red_pipe[i-1];
      alarm3_number_green_pipe[i] <= alarm3_number_green_pipe[i-1];
      alarm3_number_blue_pipe[i] <= alarm3_number_blue_pipe[i-1];

      alarm4_number_red_pipe[i] <= alarm4_number_red_pipe[i-1];
      alarm4_number_green_pipe[i] <= alarm4_number_green_pipe[i-1];
      alarm4_number_blue_pipe[i] <= alarm4_number_blue_pipe[i-1];

    end
  end

  channel_select(
     .sel_in(channel_sel),
     .r_in(fb_red_pipe[2]),    //TODO: needs to use pipelined signal (PS1)
     .g_in(fb_green_pipe[2]),  //TODO: needs to use pipelined signal (PS1)
     .b_in(fb_blue_pipe[2]),   //TODO: needs to use pipelined signal (PS1)
     .y_in(y),
     .cr_in(cr),
     .cb_in(cb),
     .channel_out(selected_channel)
  );

  //threshold values used to determine what value  passes:
  assign lower_threshold = {sw[11:8],4'b0};
  assign upper_threshold = {sw[15:12],4'b0};

  //Thresholder: Takes in the full selected channedl and
  //based on upper and lower bounds provides a binary mask bit
  // * 1 if selected channel is within the bounds (inclusive)
  // * 0 if selected channel is not within the bounds
  threshold(
     .clk_in(clk_pixel),
     .rst_in(sys_rst),
     .pixel_in(selected_channel),
     .lower_bound_in(lower_threshold),
     .upper_bound_in(upper_threshold),
     .mask_out(mask) //single bit if pixel within mask.
  );

  //modified version of seven segment display for showing
  // thresholds and selected channel
  // lab05_ssc mssc(.clk_in(clk_pixel),
  //                .rst_in(sys_rst),
  //                .lt_in(lower_threshold),
  //                .ut_in(upper_threshold),
  //                .channel_sel_in(channel_sel),
  //                .cat_out(ss_c),
  //                .an_out({ss0_an, ss1_an})
  // );
  //assign ss0_c = ss_c; //control upper four digit's cathodes!
  //assign ss1_c = ss_c; //same as above but for lower four digits!

  ////////////////
  // SUNDIAL CALC STUFF
  ////////////////

  //Center of Mass Calculation:
  //using x_com_calc and y_com_calc values
  //Center of Mass:
  edge_detection edge_m(
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .x_in(hcount_pipe[6]),  //TODO: needs to use pipelined signal! (PS3)
    .y_in(vcount_pipe[6]), //TODO: needs to use pipelined signal! (PS3)
    .valid_in(mask), //aka threshold
    .tabulate_in((new_frame)),
    .x_out(x_cen_calc),
    .y_out(y_cen_calc),
    .mass_out(mass_out_calc),
    .valid_out(new_cen)
  );

  center_of_mass com_m(
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .x_in(hcount_pipe[6]),  //TODO: needs to use pipelined signal! (PS3)
    .y_in(vcount_pipe[6]), //TODO: needs to use pipelined signal! (PS3)
    .valid_in(mask), //aka threshold
    .tabulate_in((new_frame)),
    .x_out(x_com_calc),
    .y_out(y_com_calc),
    .valid_out(new_com)
  );

  //grab logic for above
  //update center of mass x_com, y_com based on new_com signal
  always_ff @(posedge clk_pixel)begin
    if (sys_rst)begin
      x_com <= 0;
      y_com <= 0;
      x_cen <= 0;
      y_cen <= 0;
      mass_out <= 0;
    end 
    if(new_com)begin
      x_com <= x_com_calc;
      y_com <= y_com_calc;
    end
    if (new_cen)begin
      x_cen <= x_cen_calc;
      y_cen <= y_cen_calc;
      mass_out <= mass_out_calc;
    end
  end

  //Calculate output angle
  angle_division angle_module(
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .data_valid_in(new_frame),
    .x0_in(x_cen),
    .y0_in(y_cen),
    .x_in(x_com),
    .y_in(y_com),
    .sun_angle_out(sun_angle_calc),
    .clock_angle_out(clock_angle_calc),
    .valid_out(new_angle));

  //grab logic for above
  //update angle based on new_angle signal
  always_ff @(posedge clk_pixel)begin
    if (sys_rst)begin
      sun_angle <= 0;
      clock_angle <= 0;
    end if (new_angle)begin
      sun_angle <= sun_angle_calc;
      clock_angle <= clock_angle_calc;
    end
  end

  // Calculate shadow length
  length #(.WIDTH(5)) length_module(
    .clk_in(clk_pixel),
    .rst_in(sys_rst),
    .data_valid_in(new_frame),
    .x0_in(x_cen),
    .y0_in(y_cen),
    .x_in(x_com),
    .y_in(y_com),
    .mass_in(mass_out),
    .length_out(shadow_length_calc),
    .valid_out(new_length)    
  );

  //grab logic for above
  //update length based on new_length signal
  always_ff @(posedge clk_pixel)begin
    if (sys_rst)begin
      shadow_length <= 0;
    end if (new_length)begin
      shadow_length <= shadow_length_calc;
    end
  end

  //Create Crosshair patter on center of mass:
  //0 cycle latency
  //TODO: Should be using output of (PS3)
  always_comb begin
    ch_red   = ((vcount==y_com) || (hcount==x_com))?8'hFF:8'h00;
    ch_green = ((vcount==y_com) || (hcount==x_com))?8'hFF:8'h00;
    ch_blue  = ((vcount==y_com) || (hcount==x_com))?8'hFF:8'h00;
    ch_red2   = ((vcount==y_cen) || (hcount==x_cen))?8'hFF:8'h00;
    ch_green2 = ((vcount==y_cen) || (hcount==x_cen))?8'hFF:8'h00;
    ch_blue2  = ((vcount==y_cen) || (hcount==x_cen))?8'hFF:8'h00;
  end


  //Image Sprite (your implementation from early in Lab 5):
  //Latency 4 cycle
  image_sprite #(
    .WIDTH(256),
    .HEIGHT(256))
    com_sprite_m (
    .pixel_clk_in(clk_pixel),
    .rst_in(sys_rst),
    .hcount_in(hcount),   //TODO: needs to use pipelined signal (PS3 or None depending on choice)
    .vcount_in(vcount),   //TODO: needs to use pipelined signal (PS3 or None depending on choice)
    .x_in(x_com>128 ? x_com-128 : 0),
    .y_in(y_com>128 ? y_com-128 : 0),
    .red_out(img_red),
    .green_out(img_green),
    .blue_out(img_blue));

  //Angle label sprite
  //Latency 4 cycle
  word_sprite #(
    .WIDTH(128),
    .HEIGHT(32))
    angle_sprite (
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_in(hcount),
      .vcount_in(vcount),
      .x_in(950),
      .y_in(600),
      .red_out(word_red),
      .green_out(word_green),
      .blue_out(word_blue));

  //Angle number sprite
  angle_number_sprite #(
    .NUMWIDTH(32),
    .NUMBERS(3),
    .HEIGHT(32))
    angle_number (
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_in(hcount),
      .vcount_in(vcount),
      .x_in(1080),
      .y_in(600),
      .num_in(sun_angle),
      .red_out(angle_number_red),
      .green_out(angle_number_green),
      .blue_out(angle_number_blue));

  // ALARM DISPLAYS
    //Angle number sprite
  angle_number_sprite #(
    .NUMWIDTH(32),
    .NUMBERS(3),
    .HEIGHT(32))
    alarm1_number (
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_in(hcount),
      .vcount_in(vcount),
      .x_in(1080),
      .y_in(100),
      .num_in(alarm1),
      .red_out(alarm1_number_red),
      .green_out(alarm1_number_green),
      .blue_out(alarm1_number_blue));
        //Angle number sprite
  angle_number_sprite #(
    .NUMWIDTH(32),
    .NUMBERS(3),
    .HEIGHT(32))
    alarm2_number (
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_in(hcount),
      .vcount_in(vcount),
      .x_in(1080),
      .y_in(150),
      .num_in(alarm2),
      .red_out(alarm2_number_red),
      .green_out(alarm2_number_green),
      .blue_out(alarm2_number_blue));
        //Angle number sprite
  angle_number_sprite #(
    .NUMWIDTH(32),
    .NUMBERS(3),
    .HEIGHT(32))
    alarm3_number (
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_in(hcount),
      .vcount_in(vcount),
      .x_in(1080),
      .y_in(200),
      .num_in(alarm3),
      .red_out(alarm3_number_red),
      .green_out(alarm3_number_green),
      .blue_out(alarm3_number_blue));
        //Angle number sprite
  angle_number_sprite #(
    .NUMWIDTH(32),
    .NUMBERS(3),
    .HEIGHT(32))
    alarm4_number (
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst),
      .hcount_in(hcount),
      .vcount_in(vcount),
      .x_in(1080),
      .y_in(250),
      .num_in(alarm4),
      .red_out(alarm4_number_red),
      .green_out(alarm4_number_green),
      .blue_out(alarm4_number_blue));


  //Length number sprite
  length_number_sprite #(
    .NUMWIDTH(32),
    .NUMBERS(4),
    .HEIGHT(32))
    length_number (
      .pixel_clk_in(clk_pixel),
      .rst_in(sys_rst),
      .valid_in(new_length),
      .hcount_in(hcount),
      .vcount_in(vcount),
      .x_in(1080),
      .y_in(650),
      .num_in(shadow_length),
      .red_out(length_number_red),
      .green_out(length_number_green),
      .blue_out(length_number_blue));
  


  assign display_choice = sw[5:4];
  assign target_choice =  sw[7:6];

  ////////////////
  // AUDIO STUFF
  ////////////////

    logic reset;
    //clock_divider clocks(.clk_in(clk_5x), .reset(reset || change_audio) , .clk_25MHz(clk_25mhz));
    assign sd_dat[2:1] = 2'b11;
    logic alarm_signal;

    // sd_controller inputs
    logic rd;                   // read enable
    logic wr;                   // write enable
    logic [7:0] din;            // data to sd card
    logic [31:0] addr;          // starting address for read/write operation
    logic [31:0] end_addr;   // end address 32'd666112 32'd489984 493056
    logic [31:0] begin_addr;  

    // sd_controller outputs
    logic ready;                // high when ready for new read/write operation
    logic [7:0] dout;           // data from sd card
    logic byte_available;       // high when byte available for read
    logic ready_for_next_byte;  // high when ready for new byte to be written
    logic [4:0] current_state; 

    // Handles reading from the SD card
    sd_controller sd(
        .reset((reset || change_audio)), .clk(clk_25mhz), .cs(sd_dat[3]), .mosi(sd_cmd), 
        .miso(sd_dat[0]), .sclk(sd_sck), .ready(ready), .address(addr),
        .rd(rd), .dout(dout), .byte_available(byte_available),
        .wr(wr), .din(din), .ready_for_next_byte(ready_for_next_byte), .status(current_state)
    );

    localparam BUFFER_SIZE = 512;
    logic [9:0] write_index;
    logic buffer_a_active_write = 1'b1; //which buffer is active for reading
    logic prev_byte_available;
    logic write_flag;
    logic buffer_a_active_read;
    logic [2:0] rd_counter;
    logic read_sector_flag;


    localparam begin_addr2 = 32'd426_496;
    localparam begin_addr1 = 32'd4_555_264;
    localparam begin_addr3 = 32'd5_177_856;
    localparam begin_addr4 = 32'd4_030_976;
    localparam end_addr2 = 32'd493_056;
    localparam end_addr1 = 32'd5_163_008; //32'd4_555_264 + 32'd607_744
    localparam end_addr3 = 32'd5_427_200; //32'd5_177_856 + 32'd249_344
    localparam end_addr4 = 32'd4_523_520; //32'd4_030_976 + 32'd492_544

    //Logic for getting data from SD_card and writing it into the BRAM
    always_ff @(posedge clk_pixel) begin
        if (change_audio || reset) begin
            rd <= 0;
            addr <= begin_addr;  //start address 32'h68200
            write_index <= 0;
            prev_byte_available <= 0;
            read_sector_flag <= 1;
            rd_counter <= 0;
        end else begin
            if (alarm_signal) begin
                if (ready && !rd && (pcm_index == 0) && read_sector_flag) begin
                    // start read
                    rd <= 1;
                    read_sector_flag <= 0;
                    rd_counter <= rd_counter + 1;
                end else if (rd_counter >= 3) begin
                    rd <= 0;
                    rd_counter <= 0;
                end else if (rd) begin
                    rd_counter <= rd_counter + 1;
                end
                //Writing bytes to BRAM
                if (byte_available && !prev_byte_available) begin
                    if (write_index < BUFFER_SIZE) begin
                        write_index <= write_index + 1;
                    end
                end
                // check if 512 bytes was read
                if ((write_index == (BUFFER_SIZE))) begin
                    write_index <= 0;
                    buffer_a_active_write <= ~buffer_a_active_write; // switch buffer
                    if ((addr + 512) <= end_addr) begin
                        addr <= addr + 512; 
                        read_sector_flag <= 1;
                    end
                end
                //Repeat Audio
                if ((addr + 512) > end_addr) begin
                    rd <= 0;
                    addr <= begin_addr;  //start address 32'h68200
                    write_index <= 0;
                    prev_byte_available <= 0;
                    read_sector_flag <= 1;
                    rd_counter <= 0;
                end
                prev_byte_available <= byte_available;
            end 
        end
    end

    // Logic for reading from the BRAM to play the audio (PDM or PWM)
    logic [7:0] level_in;
    logic signed [7:0] level_in_e;
    logic tick_in;
    logic pdm_out;
    logic pwm_out;
    logic [9:0] pcm_index; 
    logic tick_48000hz;
    logic prev_tick_48000hz;

    always_ff @(posedge clk_pixel) begin
        if (reset || change_audio) begin
            buffer_a_active_read <= 0;
            pcm_index <= 0;
        end else if (tick_48000hz && !prev_tick_48000hz) begin
            if (pcm_index < BUFFER_SIZE) begin
                pcm_index <= pcm_index + 1;
            end else begin
                pcm_index <= 0;
                buffer_a_active_read <= ~buffer_a_active_read;
            end
        end
    end

    //Logic for creating clocks of PDM and PWM (Sampling Rate and Tick in)
    logic [11:0] tick_counter;
    logic [1:0] pwm_counter;
    logic pwm_step;
    logic old_pdm_clk; 
    logic pdm_signal_valid;
    logic pdm_clk;
    logic [8:0] m_clock_counter; 
    localparam PDM_COUNT_PERIOD = 32;

    always_ff @(posedge clk_pixel) begin
        if (reset || change_audio) begin
            tick_counter <= 0;
            tick_48000hz <= 0;
        end else begin
            if (tick_counter >= 745) begin //1041
                tick_counter <= 0;
                tick_48000hz <= ~tick_48000hz;
            end else begin
                tick_counter <= tick_counter + 1;
            end
            prev_tick_48000hz <= tick_48000hz;
            pwm_counter <= pwm_counter+1;
            pdm_clk <= m_clock_counter < PDM_COUNT_PERIOD/2;
            m_clock_counter <= (m_clock_counter==PDM_COUNT_PERIOD-1)?0:m_clock_counter+1;
            old_pdm_clk <= pdm_clk;
        end
    end


    //DAC and audio playing logic
    pwm my_pwm(
        .clk_in(clk_pixel),
        .rst_in(reset || change_audio),
        .level_in(vol_out),
        .tick_in(pwm_step),
        .pwm_out(pwm_out)
    );

    pdm pdm_inst(
    .clk_in(clk_pixel),
    .rst_in(reset || change_audio),
    .level_in(vol_out), 
    .tick_in(pdm_signal_valid),  
    .pdm_out(pdm_out)
    );

    logic [17:0] level_in_fir;
    fir31 z(
        .clk_in(clk_pixel),
        .rst_in(reset || change_audio),
        .ready_in(tick_48000hz && !prev_tick_48000hz),
        .x_in(level_in_e),
        .y_out(level_in_fir)
    );

    logic signed [7:0] vol_out; 
    volume_control vc(.vol_in(3'b111), .signal_in(level_in_fir[17:10]), .signal_out(vol_out));

    //RAM instantiation with writing conditions logic
    xilinx_true_dual_port_read_first_2_clock_ram #(
        .RAM_WIDTH(8),
        .RAM_DEPTH(1024)
    ) audio_buffer (
        .addra(buffer_a_active_write ? (write_index) :  (write_index + 10'd512) ),
        .clka(clk_pixel),
        .wea(write_flag),
        .dina(dout), 
        .ena(1'b1),
        .regcea(1'b1),
        .rsta(reset || change_audio),
        .douta(),
        .addrb((buffer_a_active_read) ? (pcm_index) : (pcm_index + 10'd512)),
        .dinb(8'b0),
        .clkb(clk_pixel),
        .web(1'b0),
        .enb(1'b1),
        .rstb(reset || change_audio),
        .regceb(1'b1),
        .doutb(level_in)
    );


    always_comb begin
        reset = sys_rst;
        write_flag = (byte_available && !prev_byte_available);
        level_in_e = {~level_in[7],level_in[6:0]} - 1'b1;
        pwm_step = (pwm_counter==2'b11);
        pdm_signal_valid = pdm_clk && ~old_pdm_clk;
        if (volume) begin
          spkl = (pwm_out);
          spkr = (pwm_out);
        end else begin
          spkl = 0;
          spkr = 0;
        end
        // led = alarm_angle_value;

        case (btn1_counter)
            2'b00: begin
                begin_addr = begin_addr1;
                end_addr = end_addr1; 
            end
            2'b01: begin
                begin_addr = begin_addr2;
                end_addr = end_addr2; 
            end
            2'b10: begin
                begin_addr = begin_addr3;
                end_addr = end_addr3; 
            end
            2'b11: begin
                begin_addr = begin_addr4;
                end_addr = end_addr4; 
            end
            default: begin
                begin_addr = begin_addr1;
                end_addr = end_addr1; 
            end
        endcase
        alarm_signal = 1;
    end

    logic volume;

    // set the alarm signal to high if the output angle is in range of any of the alarms
    always_comb begin
      if (sun_angle >= alarm1 && sun_angle < alarm1 + 10) begin
        volume = 1;
      end else if (sun_angle >= alarm2 && sun_angle < alarm2 + 10) begin
        volume = 1;
      end else if (sun_angle >= alarm3 && sun_angle < alarm3 + 10) begin
        volume = 1;
      end else if (sun_angle >= alarm4 && sun_angle < alarm4 + 10) begin
        volume = 1;
      end else begin
        volume = 0;
      end
    end

    logic deb_btn1, btn1_reset;
    logic [1:0] btn1_counter; 

    debouncer btn1_db(
        .clk_in(clk_pixel),
        .rst_in(reset),
        .dirty_in(btn[1]),
        .clean_out(deb_btn1)
    );

    edge_detector ed1(
        .clk_in(clk_pixel),
        .level_in(deb_btn1),
        .pulse_out(btn1_reset)
    );

    logic change_audio;

    always_ff @(posedge clk_pixel) begin
        if (reset) begin
            btn1_counter <= 2'b00;
            change_audio <= 1'b0;
        end else if (btn1_reset) begin
            btn1_counter <= btn1_counter + 1;
            if (btn1_counter >= 2'b11) begin 
                btn1_counter <= 2'b00;
            end
            change_audio <= btn1_reset;
        end else begin
            change_audio <= btn1_reset;
        end
    end

    //Display control logic 
    assign rgb0 = both_buttons_counter[0]; 
    assign rgb1 = both_buttons_counter[1];

    logic [9:0] default_angle = 10'd140; 
    logic [15:0] alarm_angle_value;
    logic [2:0] both_buttons_counter;
    logic [15:0] alarm1;
    logic [15:0] alarm2;
    logic [15:0] alarm3;
    logic [15:0] alarm4;

    display_control dc(
        .clk_in(clk_pixel),
        .sys_rst(reset),
        .btn2(btn[2]),
        .btn3(btn[3]),
        .lower_four((btn1_counter + 1'b1)),
        .btn_count(alarm_angle_value),
        .ss_c_upper(ss0_c),
        .ss_c_lower(ss1_c),
        .ss0_an_dc(ss0_an),
        .ss1_an_dc(ss1_an),
        .both_buttons_counter(both_buttons_counter),
        .alarm1(alarm1),
        .alarm2(alarm2),
        .alarm3(alarm3),
        .alarm4(alarm4)
    );

  ////////////////
  // JPEG STUFF
  ////////////////

  // logic [7:0] camera_byte;
  // logic complete_in;
  // logic [31:0] jpeg_input_data;
  // logic jpeg_input_out;
  // logic [3:0] strb_out;
  // assign camera_byte = pmoda;
  // logic [15:0] outport_width_o = 800;
  // logic [15:0] outport_height_o = 600;
  // logic [15:0] outport_pixel_x_o, outport_pixel_y_o;
  // logic [7:0] outport_pixel_r_o, outport_pixel_g_o, outport_pixel_b_o;
  // logic inport_accept_o, outport_valid_o;
  // logic idle_o;

  // assign complete_in = pmodb[1];


  // Receiver from the ArduCam
  // jpeg_receiver camera_receiver (
  //   .clk_in(clk_pixel),
  //   .rst_in(sys_rst),
  //   .data_valid_in(cam_clk_in),
  //   .complete_in(complete_in),
  //   .byte_in(camera_byte),
  //   .data_out(jpeg_input_data),
  //   .data_valid_out(jpeg_input_out),
  //   .strb_out(strb_out)
  // );

  // jpeg_core #(.SUPPORT_WRITABLE_DHT(0)) jpeg_core_module (
  //   // Inputs
  //   .clk_i(clk_pixel),
  //   .rst_i(sys_rst),
  //   .inport_valid_i(jpeg_input_out),
  //   .inport_data_i(jpeg_input_data),    // 32 bits
  //   .inport_strb_i(strb_out),    // 4 bits
  //   .inport_last_i(0),
  //   .outport_accept_i(1),

  //   // Outputs
  //   .inport_accept_o(inport_accept_o),
  //   .outport_valid_o(outport_valid_o),
  //   .outport_width_o(outport_width_o),      // 16 bits
  //   .outport_height_o(outport_height_o),     // 16 bits
  //   .outport_pixel_x_o(outport_pixel_x_o),    // 16 bits
  //   .outport_pixel_y_o(outport_pixel_y_o),    // 16 bits
  //   .outport_pixel_r_o(outport_pixel_r_o),    // 8 bits
  //   .outport_pixel_g_o(outport_pixel_g_o),    // 8 bits
  //   .outport_pixel_b_o(outport_pixel_b_o),    // 8 bits f
  //   .idle_o(idle_o)
  // );

  // jpeg_recovery frame_buffer (

  //   .x_pixel_in(outport_pixel_x_o),
  //   .y_pixel_in(outport_pixel_y_o),
  //   .r_in(outport_pixel_r_o),
  //   .g_in(outport_pixel_g_o),
  //   .b_in(outport_pixel_b_o),
  //   .clka(clk_pixel),
  //   .wea(outport_valid_o),
  //   .ena(1'b1),
  //   .regcea(1'b1),
  //   .rsta(sys_rst),
  //   .addrb(img_addr_rot),//transformed lookup pixel
  //   .dinb(16'b0),
  //   .clkb(clk_pixel),
  //   .web(1'b0),
  //   .enb(valid_addr_rot),
  //   .rstb(sys_rst),
  //   .regceb(1'b1),
  //   .pixel_out(frame_buff_raw)
  // );

  //choose what to display from the camera:
  // * 'b00:  normal camera out
  // * 'b01:  selected channel image in grayscale
  // * 'b10:  masked pixel (all on if 1, all off if 0)
  // * 'b11:  chroma channel with mask overtop as magenta
  //
  //then choose what to use with center of mass:
  // * 'b00: nothing
  // * 'b01: crosshair
  // * 'b10: sprite on top
  // * 'b11: nothing

  video_mux (
    .bg_in(display_choice), //choose background
    .target_in(target_choice), //choose target
    .camera_pixel_in({fb_red_pipe[3], fb_green_pipe[3], fb_blue_pipe[3]}), //TODO: needs (PS2)
    .camera_y_in(y_pipe), //luminance TODO: needs (PS6)
    .channel_in(selected_channel_pipe), //current channel being drawn TODO: needs (PS5)
    .thresholded_pixel_in(mask), //one bit mask signal TODO: needs (PS4)
    .crosshair1_in({ch_red_pipe[6], ch_green_pipe[6], ch_blue_pipe[6]}), //TODO: needs (PS8)
    .crosshair2_in({ch_red2_pipe[6], ch_green2_pipe[6], ch_blue2_pipe[6]}), //TODO: needs (PS8)
    .com_sprite_pixel_in({img_red_pipe[2], img_green_pipe[2], img_blue_pipe[2]}), //TODO: needs (PS9) maybe?
    .word_sprite_pixel_in({word_red_pipe[2], word_green_pipe[2], word_blue_pipe[2]}),
    .angle_number_sprite_pixel_in({angle_number_red_pipe[2], angle_number_green_pipe[2], angle_number_blue_pipe[2]}),
    .length_number_sprite_pixel_in({length_number_red_pipe[2], length_number_green_pipe[2], length_number_blue_pipe[2]}),

    .alarm1_number_sprite_pixel_in({alarm1_number_red_pipe[2], alarm1_number_green_pipe[2], alarm1_number_blue_pipe[2]}),
    .alarm2_number_sprite_pixel_in({alarm2_number_red_pipe[2], alarm2_number_green_pipe[2], alarm2_number_blue_pipe[2]}),
    .alarm3_number_sprite_pixel_in({alarm3_number_red_pipe[2], alarm3_number_green_pipe[2], alarm3_number_blue_pipe[2]}),
    .alarm4_number_sprite_pixel_in({alarm4_number_red_pipe[2], alarm4_number_green_pipe[2], alarm4_number_blue_pipe[2]}),

    .pixel_out({red,green,blue}) //output to tmds
  );

  //TODO: Appropriate signals below need to use outputs from PS7

  //three tmds_encoders (blue, green, red)
  tmds_encoder tmds_red(
	.clk_in(clk_pixel),
  .rst_in(sys_rst),
	.data_in(red),
  .control_in(2'b0),
	.ve_in(active_draw_pipe[6]),
	.tmds_out(tmds_10b[2]));

  tmds_encoder tmds_green(
	.clk_in(clk_pixel),
  .rst_in(sys_rst),
	.data_in(green),
  .control_in(2'b0),
	.ve_in(active_draw_pipe[6]),
	.tmds_out(tmds_10b[1]));

  tmds_encoder tmds_blue(
	.clk_in(clk_pixel),
  .rst_in(sys_rst),
	.data_in(blue),
  .control_in({vert_sync_pipe[6],hor_sync_pipe[6]}),
	.ve_in(active_draw_pipe[6]),
	.tmds_out(tmds_10b[0]));

  //four tmds_serializers (blue, green, red, and clock)
  tmds_serializer red_ser(
    .clk_pixel_in(clk_pixel),
    .clk_5x_in(clk_5x),
    .rst_in(sys_rst),
    .tmds_in(tmds_10b[2]),
    .tmds_out(tmds_signal[2]));

  tmds_serializer green_ser(
    .clk_pixel_in(clk_pixel),
    .clk_5x_in(clk_5x),
    .rst_in(sys_rst),
    .tmds_in(tmds_10b[1]),
    .tmds_out(tmds_signal[1]));

  tmds_serializer blue_ser(
    .clk_pixel_in(clk_pixel),
    .clk_5x_in(clk_5x),
    .rst_in(sys_rst),
    .tmds_in(tmds_10b[0]),
    .tmds_out(tmds_signal[0]));

  //output buffers generating differential signal:
  OBUFDS OBUFDS_blue (.I(tmds_signal[0]), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
  OBUFDS OBUFDS_green(.I(tmds_signal[1]), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
  OBUFDS OBUFDS_red  (.I(tmds_signal[2]), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));
  OBUFDS OBUFDS_clock(.I(clk_pixel), .O(hdmi_clk_p), .OB(hdmi_clk_n));

endmodule // top_level


`default_nettype wire
