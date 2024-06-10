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
    input tvalid_in,
    input tlast_in,
    output wire tready_out,
    output wire [data_width-1:0] data_out,
    output wire tvalid_out,
    output wire tlast_out,
    input tready_in
    );

    // Pointers and counter
    (* ram_style = "block" *) reg [data_width-1:0] mem [0:size-1];
    reg [11:0] write_ptr = 0;  // Write pointer
    reg [11:0] read_ptr = 0;   // Read pointer
    reg [11:0] count = 0;      // Number of elements in the FIFO
    
    // FSM states
    localparam S0 = 2'b00;    
    localparam S1 = 2'b01; 
    localparam S2 = 2'b10;   
    reg [1:0] state, n_state;
    
    // Internal registers
    reg [data_width-1:0] temp;
    reg x, y, z;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            write_ptr <= 0;
            read_ptr <= 0;
            count <= 0;
        end else begin
            state <= n_state;
            if (state == S1 && tvalid_in && tready_out) begin
                mem[write_ptr] <= data_in;
                write_ptr <= (write_ptr + 1) % size;
                count <= count + 1;
                if (tlast_in) begin
                    y <= 1;
                end else begin
                    y <= 0;
                end
            end
            if (state == S2 && tready_in && x) begin
                temp <= mem[read_ptr];
                read_ptr <= (read_ptr + 1) % size;
                count <= count - 1;
            end
        end
    end
    
    always @* begin
        // Default assignments
        n_state = state;
        z = (count < size);
        x = (count > 0);

        case (state)
            S0: begin // reset
                n_state = S1;
            end

            S1: begin // write
                if (reset)
                    n_state = S0;
                else if (tvalid_in && tready_out) begin
                    n_state = S2;
                end
            end

            S2: begin // read
                if (reset)
                    n_state = S0;
                else if (tready_in && x) begin
                    n_state = S1;
                end else begin
                    n_state = S1;
                end
            end

            default: begin
                n_state = S0;
            end
        endcase
    end

    assign data_out = temp;
    assign tvalid_out = x;
    assign tlast_out = y;
    assign tready_out = z;

endmodule


module dual_fifo #(
    parameter data_width = 16,
    parameter size = 2048
) (
    input clk,
    input reset,
    input [data_width-1:0] data_in0,
    input tvalid_in0,
    input tlast_in0,
    output wire tready_out0,
    output wire [data_width-1:0] data_out0, 
    output wire [data_width-1:0] data_out1,
    output wire tvalid_out1,
    output wire tlast_out1,
    input tready_in1
);

    wire tvalid_out0;
    wire tlast_out0;
    wire tready_in0 = 1;  // Ready to read from first FIFO

    // Instantiate the first FIFO
    fifo #(
        .data_width(data_width),
        .size(size)
    ) fifo0 (
        .clk(clk),
        .reset(reset),
        .data_in(data_in0),
        .tvalid_in(tvalid_in0),
        .tlast_in(tlast_in0),
        .tready_out(tready_out0),
        .data_out(data_out0),
        .tvalid_out(tvalid_out0),
        .tlast_out(tlast_out0),
        .tready_in(tready_in0)
    );

    // Instantiate the second FIFO
    fifo #(
        .data_width(data_width),
        .size(size)
    ) fifo1 (
        .clk(clk),
        .reset(reset),
        .data_in(data_out0), 
        .tvalid_in(tvalid_out0),
        .tlast_in(tlast_out0),
        .tready_out(),
        .data_out(data_out1),
        .tvalid_out(tvalid_out1),
        .tlast_out(tlast_out1),
        .tready_in(tready_in1)
    );

endmodule
