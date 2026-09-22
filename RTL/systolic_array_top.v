module systolic_array_top #(
    parameter N = 2,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 2 * DATA_WIDTH + $clog2(N)
    
) (
    input wire [N * N * DATA_WIDTH - 1:0] inA_flat, inB_flat, 
    input wire clk, rst, g_en,
    output wire [N * N * ACC_WIDTH - 1:0] result_out,
    output wire ready
);
    reg clr;
    reg [$clog2(3 * N) - 1 : 0] counter = 0;
    reg [N * DATA_WIDTH - 1:0] temp_row[0:N - 1], temp_col[0:N - 1];
    wire [N * DATA_WIDTH - 1:0] row_in_flat, col_in_flat;
    wire [N * ACC_WIDTH - 1:0] result_out_row;
    reg [N * N * ACC_WIDTH - 1:0] result_reg;
    
    genvar i, j;
    integer k, l;
//    generate
//        for (i = 0; i < N; i = i + 1) begin: temp
//            reg [N * DATA_WIDTH - 1:0] temp_row, temp_col;
//        end
//    endgenerate
    
    wire internal_ready;
    assign internal_ready = (counter == 0)?1'b1:1'b0;
    assign ready = internal_ready;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            clr <= 1'b1;
            counter <= 0;
            result_reg <= {N * N * ACC_WIDTH{1'b0}};
            
            for (k = 0; k < N; k = k + 1) begin
                temp_row[k] <= {N * DATA_WIDTH{1'b0}};
                temp_col[k] <= {N * DATA_WIDTH{1'b0}};
            end

        end else begin
            clr <= 1'b0;
            if (g_en && counter == 0) begin
                for (k = 0; k < N; k = k + 1) begin
                    temp_row[k] <= inA_flat[k * N * DATA_WIDTH +: N * DATA_WIDTH];
                    for (l = 0; l < N; l = l + 1) begin
                        temp_col[k][l * DATA_WIDTH +: DATA_WIDTH] <= inB_flat[l * N * DATA_WIDTH + k * DATA_WIDTH +:DATA_WIDTH];
                    end
                end
                
                clr <= 1'b1;
                counter <= counter + 1;
                
            end else begin
                for (k = 0; k < N; k = k + 1) begin
                    if (k < counter) begin
                        temp_row[k] <= {{DATA_WIDTH{1'b0}}, temp_row[k][N * DATA_WIDTH - 1:DATA_WIDTH]};
                        temp_col[k] <= {{DATA_WIDTH{1'b0}}, temp_col[k][N * DATA_WIDTH - 1:DATA_WIDTH]};
                    end
                end
                
                result_reg <= {result_reg[(N - 1) * N * ACC_WIDTH - 1 : 0], result_out_row};
                
                if (counter > 3 * N) counter <= 0;
                else if (counter > 0) begin
                    counter <= counter + 1;
                end
            end
        end 
    end
    
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign row_in_flat[i * DATA_WIDTH +: DATA_WIDTH] = temp_row[i][DATA_WIDTH - 1:0];
            assign col_in_flat[i * DATA_WIDTH +: DATA_WIDTH] = temp_col[i][DATA_WIDTH - 1:0];
        end
    endgenerate 
    
    assign result_out = result_reg;
    
    pe_grid pe_grid (
    .clk(clk), .rst(rst), .clr(clr), .g_en(g_en), .ready(internal_ready),
    .row_in(row_in_flat), .col_in(col_in_flat),
    .result_out_row(result_out_row)
);

endmodule