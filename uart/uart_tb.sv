`timescale 1ns / 1ps

module uart_tb;
    reg clk = 0;
    reg rst = 0;

    wire rx_bit, rx_done;
    wire tx_bit, tx_done;
    reg tx_start;
    wire [7:0] rx_byte;
    reg [7:0] tx_byte;

    uart_rx #(.CLKS(87)) uart_rx(.clk(clk), .rst(rst), .bit_in(rx_bit), .done(rx_done), .byte_out(rx_byte));
    uart_tx #(.CLKS(87)) uart_tx(.clk(clk), .rst(rst), .start(tx_start), .bit_out(tx_bit), .done(tx_done), .byte_in(tx_byte));

    assign rx_bit = tx_bit;

    always #1 clk = ~clk;

    task init();
        begin
           	clk = 0;
            rst = 1;
            @(posedge clk);
            @(posedge clk);
            rst = 0;
        end
    endtask

    task test_byte(input [7:0] test_byte);
        begin
            @(posedge clk);
            @(posedge clk);
            tx_start <= 1'b1;
            tx_byte <= test_byte;
            @(posedge clk);
            tx_start <= 1'b0;
            @(posedge tx_done);

            $display("Incorrect Byte, expected <0x%00h>, received <0x%00h>", tx_byte, rx_byte);
            // assert (rx_byte == tx_byte) else $error("Incorrect Byte, expected <0x%00h>, received <0x%00h>", tx_byte, rx_byte);
        end
    endtask;

    initial begin
        init();
        test_byte(8'hff);
        #100;
        $finish();
    end

    initial begin
      $dumpvars;
      $dumpfile("dump.vcd");
    end
endmodule;
