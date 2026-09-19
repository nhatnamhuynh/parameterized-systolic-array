module pe_grid # (
    parameter N = 2,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = N * DATA_WIDTH + 1
)   (
    input wire clk, g_rst, g_clr, g_en,
    input wire [N * DATA_WIDTH - 1:0] row_in, col_in,
    output wire [N * ACC_WIDTH - 1:0] result_out_row
);

    // initialize wire grids
    wire [DATA_WIDTH:0] data_row [0:N][0:N], data_col[0:N][0:N];
    wire rst_row [0:N][0:N], rst_col [0:N][0:N];
    wire clr_row [0:N ][0:N], clr_col [0:N][0:N];
    wire en_row [0:N][0:N], en_col [0:N][0:N];
    wire [ACC_WIDTH - 1:0] result_in [0:N - 1][0:N];
    
    // generate PEs
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin: pe_gen_row
            for (j = 0; j < N; j = j + 1) begin: pe_gen_col
                pe pe (
                .clk(clk), 
                
                .rst_in_row(rst_row[i][j]), .rst_in_col(rst_col[i][j]),
                .clr_in_row(clr_row[i][j]), .clr_in_col(clr_col[i][j]),
                .en_in_row(en_row[i][j]), .en_in_col(en_col[i][j]),
                .row_in(data_row[i][j]), .col_in(data_col[i][j]),
                .result_in(result_in[i][j]),
                
                .rst_out_row(rst_row[i][j + 1]), .rst_out_col(rst_col[i + 1][j]),
                .clr_out_row(clr_row[i][j + 1]), .clr_out_col(clr_col[i + 1][j]),
                .en_out_row(en_row[i][j + 1]), .en_out_col(en_col[i + 1][j]),
                .row_out(data_row[i][j + 1]), .col_out(data_col[i + 1][j]),
                
                .result_out(result_in[i][j + 1])
                );
            end
        end
    endgenerate 
    
    // connect inputs
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign data_row[i][0] = row_in[i * DATA_WIDTH + DATA_WIDTH - 1:i * DATA_WIDTH];
            assign data_col[0][i] = col_in[i * DATA_WIDTH + DATA_WIDTH - 1:i * DATA_WIDTH];
            assign result_out_row[i * DATA_WIDTH + DATA_WIDTH - 1:i * DATA_WIDTH] = result_in[i][N];
        end
    endgenerate
    
    // connect global control signals
    assign rst.pe[0][0] = g_rst;
    assign clr.pe[0][0] = g_clr;
    assign en.pe[0][0] = g_en;
    
endmodule