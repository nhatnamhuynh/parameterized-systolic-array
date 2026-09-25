module pe #(
    parameter N = 2,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 2 * DATA_WIDTH + $clog2(N)
) (
    input wire clk, rst, clr,
    input wire en_row_in, en_col_in, ready, 
    input wire signed [DATA_WIDTH - 1: 0] row_in, col_in,
    input wire signed [ACC_WIDTH - 1: 0] result_in,

    output reg en_row_out, en_col_out,
    output reg signed [DATA_WIDTH - 1: 0] row_out, col_out,
    output reg signed [ACC_WIDTH - 1: 0] result_out
);
    reg signed [ACC_WIDTH - 1:0] pe_acc;
    reg signed [ACC_WIDTH - 1:0] mul_reg;
    reg mul_ready;

    wire main_en;
    assign main_en = (en_row_in & en_col_in)? 1'b1:1'b0;

    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            en_row_out <= 1'b0;
            en_col_out <= 1'b0;
            row_out <= {DATA_WIDTH {1'b0}};
            col_out <= {DATA_WIDTH {1'b0}};
            result_out <= {ACC_WIDTH{1'b0}};
            pe_acc <= {ACC_WIDTH{1'b0}};
            mul_reg <= {ACC_WIDTH{1'b0}};
            mul_ready <= 1'b0;
        end else begin
        
            en_row_out <= en_row_in;
            en_col_out <= en_col_in;
            row_out <= row_in;
            col_out <= col_in;
            
            if (clr) begin
                pe_acc <= {ACC_WIDTH{1'b0}};
            end else if (mul_ready) begin
                pe_acc <= pe_acc + mul_reg;
            end

            if (main_en) begin
                mul_reg <= row_in * col_in;
                mul_ready <= 1'b1;
            end else begin
                mul_ready <= 1'b0;
            end

            if (ready) begin
                result_out <= pe_acc;
            end else begin
                result_out <= result_in;
            end
        end

    end
    
endmodule