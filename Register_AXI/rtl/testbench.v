`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.05.2024 14:33:18
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



module testbench#(
    parameter data_width = 8,
    parameter frac_width = 6,
    parameter int_width = 2,
    parameter size = 2048
);

    // Declaration of Signals 
    reg clk; reg reset;
    reg [data_width-1:0] data_in;
    wire [data_width-1:0] data_out;
    reg tvalid_in;
    wire tready_out;
    wire tdata_out;
    wire tlast_out;
    wire tvalid_out;
    reg tready_in;
    reg tdata_in;
    reg tlast_in;

    reg [data_width-1:0] mem [0:size-1];
    
    // Instantiation of the module
    register uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out),
        .tvalid_in(tvalid_in),
        .tdata_in(tdata_in),
        .tready_in(tready_in),
        .tlast_in(tlast_in),
        .tvalid_out(tvalid_out),
        .tready_out(tready_out),
        .tdata_out(tdata_out),
        .tlast_out(tlast_out)
    );

    integer i; 
    integer fp_write_out;

    initial begin
        clk = 0; reset = 1;
        tvalid_in=1;
        tdata_in=1;
        tready_in=1;
        tlast_in=0;
        i = 0;
        $readmemb("C:/Users/shrsk/Downloads/inp_bin.dat", mem);
        fp_write_out = $fopen("out_bin.txt", "w");
        #10000000 $fclose(fp_write_out);
    end

    always #5 clk = ~clk;

    initial begin
        #10 reset = 0; // Deassert reset after 10 time units
    end

    always @(posedge clk) begin
        if (reset) begin
            i <= 0;
        end else begin
            if (i < size) begin
                data_in <= mem[i];
                tvalid_in <= 1;
            end
        if (i==10)begin
            tlast_in <= 1;
        end
        else 
            tlast_in<=0;
                if (tready_out) begin
                    $fwrite(fp_write_out, "%b\n", data_out);
                    i <= i + 1;
                //end
            end else begin
                tvalid_in <= 0;
            end
        end
    end

endmodule
