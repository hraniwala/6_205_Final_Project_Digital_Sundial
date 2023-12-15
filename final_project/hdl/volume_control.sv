`timescale 1ns / 1ps
`default_nettype none 


// Volume Control Module
module volume_control(
    input wire [2:0] vol_in,
    input wire signed [7:0] signal_in,
    output logic signed [7:0] signal_out
    );
    logic [2:0] shift;
    assign shift = 3'd7 - vol_in;
    assign signal_out = signal_in >>> shift;
endmodule

`default_nettype wire
