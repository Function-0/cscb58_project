// Part 2 skeleton

module project
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	assign writeEn = 1'b1;
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Instatiate datapath and control
    
    datapath d0(
    );

    control c0(
    );
    
endmodule

module datapath(clock, resetn, attempts,jump, init, playing, dead);
	input clock;
	input resetn;
	input jump;
	input init;
	input playing;
	
	output reg dead;
	
	reg [24:0] counter; // 24,999,999 has 25 digits in binary
	reg [2:0] height;
	reg killed;
	reg jump_pressed;
	always @(posedge clock) begin
		if(!resetn) begin
			
		end
		else begin
			if (init)
				begin
					counter <= 25'b1011111010111100000111111; // 24,999,999 (placeholder value)
					height <= 3'b000;
					killed <= 1'b0;
					jump_pressed <= 1'b0;
				end
			else if(playing)
				// this is where we calculate the player's position and collision detection
			else if(killed)
				begin
					killed <= 0;// will add more as we build the game
				end
					
				
			
		end
	end
endmodule   

module control(clock, resetn, killed, init, playing, dead);
	input clock;
	input resetn;
	input killed;
	output reg playing;
	output reg dead;
	
	reg [1:0] current_state, next_state;
	
	localparam 	INITIALIZE = 2'b00;
					PLAY_GAME  = 2'b01;
					DEAD       = 2'b10;
					DEAD_WAIT  = 2'b11;
					
					
			
	
	always@(*)
	begin: state_table
		case (current_state)
			INITIALIZE: next_state = PLAY_GAME;
			PLAY_GAME: next_state = killed ? DEAD : PLAY_GAME;
			DEAD: next_state = DEAD_WAIT;
			DEAD_WAIT: next_state = INITIALIZE;
			default: next_state = INITIALIZE;
		endcase
	end
	
	always @(*)
	begin: enable_signals
		init = 1'b0;
		playing = 1'b0;
		dead = 1'b0;
		
		case(current_state)
			INITIALIZE: init = 1'b1;
			PLAY_GAME: playing = 1'b1;
			DEAD: dead = 1'b1;
		endcase
	end

	always @(posedge clock)
	begin: state_FFs
		if(~resetn) 
		begin
			current_state <= INITIALIZE;
		end
		else
		begin
			current_state <= next_state;
		end
	end
endmodule
			
			
	