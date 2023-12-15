module edge_detector(
    input wire clk_in,
    input wire level_in,
    output logic pulse_out
);

    logic level_in_prev;

    always_ff @(posedge clk_in) begin
        level_in_prev <= level_in;
    end

    always_comb begin
        pulse_out = level_in & ~level_in_prev; // rise detect
    end

endmodule
