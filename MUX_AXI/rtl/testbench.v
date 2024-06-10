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


module tb_mux#( 
    parameter data_width = 16,
    parameter frac_width = 14,
    parameter int_width = 2
);
    // Testbench signals
    reg clk, reset;
    reg [data_width-1:0] a;
    reg [data_width-1:0] b;
    reg s;
    wire [data_width-1:0] o;
    reg tvalid_in_a;
    reg tvalid_in_b;
    wire tready_out_a;
    wire tready_out_b;
    wire tdata_out;
    wire tlast_out;
    wire tvalid_out;
    reg tlast_in_a;
    reg tdata_in_a;
    reg tready_in;
    reg tlast_in_b;
    reg tdata_in_b;

    // Instantiate the mux module
    mux uut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .s(s),
        .o(o),
        .tvalid_in_a(tvalid_in_a),
        .tready_in(tready_in),
        .tlast_in_a(tlast_in_a),
        .tdata_in_a(tdata_in_a),
        .tvalid_out(tvalid_out),
        .tready_out_a(tready_out_a),
        .tready_out_b(tready_out_b),
        .tlast_out(tlast_out),
        .tdata_out(tdata_out),
        .tvalid_in_b(tvalid_in_b),
        .tlast_in_b(tlast_in_b),
        .tdata_in_b(tdata_in_b)
    );

    // Test procedure
    initial begin
        // Initialize inputs
        a = 16'b0;
        b = 16'b0;
        clk = 0;
        reset = 1;
        s = 0;
        tvalid_in_a = 1;
        tdata_in_a = 1;
        tready_in = 1;
        tlast_in_a = 0;
        tvalid_in_b = 1;
        tdata_in_b = 1;
        tlast_in_b = 0;
        
        #10 reset = 0;
        
        // Monitor changes
        $monitor("At time %t, a = %h, b = %h, s = %b, o = %h, tvalid_out = %b, tready_out_a = %b, tready_out_b = %b, tlast_out = %b", 
                 $time, a, b, s, o, tvalid_out, tready_out_a, tready_out_b, tlast_out);

        // Test all combinations of inputs
        #10 a = 16'h2345; b = 16'h15d0; s = 0;
        #10 a = 16'h8962; b = 16'habcd; s = 1;
        #10 a = 16'h3467; b = 16'h54e0; s = 0;
        #10 a = 16'h1592; b = 16'hffff; s = 1; tlast_in_a = 1;
        #10 a = 16'h3470; b = 16'h0417; s = 0; tlast_in_a = 0;
        #10 a = 16'h2048; b = 16'haaaa; s = 1;
        #10 a = 16'hadbc; b = 16'haf28; s = 0; tlast_in_b = 1;
        #10 a = 16'h1111; b = 16'h2222; s = 1; tlast_in_b = 0;
        
        // Finish simulation
        #10 $finish;
    end

    always #5 clk = ~clk;
endmodule
