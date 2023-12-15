`timescale 1ns / 1ps
`default_nettype none 

module display_control(
    input wire clk_in,
    input wire sys_rst,
    input wire btn2,
    input wire btn3,
    input wire [9:0] lower_four,
    output logic [3:0] ss0_an_dc,
    output logic [3:0] ss1_an_dc,
    output logic [15:0] btn_count,
    output logic [6:0] ss_c_upper,
    output logic [6:0] ss_c_lower,
    output logic [2:0] both_buttons_counter,
    output logic [15:0] alarm1,
    output logic [15:0] alarm2,
    output logic [15:0] alarm3,
    output logic [15:0] alarm4
);

    logic deb_btn2, deb_btn3, deb_btn4;
    logic btn2_pulse, btn3_pulse, btn4_pulse;

    debouncer btn2_db(
        .clk_in(clk_in),
        .rst_in(sys_rst),
        .dirty_in(btn2),
        .clean_out(deb_btn2)
    );

    debouncer btn3_db(
        .clk_in(clk_in),
        .rst_in(sys_rst),
        .dirty_in(btn3),
        .clean_out(deb_btn3)
    );

    logic deb_btn4;
    debouncer btn4_db(
        .clk_in(clk_in),
        .rst_in(sys_rst),
        .dirty_in(btn2 && btn3),
        .clean_out(deb_btn4)
    );

    edge_detector ed2(
        .clk_in(clk_in),
        .level_in(deb_btn2),
        .pulse_out(btn2_pulse)
    );

    edge_detector ed3(
        .clk_in(clk_in),
        .level_in(deb_btn3),
        .pulse_out(btn3_pulse)
    );

    edge_detector ed4(
        .clk_in(clk_in),
        .level_in(deb_btn4),
        .pulse_out(btn4_pulse)
    );


    always @(posedge clk_in) begin
        if (sys_rst) begin
            btn_count <= 30;
            both_buttons_counter <= 0;
            alarm1 <= 30;
            alarm2 <= 60;
            alarm3 <= 180;
            alarm4 <= 270;
        end else begin
            if (btn4_pulse) begin
                if (both_buttons_counter == 3) begin
                    both_buttons_counter <= 0;
                end else begin
                    both_buttons_counter <= both_buttons_counter + 1;
                end
                case (both_buttons_counter)
                    2'b00: begin
                        btn_count <= alarm2;
                        // alarm1 <= btn_count - 9;
                    if (btn_count - 9 <= 0)
                        alarm1 <= (btn_count - 9) + 360 + 10;
                    else
                        alarm1 <= btn_count - 9 + 10;
                    end
                    2'b01: begin
                        btn_count <= alarm3;
                        // alarm2 <= btn_count - 9;
                        if (btn_count - 9 <= 0)
                            alarm2 <= (btn_count - 9) + 360 + 10;
                        else
                            alarm2 <= btn_count - 9 + 10;
                    end
                    2'b10: begin 
                        btn_count <= alarm4;
                        // alarm3 <= btn_count - 9;
                        if (btn_count - 9 <= 0)
                            alarm3 <= (btn_count - 9) + 360 + 10;
                        else
                            alarm3 <= btn_count - 9 + 10;
                    end
                    2'b11: begin
                        btn_count <= alarm1;
                        // alarm4 <= btn_count - 9;
                        if (btn_count - 9 <= 0)
                            alarm4 <= (btn_count - 9) + 360 + 10;
                        else
                            alarm4 <= btn_count - 9 + 10;
                    end
                endcase
            end else begin
                if (btn3_pulse) begin
                    if (btn_count + 10 >= 360)
                        btn_count <= (btn_count + 10) - 360;
                    else
                        btn_count <= btn_count + 10;
                end
                if (btn2_pulse) begin
                    if (btn_count == 0)
                        btn_count <= 359;
                    else
                        btn_count <= btn_count - 1;
                end
            end
        end
    end 

    seven_segment_controller mssc_upper(
        .clk_in(clk_in),
        .rst_in(sys_rst),
        .val_in(btn_count),
        .cat_out(ss_c_upper),
        .an_out(ss0_an_dc) 
    );

    seven_segment_controller mssc_lower(
        .clk_in(clk_in),
        .rst_in(sys_rst),
        .val_in(lower_four),
        .cat_out(ss_c_lower),
        .an_out(ss1_an_dc) 
    );

endmodule

`default_nettype wire
