module systolic_array_top #(
    parameter N = 2,
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = N * DATA_WIDTH + 1
    
) (
    input wire [N * N * DATA_WIDTH - 1:0] inA_flat, inB_flat, 
    input wire clk, g_rst, g_en,
    output wire [N * N * ACC_WIDTH - 1:0] acc_out_0,
    output wire ready
);
    reg g_clr;
    reg [2:0] counter;
    reg [N * N * DATA_WIDTH - 1:0] row_in_flat, col_in_flat;
    
    always@(*) begin
        row_in_flat <= inA_flat;
    end 
    
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin
            reg [N * DATA_WIDTH - 1:0] temp_col;
            for (j = 0; j < N; j = j + 1) begin
                always@(*) begin
                    temp_col[j * DATA_WIDTH + DATA_WIDTH - 1:j * DATA_WIDTH] <= inB_flat[i * DATA_WIDTH + j * N * DATA_WIDTH + DATA_WIDTH - 1:i * DATA_WIDTH + j * N * DATA_WIDTH];
                end
            end 
            always@(*) begin
                col_in_flat[i * N * DATA_WIDTH + N * DATA_WIDTH - 1:i * N * DATA_WIDTH] <= temp_col;
            end
        end
    endgenerate
    //////////////////////////////////////////
    
    wire [DATA_WIDTH - 1:0] inA [0:3];
    wire [DATA_WIDTH - 1:0] inB [0:3];

    assign inA[0] = inA_flat[1 * DATA_WIDTH - 1 : 0 * DATA_WIDTH];
    assign inA[1] = inA_flat[2 * DATA_WIDTH - 1 : 1 * DATA_WIDTH];
    assign inA[2] = inA_flat[3 * DATA_WIDTH - 1 : 2 * DATA_WIDTH];
    assign inA[3] = inA_flat[4 * DATA_WIDTH - 1 : 3 * DATA_WIDTH];

    assign inB[0] = inB_flat[1 * DATA_WIDTH - 1 : 0 * DATA_WIDTH];
    assign inB[1] = inB_flat[2 * DATA_WIDTH - 1 : 1 * DATA_WIDTH];
    assign inB[2] = inB_flat[3 * DATA_WIDTH - 1 : 2 * DATA_WIDTH];
    assign inB[3] = inB_flat[4 * DATA_WIDTH - 1 : 3 * DATA_WIDTH];

    assign ready = (counter == 3'd0)?1'b1:1'b0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            clr <= 1'b1;
            counter <= 3'd0;
            
            temp_row_0 <= {2 * DATA_WIDTH{1'b0}};
            temp_row_1 <= {2 * DATA_WIDTH{1'b0}};
            temp_col_0 <= {2 * DATA_WIDTH{1'b0}};
            temp_col_1 <= {2 * DATA_WIDTH{1'b0}};
            
            row_in_0 <= {DATA_WIDTH{1'b0}};
            row_in_1 <= {DATA_WIDTH{1'b0}};
            col_in_0 <= {DATA_WIDTH{1'b0}};
            col_in_1 <= {DATA_WIDTH{1'b0}};
        end else if (en == 1'b1 && counter == 3'd0) begin
            clr <= 1'b1;
            counter <= counter + 3'd1;
            
            row_in_0 <= inA[0];
            row_in_1 <= {DATA_WIDTH{1'b0}};
            col_in_0 <= inB[0];
            col_in_1 <= {DATA_WIDTH{1'b0}};
            
            temp_row_0 <= {{DATA_WIDTH{1'b0}}, inA[1]};
            temp_row_1 <= {inA[3], inA[2]};
            temp_col_0 <= {{DATA_WIDTH{1'b0}}, inB[2]};
            temp_col_1 <= {inB[3], inB[1]};
        end else if (counter > 3'd0) begin   
            clr <= 1'b0;  
            if (counter >= 3'd4) counter <= 3'd0;
            else counter <= counter + 3'd1;
            
            row_in_0 <= temp_row_0[DATA_WIDTH - 1:0]; 
            row_in_1 <= temp_row_1[DATA_WIDTH - 1:0]; 
            col_in_0 <= temp_col_0[DATA_WIDTH - 1:0]; 
            col_in_1 <= temp_col_1[DATA_WIDTH - 1:0]; 
            
            temp_row_0 <= temp_row_0 >> DATA_WIDTH;
            temp_row_1 <= temp_row_1 >> DATA_WIDTH;
            temp_col_0 <= temp_col_0 >> DATA_WIDTH;
            temp_col_1 <= temp_col_1 >> DATA_WIDTH;
        end
    end
    
    pe_grid pe_grid (
    .clk(clk), .g_rst(g_rst), .g_clr(g_clr), .g_en(g_en),
    .row_in(.data_row), .col_in(.data_col),
    .acc_out_row()
);

endmodule














//    generate
//        for (i = 0; i < N; i = i + 1) begin
//            for (j = 0; j < N; j = j + 1) begin
//                always@(*) begin
//                    inA[i][j] <= inA_flat[i * N * DATA_WIDTH + (j + 1) * DATA_WIDTH - 1:i * N * DATA_WIDTH + j * DATA_WIDTH];
//                    inB[i][j] <= inB_flat[i * N * DATA_WIDTH + (j + 1) * DATA_WIDTH - 1:i * N * DATA_WIDTH + j * DATA_WIDTH];
//                end
//            end
//        end
//    endgenerate
    
//    generate
//        for (i = 0; i < N; i = i + 1) begin
//            reg [N * DATA_WIDTH - 1:0] temp_row;
//            always@(*) begin
//                temp_row <= inA_flat[(i + 1) * N * DATA_WIDTH - 1:i * N * DATA_WIDTH];
//            end
//        end
//    endgenerate