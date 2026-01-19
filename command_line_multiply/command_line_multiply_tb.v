module main;

    integer fd_r;
    reg [10*8:1] line;
    reg clk;
    reg [31:0] m1, m2;
    wire [64:0] p;

    command_line_multiply mult (.clk(clk), .m1(m1), .m2(m2), .p(p));

    always #10 clk = ~clk;

    initial begin
        clk = 0;

        if (! ($value$plusargs("m1=%d", m1) && $value$plusargs("m2=%d", m2))) begin
            $display("ERROR: commandline format is '+m1=<value> +m2=<value>'");
            $finish;
        end

        #10;

        $finish;
    end

    always @(posedge clk) begin
        $display("p=%0d", p);
    end

    initial begin
        $dumpvars;
        $dumpfile("dump.vcd");
    end

endmodule
