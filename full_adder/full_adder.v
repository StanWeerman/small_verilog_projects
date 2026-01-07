//////////////////////////////////////////////////////////////////////////////////
// Author:			Stan Weerman
// Create Date:  01/05/26
// File Name:		full_adder.v
// Description:
//
//
// Revision: 		2.1
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////


module full_adder (input [8:0] a,
                  input [8:0] b,
                  input c_in,
                  output c_out,
                  output [8:0] sum);
   assign {c_out, sum} = a + b + c_in;
endmodule
