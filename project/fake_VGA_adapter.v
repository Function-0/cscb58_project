module fake_VGA_adapter(
// Input
resetn,
clock,
colour,
x,
y,
plot,
// Output
VGA_R,
VGA_G,
VGA_B,
VGA_HS,
VGA_VS,	
VGA_BLANK,
VGA_SYNC,
VGA_CLK
);

	input clock;
	input [10:0] x;      // 0 - 160 pixels
	input [10:0] y;      // 0 - 120 pixels
   input resetn;        // Active logic-0
	input plot;          // VGA adapter ON
	input [2:0] colour;
	output VGA_CLK;      // VGA Clock
	output VGA_HS;       // VGA H_SYNC
	output VGA_VS;       // VGA V_SYN
	output VGA_BLANK;    // VGA BLANK
	output VGA_SYNC;     // VGA SYNC
	output [10:0] VGA_R; // VGA Red[10:0]
	output [10:0] VGA_G; // VGA Green[10:0]
	output [10:0] VGA_B; // VGA Blue[10:0]
	
endmodule
