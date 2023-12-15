module lfsr_16 ( input wire clk_in, input wire rst_in,
                    input wire [15:0] seed_in,
                    output logic [15:0] q_out);

    logic [15:0] q_old;

    always_comb begin
        q_out[0] = q_old[15];
        q_out[1] = q_old[0];
        q_out[2] = q_old[1]^q_old[15];
        q_out[3] = q_old[2];
        q_out[4] = q_old[3];
        q_out[5] = q_old[4];
        q_out[6] = q_old[5];
        q_out[7] = q_old[6];
        q_out[8] = q_old[7];
        q_out[9] = q_old[8];
        q_out[10] = q_old[9];
        q_out[11] = q_old[10];
        q_out[12] = q_old[11];
        q_out[13] = q_old[12];
        q_out[14] = q_old[13];
        q_out[15] = q_old[14]^q_old[15];


    end

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            q_out <= seed_in;
        end else begin
            q_old <= q_out;
        end
    end


endmodule