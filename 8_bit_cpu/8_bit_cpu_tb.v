module cpu_tb;

    integer output_file;
    integer output_reg_file;
    integer input_file;
    integer i;
    event end_clk;
    integer clk_count;
    reg clk, rst, en;
    reg from_file;
    wire [15:0] instruction = from_file ? instruction_mem : instruction_input;

    reg [15:0] instruction_input;
    wire [15:0] instruction_mem;
    wire [7:0] cpu_d_out;
    cpu #(.WAVE(1)) cpu (.clk(clk), .rst(rst), .instruction(instruction), .en(en), .data_in(ram.d_out), .data_out(cpu_d_out));
    ins_mem #(.WAVE(1)) ins_mem (.a(cpu.pc.pco), .d_out(instruction_mem));
    ram #(.WAVE(1))  ram (.clk(clk), .a(cpu.address), .d_in(cpu_d_out), .d_out(), .read(cpu.cu.mem_rd), .write(cpu.cu.mem_wr), .stall());

    always #10 clk = ~clk;

    always #1 clk_count +=1;

    task init();
        begin
            input_file = $fopen ("8_bit_cpu/assembler/tests/build/add", "r");
           	output_file = $fopen ("output_results.txt", "w");
            output_reg_file = $fopen ("8_bit_cpu/build/output_reg_file.txt", "w");
           	clk = 0;
            rst = 0;
            en  = 0;
            clk_count = 0;
            from_file = 0;
            // instruction_input = 16'b000_00000001_00101;
            instruction_input = 16'b0000_0000_0000_0000;
        end
    endtask

    task instr_en();
        begin
            en = 1;
            @(posedge clk);
            en = 0;
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
            @(negedge clk);
            instruction_input = get_instruction(dest, src1, src2, val, instr);
            instr_en();
            // $fdisplay (output_file, "[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[dest]);
        end
    endtask;

    task move(input [2:0] dest, input [7:0] val);
        begin
            instruction_input = {dest, val, 5'b00101};
            instr_en();
            $fdisplay (output_file, "[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[dest]);
        end
    endtask

    task add(input [2:0] dest, src1, src2);
        begin
            instruction_input = {dest, src1, src2, 7'b0000001};
            instr_en();
            $fdisplay (output_file, "[$display] time=%0t $0=0x%00h", $time, cpu.register_file.reg_file[dest]);
        end
    endtask

    integer code;

    task set_memory ();
        begin
            $display("Test");
            if (input_file == 0) begin
                $display("Error: Could not open file.");
                $finish;
            end

            // Read data from the file into memory array
            code = $fread(ins_mem.memory, input_file, 0, 65355);
            if (code == 0) begin
                $display("Error: Could not read data.");
            end
            else begin
                $display("Read %0d bytes of data.", code);
            end

            // Display the contents of the first few memory locations
            for (i = 0; i < code; i++) begin
                $display("ins_mem[%0d] = %h", i, ins_mem.memory[i]);
            end

            $fclose(input_file);
        end
    endtask

    initial begin
        init();

        $monitor ("[$monitor] time=%0t mem[1]=0x%00h", $time, ram.memory[1]);

        // move(0, 1);
        // do_instruction(0,0,0,1,MOVE);
        // do_instruction(1,0,0,1,MOVE);

        // do_instruction(0,0,0,0,ADD);
        // do_instruction(0,0,1,0,SUB);

        // for (i=0; i<10; i++) begin
        //     // add(0, 0, 0);
        //     do_instruction(0,0,0,0,ADD);
        // end

        en = 0;
        rst = 1;
        $fdisplay(output_file, "--- Starting Instruction Memory Run ---");
        $fdisplay(output_reg_file, "--- Starting Instruction Memory Run ---");


        set_memory();
        from_file = 1;

        @(posedge clk);
        en = 1;
        rst = 0;

        #500;
        $display ("[$monitor] time=%0t mem[1]=0x%00h", $time, ram.memory[1]);
        $finish();
    end

    // always begin
    //     if (from_file == 0) begin
    //         #10 clk = ~clk;
    //     end
    // end
    always@(negedge clk) begin
        $fdisplay (output_reg_file, "-%4t: |0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|", $time, cpu.register_file.reg_file[0], cpu.register_file.reg_file[1], cpu.register_file.reg_file[2], cpu.register_file.reg_file[3], cpu.register_file.reg_file[4], cpu.register_file.reg_file[5], cpu.register_file.reg_file[6], cpu.register_file.reg_file[7]);
    end

    always @ (posedge clk) begin
        // if (from_file) begin
        // if (en) begin
            $fdisplay (output_reg_file, "+%4t: |0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|0x%00h|", $time, cpu.register_file.reg_file[0], cpu.register_file.reg_file[1], cpu.register_file.reg_file[2], cpu.register_file.reg_file[3], cpu.register_file.reg_file[4], cpu.register_file.reg_file[5], cpu.register_file.reg_file[6], cpu.register_file.reg_file[7]);
            $fdisplay (output_file, "%4t: |$0=0b%16b|pc=0x%00h|en=%1b", $time, instruction, cpu.pc.pco, en);
        // end
        ->end_clk;
            // $fdisplay (output_file, "[$display] time=%0t $1=0x%00h pc=0x%00h", $time, cpu.register_file.reg_file[1], cpu.pc.pco);
        // end
    end

    initial begin

      $dumpvars(0, cpu_tb);
      // $dumpall;
      $dumpfile("dump.vcd");
    end

endmodule;
