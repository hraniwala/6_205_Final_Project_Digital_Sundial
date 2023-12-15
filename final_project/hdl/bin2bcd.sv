`timescale 1ns / 1ps
`default_nettype none

module bin2bcd (
    input wire clk_in,
    input wire rst_in,
    input wire [11:0] bin,
    input wire data_valid_in,
    output logic [15:0] bcd_out
    );

    logic [4:0] i; // run for 12 iterations

    typedef enum {IDLE = 0 ,INITIALIZE=1, BCD = 2, BCD_CHECK = 3, OUTPUT = 4} current_state;
    current_state state;
    logic [15:0] bcd_temp;

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            bcd_temp <= 16'b0;
            bcd_out <= 16'b0;
            i <= 5'b0;
            state <= INITIALIZE;
        end else begin
            case (state)
            IDLE: begin
                if (data_valid_in) begin
                state <= INITIALIZE;
                end else begin
                    state <= IDLE;
                end
            end
            INITIALIZE: begin
                bcd_temp <= 0;
                i <= 0;
                state <= BCD;
            end
            BCD: begin
                if (i < 12) begin
                    //bcd_temp <= {bcd_temp[15:1],bin[11-i]};
                    bcd_temp[15] <= bcd_temp[14];
                    bcd_temp[14] <= bcd_temp[13];
                    bcd_temp[13] <= bcd_temp[12];
                    bcd_temp[12] <= bcd_temp[11];
                    bcd_temp[11] <= bcd_temp[10];
                    bcd_temp[10] <= bcd_temp[9];
                    bcd_temp[9] <= bcd_temp[8];
                    bcd_temp[8] <= bcd_temp[7];
                    bcd_temp[7] <= bcd_temp[6];
                    bcd_temp[6] <= bcd_temp[5];
                    bcd_temp[5] <= bcd_temp[4];
                    bcd_temp[4] <= bcd_temp[3];
                    bcd_temp[3] <= bcd_temp[2];
                    bcd_temp[2] <= bcd_temp[1];
                    bcd_temp[1] <= bcd_temp[0];
                    bcd_temp[0] <= bin[11-i];

                    state <= BCD_CHECK;
                end else begin
                    bcd_out <= bcd_temp;
                    i <= 0;
                    state <= OUTPUT;
                end
            end
            BCD_CHECK: begin
                if (i < 11 && bcd_temp[3:0] > 4) begin
                    bcd_temp[3:0] <= bcd_temp[3:0] + 3;
                end else begin
                end
                if (i < 11 && bcd_temp[7:4] > 4) begin
                    bcd_temp[7:4] <= bcd_temp[7:4] + 3;
                end else begin
                end
                if (i < 11 && bcd_temp[11:8] > 4) begin
                    bcd_temp[11:8] <= bcd_temp[11:8] + 3;
                end else begin
                end
                if (i < 11 && bcd_temp[15:12] > 4) begin
                    bcd_temp[15:12] <= bcd_temp[15:12] + 3;
                end else begin
                end
                state <= BCD;
                i <= i + 1;
            end
            OUTPUT: begin
                bcd_temp <= 0;
                state <= IDLE;
            end
            endcase
        end
    end


    // always_comb begin
    //     for (i = 0; i < 12; i = i + 1) begin
    //         bcd = {bcd[14:0],bin[7-i]};
    //         //if a hex digit of 'bcd' is more than 4, add 3 to it.  
    //         if (i < 7 && bcd[3:0] > 4) begin
    //             bcd[3:0] = bcd[3:0]+ 3;
    //         end
    //         if (i < 7 && bcd[7:4] > 4) begin
    //             bcd[7:4] = bcd[7:4]+ 3;
    //         end
    //         if (i < 7 && bcd[11:8] > 4) begin
    //             bcd[11:8] = bcd[11:8]+ 3;
    //         end
    //         if (i < 7 && bcd[15:12] > 4) begin
    //             bcd[15:12] = bcd[15:12]+ 3;
    //         end
    //     end
    // end

endmodule


`default_nettype none