module uart_rx (
                input clk,
                input rst,
                input bit_in,
                output reg done,
                output reg [7:0] byte_out
                );
    parameter CLKS = 115;
    reg [3:0] state;
    reg [2:0] index;
    reg bit_in_r, bit_in_rr;
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
                bit_in_r <= 1'bx;
                bit_in_rr <= 1'bx;
                clk_count <= 4'bxxxx;
            end
        else
            begin
                bit_in_r <= bit_in;
                bit_in_rr <= bit_in;
                case (state)
                    IDLE:
                        begin
                            // NSL
                            if (bit_in_rr == 0) state <= START;

                            // RTL
                            done <= 1'b0;
                            index <= 0;
                            clk_count <= 0;
                        end
                    START:
                        begin
                            // NSL
                            if (clk_count == (CLKS-1)/2)
                                begin
                                    if (bit_in_rr == 0) state <= DATA;
                                    else state <= IDLE;
                                end

                            // RTL
                            clk_count <= clk_count + 1;
                            if (clk_count == (CLKS-1)/2) clk_count <= 0;
                        end
                    DATA:
                        begin
                            // NSL
                            if (clk_count == CLKS-1 && index == 7) state <= STOP;

                            // RTL
                            clk_count <= clk_count + 1;
                            if (clk_count == CLKS-1)
                                begin
                                    clk_count <= 0;
                                    byte_out[index] <= bit_in_rr;
                                    if (index != 7) index <= index + 1;
                                    else index <= 0;
                                end
                        end
                    STOP:
                        begin
                            // NSL
                            if (clk_count == CLKS-1) state <= IDLE;

                            // RTL
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
