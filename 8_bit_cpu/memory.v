module ram(clk, a, d_in, d_out, read, write, stall);
    input clk;
    input [15:0] a;
    input [7:0] d_in;
    output [7:0] d_out;
    input read, write;
    output stall;

    reg [7:0] memory [0:65535];

    assign d_out = read ? memory[a] : 0;

    always @(posedge clk) begin
        if (write) begin
            memory[a] = d_in;
        end
    end

    wire test = memory[1];

    parameter WAVE = 0;
    // genvar idx;
    // generate
    //     if (WAVE) begin
    //             for (idx = 0; idx < 256; idx = idx + 1) begin
    //                 initial $dumpvars(0, memory[idx]);
    //             end
    //     end
    // endgenerate
endmodule
