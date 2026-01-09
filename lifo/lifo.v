//////////////////////////////////////////////////////////////////////////////////
// Author:			Stan Weerman
// Create Date:  01/06/26
// File Name:		lifo.v
// Description:
//
//
// Revision: 		2.1
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module lifo (clk, reset, data_in, wen, ren, data_out, depth, empty, full, fill_array);

parameter DATA_WIDTH = 16;
parameter ADDR_WIDTH = 4;

input clk, reset;
input wen, ren; // the read or write request for CPU
input [DATA_WIDTH-1:0] data_in;
output [ADDR_WIDTH-1:0] depth;
output [DATA_WIDTH-1:0] data_out;
output empty, full;

reg [ADDR_WIDTH-1:0] stack_ptr; //stack pointer of LIFO
wire [ADDR_WIDTH-1:0] depth;
wire wenq, renq;// read and write enable for LIFO
reg full, empty;

reg [DATA_WIDTH-1:0] Reg_Array [(2**ADDR_WIDTH)-1:0];// LIFO array
output reg [(2**ADDR_WIDTH)-1:0] fill_array;
reg AE_AF_flag; // zero means almost empty and one means almost full
wire  raw_almost_empty, raw_almost_full;

assign depth = stack_ptr;


assign raw_almost_full  = (depth[1] & depth[0]);
assign raw_almost_empty = (~depth[1] & depth[0]);


always@(*)
begin
	empty = 1'b0;
	full = 1'b0;

	if ( (depth == 0) & (AE_AF_flag == 0)  )
		empty = 1'b1;
	if ( (depth == 0) & (AE_AF_flag == 1)  )
		full =  1'b1;
end

assign wenq = (~full) & wen;
assign renq = (~empty)& ren;
assign data_out = Reg_Array[stack_ptr-1];

always@(posedge clk, posedge reset)
begin
    if (reset)
		begin
		    fill_array <= {((2**ADDR_WIDTH)-1){1'b0}};
			stack_ptr <= {(ADDR_WIDTH){1'b0}};
			AE_AF_flag <= 1'b0;
		end
	else
		begin
		    if (wenq && renq)
				begin
			        fill_array[stack_ptr-1] <= 1;
                    Reg_Array[stack_ptr-1] <= data_in;
                   	stack_ptr <= stack_ptr;
				end
			else if (wenq)
				begin
				    fill_array[stack_ptr] <= 1;
                    Reg_Array[stack_ptr] <= data_in;
                   	stack_ptr <= stack_ptr + 1;
				end
			else if (renq)
				begin
				    fill_array[stack_ptr-1] <= 0;
                    stack_ptr <= stack_ptr - 1;
				end


			if (raw_almost_full)
					AE_AF_flag <= 1;
			if (raw_almost_empty)
					AE_AF_flag <= 0;
		end
end

endmodule
