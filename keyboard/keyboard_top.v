module keyboard_top
		(//MemOE, MemWR, RamCS,
		input qspi_csn, // Disable the three memory chips

        input CLK100MHZ,                           // the 100 MHz incoming clock signal

		input BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons BtnL, BtnR,
		input BtnC,                             // the center button (this is our reset in most of our designs)
		input PS2_CLK, PS2_DATA,
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

assign board_clk = CLK100MHZ;
	// BUFGP BUFGP1 (board_clk, CLK100MHZ);
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

    // ee354_debouncer #(.N_dc(28)) left_debounce
    //         (.CLK(sys_clk), .RESET(Reset), .PB(BtnL),
    // 		.DPB( ), .SCEN(left), .MCEN( ), .CCEN( ));
    // ee354_debouncer #(.N_dc(28)) right_debounce
    //         (.CLK(sys_clk), .RESET(Reset), .PB(BtnR),
    // 		.DPB( ), .SCEN(right), .MCEN( ), .CCEN( ));
    // ee354_debouncer #(.N_dc(28)) down_debounce
    //         (.CLK(sys_clk), .RESET(Reset), .PB(BtnD),
    // 		.DPB( ), .SCEN(down), .MCEN( ), .CCEN( ));
    // ee354_debouncer #(.N_dc(28)) up_debounce
    //         (.CLK(sys_clk), .RESET(Reset), .PB(BtnU),
    // 		.DPB( ), .SCEN(up), .MCEN( ), .CCEN( ));

// DESIGN

    reg CLK50MHZ=0;
    wire [31:0]keycode;

    always @(posedge(board_clk))begin
        CLK50MHZ<=~CLK50MHZ;
    end

    PS2Receiver keyboard (
    .clk(CLK50MHZ),
    .kclk(PS2_CLK),
    .kdata(PS2_DATA),
    .keycodeout(keycode[31:0])
    );

// SSD (Seven Segment Display)

    hex_7sd ssd (.x(keycode[31:0]), .clk(board_clk), .rst(Reset), .seg(seg[6:0]), .an(an[7:0]), .Dp(Dp));

// Simulation Test
    // initial #1000;
    // initial begin
    //     #100;
    //   $dumpvars();
    //   // $dumpall;
    //   $dumpfile("dump.vcd");
    // end
endmodule
