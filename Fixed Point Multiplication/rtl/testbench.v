`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2024 15:02:59
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


`timescale 1ns/1ps

module tb_mult;

    parameter data_width = 16;
    parameter frac_width = 14;
    parameter int_width = 2;
    parameter dfrac = 28;
    parameter dint = 4;
    parameter dwidth = 32;

    reg signed [data_width-1:0] A_in;
    reg signed [data_width-1:0] B_in;
    wire signed [data_width-1:0] out;
    wire overflow_flag;
    wire underflow_flag;

    mult #(data_width, frac_width, int_width, dfrac, dint, dwidth) uut (
        .A_in(A_in),
        .B_in(B_in),
        .out(out),
        .overflow_flag(overflow_flag),
        .underflow_flag(underflow_flag)
    );

    initial begin
        // Monitor the values
        $monitor("A_in = %d, B_in = %d, out = %d, overflow_flag = %b, underflow_flag = %b", A_in, B_in, out, overflow_flag, underflow_flag);

       
        A_in = 16'b0000000000100000; // 2.0
        B_in = 16'b0000000000010000; // 1.0
        #10;

        
        A_in = 16'b0000000000110000; // 3.0
        B_in = 16'b0000000000100000; // 2.0
        #10;

        
        A_in = 16'b0111111111111111; // Maximum positive
        B_in = 16'b0000000000100000; // 2.0
        #10;

        
        A_in = 16'b1000000000000000; // Maximum negative
        B_in = 16'b1111111111111111; // -1.0
        #10;

        
        A_in = 16'b0111111111111111; // Maximum positive
        B_in = 16'b0111111111111111; // Maximum positive
        #10;

       
        A_in = 16'b1000000000000000; // Maximum negative
        B_in = 16'b1000000000000000; // Maximum negative
        #10;

       
        A_in = 16'b0111111111111111; // Maximum positive
        B_in = 16'b1000000000000000; // Maximum negative
        #10;

        
        A_in = 16'b1000000000000000; // Maximum negative
        B_in = 16'b0111111111111111; // Maximum positive
        #10;

      
        A_in = 16'b0000000000000001; // Small positive
        B_in = 16'b0000000000000001; // Small positive
        #10;

       
        A_in = 16'b1111111111111111; // Small negative
        B_in = 16'b1111111111111111; // Small negative
        #10;

        
        A_in = 16'b0000000000000001; // Small positive
        B_in = 16'b1111111111111111; // Small negative
        #10;

        
        A_in = 16'b1111111111111111; // Small negative
        B_in = 16'b0000000000000001; // Small positive
        #10;

       
        A_in = 16'b0000000000000000; // Zero
        B_in = 16'b1000000000000000; // Maximum negative
        #10;

        
        A_in = 16'b0000000000000010; // Small positive
        B_in = 16'b0000000000000010; // Small positive
        #10;

        
        A_in = 16'b1111111111111110; // Small negative
        B_in = 16'b1111111111111110; // Small negative
        #10;

       
        A_in = 16'b0111111111110000; // Large positive
        B_in = 16'b0000000000001000; // 8
        #10;

        
        A_in = 16'b1000000000001111; // Large negative
        B_in = 16'b1111111111111000; // -8
        #10;

        
        A_in = 16'b0111111111110000; // Large positive
        B_in = 16'b1111111111111000; // -8
        #10;

        // Finish simulation
        $finish;
    end

endmodule

