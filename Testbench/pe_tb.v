module pe_tb;
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH = 2 * DATA_WIDTH + 1;

    reg clk, rst, clr;
    reg [DATA_WIDTH - 1: 0] row_in, col_in;
    wire [DATA_WIDTH - 1: 0] row_out, col_out;
    wire [ACC_WIDTH - 1: 0] c_out;
    
endmodule