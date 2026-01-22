module command_line_multiply(m1, m2, p);

    input [31:0] m1, m2;
    output wire [64:0] p;

    assign p = m1 * m2;

    // always @(posedge clk) begin
    //     p = m1 * m2;
    // end


endmodule
