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

    task instr_clk();
        begin
            #1;
            clk = 1;
            #1;
            clk = 0;
        end
    endtask

    task move(input [2:0] dest, input [7:0] val);
        begin
            instruction = {dest, val, 5'b00101};
            instr_clk();
            $display ("[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[dest]);
        end
    endtask

    task add(input [2:0] dest, src1, src2);
        begin
            instruction = {dest, src1, src2, 7'b0000001};
            instr_clk();
            $display ("[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[dest]);
        end
    endtask

    integer i;

    initial begin
        init();

        move(0, 1);

        for (i=0; i<10; i++) begin
            add(0, 0, 0);
        end
    end

    initial begin
      $dumpvars;
      $dumpfile("dump.vcd");
    end

endmodule;
