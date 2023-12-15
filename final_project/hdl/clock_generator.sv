`timescale 1ns / 1ps
`default_nettype none 

module clock_generator(
    input wire clk_100mhz,  // Input clock at 100 MHz
    input wire reset,       // Reset signal
    output logic tick_48000hz,      // Output clock at 48 kHz
    output logic prev_tick_48000hz, // Previous state of 48 kHz clock
    output logic clk_3MHz           // Output clock at 3 MHz
);
    logic [11:0] tick_counter;       // Counter for 48 kHz clock
    logic [4:0] tick_counter_3MHz;   // Counter for 3 MHz clock

    always_ff @(posedge clk_100mhz) begin
        if (reset) begin
            // Reset all counters and output clocks
            tick_counter <= 0;
            tick_48000hz <= 0;
            prev_tick_48000hz <= 0;
            tick_counter_3MHz <= 0; 
            clk_3MHz <= 0; 
        end else begin
            // Generate 48 kHz clock
            if (tick_counter >= 1000) begin // 1041 for exact 48 kHz
                tick_counter <= 0;
                tick_48000hz <= ~tick_48000hz;
            end else begin
                tick_counter <= tick_counter + 1;
            end
            prev_tick_48000hz <= tick_48000hz;

            // Generate 3 MHz clock
            if (tick_counter_3MHz >= 16) begin 
                tick_counter_3MHz <= 0;
                clk_3MHz <= ~clk_3MHz;
            end else begin
                tick_counter_3MHz <= tick_counter_3MHz + 1;
            end
        end
    end
endmodule

`default_nettype wire
