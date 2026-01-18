module cpu_top
		(//MemOE, MemWR, RamCS,
		input qspi_csn, // Disable the three memory chips

        input CLK100MHZ,                           // the 100 MHz incoming clock signal

		input BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons BtnL, BtnR,
		input BtnC,                             // the center button (this is our reset in most of our designs)
		input [15:0] sw, // 16 switches
		output [15:0] LED, // 16 LEDs
		output [7:0] an, // 8 anodes
		output [6:0] seg,        // 7 cathodes
		output Dp,                                 // Dot Point Cathode on SSDs
		output LED16_R, LED17_R // Warning Lights
	  );

	/*  LOCAL SIGNALS */
	wire		Reset;
	wire		board_clk, sys_clk;
	wire [2:0] 	ssdscan_clk;
	reg [26:0]	DIV_CLK;

	reg [3:0]	SSD;
	wire [3:0]	SSD7, SSD6, SSD5, SSD4, SSD3, SSD2, SSD1, SSD0;
	reg [7:0]  SSD_CATHODES;

//------------
// Disable the three memories so that they do not interfere with the rest of the design.
	assign {MemOE, MemWR, RamCS, qspi_csn} = 4'b1111;


//------------
// CLOCK DIVISION


	BUFGP BUFGP1 (board_clk, CLK100MHZ);
	assign Reset = BtnC;

//------------
	// Our clock is too fast (100MHz) for SSD scanning
	// create a series of slower "divided" clocks
	// each successive bit is 1/2 frequency
  always @(posedge board_clk, posedge Reset)
    begin
        if (Reset)
		DIV_CLK <= 0;
        else
		DIV_CLK <= DIV_CLK + 1'b1;
    end
//-------------------
	// In this design, we run the core design at full 100MHz clock!
	assign	sys_clk = board_clk;

// DEBOUNCE
    wire left, right, up, down;

    ee354_debouncer #(.N_dc(28)) left_debounce
            (.CLK(sys_clk), .RESET(Reset), .PB(BtnL),
    		.DPB( ), .SCEN(left), .MCEN( ), .CCEN( ));
    ee354_debouncer #(.N_dc(28)) right_debounce
            (.CLK(sys_clk), .RESET(Reset), .PB(BtnR),
    		.DPB( ), .SCEN(right), .MCEN( ), .CCEN( ));
    ee354_debouncer #(.N_dc(28)) down_debounce
            (.CLK(sys_clk), .RESET(Reset), .PB(BtnD),
    		.DPB( ), .SCEN(down), .MCEN( ), .CCEN( ));
    ee354_debouncer #(.N_dc(28)) up_debounce
            (.CLK(sys_clk), .RESET(Reset), .PB(BtnU),
    		.DPB( ), .SCEN(up), .MCEN( ), .CCEN( ));

// DESIGN
    wire [15:0] instruction;
    cpu cpu (.clk(sys_clk), .rst(Reset), .instruction(instruction), .en(down));

    ins_mem ins_mem (.a(cpu.pc.pco), .d_out(instruction));

    assign LED = instruction;

    reg [2:0] display_reg;
    wire [7:0] display_reg_data = cpu.register_file.reg_file[display_reg];

    always @(posedge board_clk, posedge Reset)
      begin
        if (Reset) begin
            // ins_mem.memory[0] = 16'b0000000000100101;
            // ins_mem.memory[1] = 16'b0000000000000001;
            // ins_mem.memory[2] = 16'b0000000000101000;
            ins_mem.memory[0] = 16'b0000000000100101;
            ins_mem.memory[1] = 16'b0011111111100101;
            ins_mem.memory[2] = 16'b0000000000000001;
            ins_mem.memory[3] = 16'b0010000010000011;
            ins_mem.memory[4] = 16'b0000000001001000;
            display_reg <= 0;
        end
        else if (left)
            display_reg <= display_reg - 1;
        else if (right)
            display_reg <= display_reg + 1;
      end

// SSD (Seven Segment Display)

    assign SSD0 = instruction[3:0];
    assign SSD1 = instruction[7:4];
    assign SSD2 = cpu.write_data[3:0];
    assign SSD3 = cpu.write_data[7:4];
    assign SSD4 = ins_mem.a[3:0];
    assign SSD5 = display_reg_data[3:0];
    assign SSD6 = display_reg_data[7:4];
    assign SSD7 = display_reg;

	assign ssdscan_clk = DIV_CLK[19:17];

    assign an[7]	= !(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 000
    assign an[6]	= !(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) && (ssdscan_clk[0]));  // when ssdscan_clk = 001
    assign an[5]	= !(~(ssdscan_clk[2]) && (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 010
    assign an[4]	= !(~(ssdscan_clk[2]) && (ssdscan_clk[1]) && (ssdscan_clk[0]));  // when ssdscan_clk = 011
    assign an[3]	= !((ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 100
    assign an[2]	= !((ssdscan_clk[2]) && ~(ssdscan_clk[1]) && (ssdscan_clk[0]));  // when ssdscan_clk = 101
    assign an[1]	= !((ssdscan_clk[2]) && (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 110
    assign an[0]	= !((ssdscan_clk[2]) && (ssdscan_clk[1]) && (ssdscan_clk[0]));  // when ssdscan_clk = 111


	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3, SSD4, SSD5, SSD6, SSD7)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk)
            3'b000: SSD =     SSD7;
            3'b001: SSD =     SSD6;
            3'b010: SSD =     SSD5;
            3'b011: SSD =     SSD4;
            3'b100: SSD =     SSD3;
            3'b101: SSD =     SSD2;
            3'b110: SSD =     SSD1;
            3'b111: SSD =     SSD0;
		endcase
	end

	// and finally convert SSD_num to ssd
	// We convert the output of our 4-bit 4x1 mux

	assign {seg[0], seg[1], seg[2], seg[3], seg[4], seg[5], seg[6], Dp} = {SSD_CATHODES};

	// Following is Hex-to-SSD conversion
	always @ (SSD)
	begin : HEX_TO_SSD
		case (SSD) // in this solution file the dot points are made to glow by making Dp = 0
		    //                                                                abcdefg,Dp
			// ****** TODO  in Part 2 ******
			// Revise the code below so that the dot points do not glow for your design.
			4'b0000: SSD_CATHODES = 8'b00000011; // 0
			4'b0001: SSD_CATHODES = 8'b10011111; // 1
			4'b0010: SSD_CATHODES = 8'b00100101; // 2
			4'b0011: SSD_CATHODES = 8'b00001101; // 3
			4'b0100: SSD_CATHODES = 8'b10011001; // 4
			4'b0101: SSD_CATHODES = 8'b01001001; // 5
			4'b0110: SSD_CATHODES = 8'b01000001; // 6
			4'b0111: SSD_CATHODES = 8'b00011111; // 7
			4'b1000: SSD_CATHODES = 8'b00000001; // 8
			4'b1001: SSD_CATHODES = 8'b00001001; // 9
			4'b1010: SSD_CATHODES = 8'b00010001; // A
			4'b1011: SSD_CATHODES = 8'b11000001; // B
			4'b1100: SSD_CATHODES = 8'b01100011; // C
			4'b1101: SSD_CATHODES = 8'b10000101; // D
			4'b1110: SSD_CATHODES = 8'b01100001; // E
			4'b1111: SSD_CATHODES = 8'b01110001; // F
			default: SSD_CATHODES = 8'bXXXXXXX1; // default is not needed as we covered all cases
		endcase
	end

endmodule
