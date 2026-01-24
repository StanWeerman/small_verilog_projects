module ram(clk, a, d_in, d_out, read, write, stall);
    input clk;
    input [7:0] a;
    input [7:0] d_in;
    output [7:0] d_out;
    input read, write;
    output stall;

    reg [7:0] memory [0:255];

    assign d_out = read ? memory[a] : 0;

    always @(posedge clk) begin
        if (write) begin
            memory[a] = d_in;
        end
    end

    parameter DISPLAY = 0;

    generate
    if (DISPLAY) begin
        genvar idx;
        for(idx = 0; idx < 256; idx = idx+1) begin: register
            wire [7:0] word;
            assign word = memory[idx];
        end
    end
    endgenerate
endmodule
