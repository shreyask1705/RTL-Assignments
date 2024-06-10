`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2024 11:50:29
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////




module testbench;

    parameter data_width = 16;
    parameter frac_width = 14;
    parameter int_width = 2;

    // Inputs
    reg signed [data_width-1:0] A_in;
    reg signed [data_width-1:0] B_in;

    // Outputs
    wire signed [data_width-1:0] out;
    wire overflow_flag;
    wire underflow_flag;

    // Instantiate the add module
    add #(data_width, frac_width, int_width) uut (
        .A_in(A_in), 
        .B_in(B_in), 
        .out(out), 
        .overflow_flag(overflow_flag), 
        .underflow_flag(underflow_flag)
    );

    // Testbench procedure
    initial begin
        // Initialize inputs
        A_in = 0;
        B_in = 0;

        // Monitor changes
        $monitor("Time: %d, A_in: %b, B_in: %b, out: %b, overflow_flag: %b, underflow_flag: %b", 
            $time, A_in, B_in, out, overflow_flag, underflow_flag);

        // Test case 1: Normal addition
        #10 A_in = 16'b0000000000001100; // 0.75
        B_in = 16'b0000000000000011; // 0.1875
        #10;

        // Test case 2: Overflow case
        #10 A_in = 16'b0111111111111111; // Just below 2.0
        B_in = 16'b0000000000000001; // 0.0625
        #10;

        // Test case 3: Underflow case
        #10 A_in = 16'b1000000000000001; // -1.9375
        B_in = 16'b1000000000000001; // -1.9375
        #10;

        // Test case 4: Another normal addition
        #10 A_in = 16'b0000000000011000; // 1.5
        B_in = 16'b0000000000001100; // 0.75
        #10;

        // Test case 5: Another overflow case
        #10 A_in = 16'b0111111111111111; // Just below 2.0
        B_in = 16'b0111111111111111; // Just below 2.0
        #10;

        // Test case 6: Another underflow case
        #10 A_in = 16'b1100000000000000; // -2.0
        B_in = 16'b1100000000000000; // -2.0
        #10;

        // Finish simulation
        $finish;
    end
endmodule

