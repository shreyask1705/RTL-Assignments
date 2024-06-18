`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.05.2024 14:33:18
// Design Name: 
// Module Name: register
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


module register#(
    parameter data_width = 8,
    parameter frac_width = 6,
    parameter int_width = 2
)(
    input clk, input reset,
    input [data_width-1:0] data_in,
    output wire [data_width-1:0] data_out,
    input s_axis_tvalid,
    output s_axis_tready,
    //output tdata_out,
    output m_axis_tlast,
    output m_axis_tvalid,
    input m_axis_tready,
    //input tdata_in,
    input s_axis_tlast
);

    reg [data_width-1:0] register;
    reg [data_width-1:0] x;
    reg l;

    localparam s0 = 2'b00;
    localparam s1 = 2'b01;
    localparam s2 = 2'b10;
    //localparam s3 = 2'b11;

    reg [1:0] state, n_state;
    reg nready;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= s0;
            nready <= 1;
        end else begin
            state <= n_state;
            nready <= (state == s2) ? 1'b1 : 1'b0;
        end
    end

    always @(*) begin
        case(state)
            s0 : begin
                if (!reset) begin
                    n_state <= s1;  
                end
            end
            s1 : begin
                if (s_axis_tvalid == 1) begin
                    register <= data_in;
                end
                n_state <= s2;
            end
            s2 : begin
                if (m_axis_tready == 1) begin
                    x <= register;
                    n_state <= s1;
                end
            end
//            s3 : begin
//                n_state <= s0;
//            end
            default : begin
                n_state <= s0;
            end
        endcase
    end

    always @(*) begin
        if (s_axis_tlast)
            l=1;
        else
            l=0;
    end            
    assign data_out = x;
    assign s_axis_tready = nready;
    assign m_axis_tvalid = (state == s2);
    //assign tdata_out = (state == s2);
    assign m_axis_tlast = l;//(state == s3);

endmodule

