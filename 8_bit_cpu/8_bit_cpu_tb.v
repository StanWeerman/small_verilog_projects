module register_alu_tb;

    integer output_file;
    integer input_file;
    integer i;

    reg clk, rst, en;
    reg from_file;
    wire [15:0] instruction = from_file ? instrution_mem : instrution_input;

    reg [15:0] instrution_input;
    wire [15:0] instrution_mem;
    cpu cpu (.clk(clk), .rst(rst), .instruction(instruction), .en(en));
    ins_mem ins_mem (.a(cpu.pc.pco), .d_out(instrution_mem));

    task init();
        begin
            input_file = $fopen ("8_bit_cpu/assembler/tests/build/add", "r");
           	output_file = $fopen ("output_results.txt", "w");
           	clk = 0;
            rst = 0;
            en  = 1;
            from_file = 0;
            instrution_input = 16'b000_00000001_00101;
        end
    endtask

    task instr_clk();
        begin
            #1 clk = 1;
            #1 clk = 0;
        end
    endtask

    localparam [4:0]
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
            instrution_input = get_instruction(dest, src1, src2, val, instr);
            instr_clk();
            $fdisplay (output_file, "[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[dest]);
        end
    endtask;

    task move(input [2:0] dest, input [7:0] val);
        begin
            instrution_input = {dest, val, 5'b00101};
            instr_clk();
            $fdisplay (output_file, "[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[dest]);
        end
    endtask

    task add(input [2:0] dest, src1, src2);
        begin
            instrution_input = {dest, src1, src2, 7'b0000001};
            instr_clk();
            $fdisplay (output_file, "[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[dest]);
        end
    endtask

    integer code;

    task set_memory ();
        begin

            if (input_file == 0) begin
                $display("Error: Could not open file.");
                $finish;
            end

            // Read data from the file into memory array
            code = $fread(ins_mem.memory, input_file, 0, 8);
            if (code == 0) begin
                $display("Error: Could not read data.");
            end
            else begin
                $display("Read %0d bytes of data.", code);
            end

            // Display the contents of the first few memory locations
            for (i = 0; i < 8; i++) begin
                $display("mem[%0d] = %h", i, ins_mem.memory[i]);
            end

            $fclose(input_file);
        end
    endtask

    initial begin
        init();

        // move(0, 1);
        do_instruction(0,0,0,1,MOVE);
        do_instruction(1,0,0,1,MOVE);

        do_instruction(0,0,0,0,ADD);
        do_instruction(0,0,1,0,SUB);

        for (i=0; i<10; i++) begin
            // add(0, 0, 0);
            do_instruction(0,0,0,0,ADD);
        end

        en = 0;
        rst = 1;
        $fdisplay(output_file, "Starting Instruction Memory Run");

        set_memory();
        from_file = 1;
        #1 clk = 1;
        #1 clk = 0;
        en = 1;
        rst = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        // #1000;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
    end

    // always begin
    //     if (from_file == 0) begin
    //         #10 clk = ~clk;
    //     end
    // end

    always @ (posedge clk) begin
        if (from_file) begin
            $fdisplay (output_file, "[$display] time=%0t $0=0x%00h pc=0x%00h", $time, cpu.register_file.reg_file[0], cpu.pc.pco);
            $fdisplay (output_file, "[$display] time=%0t $1=0x%00h pc=0x%00h", $time, cpu.register_file.reg_file[1], cpu.pc.pco);
        end
    end

    initial begin
      $dumpvars;
      $dumpfile("dump.vcd");
    end

endmodule;
