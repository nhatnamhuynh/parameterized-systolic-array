`timescale 1ns / 1ps

module systolic_array_16x16_tb;

    parameter N          = 16;
    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH  = 2 * DATA_WIDTH + $clog2(N);
    parameter CLK_PERIOD = 10;

    reg [N * N * DATA_WIDTH - 1:0] inA_flat, inB_flat;
    reg clk = 0, rst, en;
    wire [N * N * ACC_WIDTH - 1:0] result_out;
    wire ready;

    systolic_array_top #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) uut (
        .inA_flat(inA_flat), 
        .inB_flat(inB_flat),
        .clk(clk), 
        .rst(rst), 
        .en(en),
        .result_out(result_out),
        .ready(ready)
    );

    always #(CLK_PERIOD / 2) clk = ~clk;
    
    task matrix_multiplication_check;
        input [64:0] test_name;
        input [N * N * ACC_WIDTH - 1:0] expected;
        reg pass;
        integer i, j;
        begin
            pass = 1;
            $display("---%s---", test_name);
            for (i = 0; i < N; i = i + 1) begin
                for (j = 0; j < N; j = j + 1) begin
                    if (result_out[i * N * ACC_WIDTH + j * ACC_WIDTH +: ACC_WIDTH] !== expected[i * N * ACC_WIDTH + j * ACC_WIDTH +: ACC_WIDTH]) begin
                        $display("Incorrect at PE[%0d:%0d], expected = %0d, received = %0d", 
                                i, j, 
                                $signed(expected[i * N * ACC_WIDTH + j * ACC_WIDTH +: ACC_WIDTH]), 
                                $signed(result_out[i * N * ACC_WIDTH + j * ACC_WIDTH +: ACC_WIDTH]));
                        pass = 0;
                    end
                end
            end
            if (pass) $display("TEST PASSED!\n");
            else $display("TEST FAILED!\n");
        end                
    endtask
    
    initial begin
        rst      = 1; #5 rst = 0;
        en       = 0;
        inA_flat = {256{8'd0}};
        inB_flat = {256{8'd0}};

        // TEST 10: 16x16 IDENTITY MATRIX MULTIPLICATION
        // Matrix A x Identity B = Matrix A
        rst = 0;          
        en = 1;    
        
        inA_flat = { 
            8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9, 8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16, // Row 15
            8'd2, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  8'd1,  // Row 14
            8'd3, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  8'd1,  8'd0,  // Row 13
            8'd4, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,  8'd0,  8'd0,  8'd0,  8'd1,  8'd0,  8'd0,  // Row 12
            8'd5, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,  8'd0,  8'd0,  8'd1,  8'd0,  8'd0,  8'd0,  // Row 11
            8'd6, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0,  8'd0,  8'd1,  8'd0,  8'd0,  8'd0,  8'd0,  // Row 10
            8'd7, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0,  8'd1,  8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  // Row 9
            8'd8, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd1,  8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  // Row 8
            8'd9, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd1, 8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  // Row 7
            8'd10,8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd1,  8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  // Row 6
            8'd11,8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0,  8'd1,  8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  // Row 5
            8'd12,8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,  8'd0,  8'd1,  8'd0,  8'd0,  8'd0,  8'd0,  // Row 4
            8'd13,8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,  8'd0,  8'd0,  8'd1,  8'd0,  8'd0,  8'd0,  // Row 3
            8'd14,8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,  8'd0,  8'd0,  8'd0,  8'd1,  8'd0,  8'd0,  // Row 2
            8'd15,8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0,  8'd0,  8'd0,  8'd0,  8'd0,  8'd1,  8'd0,  // Row 1
            8'd16,8'd15,8'd14,8'd13,8'd12,8'd11,8'd10,8'd9, 8'd8, 8'd7,  8'd6,  8'd5,  8'd4,  8'd3,  8'd2,  8'd1   // Row 0
        };

        inB_flat = { 
            8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 15
            8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 14
            8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 13
            8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 12
            8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 11
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 10
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 9
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 8
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 7
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 6
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, // Row 5
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, 8'd0, // Row 4
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, 8'd0, // Row 3
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, 8'd0, // Row 2
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1, 8'd0, // Row 1
            8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd1  // Row 0
        };

        #15;
        en = 0;
        
        wait(ready == 1'b1);
        matrix_multiplication_check("Test 10", { 
            20'd1, 20'd2, 20'd3, 20'd4, 20'd5, 20'd6, 20'd7, 20'd8, 20'd9, 20'd10, 20'd11, 20'd12, 20'd13, 20'd14, 20'd15, 20'd16,
            20'd2, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0,  20'd0,  20'd0,  20'd0,  20'd0,  20'd0,  20'd1,
            20'd3, 20'd0, 20'd1, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0,  20'd0,  20'd0,  20'd0,  20'd0,  20'd1,  20'd0,
            20'd4, 20'd0, 20'd0, 20'd1, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0,  20'd0,  20'd0,  20'd0,  20'd1,  20'd0,  20'd0,
            20'd5, 20'd0, 20'd0, 20'd0, 20'd1, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0,  20'd0,  20'd0,  20'd1,  20'd0,  20'd0,  20'd0,
            20'd6, 20'd0, 20'd0, 20'd0, 20'd0, 20'd1, 20'd0, 20'd0, 20'd0, 20'd0,  20'd0,  20'd1,  20'd0,  20'd0,  20'd0,  20'd0,
            20'd7, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd1, 20'd0, 20'd0, 20'd0,  20'd1,  20'd0,  20'd0,  20'd0,  20'd0,  20'd0,
            20'd8, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd1, 20'd0, 20'd1,  20'd0,  20'd0,  20'd0,  20'd0,  20'd0,  20'd0,
            20'd9, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd1, 20'd1, 20'd0,  20'd0,  20'd0,  20'd0,  20'd0,  20'd0,  20'd0,
            20'd10,20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd1, 20'd0, 20'd0, 20'd1,  20'd0,  20'd0,  20'd0,  20'd0,  20'd0,  20'd0,
            20'd11,20'd0, 20'd0, 20'd0, 20'd0, 20'd1, 20'd0, 20'd0, 20'd0, 20'd0,  20'd1,  20'd0,  20'd0,  20'd0,  20'd0,  20'd0,
            20'd12,20'd0, 20'd0, 20'd0, 20'd1, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0,  20'd0,  20'd1,  20'd0,  20'd0,  20'd0,  20'd0,
            20'd13,20'd0, 20'd0, 20'd1, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0,  20'd0,  20'd0,  20'd1,  20'd0,  20'd0,  20'd0,
            20'd14,20'd0, 20'd1, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0,  20'd0,  20'd0,  20'd0,  20'd1,  20'd0,  20'd0,
            20'd15,20'd1, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0,  20'd0,  20'd0,  20'd0,  20'd0,  20'd1,  20'd0,
            20'd16,20'd15,20'd14,20'd13,20'd12,20'd11,20'd10,20'd9, 20'd8, 20'd7,  20'd6,  20'd5,  20'd4,  20'd3,  20'd2,  20'd1
        });     

        $finish;
    end
    
endmodule