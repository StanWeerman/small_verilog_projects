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
endmodule

module alu (input [7:0] a, input [7:0] b, output [7:0] c, input control, output c_out);
    assign {c_out, sum} = control ? a+~b+control : a+b;
    // always @ (*) begin
    //     if (control == 0) begin
    //         {c_out, c} = a + b + control;
    //     end
    //     else begin
    //         {c_out, c} = a + ~b + control;
    //     end
    // end
endmodule;

module cpu (input clk, input rst, input [15:0] instruction, input en);


    wire [7:0] reg_1_data, reg_2_data, write_data;
    wire reg_write = instruction[0] & en;

    register_file register_file (.r1a(instruction[12:10]), .r2a(instruction[9:7]), .r1d(reg_1_data), .r2d(reg_2_data), .wa(instruction[15:13]), .wd(write_data), .reg_write(reg_write), .clk(clk));

    wire [7:0] alu_output;
    wire c_out;
    alu alu (.a(r1d), .b(r2d), .c(alu_output), .control(instruction[1]), .c_out(c_out));

    assign write_data = instruction[2] ? instruction[12:5] : alu_output;

endmodule;
