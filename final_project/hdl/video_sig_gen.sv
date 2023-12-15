module video_sig_gen
#(
  parameter ACTIVE_H_PIXELS = 1280,
  parameter H_FRONT_PORCH = 110,
  parameter H_SYNC_WIDTH = 40,
  parameter H_BACK_PORCH = 220,
  parameter ACTIVE_LINES = 720,
  parameter V_FRONT_PORCH = 5,
  parameter V_SYNC_WIDTH = 20,
  parameter V_BACK_PORCH = 5)
(
  input wire clk_pixel_in,
  input wire rst_in,
  output logic [$clog2(TOTAL_PIXELS)-1:0] hcount_out, //The current horizontal count on the screen
  output logic [$clog2(TOTAL_LINES)-1:0] vcount_out, //The current vertical count on the screen
  output logic vs_out, //The vertical sync signal, high when in the vertical sync region
  output logic hs_out, //The horizontal sync signal, high when in the horizontal sync region
  output logic ad_out, //The active drawing indicator, low when in blanking or sync period, high when actively drawing.
  output logic nf_out, //Single cycle indicator of a new frame
  output logic [5:0] fc_out); //Current frame with a rolling second-long window (ranges from 0 to 59 inclusive)
 
  localparam TOTAL_PIXELS = (ACTIVE_H_PIXELS+H_FRONT_PORCH+H_SYNC_WIDTH+H_BACK_PORCH);
  localparam TOTAL_LINES = (ACTIVE_LINES+V_FRONT_PORCH+V_SYNC_WIDTH+V_BACK_PORCH);

  typedef enum {QUIET=0, ACTIVE=1, HSYNC=2, VSYNC=3, HV_SYNC=4,RESET=5} sig_state;
  sig_state state;

  always_ff @(posedge clk_pixel_in) begin
    if (rst_in) begin // reset the system to the top left corner of the frame 
      state <= RESET;
      hcount_out<=0;
      vcount_out<=0;
      vs_out<=0;
      hs_out<=0;
      ad_out<=1;
      nf_out<=0;
      fc_out<=0;
    end else begin
      if (hcount_out == ACTIVE_H_PIXELS && vcount_out == ACTIVE_LINES) begin
        nf_out <= 1;
        if (fc_out == 59) begin
          fc_out <= 0;
        end else begin
          fc_out <= fc_out + 1;
        end
      end else begin
        nf_out <= 0;
      end
      if (hcount_out==TOTAL_PIXELS-1) begin // always incrememnt pixel, conditionally increment line
        hcount_out <= 0;
        if (vcount_out==TOTAL_LINES-1) begin
          vcount_out <= 0;
        end else begin
          vcount_out <= vcount_out + 1;
        end
      end else begin
        hcount_out <= hcount_out + 1;
      end
      case(state)
        QUIET: begin
          vs_out <= 0;
          hs_out <= 0;
          ad_out <= 0;
          // quiet goes to hsync, active drawing, vsync, or itself
          if (hcount_out == ACTIVE_H_PIXELS+H_FRONT_PORCH-1) begin
            state <= HSYNC;
          end else if (hcount_out == TOTAL_PIXELS-1 && vcount_out == ACTIVE_LINES+V_FRONT_PORCH-1) begin
            state <= VSYNC;
          end else if (hcount_out == TOTAL_PIXELS-1 && (vcount_out < ACTIVE_LINES-1 || vcount_out == TOTAL_LINES-1)) begin
            //ad_out<=1;
            state <= ACTIVE;
          end else begin
            state <= QUIET;
          end
        end
        ACTIVE: begin
          vs_out <= 0;
          hs_out <= 0;
          ad_out <= 1;
          // active drawing transitions to horizontal front porch
          if (hcount_out == ACTIVE_H_PIXELS-1) begin
            //ad_out<=0;
            state <= QUIET;
          end else begin
            state <= ACTIVE;
          end
        end
        HSYNC: begin
          vs_out <= 0;
          hs_out <= 1;
          ad_out <= 0;
          // horizontal sync transitions to horizontal back porch
          if (hcount_out == TOTAL_PIXELS-H_BACK_PORCH-1) begin
            state <= QUIET;
          end else begin
            state <= HSYNC;
          end
        end
        VSYNC: begin
          vs_out <= 1;
          hs_out <= 0;
          ad_out <= 0;
          // vertical sync transitions to vsync+hsync or vertical back porch
          if (hcount_out == TOTAL_PIXELS-1 && vcount_out == TOTAL_LINES-V_BACK_PORCH-1) begin
            state <= QUIET;
          end else if (hcount_out == ACTIVE_H_PIXELS+H_FRONT_PORCH-1) begin
            state <= HV_SYNC;
          end else begin
            state <= VSYNC;
          end
        end
        HV_SYNC: begin
          vs_out <= 1;
          hs_out <= 1;
          ad_out <= 0;
          // vsync+hsync transitions back to vertical sync
          if (hcount_out == TOTAL_PIXELS-H_BACK_PORCH-1) begin
            state <= VSYNC;
          end else begin
            state <= HV_SYNC;
          end
        end
      RESET: begin
        vs_out <= 0;
        hs_out <= 0;
        ad_out <= 0;    
        hcount_out <= 0;
        vcount_out <= 0;
        nf_out <= 0;
        fc_out <= 0;      
        state <= ACTIVE; 
      end
      default: state <= RESET;
      endcase
    end
  end

endmodule