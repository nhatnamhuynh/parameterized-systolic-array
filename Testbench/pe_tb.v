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
            $display ("rst = %b \t clr = %b \t row_in = %3d \t col_in = %3d \t row_out = %3d \t col_out = %3d \t acc_out = %3d",
                      expected_rst, expected_clr, expected_row_in, expected_col_in,
                      expected_row_out, expected_col_out, expected_acc_out);
            $display ("--- RECEIVED VALUE ---");
            $display ("rst = %b \t clr = %b \t row_in = %3d \t col_in = %3d \t row_out = %3d \t col_out = %3d \t acc_out = %3d",
                      rst, clr, row_in, col_in, row_out, col_out, acc_out);
            
            if (rst !== expected_rst || clr !== expected_clr || row_in !== expected_row_in || col_in !== expected_col_in ||
                row_out !== expected_row_out || col_out !== expected_col_out || acc_out !== expected_acc_out) begin
                $display ("--- RESULT: FAILED ---");
            end else begin
                $display ("--- RESULT: PASSED ---");
            end

        end

        initial begin
            rst = 0; clr = 0;
            row_in = {DATA_WIDTH{1'b0}}; col_in = {DATA_WIDTH{1'b0}};

            // Test 1: Reset
            #10
            rst = 1; clr = 0;
            row_in = 8'd3; col_in = 8'd4;
            print_results("Test 1", 1'b1, 1'b0, 8'd3, 8'd4, 8'd0, 8'd0, 17'd0);

            // Test 2: Load with Clear
            #10
            rst = 0; clr = 1;
            row_in = 8'd3; col_in = 8'd4;
            print_results("Test 2", 1'b0, 1'b1, 8'd3, 8'd4, 8'd3, 8'd4, 17'd12);

            // Test 3: Accumulate
            #10
            rst = 0; clr = 0;
            row_in = 8'd5; col_in = 8'd6;
            print_results("Test 3", 1'b0, 1'b0, 8'd5, 8'd6, 8'd5, 8'd6, 17'd42);

            // Test 4: Accumulate one more
            #10
            rst = 0; clr = 0;
            row_in = 8'd7; col_in = 8'd8;
            print_results("Test 4", 1'b0, 1'b0, 8'd7, 8'd8, 8'd7, 8'd8, 17'd98);

            // Test 5: Load max values with clear
            #10
            rst = 0; clr = 1;
            row_in = 8'd255; col_in = 8'd255;
            print_results("Test 5", 1'b0, 1'b1, 8'd255, 8'd255, 8'd255, 8'd255, 17'd65025);

            // Test 6: Accumulate max values
            #10
            rst = 0; clr = 0;
            row_in = 8'd255; col_in = 8'd255;
            print_results("Test 6", 1'b0, 1'b0, 8'd255, 8'd255, 8'd255, 8'd255, 17'd130050);

            $finish;
        end

    endtask
    
endmodule