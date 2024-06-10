`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2024 15:02:59
// Design Name: 
// Module Name: mult
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


module mult #( data_width = 16, frac_width = 14, int_width = 2, dfrac = 28, dint = 4, dwidth = 32 )
(
    input signed [data_width-1:0] A_in,
    input signed [data_width-1:0] B_in,
    output wire signed [data_width-1:0] out,
    output reg overflow_flag,
    output reg underflow_flag
);

    reg signed [dwidth-1:0] temp;
    reg signed [data_width-1:0] temp1;
    
    always @(*) begin
        overflow_flag = 1'b0;
        underflow_flag = 1'b0;
        
        temp = A_in * B_in;
        
        
        temp1 = temp >>> frac_width;
        
        // Overflow and underflow conditions
        if ((A_in[data_width-1] == 1'b0 && B_in[data_width-1] == 1'b0 && temp1[data_width-1] == 1'b1) ||
            (A_in[data_width-1] == 1'b1 && B_in[data_width-1] == 1'b1 && temp1[data_width-1] == 1'b0)) begin
            overflow_flag = 1'b1;
        end else if ((A_in[data_width-1] == 1'b0 && B_in[data_width-1] == 1'b0 && temp1[data_width-1] == 1'b0) ||
                     (A_in[data_width-1] == 1'b1 && B_in[data_width-1] == 1'b1 && temp1[data_width-1] == 1'b1)) begin
            underflow_flag = 1'b1;
        end
    end
    
    assign out = temp1;
    
endmodule
