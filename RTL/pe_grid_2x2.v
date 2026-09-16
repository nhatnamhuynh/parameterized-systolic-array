module pe_grid_2x2 # (
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 2 * DATA_WIDTH + 1
)   (
    input wire clk, rst, clr,
    input wire [DATA_WIDTH - 1:0] row_in_0, row_in_1, col_in_0, col_in_1,
    output wire [ACC_WIDTH - 1:0] acc_out_0, acc_out_1, acc_out_2, acc_out_3
);

    wire [DATA_WIDTH - 1:0] row_01, row_23, col_02, col_13;
    
    pe pe0 (
        .clk(clk), .rst(rst), .clr(clr),
        .row_in(row_in_0), .row_out(row_01),
        .col_in(col_in_0), .col_out(col_02),
        .acc_out(acc_out_0)
        );
        
    pe pe1 (
        .clk(clk), .rst(rst), .clr(clr),
        .row_in(row_01), .row_out(),
        .col_in(col_in_1), .col_out(col_13),
        .acc_out(acc_out_1)
        );
        
    pe pe2 (
        .clk(clk), .rst(rst), .clr(clr),
        .row_in(row_in_1), .row_out(row_23),
        .col_in(col_02), .col_out(),
        .acc_out(acc_out_2)
        );
        
     pe pe3 (
        .clk(clk), .rst(rst), .clr(clr),
        .row_in(row_23), .row_out(),
        .col_in(col_13), .col_out(),
        .acc_out(acc_out_3)
        );      
    
endmodule