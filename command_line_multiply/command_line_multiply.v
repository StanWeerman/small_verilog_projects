module command_line_multiply(m1, m2, p);
  input  clk;
  output rdy;
  input  reset;

  input [31:0] m1, m2;
  output [64:0] p;

 assign p = m1 * m2;


endmodule
