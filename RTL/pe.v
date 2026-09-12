module pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 2 * DATA_WIDTH + 1
) (
    input wire clk, rst, clr,
    input wire [DATA_WIDTH - 1: 0] a_in, b_in,
    output reg [DATA_WIDTH - 1: 0] a_out, b_out,
    output reg [ACC_WIDTH: 0] c_out
);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_out <= {DATA_WIDTH {1'b0}};
            b_out <= {DATA_WIDTH {1'b0}};
            c_out <= {ACC_WIDTH{1'b0}};
        end else begin
            a_out <= a_in;
            b_out <= b_in;

            if (clr) begin
                c_out <= a_in * b_in;
            end else begin
                c_out <= c_out + a_in * b_in;
            end
        end
    end
    
endmodule