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

    localparam [5:0]
    MOVE = 5'b00101,
    ADD = 5'b00001,
    SUB = 5'b00011,
    JMP = 5'b01000;


    function [15:0] get_instruction (input [2:0] dest, src1, src2, input [7:0] val, input [5:0] instr);
        begin
            case (instr)
                MOVE: get_instruction = {dest, val, MOVE};
                ADD: get_instruction = {dest, src1, src2, 2'b00, ADD};
                SUB: get_instruction = {dest, src1, src2, 2'b00, SUB};
                JMP: get_instruction = {3'b000, val, JMP};
                default: get_instruction = 16'b0000000000001000; // Jump to start
            endcase
        end
    endfunction;

    task do_instruction (input [2:0] dest, src1, src2, input [7:0] val, input [5:0] instr);
        begin
            instruction = get_instruction(dest, src1, src2, val, instr);
            instr_clk();
            $display ("[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[dest]);
        end
    endtask;

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

        // move(0, 1);
        do_instruction(0,0,0,1,MOVE);

        for (i=0; i<10; i++) begin
            // add(0, 0, 0);
            do_instruction(0,0,0,0,ADD);
        end
    end

    initial begin
      $dumpvars;
      $dumpfile("dump.vcd");
    end

endmodule;
