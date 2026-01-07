//////////////////////////////////////////////////////////////////////////////////
// Author:			Stan Weerman
// Create Date:  01/06/26
// File Name:		fifo_np.v
// Description:
//
//
// Revision: 		2.1
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module fifo_np (clk, reset, data_in, wen, ren, data_out, depth, empty, full, fill_array);

parameter DATA_WIDTH = 16;
parameter ADDR_WIDTH = 4;

input clk, reset;
input wen, ren; // the read or write request for CPU
input [DATA_WIDTH-1:0] data_in;
output [ADDR_WIDTH-1:0] depth;
output [DATA_WIDTH-1:0] data_out;
output empty, full;

reg [ADDR_WIDTH-1:0] rdptr, wrptr; //read pointer and write pointer of FIFO
wire [ADDR_WIDTH-1:0] depth;
wire wenq, renq;// read and write enable for FIFO
reg full, empty;

reg [DATA_WIDTH-1:0] Reg_Array [(2**ADDR_WIDTH)-1:0];// FIFO array
output reg [(2**ADDR_WIDTH)-1:0] fill_array;
reg AE_AF_flag; // zero means almost empty and one means almost full
wire  raw_almost_empty, raw_almost_full;


wire [ADDR_WIDTH-1:0] N_zeros = {(ADDR_WIDTH){1'b0}};


assign depth = wrptr - rdptr;


// task #1: complete the two assign statements using as few and as small gates as possible
// (and using as few higher-order bits of depth as possible).
assign raw_almost_full  = (depth[1] & depth[0]);
assign raw_almost_empty = (~depth[1] & depth[0]);


always@(*)
begin
	empty = 1'b0;
	full = 1'b0;
//task #2: fill in the conditions for signal "empty" and "full".
	if ( (depth == 0) & (AE_AF_flag == 0)  )
		empty = 1'b1;
	if ( (depth == 0) & (AE_AF_flag == 1)  )
		full =  1'b1;
end

assign wenq = (~full) & wen;// only if the FIFO is not full and there is write request from CPU, we enable the write to FIFO.
assign renq = (~empty)& ren;// only if the FIFO is not empty and there is read request from CPU, we enable the read to FIFO.
assign data_out = Reg_Array[rdptr];

always@(posedge clk, posedge reset)
begin
    if (reset)
		begin
		    fill_array <= {((2**ADDR_WIDTH)-1){1'b0}};
			wrptr <= N_zeros;
			rdptr <= N_zeros;
			AE_AF_flag <= 1'b0;
		end
	else
		begin
// task #3: complete these two if statements.  You may want to refer to the n-plus-1 pointer design
			if (wenq)
				begin
				    fill_array[wrptr[ADDR_WIDTH-1:0]] <= 1;
                    Reg_Array[wrptr[ADDR_WIDTH-1:0]] <= data_in;
                   	wrptr <= wrptr + 1;
				end
			if (renq)
				begin
				    fill_array[rdptr[ADDR_WIDTH-1:0]] <= 0;
                    rdptr <= rdptr + 1;
				end

// task #4: complete set and reset of AE_AF_flag (zero means almost empty and one means almost full).
			if (raw_almost_full)
					AE_AF_flag <= 1;
			if (raw_almost_empty)
					AE_AF_flag <= 0;
		end
end

endmodule // fifo_reg_array_sc
