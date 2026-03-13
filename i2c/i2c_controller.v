module i2c_controller (
                    input clk,
                    input rst,
                    input enable,
                    input rw,
                    input wire[6:0] addr,
                    input wire[7:0] byte_in,
                    output reg[7:0] byte_out,
                    output reg busy,
                    output reg error,
                    inout wire scl,
                    inout wire sda
                    );

    parameter ICLK = 10000000;
    parameter BCLK = 400000;
    localparam integer PERIOD = ICLK/BCLK;

    reg internal_sda;
    // reg sda_en;

    reg scl_out;
    reg sda_clk;
    reg sda_out;
    reg stretch_n;
    // wire sda_others;
    // wire sda_start;
    // wire sda_stop;

    reg[7:0] byte_r;
    reg[6:0] addr_r;
    reg rw_r;
    reg enable_r;
    reg [2:0] index;

    reg [6:0] state = IDLE;
    localparam
     IDLE  =        7'b0000001,
     START =        7'b0000010,
     ADDRESS  =     7'b0000100,
     GETACK  =      7'b0001000,
     SENDACK =      7'b0010000,
     DATA =         7'b0100000,
     STOP =         7'b1000000,
     UNKN  =        7'bxxxxxxx;

    assign scl = !scl_out ? 1'b0 : 1'bZ;
    // assign sda_other = (!sda_clk && !sda_out) ? 1'b0 : 1'bZ;
    // assign sda_start = !sda_clk ? 1'b0 : 1'bZ;
    // assign sda_stop = !sda_clk ? 1'bZ : 1'b0;

    // always @(*) begin
    //     case (state)
    //         START: sda = !sda_clk ? 1'b0 : 1'bZ;
    //         STOP: sda = !sda_clk ? 1'bZ : 1'b0;
    //         default: sda = (!sda_clk && !sda_out) ? 1'b0 : 1'bZ;
    //     endcase
    // end
    assign sda = internal_sda ? 1'b0 : 1'bZ;
    always @(*) begin
        case (state)
            START: internal_sda = !sda_clk ? 1'b0 : 1'b1;
            STOP: internal_sda = !sda_clk ? 1'b1 : 1'b0;
            default: internal_sda = (!sda_clk && !sda_out) ? 1'b0 : 1'b1;
        endcase
    end

    integer clk_count;
    always @(posedge clk) begin
        if (rst)
            begin
                clk_count = 0;
                stretch_n <= 1'b1;
            end
        else if (clk)
            begin
                if (clk_count == PERIOD - 1) clk_count = 0;
                else if (stretch_n) clk_count = clk_count + 1;

                if (clk_count < PERIOD/2)
                    begin
                        scl_out <= 1'b0;
                        if (clk_count < PERIOD/4) sda_clk <= 1'b0;
                        else sda_clk <= 1'b1;
                    end
                else
                    begin
                        scl_out <= 1'b1;
                        if (scl == 1'b0) stretch_n <= 1'b0;
                        else stretch_n <= 1'b1;
                        if (clk_count < PERIOD/2 + PERIOD/4) sda_clk <= 1'b1;
                        else sda_clk <= 1'b0;
                    end
            end
    end

    always @(posedge clk) begin
        if (rst) enable_r <= 1'b0;
        else if (clk)
            begin
                if (state == STOP || state == DATA || (state == IDLE)) enable_r <= enable;
            end
    end

    always @(posedge sda_clk) begin
        if (rst)
            begin
                index <= 7;
                busy <= 1'b0;
                sda_out <= 1'b0;
                state <= IDLE;
            end
        else
            begin
                case (state)
                    IDLE:
                        begin
                            // NSL
                            if (enable_r == 1) state <= START;

                            // RTL
                            if (enable_r == 1)
                                begin
                                    busy <= 1'b1;
                                    addr_r <= addr;
                                    rw_r <= rw;
                                    index <= 7;
                                end
                        end
                    START:
                        begin
                            // NSL
                            state <= ADDRESS;

                            // RTL
                            index <= index - 1;
                            sda_out <= addr_r[index-1];
                        end
                    ADDRESS:
                        begin
                            // NSL
                            if (index == 0) state <= GETACK;

                            // RTL
                            if (index == 0)
                                begin
                                    sda_out <= rw_r;
                                    byte_r <= byte_in;
                                    index <= 7;
                                end
                            else
                                begin
                                    index <= index - 1;
                                    sda_out <= addr_r[index-1];
                                end
                            end
                    GETACK:
                        begin
                            // NSL
                            state <= DATA;
                            if (enable_r) state <= DATA;
                            else state <= STOP;

                            // RTL
                            index <= index - 1;
                            if (rw_r) sda_out <= byte_r[index];
                            else sda_out <= 1'b1;
                            if (enable_r) byte_r <= byte_in;
                        end
                    DATA:
                        begin
                            // NSL
                            if (index == 0 && rw_r) state <= GETACK;
                            else if (index == 0 && !rw_r) state <= SENDACK;

                            // RTL
                            index <= index - 1;
                            if (rw_r) sda_out <= byte_r[index];
                            else byte_out[index] = sda;
                        end
                    SENDACK:
                        begin
                            // NSL
                            if (enable_r && rw_r == rw && addr_r == addr) state <= DATA;
                            else if (enable_r) state <= START;

                            // RTL
                            index <= 6;
                            if (enable_r && rw_r == rw && addr_r == addr) byte_r <= byte_in;
                            else if (enable_r)
                                begin
                                    busy <= 1'b1;
                                    addr_r <= addr;
                                    rw_r <= rw;
                                    index <= 7;
                                end
                        end
                    STOP:
                        begin
                            // NSL
                            state <= IDLE;

                            // RTL
                            busy <= 1'b0;
                        end
                    default:
                        begin
                            state <= UNKN;
                        end
                endcase
        end
    end
endmodule;
