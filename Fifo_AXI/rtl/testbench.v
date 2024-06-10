module dual_fifo_tb;

    parameter data_width = 16;
    parameter size = 2048;

    reg clk;
    reg reset;
    
    reg [data_width-1:0] mem [0:24000];
    integer i;
    integer fp_write_out;
    
    // FIFO 0 signals
    reg [data_width-1:0] data_in0;
    reg tvalid_in0;
    reg tlast_in0;
    wire tready_out0;
    wire [data_width-1:0] data_out0;
    
    // FIFO 1 signals
    wire [data_width-1:0] data_out1;
    wire tvalid_out1;
    wire tlast_out1;
    reg tready_in1;

    // Instantiate the dual_fifo module
    dual_fifo #(
        .data_width(data_width),
        .size(size)
    ) uut (
        .clk(clk),
        .reset(reset),
        .data_in0(data_in0),
        .tvalid_in0(tvalid_in0),
        .tlast_in0(tlast_in0),
        .tready_out0(tready_out0),
        .data_out1(data_out1),
        .tvalid_out1(tvalid_out1),
        .tlast_out1(tlast_out1),
        .tready_in1(tready_in1)
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
        tvalid_in0 = 0;
        tlast_in0 = 0;
        tready_in1 = 1;  // Enable reading from FIFO 1

        $readmemb("C:/Users/shrsk/Downloads/inp_bin.dat", mem);
        fp_write_out = $fopen("out_bin.txt", "w");
        
        // Reset the FIFOs
        #10 reset = 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            i <= 0;
        end else begin
            if (i < 24000) begin
                if (tready_out0) begin
                    data_in0 <= mem[i];
                    tvalid_in0 <= 1;
                    if (i == 10) begin
                        tlast_in0 <= 1;
                    end else begin
                        tlast_in0 <= 0;
                    end
                    i <= i + 1;
                end else begin
                    tvalid_in0 <= 0;
                end
            end else begin
                tvalid_in0 <= 0;
                tlast_in0 <= 0;
            end

            // Write output data to file
            if (tvalid_out1 && tready_in1) begin
                $fwrite(fp_write_out, "%b\n", data_out1);
            end
        end
    end

    initial begin
        // Close the file at the end of the simulation
        #500000 $fclose(fp_write_out);  // Increased simulation time
        $stop;
    end

endmodule