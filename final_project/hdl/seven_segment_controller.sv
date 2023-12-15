`default_nettype none

module seven_segment_controller #(parameter COUNT_TO = 100000)
				(input wire         clk_in,
				 input wire         rst_in,
				 input wire [31:0]  val_in,
				 output logic[6:0]   cat_out,
				 output logic[7:0]   an_out
	);

  logic [7:0]	segment_state;
	logic [31:0] segment_counter;
	logic [3:0]	routed_vals;
	logic [6:0]	led_out;
  logic [3:0] hundreds;   
  logic [3:0] tens;    
  logic [3:0] ones;
  logic [31:0] modified_val_in;

  digit_extractor de(.a(val_in), .hundreds(hundreds), .tens(tens), .ones(ones));
  
  assign modified_val_in = ones + tens*16 + hundreds*16*16;

	/* TODO: wire up routed_vals (-> x_in) with your input, val_in
	 * Note that x_in is a 4 bit input, and val_in is 32 bits wide
	 * Adjust accordingly, based on what you know re. which digits
	 * are displayed when...
	 */

    always_comb begin
        case(segment_state)
        8'b1: routed_vals = modified_val_in[3:0];
        8'b10: routed_vals = modified_val_in[7:4];
        8'b100: routed_vals = modified_val_in[11:8];
        8'b1000: routed_vals = modified_val_in[15:12];
        8'b10000: routed_vals = modified_val_in[19:16];
        8'b100000: routed_vals = modified_val_in[23:20];
        8'b01000000: routed_vals = modified_val_in[27:24];
        8'b10000000: routed_vals = modified_val_in[31:28];
        default: routed_vals = 4'b0;
        endcase
  end

    bto7s mbto7s (.x_in(routed_vals), .s_out(led_out));
  assign cat_out = ~led_out; //<--note this inversion is needed
  assign an_out = ~segment_state; //note this inversion is needed

	always_ff @(posedge clk_in)begin
		if (rst_in)begin
			segment_state <= 8'b0000_0001;
			segment_counter <= 32'b0;
		end else begin
			if (segment_counter == COUNT_TO) begin
				segment_counter <= 32'd0;
				segment_state <= {segment_state[6:0],segment_state[7]};
			end else begin
				segment_counter <= segment_counter +1;
			end
		end
	end
endmodule // seven_segment_controller


module bto7s(
        input wire [3:0]   x_in,
        output logic [6:0] s_out
        );

        // your code here!
        logic [15:0] num;
        assign num[0] = ~x_in[3] && ~x_in[2] && ~x_in[1] && ~x_in[0];
        assign num[1] = ~x_in[3] && ~x_in[2] && ~x_in[1] && x_in[0];
        assign num[2] = x_in == 4'd2;
        assign num[3] = x_in == 4'd3;
        assign num[4] = x_in == 4'd4;
        assign num[5] = x_in == 4'd5;
        assign num[6] = x_in == 4'd6;
        assign num[7] = x_in == 4'd7;
        assign num[8] = x_in == 4'd8;
        assign num[9] = x_in == 4'd9;
        assign num[10] = x_in == 4'd10;  
        assign num[11] = x_in == 4'd11; 
        assign num[12] = x_in == 4'd12;  
        assign num[13] = x_in == 4'd13;  
        assign num[14] = x_in == 4'd14;  
        assign num[15] = x_in == 4'd15;

        assign s_out[0] = num[0] || num[2] || num[3] || num[5] || num[6] || num[7] || num[8] || num[9] || num[10] || num[12] || num[14] || num[15];
        assign s_out[1] = num[0] || num[1] || num[2] || num[3] || num[4] || num[7] || num[8] || num[9] || num[10] || num[13];
        assign s_out[2] = num[0] || num[1] || num[3] || num[4] || num[5] || num[6] || num[7] || num[8] || num[9] || num[10] || num[11] || num[13];
        assign s_out[3] = num[0] || num[2] || num[3] || num[5] || num[6] || num[8] || num[9] || num[11] || num[12] || num[13] || num[14];
        assign s_out[4] = num[0] || num[2] || num[6] || num[8] || num[10] || num[11] || num[12] || num[13] || num[14] || num[15];
        assign s_out[5] = num[0] || num[4] || num[5] || num[6] || num[8] || num[9] || num[10] || num[11] || num[12] || num[14] || num[15]; 
        assign s_out[6] = num[2] || num[3] || num[4] || num[5] || num[6] || num[8] || num[9] || num[10] || num[11] || num[13] || num[14] || num[15];
       
endmodule

module digit_extractor (
    input wire [31:0] a,  
    output logic [3:0] hundreds,   
    output logic [3:0] tens,       
    output logic [3:0] ones       
);
    logic [31:0] b;
    logic [31:0] c;

    always_comb begin
        if (a >= 300) begin
            hundreds = 3;
        end else if (a >= 200) begin
            hundreds = 2;
        end else if (a >= 100) begin
            hundreds = 1;
        end else begin
            hundreds = 0;
        end

        b = a - hundreds * 100;
        if (b >= 90) begin
            tens = 9;
        end else if (b >= 80 && b < 90) begin
            tens = 8;
        end else if (b >= 70 && b < 80) begin
            tens = 7;
        end else if (b >= 60 && b < 70) begin
            tens = 6;
        end else if (b >= 50 && b < 60) begin
            tens = 5;
        end else if (b >= 40 && b < 50) begin
            tens = 4;
        end else if (b >= 30 && b < 40) begin
            tens = 3;
        end else if (b >= 20 && b < 30) begin
            tens = 2;
        end else if (b >= 10 && b < 20) begin
            tens = 1;
        end else begin
            tens = 0;
        end

        c = b - tens * 10;
        ones = c;
    end 
endmodule

`default_nettype wire
