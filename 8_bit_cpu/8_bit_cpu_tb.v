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

    task add(input [2:0] dest, src1, src2);
        begin
            instruction = {dest, src1, src2, 7'b0000001};
            #1;
            clk = 1;
            #1;
            clk = 0;
            #1;

            $display ("[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[0]);
        end
    endtask

    reg [2:0] dest, src1, src2;
    integer i;

    initial begin
        init();
        #1;
        clk = 1;
        #1;
        clk = 0;
        #1;
        $display ("[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[0]);

        dest = 0;
        src1 = 0;
        src2 = 0;
        for (i=0; i<10; i++) begin
            add(dest, src1, src2);
        end
    end

    initial begin
      $dumpvars;
      $dumpfile("dump.vcd");
    end

endmodule;
