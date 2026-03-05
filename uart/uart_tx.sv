module uart_tx (
                input clk,
                input rst,
                input start,
                output reg bit_out,
                output reg done,
                input [7:0] byte_in
                );
    parameter CLKS = 115;
    reg [3:0] state;
    reg [2:0] index;
    reg [7:0] byte_out;
    integer clk_count;

    localparam
     IDLE  = 4'b001,
     START = 4'b010,
     DATA  = 4'b0100,
     STOP  = 4'b1000,
     UNKN  = 4'bxxxx;

    always @(posedge clk) begin
        if (rst)
            begin
                index <= 3'bxxx;
                state <= IDLE;
                byte_out <= 8'bxxxxxxxx;
                clk_count <= 4'bxxxx;
            end
        else
            begin
                case (state)
                    IDLE:
                        begin
                            // NSL
                            if (start == 1) state <= START;

                            // RTL
                            done <= 1'b0;
                            index <= 0;
                            clk_count <= 0;
                            bit_out <= 1'b1;
                            if (start == 1) byte_out <= byte_in;
                        end
                    START:
                        begin
                            // NSL
                            if (clk_count == CLKS-1) state <= DATA;

                            // RTL
                            bit_out <= 1'b0;
                            clk_count <= clk_count + 1;
                            if (clk_count == CLKS-1) clk_count <= 0;
                        end
                    DATA:
                        begin
                            // NSL
                            if (clk_count == CLKS-1 && index == 7) state <= STOP;

                            // RTL
                            bit_out <= byte_out[index];
                            clk_count <= clk_count + 1;
                            if (clk_count == CLKS-1)
                                begin
                                    clk_count <= 0;
                                    index <= index + 1;
                                end
                        end
                    STOP:
                        begin
                            // NSL
                            if (clk_count == CLKS-1) state <= IDLE;

                            // RTL
                            bit_out <= 1'b1;
                            clk_count <= clk_count + 1;
                            if (clk_count == CLKS-1)
                                begin
                                    done <= 1'b1;
                                    clk_count <= 0;
                                end
                        end
                    default:
                        begin
                             state <= UNKN;
                        end
                endcase
        end
    end

endmodule;
