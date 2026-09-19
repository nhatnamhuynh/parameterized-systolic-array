module pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 2 * DATA_WIDTH + 1
) (
    input wire clk,
    input wire rst_in_row, rst_in_col, 
    input wire clr_in_row, clr_in_col, 
    input wire en_in_row, en_in_col,
    input wire [ACC_WIDTH - 1: 0] result_in,
    input wire [DATA_WIDTH - 1: 0] row_in, col_in,
    output reg [DATA_WIDTH - 1: 0] row_out, col_out,
    output reg [ACC_WIDTH - 1: 0] result_out,
    output reg rst_out_row, rst_out_col, 
    output reg clr_out_row, clr_out_col, 
    output reg en_out_row, en_out_col
);
    
//    always @(posedge clk, posedge rst) begin
//        if (rst) begin
//            row_out <= {DATA_WIDTH {1'b0}};
//            col_out <= {DATA_WIDTH {1'b0}};
//            acc_out <= {ACC_WIDTH{1'b0}};
//        end else begin
//            row_out <= row_in;
//            col_out <= col_in;

//            if (clr) begin
//                acc_out <= $signed(row_in) * $signed(col_in);
//            end else begin
//                acc_out <= $signed(acc_out) + $signed(row_in) * $signed(col_in);
//            end
//        end
//    end
    
endmodule