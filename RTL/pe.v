module pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 2 * DATA_WIDTH + 1
) (
    input wire clk, rst, clr,
    input wire [DATA_WIDTH - 1: 0] row_in, col_in,
    output reg [DATA_WIDTH - 1: 0] row_out, col_out,
    output reg [ACC_WIDTH - 1: 0] c_out
);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row_out <= {DATA_WIDTH {1'b0}};
            col_out <= {DATA_WIDTH {1'b0}};
            c_out <= {ACC_WIDTH{1'b0}};
        end else begin
            row_out <= row_in;
            col_out <= col_in;

            if (clr) begin
                c_out <= row_in * col_in;
            end else begin
                c_out <= c_out + row_in * col_in;
            end
        end
    end
    
endmodule