`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2024 11:50:29
// Design Name: 
// Module Name: add
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


module add #( 
    parameter data_width = 16,
    parameter frac_width = 14,
    parameter int_width = 2
)
(
    input signed [data_width-1:0] A_in,
    input signed [data_width-1:0] B_in,
    output reg signed [data_width-1:0] out,
    output reg overflow_flag,
    output reg underflow_flag
);

    wire signed [int_width-1:0] a_int = A_in[data_width-1:data_width-int_width];
    wire signed [frac_width-1:0] a_frac = A_in[frac_width-1:0];
    wire signed [int_width-1:0] b_int = B_in[data_width-1:data_width-int_width];
    wire signed [frac_width-1:0] b_frac = B_in[frac_width-1:0];
    
    reg signed [frac_width:0] fracp;  // Extra bit for carry
    reg signed [int_width-1:0] intp;
    reg signed [data_width:0] temp;   // Extra bit for carry

    always @(*) begin
        // Initialize flags
        overflow_flag = 1'b0;
        underflow_flag = 1'b0;

        // Add fractional parts
        fracp = a_frac + b_frac;

        // If there's a carry from the fractional addition, add it to the integer part
        intp = a_int + b_int + fracp[frac_width];

        // Concatenate the integer and fractional parts
        out = {intp, fracp[frac_width-1:0]}; 
        
        // Underflow logic
        if (A_in[data_width-1] == 1'b1  && B_in[data_width-1] == 1'b1 && out[data_width-1] == 1'b0) begin
            underflow_flag = 1'b1;
        end
        
        // Overflow logic
        else if (A_in[data_width-1] == 1'b0 && B_in[data_width-1] == 1'b0 && out[data_width-1] == 1'b1) begin
            overflow_flag = 1'b1;
        end
    end

endmodule

