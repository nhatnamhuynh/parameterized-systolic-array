`timescale 1ns / 1ps

module pe_tb;
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH = 2 * DATA_WIDTH + 1;

    reg clk, rst, clr;
    reg [DATA_WIDTH - 1: 0] row_in, col_in;
    wire [DATA_WIDTH - 1: 0] row_out, col_out;
    wire [ACC_WIDTH - 1: 0] acc_out;

    pe #(.DATA_WIDTH(DATA_WIDTH)) uut (
        .clk(clk), .rst(rst), .clr(clr),
        .row_in(row_in), .col_in(col_in),
        .row_out(row_out), .col_out(col_out),
        .acc_out(acc_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task print_results;
        input [63:0] test;
        input expected_rst, expected_clr;
        input [DATA_WIDTH - 1: 0] expected_row_in, expected_col_in,
                                  expected_row_out, expected_col_out;
        input [ACC_WIDTH - 1: 0] expected_acc_out;

        begin 
            $display ("");
            $display ("--- %s ---", test);
            $display ("--- EXPECTED VALUE ---");
            $display ("rst = %b \t clr = %b \t row_in = %3d \t col_in = %3d \t row_out = %3d \t col_out = %3d \t acc_out = %6d",
                      expected_rst, expected_clr, $signed(expected_row_in), $signed(expected_col_in),
                      $signed(expected_row_out), $signed(expected_col_out), $signed(expected_acc_out));
            $display ("--- RECEIVED VALUE ---");
            $display ("rst = %b \t clr = %b \t row_in = %3d \t col_in = %3d \t row_out = %3d \t col_out = %3d \t acc_out = %6d",
                      rst, clr, $signed(row_in), $signed(col_in), $signed(row_out), $signed(col_out), $signed(acc_out));
            
            if (rst !== expected_rst || clr !== expected_clr || row_in !== expected_row_in || col_in !== expected_col_in ||
                row_out !== expected_row_out || col_out !== expected_col_out || acc_out !== expected_acc_out) begin
                $display ("--- RESULT: FAILED ---");
            end else begin
                $display ("--- RESULT: PASSED ---");
            end

        end
    endtask

    initial begin
        rst = 0; clr = 0;
        row_in = {DATA_WIDTH{1'b0}}; col_in = {DATA_WIDTH{1'b0}};
        #10;

        // Test 1: Reset
        @(posedge clk);
        rst = 1; clr = 0;
        row_in = 8'd3; col_in = 8'd4;
        @(posedge clk); #1;
        print_results("Test 1", 1'b1, 1'b0, 8'd3, 8'd4, 8'd0, 8'd0, 17'd0);

        // Test 2: Load with Clear
        rst = 0; clr = 1;
        row_in = 8'd3; col_in = 8'd4;
        @(posedge clk); #1;
        print_results("Test 2", 1'b0, 1'b1, 8'd3, 8'd4, 8'd3, 8'd4, 17'd12);

        // Test 3: Accumulate
        rst = 0; clr = 0;
        row_in = 8'd5; col_in = 8'd6;
        @(posedge clk); #1;
        print_results("Test 3", 1'b0, 1'b0, 8'd5, 8'd6, 8'd5, 8'd6, 17'd42);

        // Test 4: Accumulate one more
        rst = 0; clr = 0;
        row_in = 8'd7; col_in = 8'd8;
        @(posedge clk); #1;
        print_results("Test 4", 1'b0, 1'b0, 8'd7, 8'd8, 8'd7, 8'd8, 17'd98);

        // Test 5: Load max values with clear
        rst = 0; clr = 1;
            row_in = 8'd127; col_in = 8'd127;
            @(posedge clk); #1;
            print_results("Test 5", 1'b0, 1'b1, 8'd127, 8'd127, 8'd127, 8'd127, 17'd16129);

        // Test 6: Accumulate max values
        rst = 0; clr = 0;
        row_in = 8'd127; col_in = 8'd127;
        @(posedge clk); #1;
        print_results("Test 6", 1'b0, 1'b0, 8'd127, 8'd127, 8'd127, 8'd127, 17'd32258);

        // Test 7: Negative values
        rst = 0; clr = 1;
        row_in = -8'd124; col_in = 8'd57;
        @(posedge clk); #1;
        print_results("Test 7", 1'b0, 1'b1, -8'd124, 8'd57, -8'd124, 8'd57, -17'd7068);

        // Test 8: Maximum negative values
        rst = 0; clr = 1;
        row_in = -8'd128; col_in = -8'd128;
        @(posedge clk); #1;
        print_results("Test 8", 1'b0, 1'b1, -8'd128, -8'd128, -8'd128, -8'd128, 17'd16384);

        $finish;
    end
    
endmodule