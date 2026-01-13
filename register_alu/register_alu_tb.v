module register_alu_tb;

    reg clk, rst, en;
    reg [15:0] instruction;

    cpu cpu (.clk(clk), .rst(rst), .instruction(instruction), .en(en));

    function void init();
       	clk = 0;
        rst = 0;
        en  = 1;
        instruction = 16'b000_00000001_00101;
    endfunction

    initial begin
        init();
        #1;
        clk = 1;
        #1;
        clk = 0;
        #1;
        $display ("[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[0]);
    end

    initial begin
      $dumpvars;
      $dumpfile("dump.vcd");
    end

endmodule;
