module Angles_Lookup(
    input wire [63:0] ratio,
    output logic [7:0] sun_angle_val,
    output logic [7:0] clock_angle_val);
    logic [7:0] lookup_val;

    always_comb begin
        case (lookup_val)
            8'b00000000: begin
                sun_angle_val = 8'b00000000;
                clock_angle_val = 8'b00000000;
            end
            8'b00000001: begin
                sun_angle_val = 8'b00000001;
                clock_angle_val = 8'b00000001;
            end
            8'b00000010: begin
                sun_angle_val = 8'b00000010;
                clock_angle_val = 8'b00000010;
            end
            8'b00000011: begin
                sun_angle_val = 8'b00000011;
                clock_angle_val = 8'b00000011;
            end
            8'b00000100: begin
                sun_angle_val = 8'b00000100;
                clock_angle_val = 8'b00000100;
            end
            8'b00000101: begin
                sun_angle_val = 8'b00000101;
                clock_angle_val = 8'b00000101;
            end
            8'b00000110: begin
                sun_angle_val = 8'b00000110;
                clock_angle_val = 8'b00000110;
            end
            8'b00000111: begin
                sun_angle_val = 8'b00000111;
                clock_angle_val = 8'b00000111;
            end
            8'b00001000: begin
                sun_angle_val = 8'b00001000;
                clock_angle_val = 8'b00001000;
            end
            8'b00001001: begin
                sun_angle_val = 8'b00001001;
                clock_angle_val = 8'b00001001;
            end
            8'b00001010: begin
                sun_angle_val = 8'b00001010;
                clock_angle_val = 8'b00001010;
            end
            8'b00001011: begin
                sun_angle_val = 8'b00001011;
                clock_angle_val = 8'b00001011;
            end
            8'b00001100: begin
                sun_angle_val = 8'b00001100;
                clock_angle_val = 8'b00001100;
            end
            8'b00001101: begin
                sun_angle_val = 8'b00001101;
                clock_angle_val = 8'b00001101;
            end
            8'b00001110: begin
                sun_angle_val = 8'b00001110;
                clock_angle_val = 8'b00001110;
            end
            8'b00001111: begin
                sun_angle_val = 8'b00001111;
                clock_angle_val = 8'b00001111;
            end
            8'b00010000: begin
                sun_angle_val = 8'b00010000;
                clock_angle_val = 8'b00010000;
            end
            8'b00010001: begin
                sun_angle_val = 8'b00010001;
                clock_angle_val = 8'b00010001;
            end
            8'b00010010: begin
                sun_angle_val = 8'b00010010;
                clock_angle_val = 8'b00010010;
            end
            8'b00010011: begin
                sun_angle_val = 8'b00010011;
                clock_angle_val = 8'b00010011;
            end
            8'b00010100: begin
                sun_angle_val = 8'b00010100;
                clock_angle_val = 8'b00010100;
            end
            8'b00010101: begin
                sun_angle_val = 8'b00010101;
                clock_angle_val = 8'b00010101;
            end
            8'b00010110: begin
                sun_angle_val = 8'b00010110;
                clock_angle_val = 8'b00010110;
            end
            8'b00010111: begin
                sun_angle_val = 8'b00010111;
                clock_angle_val = 8'b00010111;
            end
            8'b00011000: begin
                sun_angle_val = 8'b00011000;
                clock_angle_val = 8'b00011000;
            end
            8'b00011001: begin
                sun_angle_val = 8'b00011001;
                clock_angle_val = 8'b00011001;
            end
            8'b00011010: begin
                sun_angle_val = 8'b00011010;
                clock_angle_val = 8'b00011010;
            end
            8'b00011011: begin
                sun_angle_val = 8'b00011011;
                clock_angle_val = 8'b00011011;
            end
            8'b00011100: begin
                sun_angle_val = 8'b00011100;
                clock_angle_val = 8'b00011100;
            end
            8'b00011101: begin
                sun_angle_val = 8'b00011101;
                clock_angle_val = 8'b00011101;
            end
            8'b00011110: begin
                sun_angle_val = 8'b00011110;
                clock_angle_val = 8'b00011110;
            end
            8'b00011111: begin
                sun_angle_val = 8'b00011111;
                clock_angle_val = 8'b00011111;
            end
            8'b00100000: begin
                sun_angle_val = 8'b00100000;
                clock_angle_val = 8'b00100000;
            end
            8'b00100001: begin
                sun_angle_val = 8'b00100001;
                clock_angle_val = 8'b00100001;
            end
            8'b00100010: begin
                sun_angle_val = 8'b00100010;
                clock_angle_val = 8'b00100010;
            end
            8'b00100011: begin
                sun_angle_val = 8'b00100011;
                clock_angle_val = 8'b00100011;
            end
            8'b00100100: begin
                sun_angle_val = 8'b00100100;
                clock_angle_val = 8'b00100100;
            end
            8'b00100101: begin
                sun_angle_val = 8'b00100101;
                clock_angle_val = 8'b00100101;
            end
            8'b00100110: begin
                sun_angle_val = 8'b00100110;
                clock_angle_val = 8'b00100110;
            end
            8'b00100111: begin
                sun_angle_val = 8'b00100111;
                clock_angle_val = 8'b00100111;
            end
            8'b00101000: begin
                sun_angle_val = 8'b00101000;
                clock_angle_val = 8'b00101000;
            end
            8'b00101001: begin
                sun_angle_val = 8'b00101001;
                clock_angle_val = 8'b00101001;
            end
            8'b00101010: begin
                sun_angle_val = 8'b00101010;
                clock_angle_val = 8'b00101010;
            end
            8'b00101011: begin
                sun_angle_val = 8'b00101011;
                clock_angle_val = 8'b00101011;
            end
            8'b00101100: begin
                sun_angle_val = 8'b00101100;
                clock_angle_val = 8'b00101100;
            end
            8'b00101101: begin
                sun_angle_val = 8'b00101101;
                clock_angle_val = 8'b00101101;
            end
            default: begin
                sun_angle_val = 8'b00000000;
                clock_angle_val = 8'b00000000;
            end
        endcase
    end

    always_comb begin
        if ((ratio > 64'd0) && (ratio <= 64'd2)) begin
                lookup_val = 8'b00000000;
        end else if ((ratio > 64'd0) && (ratio <= 64'd2)) begin
                lookup_val = 8'b00000000;
        end else if ((ratio > 64'd2) && (ratio <= 64'd3)) begin
                lookup_val = 8'b00000001;
        end else if ((ratio > 64'd3) && (ratio <= 64'd5)) begin
                lookup_val = 8'b00000010;
        end else if ((ratio > 64'd5) && (ratio <= 64'd7)) begin
                lookup_val = 8'b00000011;
        end else if ((ratio > 64'd7) && (ratio <= 64'd9)) begin
                lookup_val = 8'b00000100;
        end else if ((ratio > 64'd9) && (ratio <= 64'd11)) begin
                lookup_val = 8'b00000101;
        end else if ((ratio > 64'd11) && (ratio <= 64'd12)) begin
                lookup_val = 8'b00000110;
        end else if ((ratio > 64'd12) && (ratio <= 64'd14)) begin
                lookup_val = 8'b00000111;
        end else if ((ratio > 64'd14) && (ratio <= 64'd16)) begin
                lookup_val = 8'b00001000;
        end else if ((ratio > 64'd16) && (ratio <= 64'd18)) begin
                lookup_val = 8'b00001001;
        end else if ((ratio > 64'd18) && (ratio <= 64'd19)) begin
                lookup_val = 8'b00001010;
        end else if ((ratio > 64'd19) && (ratio <= 64'd21)) begin
                lookup_val = 8'b00001011;
        end else if ((ratio > 64'd21) && (ratio <= 64'd23)) begin
                lookup_val = 8'b00001100;
        end else if ((ratio > 64'd23) && (ratio <= 64'd25)) begin
                lookup_val = 8'b00001101;
        end else if ((ratio > 64'd25) && (ratio <= 64'd27)) begin
                lookup_val = 8'b00001110;
        end else if ((ratio > 64'd27) && (ratio <= 64'd29)) begin
                lookup_val = 8'b00001111;
        end else if ((ratio > 64'd29) && (ratio <= 64'd31)) begin
                lookup_val = 8'b00010000;
        end else if ((ratio > 64'd31) && (ratio <= 64'd32)) begin
                lookup_val = 8'b00010001;
        end else if ((ratio > 64'd32) && (ratio <= 64'd34)) begin
                lookup_val = 8'b00010010;
        end else if ((ratio > 64'd34) && (ratio <= 64'd36)) begin
                lookup_val = 8'b00010011;
        end else if ((ratio > 64'd36) && (ratio <= 64'd38)) begin
                lookup_val = 8'b00010100;
        end else if ((ratio > 64'd38) && (ratio <= 64'd40)) begin
                lookup_val = 8'b00010101;
        end else if ((ratio > 64'd40) && (ratio <= 64'd42)) begin
                lookup_val = 8'b00010110;
        end else if ((ratio > 64'd42) && (ratio <= 64'd45)) begin
                lookup_val = 8'b00010111;
        end else if ((ratio > 64'd45) && (ratio <= 64'd47)) begin
                lookup_val = 8'b00011000;
        end else if ((ratio > 64'd47) && (ratio <= 64'd49)) begin
                lookup_val = 8'b00011001;
        end else if ((ratio > 64'd49) && (ratio <= 64'd51)) begin
                lookup_val = 8'b00011010;
        end else if ((ratio > 64'd51) && (ratio <= 64'd53)) begin
                lookup_val = 8'b00011011;
        end else if ((ratio > 64'd53) && (ratio <= 64'd55)) begin
                lookup_val = 8'b00011100;
        end else if ((ratio > 64'd55) && (ratio <= 64'd58)) begin
                lookup_val = 8'b00011101;
        end else if ((ratio > 64'd58) && (ratio <= 64'd60)) begin
                lookup_val = 8'b00011110;
        end else if ((ratio > 64'd60) && (ratio <= 64'd62)) begin
                lookup_val = 8'b00011111;
        end else if ((ratio > 64'd62) && (ratio <= 64'd65)) begin
                lookup_val = 8'b00100000;
        end else if ((ratio > 64'd65) && (ratio <= 64'd67)) begin
                lookup_val = 8'b00100001;
        end else if ((ratio > 64'd67) && (ratio <= 64'd70)) begin
                lookup_val = 8'b00100010;
        end else if ((ratio > 64'd70) && (ratio <= 64'd73)) begin
                lookup_val = 8'b00100011;
        end else if ((ratio > 64'd73) && (ratio <= 64'd75)) begin
                lookup_val = 8'b00100100;
        end else if ((ratio > 64'd75) && (ratio <= 64'd78)) begin
                lookup_val = 8'b00100101;
        end else if ((ratio > 64'd78) && (ratio <= 64'd81)) begin
                lookup_val = 8'b00100110;
        end else if ((ratio > 64'd81) && (ratio <= 64'd84)) begin
                lookup_val = 8'b00100111;
        end else if ((ratio > 64'd84) && (ratio <= 64'd87)) begin
                lookup_val = 8'b00101000;
        end else if ((ratio > 64'd87) && (ratio <= 64'd90)) begin
                lookup_val = 8'b00101001;
        end else if ((ratio > 64'd90) && (ratio <= 64'd93)) begin
                lookup_val = 8'b00101010;
        end else if ((ratio > 64'd93) && (ratio <= 64'd97)) begin
                lookup_val = 8'b00101011;
        end else if ((ratio > 64'd97) && (ratio <= 64'd100)) begin
                lookup_val = 8'b00101100;
        end else begin
            lookup_val = 8'b00000000;
        end
    end
endmodule
