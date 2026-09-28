`timescale 1ns / 1ps

module systolic_array_2x2_tb;

    parameter N          = 2;
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
                    if (result_out[i * N * ACC_WIDTH + j * ACC_WIDTH +: ACC_WIDTH] != expected[i * N * ACC_WIDTH + j * ACC_WIDTH +: ACC_WIDTH]) begin
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
        en     = 0;
        inA_flat = {8'd0, 8'd0, 8'd0, 8'd0};
        inB_flat = {8'd0, 8'd0, 8'd0, 8'd0};

        // TEST 1: RESET SIGNAL 
        rst = 1;
        en = 1;
        inA_flat = {8'd1, 8'd2, 8'd3, 8'd4};
        inB_flat = {8'd0, 8'd1, 8'd1, 8'd0};
        #15;
        en = 0;

        wait(ready == 1'b1);
        matrix_multiplication_check("Test 1", {17'd0, 17'd0, 17'd0, 17'd0});
        
        // TEST 2: BASIC MATRICES
        // 1 2     x       4 3     =       8 5   
        // 3 4             2 1             20 13
        rst = 0;          
        en = 1;    
        inA_flat = {8'd4, 8'd3, 8'd2, 8'd1};
        inB_flat = {8'd1, 8'd2, 8'd3, 8'd4};  
        #15;
        en = 0;
        
        wait(ready == 1'b1);
        matrix_multiplication_check("Test 2", {17'd13, 17'd20, 17'd5, 17'd8});
        
        // TEST 3: ZERO MATRIX
        // 1 2     x       0 0     =       0 0   
        // 3 4             0 0             0 0
        rst = 0;          
        en = 1;    
        inA_flat = {8'd4, 8'd3, 8'd2, 8'd1};
        inB_flat = {8'd0, 8'd0, 8'd0, 8'd0};   
        #15;
        en = 0;
        
        wait(ready == 1'b1);
        matrix_multiplication_check("Test 3", {17'd0, 17'd0, 17'd0, 17'd0});

        // TEST 4: IDENTITY MATRIX
        // 1 2     x       1 0     =       1 2   
        // 3 4             0 1             3 4
        rst = 0;          
        en = 1;    
        inA_flat = {8'd4, 8'd3, 8'd2, 8'd1};
        inB_flat = {8'd1, 8'd0, 8'd0, 8'd1};   
        #15;
        en = 0;
        
        wait(ready == 1'b1);
        matrix_multiplication_check("Test 4", {17'd4, 17'd3, 17'd2, 17'd1});
        
        // TEST 5: INVERSE MATRIX
        // 1 2     x       -3 2     =       1 0   
        // 2 3              2 -1            0 1
        rst = 0;          
        en = 1;    
        inA_flat = {8'd3, 8'd2, 8'd2, 8'd1};
        inB_flat = {-8'd1, 8'd2, 8'd2, -8'd3};   
        #15;
        en = 0;
        
        wait(ready == 1'b1);
        matrix_multiplication_check("Test 5", {17'd1, 17'd0, 17'd0, 17'd1});        
        
        // TEST 6: ENABLE SIGNAL 
        // 1 2     x       -3 2     =       1 0   
        // 2 3              2 -1            0 1
        rst = 0;          
        en = 1;    
        inA_flat = {8'd3, 8'd2, 8'd2, 8'd1};
        inB_flat = {-8'd1, 8'd2, 8'd2, -8'd3};   
        #15;
        en = 0;
        inA_flat = {8'd4, 8'd3, 8'd2, 8'd1};
        inB_flat = {8'd1, 8'd0, 8'd0, 8'd1};   
        
        wait(ready == 1'b1);
        matrix_multiplication_check("Test 6", {17'd1, 17'd0, 17'd0, 17'd1});        
        
        // TEST 7: MAXIMUM VALUE 
        // 127 127     x       127 127     =       32258 32258   
        // 127 127             127 127             32258 32258
        rst = 0;          
        en = 1;    
        inA_flat = {8'd127, 8'd127, 8'd127, 8'd127};
        inB_flat = {8'd127, 8'd127, 8'd127, 8'd127};   
        #15;
        en = 0;
        
        wait(ready == 1'b1);
        matrix_multiplication_check("Test 7", {17'd32258, 17'd32258, 17'd32258, 17'd32258});     
        
        // TEST 8: MINIMUM VALUE
        // -128 -128     x       -128 -128     =       32768 32768   
        // -128 -128             -128 -128             32768 32768
        rst = 0;          
        en = 1;    
        inA_flat = {-8'd128, -8'd128, -8'd128, -8'd128};
        inB_flat = {-8'd128, -8'd128, -8'd128, -8'd128};   
        #15;
        en = 0;
        
        wait(ready == 1'b1);
        matrix_multiplication_check("Test 8", {17'd32768, 17'd32768, 17'd32768, 17'd32768});     

        $finish;
    end
    
endmodule