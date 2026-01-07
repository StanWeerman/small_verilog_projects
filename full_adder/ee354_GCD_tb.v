//////////////////////////////////////////////////////////////////////////////////
// Author:			Stan Weerman
// Create Date:   01/07/26
// File Name:		full_adder_tb.v
// Description:
//
//
// Revision: 		2.1
// Additional Comments:

//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module full_adder_tb;
    integer output_file;

	// 1. Declare testbench variables
   reg [3:0] a;
   reg [3:0] b;
   reg c_in;
   wire [3:0] sum;
   integer i;

	// 2. Instantiate the design and connect to testbench variables
   full_adder  fa0 ( .a (a),
                  .b (b),
                  .c_in (c_in),
                  .c_out (c_out),
                  .sum (sum));

   initial begin
	output_file = $fopen ("full_adder__results.txt", "w"); // create the file "output_results.txt" and open it for writing
   end

	// 3. Provide stimulus to test the design
   initial begin
      a <= 0;
      b <= 0;
      c_in <= 0;

      $display("\n  FullAdder results  \n");
	  $fdisplay(output_file, "\n  FullAdder results  \n");
      $monitor ("a=0x%0h b=0x%0h c_in=0x%0h c_out=0x%0h sum=0x%0h", a, b, c_in, c_out, sum);
      $fmonitor (output_file, "a=0x%0h b=0x%0h c_in=0x%0h c_out=0x%0h sum=0x%0h", a, b, c_in, c_out, sum);

		// Use a for loop to apply random values to the input
      for (i = 0; i < 5; i = i+1) begin
         #10 a <= $random;
             b <= $random;
         		 c_in <= $random;
      end
   end
endmodule
