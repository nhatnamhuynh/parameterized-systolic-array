`timescale 1ns / 1ps

module pe_tb;
    parameter N = 16;
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH = 2 * DATA_WIDTH + $clog2(N);

    reg clk;
    reg rst;
    reg clr;
    reg en_row_in;
    reg en_col_in;
    reg signed [DATA_WIDTH - 1:0] row_in;
    reg signed [DATA_WIDTH - 1:0] col_in;

    wire en_row_out;
    wire en_col_out;
    wire signed [DATA_WIDTH - 1:0] row_out;
    wire signed [DATA_WIDTH - 1:0] col_out;
    wire signed [ACC_WIDTH - 1:0]  result_out;

    pe #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .clr(clr),
        .en_row_in(en_row_in),
        .en_col_in(en_col_in),
        .row_in(row_in),
        .col_in(col_in),
        .en_row_out(en_row_out),
        .en_col_out(en_col_out),
        .row_out(row_out),
        .col_out(col_out),
        .result_out(result_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task print_results;
        input [63:0] test_name;
        input expected_rst, expected_clr;
        input signed [DATA_WIDTH - 1:0] expected_row_in, expected_col_in;
        input signed [DATA_WIDTH - 1:0] expected_row_out, expected_col_out;
        input signed [ACC_WIDTH - 1:0]  expected_result_out;

        begin 
            $display("");
            $display("--- %0s ---", test_name);
            $display("--- EXPECTED VALUE ---");
            $display("rst = %b \t clr = %b \t row_in = %4d \t col_in = %4d \t row_out = %4d \t col_out = %4d \t result_out = %6d",
                      expected_rst, expected_clr, expected_row_in, expected_col_in,
                      expected_row_out, expected_col_out, expected_result_out);
            $display("--- RECEIVED VALUE ---");
            $display("rst = %b \t clr = %b \t row_in = %4d \t col_in = %4d \t row_out = %4d \t col_out = %4d \t result_out = %6d",
                      rst, clr, $signed(row_in), $signed(col_in), $signed(row_out), $signed(col_out), $signed(result_out));
            
            if (rst !== expected_rst || clr !== expected_clr ||
                row_in !== expected_row_in || col_in !== expected_col_in ||
                row_out !== expected_row_out || col_out !== expected_col_out ||
                result_out !== expected_result_out) begin
                $display("--- RESULT: FAILED ---");
            end else begin
                $display("--- RESULT: PASSED ---");
            end
        end
    endtask

    initial begin
        rst = 0; clr = 0;
        en_row_in = 0; en_col_in = 0;
        row_in = 0; col_in = 0;
        #10;

        // TEST 1: Global Reset
        @(posedge clk);
        rst = 1; clr = 0;
        row_in = 8'd3; col_in = 8'd4;
        @(posedge clk); #1;
        print_results("Test 1", 1'b1, 1'b0, 8'sd3, 8'sd4, 8'sd0, 8'sd0, 20'sd0);

        // TEST 2: Clear & Load 1st Product (3 * 4) [Multiplication Stage]
        rst = 0; clr = 1;
        en_row_in = 1; en_col_in = 1;
        row_in = 8'd3; col_in = 8'd4;
        
        @(posedge clk); #1;
        // result_out = 0 (cleared), mul_reg = 3 * 4 = 12 
        print_results("Test 2", 1'b0, 1'b1, 8'sd3, 8'sd4, 8'sd3, 8'sd4, 20'sd0);

        // TEST 3: Accumulate 1st Product (0 + 12 = 12) & Load 2nd Product (5 * 6)
        clr = 0;
        en_row_in = 1; en_col_in = 1;
        row_in = 8'd5; col_in = 8'd6;
        
        @(posedge clk); #1;
        // result_out = 0 + 12 = 12, mul_reg = 5 * 6 = 30
        print_results("Test 3", 1'b0, 1'b0, 8'sd5, 8'sd6, 8'sd5, 8'sd6, 20'sd12);

        // TEST 4: Accumulate 2nd Product & Load Negative
        en_row_in = 1; en_col_in = 1;
        row_in = -8'd10; col_in = 8'd5;
        
        @(posedge clk); #1;
        // result_out = 12 + 30 = 42, mul_reg = -10 * 5 = -50
        print_results("Test 4", 1'b0, 1'b0, -8'sd10, 8'sd5, -8'sd10, 8'sd5, 20'sd42);

        // TEST 5: Accumulate Negative Product
        en_row_in = 0; en_col_in = 0; // stop loading new inputs
        row_in = 8'd0; col_in = 8'd0;
        
        @(posedge clk); #1;
        // result_out = 42 - 50 = -8
        print_results("Test 5", 1'b0, 1'b0, 8'sd0, 8'sd0, 8'sd0, 8'sd0, -20'sd8);

        // TEST 6: Clear result_out
        clr = 1;
        en_row_in = 0; en_col_in = 0;
        row_in = 8'd0; col_in = 8'd0;
        
        @(posedge clk); #1;
        print_results("Test 6", 1'b0, 1'b1, 8'sd0, 8'sd0, 8'sd0, 8'sd0, 20'sd0);

        $finish;
    end

endmodule