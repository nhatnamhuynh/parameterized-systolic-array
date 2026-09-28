`timescale 1ns / 1ps

module pe_grid_tb;
    parameter N = 2;
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH = 2 * DATA_WIDTH + $clog2(N); // ACC_WIDTH = 17 bits cho N = 2

    reg clk;
    reg rst;
    reg clr;
    reg en;
    reg ready;
    reg signed [N * DATA_WIDTH - 1:0] row_in;
    reg signed [N * DATA_WIDTH - 1:0] col_in;
    reg [N - 1:0] en_first_row;
    reg [N - 1:0] en_first_col;

    wire signed [N * N * ACC_WIDTH - 1:0] result_out;

    pe_grid #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .clr(clr),
        .en(en),
        .ready(ready),
        .row_in(row_in),
        .col_in(col_in),
        .en_first_row(en_first_row),
        .en_first_col(en_first_col),
        .result_out(result_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task print_results;
        input [63:0] test_name;
        input expected_rst, expected_clr;
        input signed [ACC_WIDTH - 1:0] exp_c00, exp_c01, exp_c10, exp_c11;

        reg signed [ACC_WIDTH - 1:0] rec_c00, rec_c01, rec_c10, rec_c11;

        begin 
            rec_c00 = result_out[0 * ACC_WIDTH +: ACC_WIDTH];
            rec_c01 = result_out[1 * ACC_WIDTH +: ACC_WIDTH];
            rec_c10 = result_out[2 * ACC_WIDTH +: ACC_WIDTH];
            rec_c11 = result_out[3 * ACC_WIDTH +: ACC_WIDTH];

            $display("");
            $display("--- %0s ---", test_name);
            $display("--- EXPECTED MATRIX C ---");
            $display("rst = %b \t clr = %b", expected_rst, expected_clr);
            $display("C[0][0] = %6d \t C[0][1] = %6d", exp_c00, exp_c01);
            $display("C[1][0] = %6d \t C[1][1] = %6d", exp_c10, exp_c11);

            $display("--- RECEIVED MATRIX C ---");
            $display("rst = %b \t clr = %b", rst, clr);
            $display("C[0][0] = %6d \t C[0][1] = %6d", rec_c00, rec_c01);
            $display("C[1][0] = %6d \t C[1][1] = %6d", rec_c10, rec_c11);
            
            if (rst !== expected_rst || clr !== expected_clr ||
                rec_c00 !== exp_c00 || rec_c01 !== exp_c01 ||
                rec_c10 !== exp_c10 || rec_c11 !== exp_c11) begin
                $display("--- RESULT: FAILED ---");
            end else begin
                $display("--- RESULT: PASSED ---");
            end
        end
    endtask

    initial begin
        rst = 0; clr = 0; en = 0; ready = 0;
        row_in = 0; col_in = 0;
        en_first_row = 0; en_first_col = 0;
        #10;

        // TEST 1: Global Reset
        @(posedge clk);
        rst = 1; clr = 0;
        row_in = {8'd4, 8'd3}; col_in = {8'd6, 8'd5};
        en_first_row = 2'b11; en_first_col = 2'b11;

        @(posedge clk); #1;
        print_results("Test 1: Global Reset", 1'b1, 1'b0, 17'sd0, 17'sd0, 17'sd0, 17'sd0);

        // TEST 2: Clear Grid
        rst = 0; clr = 1;
        en_first_row = 2'b00; en_first_col = 2'b00;

        @(posedge clk); #1;
        print_results("Test 2: Clear Grid", 1'b0, 1'b1, 17'sd0, 17'sd0, 17'sd0, 17'sd0);

        // TEST 3: Positive 2x2 Matrix Multiplication
        // Matrix A = [1 2; 3 4], Matrix B = [5 6; 7 8]
        // Expected Matrix C = A * B = [19 22; 43 50]
        clr = 0;

        // --- Cycle 1: A00=1, B00=5 ---
        row_in = {8'd0, 8'd1}; col_in = {8'd0, 8'd5};
        en_first_row = 2'b01; en_first_col = 2'b01;
        @(posedge clk);

        // --- Cycle 2: A01=2, A10=3, B10=7, B01=6 ---
        row_in = {8'd3, 8'd2}; col_in = {8'd6, 8'd7};
        en_first_row = 2'b11; en_first_col = 2'b11;
        @(posedge clk);

        // --- Cycle 3: A11=4, B11=8 ---
        row_in = {8'd4, 8'd0}; col_in = {8'd8, 8'd0};
        en_first_row = 2'b10; en_first_col = 2'b10;
        @(posedge clk);

        // --- Cycle 4: ---
        row_in = 0; col_in = 0;
        en_first_row = 2'b00; en_first_col = 2'b00;
        @(posedge clk);

        // --- Cycle 5: Wait for Pipeline Completion ---
        @(posedge clk); #1;
        print_results("Test 3", 1'b0, 1'b0, 17'sd19, 17'sd22, 17'sd43, 17'sd50);

        // TEST 4: Clear and Negative 2x2 Matrix Multiplication
        // Matrix A = [-2 3; 4 -1], Matrix B = [5 -3; -2 4]
        // Expected Matrix C = [-16 18; 22 -16]
        @(posedge clk); #1;
        clr = 1;

        @(posedge clk); #1;
        clr = 0;

        // --- Cycle 1: A00=-2, B00=5 ---
        row_in = {8'd0, -8'd2}; col_in = {8'd0, 8'd5};
        en_first_row = 2'b01; en_first_col = 2'b01;
        @(posedge clk);

        // --- Cycle 2: A01=3, A10=4, B10=-2, B01=-3 ---
        row_in = {8'd4, 8'd3}; col_in = {-8'd3, -8'd2};
        en_first_row = 2'b11; en_first_col = 2'b11;
        @(posedge clk);

        // --- Cycle 3: A11=-1, B11=4 ---
        row_in = {-8'd1, 8'd0}; col_in = {8'd4, 8'd0};
        en_first_row = 2'b10; en_first_col = 2'b10;
        @(posedge clk);

        // --- Cycle 4: ---
        row_in = 0; col_in = 0;
        en_first_row = 2'b00; en_first_col = 2'b00;
        @(posedge clk);

        // --- Cycle 5: Wait for Pipeline Completion ---
        @(posedge clk); #1;
        print_results("Test 4", 1'b0, 1'b0, -17'sd16, 17'sd18, 17'sd22, -17'sd16);

        $finish;
    end

endmodule