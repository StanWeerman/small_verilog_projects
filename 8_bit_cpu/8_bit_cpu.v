module pc (input en,
            input clk,
            input rstb,
            input jmp,
            input [7:0] jmp_address,
            output reg [7:0] pco);

    always @ (posedge clk, negedge rstb) begin
        if (rstb == 1'b0)
            begin
                pco <= 0;
            end
        else if (en)
            begin
                if (jmp) pco <= jmp_address;
                else pco <= pco + 1;
            end
    end
endmodule


module register_file (r1a,r2a,r1d,r2d,wa,wd,reg_write,clk);
    input clk,reg_write;
	input [2:0]r1a,r2a,wa;
	input [7:0] wd;
    output[7:0] r1d,r2d;

    reg [7:0] reg_file [0:7] ;

	assign r1d = reg_file[r1a];
    assign r2d = reg_file[r2a];

    always @(posedge clk) begin
        if (reg_write)
        begin
           reg_file[wa] <= wd;
        end
    end

    parameter WAVE = 0;
    genvar idx;
    generate
        if (WAVE) begin
                for (idx = 0; idx < 8; idx = idx + 1) begin
                    initial $dumpvars(0, reg_file[idx]);
                end
        end
    endgenerate

endmodule

module alu (input [7:0] a, input [7:0] b, output reg [7:0] c, input [6:0] control, output reg c_out);
    // assign {c_out, c} = control ? a+~b+1 : a+b;
    // assign c = a+b;

    alu_cu alu_cu(.control(control));


    always @ (*) begin
        if (alu_cu.and_or) begin
            c_out = 0;
            c = alu_cu.and_ ? a & b : a | b;
        end
        {c_out, c} = a + (b^{8{alu_cu.sign}}) + alu_cu.sign;
    end
endmodule;

module alu_cu(input [6:0] control);
    wire mov = control[1];
    wire sign = control[2];
    wire add = ~control[2];
    wire sub = control[2];
    wire and_or = control[3];
    wire and_ = control[2];
    wire or_ = ~control[2];
endmodule

module cu(input [4:0] control);
    wire jump = alu ? 0 : control[4];
    wire branch = alu ? 0 : control[3];
    wire mem_rd = alu ? 0 : control[2];
    wire mem_wr = alu ? 0 : control[1];
    wire alu = control[0];
    wire reg_wr = alu | mem_rd;
    wire memtoreg = ~alu;
endmodule

module cpu (input clk, input rst, input [15:0] instruction, input en, input [7:0] data_in);
    parameter WAVE = 0;

    wire [7:0] reg_1_data, reg_2_data;
    reg [7:0] write_data;

    cu cu(.control(instruction[4:0]));

    register_file #(.WAVE(1)) register_file (.r1a(instruction[12:10]), .r2a(instruction[9:7]), .r1d(reg_1_data), .r2d(reg_2_data), .wa(instruction[15:13]), .wd(write_data), .reg_write(cu.reg_wr & en), .clk(clk));

    wire [7:0] alu_output;
    wire c_out;
    alu alu (.a(reg_1_data), .b(reg_2_data), .c(alu_output), .control(instruction[6:0]), .c_out(c_out));

    // assign write_data = instruction[2] ? instruction[12:5] : alu_output;

    always @(*) begin
        if (cu.memtoreg) begin
            write_data = cu.mem_rd ? data_in : reg_1_data;
        end
        else begin
            write_data = alu.alu_cu.mov ? instruction[12:5] : alu_output;
        end
    end

    pc pc (.en(en), .clk(clk), .rstb(~rst), .jmp(cu.jump), .jmp_address(instruction[12:5]),.pco());

    // wire mem_read = instruction[4] & instruction[0];
    // wire mem_write = instruction[4] & ~instruction[0];
    wire [7:0] address = instruction[12:5];

endmodule;
