module main;

  reg clk;
  reg [31:0] m1, m2;
  wire [64:0] p;

  command_line_multiply mult (.m1(m1), .m2(m2), .p(p));

  always #10 clk = ~clk;

  initial begin
     clk = 0;

     if (! $value$plusargs("m1=%d,%d", m1, m2)) begin
        $display("ERROR: commandline format is '+m1=<value>,m2=<value>'");
        $finish;
     end

     // wait (rdy) $display("y=%d", y);
     $display("p=%d", p);
     $finish;
  end

  initial begin
    $dumpvars;
    $dumpfile("dump.vcd");
  end

endmodule
