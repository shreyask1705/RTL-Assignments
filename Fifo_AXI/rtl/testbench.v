module dual_fifo_tb;

    parameter data_width = 16;
    parameter size = 2048;

    reg clk;
    reg reset;
    
    reg [data_width-1:0] mem [0:24000];
    integer i;
    integer fp_write_out0;
    integer fp_write_out1;
    
    // FIFO 0 signals
    reg [data_width-1:0] data_in0;
    reg s_axis_tvalid_f0;
    reg s_axis_tlast_f0;
    wire s_axis_tready_f0;
    wire [data_width-1:0] data_out0;
    
    // FIFO 1 signals
    wire [data_width-1:0] data_out1;
    wire m_axis_tvalid_f1;
    wire m_axis_tlast_f1;
    reg m_axis_tready_f1;

    // Instantiate the dual_fifo module
    dual_fifo #(
        .data_width(data_width),
        .size(size)
    ) uut (
        .clk(clk),
        .reset(reset),
        .data_in0(data_in0),
        .s_axis_tvalid_f0(s_axis_tvalid_f0),
        .s_axis_tlast_f0(s_axis_tlast_f0),
        .s_axis_tready_f0(s_axis_tready_f0),
        .data_out0(data_out0),
        .data_out1(data_out1),
        .m_axis_tvalid_f1(m_axis_tvalid_f1),
        .m_axis_tlast_f1(m_axis_tlast_f1),
        .m_axis_tready_f1(m_axis_tready_f1)
    );
    
    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        data_in0 = 0;
        s_axis_tvalid_f0 = 0;
        s_axis_tlast_f0 = 0;
        m_axis_tready_f1 = 1;  // Enable reading from FIFO 1

        $readmemb("C:/Users/shrsk/Downloads/inp_bin.dat", mem);
        fp_write_out0 = $fopen("out_fifo0_bin.txt", "w");
        fp_write_out1 = $fopen("out_fifo1_bin.txt", "w");
        
        // Reset the FIFOs
        #10 reset = 0;
    end

    always @(negedge clk) begin
        if (reset) begin
            i <= 0;
        end else begin
            if (i < 24000) begin
                if (s_axis_tready_f0) begin
                    data_in0 <= mem[i];
                    s_axis_tvalid_f0 <= 1;
                    if (i == 10) begin
                        s_axis_tlast_f0 <= 1;
                    end else begin
                        s_axis_tlast_f0 <= 0;
                    end
                    i <= i + 1;
                end else begin
                    s_axis_tvalid_f0 <= 0;
                end
            end else begin
                s_axis_tvalid_f0 <= 0;
                s_axis_tlast_f0 <= 0;
            end

            // Write output data to file
            if (m_axis_tvalid_f1 && m_axis_tready_f1) begin
                $fwrite(fp_write_out1, "%b\n", data_out1);
            end
            
            // Write FIFO 0 output data to file
            if (s_axis_tvalid_f0 && s_axis_tready_f0) begin
                $fwrite(fp_write_out0, "%b\n", data_out0);
            end
        end
    end

    initial begin
        // Close the files at the end of the simulation
        #500000 begin
            $fclose(fp_write_out0);
            $fclose(fp_write_out1);
        end
        $stop;
    end

endmodule
