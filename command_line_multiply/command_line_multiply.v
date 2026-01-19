module command_line_multiply(clk, m1, m2, p);
    input  clk;

    input [31:0] m1, m2;
    output reg [64:0] p;


    always @(posedge clk) begin
        p = m1 * m2;
    end


endmodule
