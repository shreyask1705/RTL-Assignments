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
    reg s_axis_tvalid;
    wire s_axis_tready;
    //wire m_axis_tdata;
    wire m_axis_tlast;
    wire m_axis_tvalid;
    reg m_axis_tready;
    //reg tdata_in;
    reg s_axis_tlast;

    reg [data_width-1:0] mem [0:size-1];
    
    // Instantiation of the module
    register uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out),
        .s_axis_tvalid(s_axis_tvalid),
        //.tdata_in(tdata_in),
        .m_axis_tready(m_axis_tready),
        //.tlast_in(tlast_in),
        .m_axis_tvalid(m_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),
        .m_axis_tlast(m_axis_tlast)
    );

    integer i; 
    integer fp_write_out;

    initial begin
        clk = 0; reset = 1;
        s_axis_tvalid=1;
        //tdata_in=1;
        m_axis_tready=1;
        s_axis_tlast=0;
        i = 0;
        $readmemb("C:/Users/shrsk/Downloads/inp_bin.dat", mem);
        fp_write_out = $fopen("out_bin.txt", "w");
        #10000000 $fclose(fp_write_out);
    end

    always #5 clk = ~clk;

    initial begin
        #10 reset = 0; // Deassert reset after 10 time units
    end

    always @(negedge clk) begin
        if (reset) begin
            i <= 0;
        end else begin
            if (i < size) begin
                data_in <= mem[i];
                s_axis_tvalid <= 1;
            end
        if (i==10)begin
            s_axis_tlast <= 1;
        end
        else 
            s_axis_tlast<=0;
                if (s_axis_tready) begin
                    $fwrite(fp_write_out, "%b\n", data_out);
                    i <= i + 1;
                //end
            end else begin
                s_axis_tvalid <= 0;
            end
        end
    end

endmodule
