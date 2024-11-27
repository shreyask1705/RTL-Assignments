module mac #(
    parameter frac_width_a = 8, 
    parameter int_width_a = 8, 
    parameter frac_width_b = 8, 
    parameter int_width_b = 8,
    parameter additional_bits = 9, // log2(300) = 8.229 300 data points --> 100 for each case
    parameter int_width_out = 16,
    parameter frac_width_out = 16,
    parameter overflow_en = 0    
) (
    input clk,
    input reset_n,
    input s_valid_a,
    input s_valid_b,
    input s_last_a,
    input s_last_b,
    output reg s_ready_a,
    output reg s_ready_b,
    input signed [int_width_a+frac_width_a-1:0] A_in,
    input signed [int_width_b+frac_width_b-1:0] B_in,
    output wire signed [int_width_out+frac_width_out-1:0] m_data,
    output reg m_valid,
    output reg m_last,
    input m_ready,
    output reg overflow_flg,
    output reg underflow_flg   
);

// Local Parameters
localparam accumulator_width = int_width_a + int_width_b + frac_width_a + frac_width_b + additional_bits;
localparam product_width = int_width_a + int_width_b + frac_width_a + frac_width_b;
localparam output_data_width = int_width_out + frac_width_out;

// Internal Registers 
reg signed [product_width-1:0]            product; 
reg signed [accumulator_width-1:0]        accumulator; 
reg signed [output_data_width-1:0]        data_out;
reg signed [output_data_width-1:0]        temp;
reg signed [int_width_a+frac_width_a-1:0] A_reg;
reg signed [int_width_b+frac_width_b-1:0] B_reg;
reg                                       valid_a;
reg                                       valid_b;
reg signed [accumulator_width-1:0]        prod_temp;

// Internal Wires 
wire reset_release;
wire system_reset_n;

// FSM States
localparam RESET    = 2'b00;
localparam MULTIPLY = 2'b01;
localparam OUTPUT   = 2'b10;

// State Variables 
reg [1:0] state, next_state;

// Reset Release logic

//assign system_reset_n = reset_n && ~reset_release;

// FSM state register
always @ (posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state <= RESET;
    end else begin
        state <= next_state;
    end
end

// Registering the Inputs before Multiplication
always @ (*) begin
    if (s_valid_a && s_ready_a) begin
        A_reg = A_in;
        valid_a = s_valid_a;
    end else begin
        A_reg = 0;
        valid_a = 0;
    end
    if (s_valid_b && s_ready_b) begin
        B_reg = B_in;
        valid_b = s_valid_b;
    end else begin
        B_reg = 0;
        valid_b = 0;
    end
end



// FSM Transitions
always @ (*) begin
    next_state = state;
    case (state)
        RESET: begin
            next_state = MULTIPLY;
        end
        MULTIPLY: begin
            if (s_last_a || s_last_b) begin
                next_state = OUTPUT;
            end else begin
                next_state = MULTIPLY;
            end
        end
        OUTPUT: begin
            if (m_ready) begin
                next_state = MULTIPLY; 
            end else begin
                next_state = OUTPUT; 
            end
        end
        default: begin
            next_state = RESET;
        end
    endcase
end

// FSM Combinational Logic
always @ (posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        product <= 0;
        accumulator <= 0;
        s_ready_a <= 0;
        s_ready_b <= 0;
        m_valid <= 0;
        m_last <= 0;
        data_out <= 0;
        overflow_flg <= 0;
        underflow_flg <= 0;  
    end else begin
        case (state)
            RESET: begin 
                s_ready_a <= 1; 
                s_ready_b <= 1;
                m_valid <= 0;
                m_last <= 0;
                accumulator <= 0;
                overflow_flg <= 0; 
                underflow_flg <= 0;  
            end
            MULTIPLY: begin 
                if (valid_a && valid_b) begin
                    product <= A_reg * B_reg;
                    prod_temp <= product; // prod_temp to avoid negative slack between product and accumulator register.
                    accumulator <= prod_temp + accumulator; 
                    temp <= {accumulator[accumulator_width-1], accumulator[product_width-2:0]};
                    
                    // Overflow and Underflow Detection
                    if (accumulator[accumulator_width-2:product_width-3] != 0 && accumulator[accumulator_width-1] == 0) begin
                        overflow_flg <= 1'b1; 
                    end else if (accumulator[accumulator_width-2:product_width-3] == 0 && accumulator[accumulator_width-1] == 1) begin
                        underflow_flg <= 1'b1;  
                    end else begin
                        overflow_flg <= 1'b0;
                        underflow_flg <= 1'b0;
                    end
                    
                    if (s_last_a || s_last_b) begin
                        m_valid <= 1; 
                        s_ready_a <= 0; 
                        s_ready_b <= 0;
                    end else begin
                        m_valid <= 0; 
                        s_ready_a <= 1; 
                        s_ready_b <= 1;
                    end
                    if (s_valid_a && !s_valid_b) begin
                        s_ready_a <= 0;
                    end else begin
                        s_ready_a <= 1;
                    end
                    if (!s_valid_a && s_valid_b) begin
                        s_ready_b <= 0;
                    end else begin
                        s_ready_b <= 1;
                    end
                end else begin
                    product <= 0;
                    accumulator <= 0;
                    temp <= 0;
                end
            end
            OUTPUT: begin
                if (m_ready) begin 
                    if (overflow_flg && overflow_en) begin
                        data_out <= 32'hFFFFFFFF;
                    end else if (overflow_flg && !overflow_en) begin
                        data_out <= temp;
                    end else begin
                        data_out <= accumulator;
                    end
                    s_ready_a <= 1; 
                    s_ready_b <= 1;
                end else begin
                    m_valid <= 1;   
                    s_ready_a <= 0;
                    s_ready_b <= 0;
                end
                if (s_last_a && s_last_b) begin
                    m_last <= 1;
                end else begin
                    m_last <= 0;
                end
                m_valid <= 0; 
            end
        endcase
    end
end

assign m_data = data_out;

// res res (
//     .ninit_done(reset_release)
// );

endmodule
