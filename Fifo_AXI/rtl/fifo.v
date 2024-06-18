`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2024 10:26:49
// Design Name: 
// Module Name: fifo
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



module fifo#( 
    parameter data_width = 16,
    parameter size = 2048
    )
    (
    input clk,
    input reset,
    input [data_width-1:0] data_in,
    input s_axis_tvalid,
    input s_axis_tlast,
    output wire s_axis_tready,
    output wire [data_width-1:0] data_out,
    output wire m_axis_tvalid,
    output wire m_axis_tlast,
    input m_axis_tready
    );

    // Pointers and counter
    (* ram_style = "block" *) reg [data_width-1:0] mem [0:size-1];
    reg [11:0] write_ptr = 0;  // Write pointer
    reg [11:0] read_ptr = 0;   // Read pointer
    reg [11:0] count = 0;      // Number of elements in the FIFO

    // Internal registers
    reg [data_width-1:0] temp;
    reg m_axis_tlast_reg;
    reg write_enable;
    reg read_enable;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0;
            read_ptr <= 0;
            count <= 0;
            temp <= 0;
            m_axis_tlast_reg <= 0;
        end else begin
            if (s_axis_tvalid && s_axis_tready) begin
                mem[write_ptr] <= data_in;
                write_ptr <= (write_ptr + 1) % size;
                count <= count + 1;
                m_axis_tlast_reg <= s_axis_tlast;
            end
            if (m_axis_tvalid && m_axis_tready) begin
                temp <= mem[read_ptr];
                read_ptr <= (read_ptr + 1) % size;
                count <= count - 1;
            end
        end
    end

    always @* begin
        // Default assignments
        write_enable = (count < size);
        read_enable = (count > 0);
    end

    assign data_out = temp;
    assign m_axis_tvalid = read_enable;
    assign m_axis_tlast = m_axis_tlast_reg;
    assign s_axis_tready = write_enable;

endmodule

module dual_fifo #(
    parameter data_width = 16,
    parameter size = 2048
) (
    input clk,
    input reset,
    input [data_width-1:0] data_in0,
    input s_axis_tvalid_f0,
    input s_axis_tlast_f0,
    output wire s_axis_tready_f0,
    output wire [data_width-1:0] data_out0, 
    output wire [data_width-1:0] data_out1,
    output wire m_axis_tvalid_f1,
    output wire m_axis_tlast_f1,
    input m_axis_tready_f1
);

    wire m_axis_tvalid_f0;
    wire m_axis_tlast_f0;

    // Instantiate the first FIFO
    fifo #(
        .data_width(data_width),
        .size(size)
    ) fifo0 (
        .clk(clk),
        .reset(reset),
        .data_in(data_in0),
        .s_axis_tvalid(s_axis_tvalid_f0),
        .s_axis_tlast(s_axis_tlast_f0),
        .s_axis_tready(s_axis_tready_f0),
        .data_out(data_out0),
        .m_axis_tvalid(m_axis_tvalid_f0),
        .m_axis_tlast(m_axis_tlast_f0),
        .m_axis_tready(1'b1) // Always ready to accept new data
    );

    // Instantiate the second FIFO
    fifo #(
        .data_width(data_width),
        .size(size)
    ) fifo1 (
        .clk(clk),
        .reset(reset),
        .data_in(data_out0), 
        .s_axis_tvalid(m_axis_tvalid_f0),
        .s_axis_tlast(m_axis_tlast_f0),
        .s_axis_tready(), // This signal is not used in this context
        .data_out(data_out1),
        .m_axis_tvalid(m_axis_tvalid_f1),
        .m_axis_tlast(m_axis_tlast_f1),
        .m_axis_tready(m_axis_tready_f1)
    );

endmodule
