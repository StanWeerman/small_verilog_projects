module main;

    integer fd_r;
    reg [10*8:1] line;
    event change_input;
    integer clk_count;
    reg clk;
    reg [31:0] m1, m2;
    wire [64:0] p;

    command_line_multiply mult (.m1(m1), .m2(m2), .p(p));

    always #10 clk = ~clk;

    always #1 clk_count +=1;

    initial begin
        clk = 0;
        clk_count = 0;

        if (! ($value$plusargs("m1=%d", m1) && $value$plusargs("m2=%d", m2))) begin
            $display("ERROR: commandline format is '+m1=<value> +m2=<value>'");
            $finish;
        end

        // @(negedge clk);
        @(change_input);

        fd_r = $fopen ("command_line_multiply/arguments.txt", "r");
        if (fd_r)     begin
                while ($fscanf (fd_r, "%d * %d", m1, m2) == 2) begin
                    // @(negedge clk);
                    @(change_input);
                end
            end
        else      	  $display("File was NOT opened successfully : %0d", fd_r);

        $finish;
    end

    always @(posedge clk) begin
        $display ("%d: Calculating: %d * %d = %d", clk_count, m1, m2, p);
        ->change_input;
    end

    initial begin
        $dumpvars;
        $dumpfile("dump.vcd");
    end

endmodule
