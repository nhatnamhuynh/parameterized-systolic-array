module systolic_array_top #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 2 * DATA_WIDTH + 1
) (
    input wire [4 * DATA_WIDTH - 1:0] inA_flat, inB_flat,
    input wire clk, rst, en,
    output wire [ACC_WIDTH - 1:0] acc_out_0, acc_out_1, acc_out_2, acc_out_3,
    output wire ready
);
    reg clr;
    reg [2 * DATA_WIDTH - 1:0] temp_row_0, temp_row_1, temp_col_0, temp_col_1;
    reg [DATA_WIDTH - 1:0] row_in_0, row_in_1, col_in_0, col_in_1;
    reg [2:0] counter;
    
    wire [DATA_WIDTH - 1:0] inA [0:3];
    wire [DATA_WIDTH - 1:0] inB [0:3];

    assign inA[0] = inA_flat[1*DATA_WIDTH-1 : 0*DATA_WIDTH];
    assign inA[1] = inA_flat[2*DATA_WIDTH-1 : 1*DATA_WIDTH];
    assign inA[2] = inA_flat[3*DATA_WIDTH-1 : 2*DATA_WIDTH];
    assign inA[3] = inA_flat[4*DATA_WIDTH-1 : 3*DATA_WIDTH];

    assign inB[0] = inB_flat[1*DATA_WIDTH-1 : 0*DATA_WIDTH];
    assign inB[1] = inB_flat[2*DATA_WIDTH-1 : 1*DATA_WIDTH];
    assign inB[2] = inB_flat[3*DATA_WIDTH-1 : 2*DATA_WIDTH];
    assign inB[3] = inB_flat[4*DATA_WIDTH-1 : 3*DATA_WIDTH];

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
        end else if (en && counter == 3'd0) begin
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
            if (counter == 3'd4) counter <= 3'd0;
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
    
    pe_grid_2x2 grid (
        .clk(clk), .rst(rst), .clr(clr),
        .row_in_0(row_in_0), .row_in_1(row_in_1), 
        .col_in_0(col_in_0), .col_in_1(col_in_1),
        .acc_out_0(acc_out_0), .acc_out_1(acc_out_1), .acc_out_2(acc_out_2), .acc_out_3(acc_out_3)
    );

endmodule