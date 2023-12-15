`timescale 1ns / 1ps
`default_nettype none

module clock_tb;

    //make logics for inputs and outputs!
    logic clk_in;
    logic rst_in;
    logic clk_out;

    clock_divider uut(
        .clk_in(clk_in),
        .reset(rst_in),      
        .clk_25MHz(clk_out) 
    );
    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk_in = !clk_in;
    end

    //initial block...this is our test simulation
    initial begin
        $dumpfile("clock.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,clock_tb); //store everything at the current level and below
        $display("Starting Sim"); //print nice message
        clk_in = 0; //initialize clk (super important)
        rst_in = 0; //initialize rst (super important)
        #10
        rst_in = 1;
        #100;
        rst_in = 0;
        #10000;
        
        $display("Finishing Sim"); //print nice message
        $finish;

    end
endmodule //counter_tb

`default_nettype wire