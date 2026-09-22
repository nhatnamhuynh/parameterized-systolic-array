module systolic_array_top #(
    parameter N = 2,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 2 * DATA_WIDTH + $clog2(N)
    
) (
    input wire [N * N * DATA_WIDTH - 1:0] inA_flat, inB_flat, 
    input wire clk, g_rst, g_en,
    output wire [N * ACC_WIDTH - 1:0] result_out,
    output wire ready
);
    reg g_clr;
    reg [$clog2(3 * N) - 1 : 0] counter;
    reg [N * DATA_WIDTH - 1:0] temp_row[0:N - 1], temp_col[0:N - 1];
    reg [N * DATA_WIDTH - 1:0] row_in_flat, col_in_flat;
    
    genvar i, j;
    integer k, l;
//    generate
//        for (i = 0; i < N; i = i + 1) begin: temp
//            reg [N * DATA_WIDTH - 1:0] temp_row, temp_col;
//        end
//    endgenerate
    
    assign ready = (counter == 0)?1'b1:1'b0;

    always @(posedge clk, posedge g_rst) begin
        if (g_rst) begin
            g_clr <= 1'b1;
            counter <= 0;
            
            for (k = 0; k < N; k = k + 1) begin
                temp_row[k] <= {N * DATA_WIDTH{1'b0}};
                temp_col[k] <= {N * DATA_WIDTH{1'b0}};
            end

        end else begin
            if (g_en && counter == 0) begin
                for (k = 0; k < N; k = k + 1) begin
                    temp_row[k] <= inA_flat[k * N * DATA_WIDTH +: N * DATA_WIDTH];
                    for (l = 0; l < N; l = l + 1) begin
                        temp_col[k][l * DATA_WIDTH +: DATA_WIDTH] <= inB_flat[l * N * DATA_WIDTH + k * DATA_WIDTH +:DATA_WIDTH];
                    end
                end
                
                g_clr <= 1'b1;
                
            end
            
            for (k = 0; k < N; k = k + 1) begin
                if (k <= counter) begin
                    temp_row[k] <= {{DATA_WIDTH{1'b0}}, temp_row[k][N * DATA_WIDTH - 1:DATA_WIDTH]};
                    temp_col[k] <= {{DATA_WIDTH{1'b0}}, temp_col[k][N * DATA_WIDTH - 1:DATA_WIDTH]};
                end
            end
            
            if (counter > 3 * N - 1) counter <= 0;
            else if (counter > 0) counter <= counter + 1;
        end 
        
        for (k = 0; k < N; k = k + 1) begin
            row_in_flat[k * DATA_WIDTH +: DATA_WIDTH] <= temp_row[k][DATA_WIDTH - 1:0];
            col_in_flat[k * DATA_WIDTH +: DATA_WIDTH] <= temp_col[k][DATA_WIDTH - 1:0];
        end
    end
    
    pe_grid pe_grid (
    .clk(clk), .g_rst(g_rst), .g_clr(g_clr), .g_en(g_en),
    .row_in(row_in_flat), .col_in(col_in_flat),
    .result_out_row(result_out)
);

endmodule