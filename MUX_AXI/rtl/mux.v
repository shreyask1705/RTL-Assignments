`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2024 12:47:15
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


module mux #(
    parameter data_width = 16,
    parameter frac_width = 14,
    parameter int_width = 2
)
(
    // Standards
    input clk,
    input reset,
    input [data_width-1:0] a,
    input [data_width-1:0] b,
    input s,
    output reg [data_width-1:0] o,  
    // A handshake signals 
    input tvalid_in_a,
    output reg tready_out_a,
    input tlast_in_a,
    input tdata_in_a,
    // B handshake signals 
    input tvalid_in_b,
    input tlast_in_b,
    input tdata_in_b,
    output reg tready_out_b,
    // Output side handshakes
    output reg tlast_out,
    output reg tdata_out,
    output reg tvalid_out,
    input tready_in
);

    // Internal components
    reg l;
    reg e, f;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o <= 0;  
            l <= 0;
            tready_out_a <= 0;
            tready_out_b <= 0;
            tlast_out <= 0;
            tdata_out <= 0;
            tvalid_out <= 0;
        end else begin
            // Output assignment
            if ((tvalid_in_a) && (tready_in) && (!s)) begin
                o <= a; 
            end else if ((tvalid_in_b) && (tready_in) && (s)) begin
                o <= b;  
            end
            
            // Ready signals
            tready_out_a <= tready_in && !s;
            tready_out_b <= tready_in && s;
            
            // Last signal
            if (tlast_in_a || tlast_in_b)
                l <= 1;
            else
                l <= 0;
                
            // Valid and data signals
            e <= 1;
            f <= 1;

            tlast_out <= l;
            tdata_out <= f;
            tvalid_out <= e;
        end
    end
endmodule

//endmodule

