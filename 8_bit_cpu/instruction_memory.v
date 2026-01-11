module ins_mem(a,d_out);
    input [5:0]a;
    output [15:0]d_out;
    reg [15:0] memory [0:63];

    initial begin
        for (i=0;i<=64;i=i+1)
            memory[i] = 0;
        memory[0] <= 16'b0000000000100101;
        memory[1] <= 16'b0000000000000001;
        memory[2] <= 16'b0000000000101000;
    end

    assign d_out = memory[a];
endmodule
