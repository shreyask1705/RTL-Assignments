module mac_tb;

// Parameters
parameter frac_width_a = 8; 
parameter int_width_a = 8;
parameter frac_width_b = 8; 
parameter int_width_b = 8;
parameter additional_bits = 9; //log2(300) = 8.229 300 data points --> 100 for each case
parameter int_width_out = 16;
parameter frac_width_out = 16;
parameter overflow_en = 1;

// Inputs
reg clk;
reg reset_n;
reg s_valid_a;
reg s_valid_b;
reg s_last_a;
reg s_last_b;
reg signed [int_width_a+frac_width_a-1:0] A_in;
reg signed [int_width_b+frac_width_b-1:0] B_in;
reg m_ready;

// Outputs
reg s_ready_a;
reg s_ready_b;
reg signed [int_width_out+frac_width_out-1:0] m_data;
reg m_valid;
wire m_last;
wire overflow_flg;
wire underflow_flg;

// Instantiate the module
mac #(
    .frac_width_a(frac_width_a),
    .int_width_a(int_width_a),
    .frac_width_b(frac_width_b), 
    .int_width_b(int_width_b),
    .additional_bits(additional_bits), 
    .int_width_out(int_width_out),
    .frac_width_out(frac_width_out),
    .overflow_en(overflow_en)
) uut
(
    .clk(clk), 
    .reset_n(reset_n), 
    .s_valid_a(s_valid_a), 
    .s_valid_b(s_valid_b), 
    .s_last_a(s_last_a), 
    .s_last_b(s_last_b), 
    .s_ready_a(s_ready_a), 
    .s_ready_b(s_ready_b), 
    .A_in(A_in), 
    .B_in(B_in), 
    .m_data(m_data), 
    .m_valid(m_valid), 
    .m_last(m_last), 
    .m_ready(m_ready),
    .overflow_flg(overflow_flg),
    .underflow_flg(underflow_flg)
);

//integer i = 0;
// Clock generation
always #5 clk = ~clk; 

integer throttle_count=0;
integer j; 
integer wait_n;
task throttle_std;
    input int throttle_value;
    //input int maxCount;
    input [int_width_a+frac_width_a-1:0] data_a;
    input [int_width_a+frac_width_a-1:0] data_b;

    for (j=0;j<throttle_value;j=j+1) begin
        s_valid_a = 1;
        s_valid_b = 1;
    end

    wait (!(s_ready_a && s_ready_b)) @ (posedge clk); // Wait for both ready to be high

    if (s_ready_a && s_ready_b) begin     
        s_valid_a <=0;
        s_valid_b <=0;
    end else begin
        s_valid_a <=1;
        s_valid_b <=1;
    end
    wait_n = $urandom % throttle_value;
    
    repeat (wait_n) begin
        @(posedge clk);
    end


endtask

task throttle;
    input [7:0] throttle_limit;
begin
    while (throttle_count < throttle_limit) begin
        s_valid_a = 0;
        s_valid_b = 0;
        
        throttle_count = throttle_count + 1;
        @(posedge clk);  
    end

    s_valid_a = 1;
    s_valid_b = 1;

   
    throttle_count = 0;
end
endtask

//Throttle based on ready
task throttle2;
    m_ready = 0;
    m_data = $random;
    m_valid = 1;
    #100 m_ready = 1;
    wait (m_ready == 1);
    @(posedge clk);
   


endtask



// Task for case 1: A is constant, B changes
task case1;
    input signed [int_width_a+frac_width_a-1:0] const_A;
    
    begin
        fork
            A_in = const_A;
            s_valid_a = 1;
            s_valid_b = 1;
            repeat (100) begin
                #10 B_in = B_in + 1;  
            end  
        join
        
        s_last_b = 1;
        s_last_a = 1;
        # 10 s_last_b = 0; s_last_a = 0;
        
        // Disable valid signals for 3 cycles
        s_valid_a = 0;
        s_valid_b = 0;
        #30;
    end
endtask

// Task for case 2: B is constant, A changes
task case2;
    input signed [int_width_b+frac_width_b-1:0] const_B;
    begin
        B_in = const_B;
        s_valid_a = 1;
        s_valid_b = 1;

        repeat (100) begin
            #10 A_in = A_in + 1;  
        end
        s_last_a = 1;
        s_last_b = 1;
        #10 s_last_a = 0; s_last_b = 0;
        
        // Disable valid signals for 3 cycles
        s_valid_a = 0;
        s_valid_b = 0;
        #30;
    end
endtask

// Task for case 3: Both A and B change every clock cycle
task case3;
    s_valid_a <= 1;
    s_valid_b <= 1;
    begin
        repeat (100) begin
            #10;
            A_in = A_in + 2;  
            B_in = B_in + 1;  
            
            if (A_in % 3 == 0) begin  
                s_last_a = 1;
            end else begin
                s_last_a = 0;
            end

            if (B_in % 5 == 0) begin  
                s_last_b = 1;
            end else begin
                s_last_b = 0;
            end
        end
        
       
    end
endtask

task reset;
    #10 reset_n = 0;
    #30
    reset_n = 1;        

endtask

task valid_toggle;
    integer i;  
    input [7:0] n;
begin
    
    for (i = 0; i < n; i = i + 1) begin
        s_valid_a = 1;  
        s_valid_b = 0;  
        @(posedge clk);  
    end
end
endtask
integer k=0;
task ready_toggle;
    input [7:0] num;
    
    begin
        while (k<num) begin
            s_ready_a = 1;
            s_ready_b = 0;
            k = k + 1;
            @(posedge clk);
            
        end
        k=0;
    end
endtask


// Testbench procedure
initial begin
    // Initialize Inputs
    clk = 0;
    reset_n = 0;
    s_valid_a = 0;
    s_valid_b = 0; 
    s_last_a = 0;
    s_last_b = 0;
    A_in = 0;
    B_in = 0;
    m_ready = 1;

    // Reset 
    @(posedge clk);
    reset_n = 1;
    
    //  Case 1: A constant, B changing
    case1(16'h1000);  
    @(negedge clk);   
    
    throttle(25);
    //throttle2();

    //  Case 2: B constant, A changing
    case2(16'h0100);  
    @(negedge clk);   
    //#30;
    valid_toggle(10);
    //ready_toggle(10);

    //  Case 3: Both A and B changing
    case3();

    #50;
    $finish;
end

endmodule
