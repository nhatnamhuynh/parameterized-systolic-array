module pe_grid # (
    parameter N = 2,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 2 * DATA_WIDTH + $clog2(N)
)   (
    input wire clk, rst, clr, g_en, ready,
    input wire [N * DATA_WIDTH - 1:0] row_in, col_in,
    output wire [N * ACC_WIDTH - 1:0] result_out_row
);

    // initialize wire grids
    wire [DATA_WIDTH - 1:0] data_row [0:N][0:N], data_col[0:N][0:N];
    wire en_row [0:N][0:N], en_col [0:N][0:N];
    wire [ACC_WIDTH - 1:0] result_in [0:N][0:N - 1];
    
    // generate PEs
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin: pe_gen_row
            for (j = 0; j < N; j = j + 1) begin: pe_gen_col
                pe pe (
                .clk(clk), .rst(rst), .clr(clr), .ready(ready),
                
                .en_row_in(en_row[i][j]), .en_col_in(en_col[i][j]),
                .row_in(data_row[i][j]), .col_in(data_col[i][j]),
                .result_in(result_in[i][j]),
                
                .en_row_out(en_row[i][j + 1]), .en_col_out(en_col[i + 1][j]),
                .row_out(data_row[i][j + 1]), .col_out(data_col[i + 1][j]),
                
                .result_out(result_in[i + 1][j])
                );
            end
        end
    endgenerate 
    
    // connect inputs
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign data_row[i][0] = row_in[i * DATA_WIDTH + DATA_WIDTH - 1:i * DATA_WIDTH];
            assign data_col[0][i] = col_in[i * DATA_WIDTH + DATA_WIDTH - 1:i * DATA_WIDTH];
            assign result_in[0][i] = {ACC_WIDTH{1'b0}}; 
            assign result_out_row[i * ACC_WIDTH +:ACC_WIDTH] = result_in[N][i];
            assign en_row[i][0] = g_en;
            assign en_col[0][i] = g_en;
        end
    endgenerate
    
endmodule