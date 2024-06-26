module testbench;

    parameter data_width = 16;
    parameter frac_width = 14;
    parameter int_width = 2;

    // Inputs
    reg signed [data_width-1:0] A_in;
    reg signed [data_width-1:0] B_in;
    reg clk;
    reg reset;

    // Outputs
    wire signed [data_width-1:0] out;
    wire overflow_flag;
    wire underflow_flag;

    // Instantiate the add module
    add #(data_width, frac_width, int_width) uut (
        .clk(clk),
        .reset(reset),
        .A_in(A_in), 
        .B_in(B_in), 
        .out(out), 
        .overflow_flag(overflow_flag), 
        .underflow_flag(underflow_flag)
    );

    initial begin
        // Initialize inputs
        A_in = 0;
        B_in = 0;
        reset = 1;
        clk = 0;
        
        #10 reset = 0;
        // Monitor changes
        $monitor("Time: %d, A_in: %b, B_in: %b, out: %b, overflow_flag: %b, underflow_flag: %b", 
            $time, A_in, B_in, out, overflow_flag, underflow_flag);

        // Test cases
        #10 A_in = 16'b0000000000001100; 
        B_in = 16'b0000000000000011; 
        #10;
        
        #10 A_in = 16'b0111111111111111; 
        B_in = 16'b0000000000000001; 
        #10;
        
        #10 A_in = 16'b1000000000000001; 
        B_in = 16'b1000000000000001; 
        #10;
        
        #10 A_in = 16'b0000000000011000; 
        B_in = 16'b0000000000001100; 
        #10;

        #10 A_in = 16'b0111111111111111; 
        B_in = 16'b0111111111111111; 
        #10;
        
        #10 A_in = 16'b1100000000000000; 
        B_in = 16'b1100000000000000; 
        #10;
        
        #10 A_in = 16'b1000000000000001; 
        B_in = 16'b1100000000000000; 
        #10;

        #10 A_in = 16'b0000000000000001; 
        B_in = 16'b0000000000000001; 
        #10;

        #10 A_in = 16'b0111111111111100; 
        B_in = 16'b0000000000000011; 
        #10;
        
        #10 A_in = 16'b1000000000000000; 
        B_in = 16'b1000000000000000; 
        #10;

        #10 A_in = 16'b0111111111111000; 
        B_in = 16'b0000000000000100; 
        #10;

        #10 A_in = 16'b1111111111111111; 
        B_in = 16'b0000000000000001; 
        #10;

        #10 A_in = 16'b1000000000000000; 
        B_in = 16'b0000000000000001; 
        #10;

        #10 A_in = 16'b0111111111111110; 
        B_in = 16'b0000000000000001; 
        #10;

        #10 A_in = 16'b1000000000000001; 
        B_in = 16'b0111111111111111; 
        #10;

        

        #10 A_in = 16'b1111111111111111;
        B_in = 16'b1111111111111111; 
        #10;

        #10 A_in = 16'b0000000000000010; 
        B_in = 16'b1111111111111110; 
        #10;

        #10 A_in = 16'b0111111111111101;
        B_in = 16'b0000000000000010; 
        #10;

        #10 A_in = 16'b1000000000000011; 
        B_in = 16'b1000000000000011; 
        #10;
        
        // Finish simulation
        $finish;
    end
    
    always #5 clk = ~clk; 
endmodule
