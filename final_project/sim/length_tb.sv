`timescale 1ns / 1ps
`default_nettype none

module length_tb;

    //make logics for inputs and outputs!
    logic clk_in;
    logic rst_in;
    logic valid_in;
    logic [10:0] x0_in;
    logic [9:0] y0_in;
    logic [10:0] x_in;
    logic [9:0] y_in;
    logic [31:0] mass_in;
    logic [31:0] length_out;
    logic valid_out;

    length #(.WIDTH(10)) uut(.clk_in(clk_in), .rst_in(rst_in),
                        .data_valid_in(valid_in),
                        .x_in(x_in),
                        .y_in(y_in),
                        .x0_in(x0_in),
                        .y0_in(y0_in),
                        .mass_in(mass_in),
                        .length_out(length_out),
                        .valid_out(valid_out));
    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk_in = !clk_in;
    end

    //initial block...this is our test simulation
    initial begin
        $dumpfile("length.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,length_tb); //store everything at the current level and below
        $display("Starting Sim"); //print nice message
        clk_in = 0; //initialize clk (super important)
        rst_in = 0; //initialize rst (super important)
        x0_in = 11'b0;
        y0_in = 10'b0;
        x_in = 11'd0;
        y_in = 11'd10;
        #10  //wait a little bit of time at beginning
        rst_in = 1; //reset system
        #10; //hold high for a few clock cycles
        rst_in=0;
        #10;
        x0_in = 11'b0;
        y0_in = 10'b0;
        x_in = 11'd10;
        y_in = 11'd10;
        #1000;  //wait a little bit of time at beginning
        rst_in = 1; //reset system
        #10; //hold high for a few clock cycles
        rst_in=0;
        #10;
        x0_in = 11'd10;
        y0_in = 10'd10;
        x_in = 11'd100;
        y_in = 11'd20;
        #1000;
        x0_in = 11'b0;
        y0_in = 10'b0;
        x_in = 11'd10;
        y_in = 11'd10;
        mass_in = (201*(x_in - x0_in)*(y_in - y0_in)) >> 6;
        #1000;
        //++ quadrant
        for (int i=0;i<200;i++) begin
            //x_in <= x_in + 11'd10;
            y_in = y_in + 11'd1;
            mass_in = (201*(x_in - x0_in)*(y_in - y0_in)) >> 6;
            valid_in = 1;
            #10;
            valid_in = 0;
            #1000;
        end 
        //-+ quadrant
        x0_in = 11'd00;
        x_in = 11'b0;
        y0_in = 10'b0;
        y_in = 11'd100;
        #10;
        for (int i=0;i<10;i++) begin
            //x_in <= x_in + 11'd10;
            y_in = y_in - 11'd2;
            mass_in = (201*(x_in - x0_in)*(y_in - y0_in)) >> 6;
            valid_in = 1;
            #10;
            valid_in = 0;
            #1000;
        end 
        // -- , +- quadrant
        x0_in = 11'd100;
        x_in = 11'b100;
        y0_in = 10'd100;
        y_in = 11'd100;
        #10;
        for (int i=0;i<200;i++) begin
            //x_in <= x_in + 11'd10;
            x_in = x_in + 11'd5;
            mass_in = (201*(x_in - x0_in)*(y_in - y0_in)) >> 6;
            valid_in = 1;
            #10;
            valid_in = 0;
            #1000;
        end 
        
        $display("Finishing Sim"); //print nice message
        $finish;

    end
endmodule //counter_tb

`default_nettype wire