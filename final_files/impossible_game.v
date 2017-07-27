module impossible_game(
// Input
CLOCK_50,
SW,
KEY,
// Output
LEDR,
HEX,
VGA_CLK,
VGA_HS,
VGA_VS,
VGA_BLANK_N,
VGA_SYNC_N,
VGA_R,
VGA_G,
VGA_B
);

	 input CLOCK_50;       // 50 MHz clock
	 input [17:0] SW;      // SW[17:0]
	 input [3:0] KEY;      // KEY[3:0]

	 output [3:0] HEX;
	 output [17:0] LEDR;   // LEDR[17:0]
	 // VGA Adapter Arguments:
	 output VGA_CLK;      
	 output VGA_HS;     
	 output VGA_VS;       
	 output VGA_BLANK_N;   
	 output VGA_SYNC_N;    
	 output [10:0] VGA_R;  // VGA Red
	 output [10:0] VGA_G;  // VGA Green
	 output [10:0] VGA_B;  // VGA Blue
	 wire [2:0] colour;    // Control to VGA 
	 wire [10:0] x;        // Control to VGA: 0 - 160 pixels [X-Dimension]
	 wire [10:0] y;        // Control to VGA: 0 - 120 pixels [Y-Dimension]
    wire resetn = SW[17]; // To VGA: Active logic-0
	 wire writeEn;         // Control to VGA
	 // VGA Adapter Parameters:
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    // defparam VGA.BACKGROUND_IMAGE = "black.mif";
    defparam VGA.BACKGROUND_IMAGE = "impossible_game_title_card.mif";
	 
	 wire [25:0] counter;       // FPS to Control
	 wire update_screen;        // Control to Block Detector
	 wire [10:0] curr_shape_id; // Control to Block Detector
	 
	 // Constants:
    // Colours:
    wire [2:0] black = 3'b000;       
    wire [2:0] dark_blue = 3'b001;  
    wire [2:0] light_green = 3'b010; 
    wire [2:0] light_blue = 3'b011;  
    wire [2:0] red = 3'b100;         
    wire [2:0] pink = 3'b101;        
    wire [2:0] yellow = 3'b110;      
    wire [2:0] white = 3'b111;       
	 // Shapes: Colour specifications
	 wire [2:0] square_colour = red;
	 wire [2:0] spike_colour = white;
	 wire [2:0] block_colour = yellow;
	 wire [2:0] checkmark_colour = light_blue;
	 wire [2:0] x_symbol_colour = light_blue;
	 wire [2:0] screen_colour = black;
	 // Shapes: Score value specifications
	 wire [7:0] block_score_value = 8'd5;
	 wire [7:0] spike_score_value = 8'd10;
	 // Shapes: Standard dimensions
	 wire [10:0] shape_num_pixels_vertical = 8'd9;        // 10 pixels vertical
    wire [10:0] shape_num_pixels_horizontal = 8'd9;      // 10 pixels horizonal
	 wire [10:0] display_num_pixels_vertical = 11'd119;   // 120 pixels vertical
	 wire [10:0] display_num_pixels_horizontal = 11'd159; // 160 pixels horizontal
	 wire [10:0] empty_row_of_pixels = 8'd10;
    // Player: Idle position
	 wire [10:0] square_bottom_left_corner_x_pos_detector;
	 wire [10:0] square_bottom_left_corner_y_pos_detector; 
    // Coordinates: y-positions
    wire [10:0] y_level [8:0]; // HEIGHT: LOW ---> HIGH
    assign y_level[0] = 8'd99;  
    assign y_level[1] = 8'd89;  
    assign y_level[2] = 8'd79;  
    assign y_level[3] = 8'd69;  
    assign y_level[4] = 8'd59;  
    assign y_level[5] = 8'd49;  
    assign y_level[6] = 8'd39;
	 assign y_level[7] = 8'd29;  
	 assign y_level[8] = 8'd19; // Checkmark; X symbol [2 Parts]: Left side and Right side  
	 // Coordinates: x-positions
	 wire [10:0] x_level [1:0];
	 assign x_level[0] = 8'd159; // Blocks; Spikes    
	 assign x_level[1] = 8'd79;  // Checkmark; X symbol [2 Parts]: Left side and Right side
	 // Delay_counters: // TEMPORARY //
	 wire [49:0] delay_counter_interval; // (frame rate * 10); Delays for 1 block
    // Increase size of the following wires if more shape modules are required
    wire [110:0] draw_start;         // Control to each Shape
    wire [110:0] draw_done;          // Each Shape to Control
	 wire [110:0] reset;              // Control to each Shape
    wire [10:0] send_x [110:0];      // Each Shape to Control
	 wire [1220:0] real_send_x = {send_x[110],
											send_x[109],
											send_x[108],
											send_x[107],
											send_x[106],
											send_x[105],
											send_x[104],
											send_x[103],
											send_x[102],
											send_x[101],
											send_x[100],
											send_x[99],
											send_x[98],
											send_x[97],
											send_x[96],
											send_x[95],
											send_x[94],
											send_x[93],
											send_x[92],
											send_x[91],
											send_x[90],
											send_x[89],
											send_x[88],
											send_x[87],
											send_x[86],
											send_x[85],
											send_x[84],
											send_x[83],
											send_x[82],
											send_x[81],
											send_x[80],
											send_x[79],
											send_x[78],
											send_x[77],
											send_x[76],
											send_x[75],
											send_x[74],
											send_x[73],
											send_x[72],
											send_x[71],
											send_x[70],
											send_x[69],
											send_x[68],
											send_x[67],
											send_x[66],
											send_x[65],
											send_x[64],
											send_x[63],
											send_x[62],
											send_x[61],
											send_x[60],
											send_x[59],
											send_x[58],
											send_x[57],
											send_x[56],
											send_x[55],
											send_x[54],
											send_x[53],
											send_x[52],
											send_x[51],
											send_x[50],
											send_x[49],
											send_x[48],
											send_x[47],
											send_x[46],
											send_x[45],
											send_x[44],
											send_x[43],
											send_x[42],
											send_x[41],
											send_x[40],
											send_x[39],
											send_x[38],
											send_x[37],
											send_x[36],
											send_x[35],
											send_x[34],
											send_x[33],
											send_x[32],
											send_x[31],
											send_x[30],
											send_x[29],
											send_x[28],
											send_x[27],
											send_x[26],
											send_x[25],
											send_x[24],
											send_x[23],
											send_x[22],
											send_x[21],
											send_x[20],
											send_x[19],
											send_x[18],
											send_x[17],
											send_x[16],
											send_x[15],
											send_x[14],
											send_x[13],
											send_x[12],
											send_x[11],
											send_x[10],
											send_x[9],
											send_x[8],
											send_x[7],
											send_x[6],
											send_x[5],
											send_x[4],
											send_x[3],
											send_x[2],
											send_x[1],
											send_x[0]};
    wire [10:0] send_y [110:0];      // Each Shape to Control
	 wire [1220:0] real_send_y = {send_y[110],
											send_y[109],
											send_y[108],
											send_y[107],
											send_y[106],
											send_y[105],
											send_y[104],
											send_y[103],
											send_y[102],
											send_y[101],
											send_y[100],
											send_y[99],
											send_y[98],
											send_y[97],
											send_y[96],
											send_y[95],
											send_y[94],
											send_y[93],
											send_y[92],
											send_y[91],
											send_y[90],
											send_y[89],
											send_y[88],
											send_y[87],
											send_y[86],
											send_y[85],
											send_y[84],
											send_y[83],
											send_y[82],
											send_y[81],
											send_y[80],
											send_y[79],
											send_y[78],
											send_y[77],
											send_y[76],
											send_y[75],
											send_y[74],
											send_y[73],
											send_y[72],
											send_y[71],
											send_y[70],
											send_y[69],
											send_y[68],
											send_y[67],
											send_y[66],
											send_y[65],
											send_y[64],
											send_y[63],
											send_y[62],
											send_y[61],
											send_y[60],
											send_y[59],
											send_y[58],
											send_y[57],
											send_y[56],
											send_y[55],
											send_y[54],
											send_y[53],
											send_y[52],
											send_y[51],
											send_y[50],
											send_y[49],
											send_y[48],
											send_y[47],
											send_y[46],
											send_y[45],
											send_y[44],
											send_y[43],
											send_y[42],
											send_y[41],
											send_y[40],
											send_y[39],
											send_y[38],
											send_y[37],
											send_y[36],
											send_y[35],
											send_y[34],
											send_y[33],
											send_y[32],
											send_y[31],
											send_y[30],
											send_y[29],
											send_y[28],
											send_y[27],
											send_y[26],
											send_y[25],
											send_y[24],
											send_y[23],
											send_y[22],
											send_y[21],
											send_y[20],
											send_y[19],
											send_y[18],
											send_y[17],
											send_y[16],
											send_y[15],
											send_y[14],
											send_y[13],
											send_y[12],
											send_y[11],
											send_y[10],
											send_y[9],
											send_y[8],
											send_y[7],
											send_y[6],
											send_y[5],
											send_y[4],
											send_y[3],
											send_y[2],
											send_y[1],
											send_y[0]};
	 wire [10:0] shape_gone [99:0];  // Each shape to Control 
	 wire [1099:0] real_shape_gone = {
											shape_gone[99],
											shape_gone[98],
											shape_gone[97],
											shape_gone[96],
											shape_gone[95],
											shape_gone[94],
											shape_gone[93],
											shape_gone[92],
											shape_gone[91],
											shape_gone[90],
											shape_gone[89],
											shape_gone[88],
											shape_gone[87],
											shape_gone[86],
											shape_gone[85],
											shape_gone[84],
											shape_gone[83],
											shape_gone[82],
											shape_gone[81],
											shape_gone[80],
											shape_gone[79],
											shape_gone[78],
											shape_gone[77],
											shape_gone[76],
											shape_gone[75],
											shape_gone[74],
											shape_gone[73],
											shape_gone[72],
											shape_gone[71],
											shape_gone[70],
											shape_gone[69],
											shape_gone[68],
											shape_gone[67],
											shape_gone[66],
											shape_gone[65],
											shape_gone[64],
											shape_gone[63],
											shape_gone[62],
											shape_gone[61],
											shape_gone[60],
											shape_gone[59],
											shape_gone[58],
											shape_gone[57],
											shape_gone[56],
											shape_gone[55],
											shape_gone[54],
											shape_gone[53],
											shape_gone[52],
											shape_gone[51],
											shape_gone[50],
											shape_gone[49],
											shape_gone[48],
											shape_gone[47],
											shape_gone[46],
											shape_gone[45],
											shape_gone[44],
											shape_gone[43],
											shape_gone[42],
											shape_gone[41],
											shape_gone[40],
											shape_gone[39],
											shape_gone[38],
											shape_gone[37],
											shape_gone[36],
											shape_gone[35],
											shape_gone[34],
											shape_gone[33],
											shape_gone[32],
											shape_gone[31],
											shape_gone[30],
											shape_gone[29],
											shape_gone[28],
											shape_gone[27],
											shape_gone[26],
											shape_gone[25],
											shape_gone[24],
											shape_gone[23],
											shape_gone[22],
											shape_gone[21],
											shape_gone[20],
											shape_gone[19],
											shape_gone[18],
											shape_gone[17],
											shape_gone[16],
											shape_gone[15],
											shape_gone[14],
											shape_gone[13],
											shape_gone[12],
											shape_gone[11],
											shape_gone[10],
											shape_gone[9],
											shape_gone[8],
											shape_gone[7],
											shape_gone[6],
											shape_gone[5],
											shape_gone[4],
											shape_gone[3],
											shape_gone[2],
											shape_gone[1],
											shape_gone[0]};
    wire [2:0]  send_colour [110:0]; // Each Shape to Control
	 wire [332:0] real_send_colour = {
										   send_colour[110],
											send_colour[109],
											send_colour[108],
											send_colour[107],
											send_colour[106],
											send_colour[105],
											send_colour[104],
											send_colour[103],
											send_colour[102],
											send_colour[101],
											send_colour[100],
											send_colour[99],
											send_colour[98],
											send_colour[97],
											send_colour[96],
											send_colour[95],
											send_colour[94],
											send_colour[93],
											send_colour[92],
											send_colour[91],
											send_colour[90],
											send_colour[89],
											send_colour[88],
											send_colour[87],
											send_colour[86],
											send_colour[85],
											send_colour[84],
											send_colour[83],
											send_colour[82],
											send_colour[81],
											send_colour[80],
											send_colour[79],
											send_colour[78],
											send_colour[77],
											send_colour[76],
											send_colour[75],
											send_colour[74],
											send_colour[73],
											send_colour[72],
											send_colour[71],
											send_colour[70],
											send_colour[69],
											send_colour[68],
											send_colour[67],
											send_colour[66],
											send_colour[65],
											send_colour[64],
											send_colour[63],
											send_colour[62],
											send_colour[61],
											send_colour[60],
											send_colour[59],
											send_colour[58],
											send_colour[57],
											send_colour[56],
											send_colour[55],
											send_colour[54],
											send_colour[53],
											send_colour[52],
											send_colour[51],
											send_colour[50],
											send_colour[49],
											send_colour[48],
											send_colour[47],
											send_colour[46],
											send_colour[45],
											send_colour[44],
											send_colour[43],
											send_colour[42],
											send_colour[41],
											send_colour[40],
											send_colour[39],
											send_colour[38],
											send_colour[37],
											send_colour[36],
											send_colour[35],
											send_colour[34],
											send_colour[33],
											send_colour[32],
											send_colour[31],
											send_colour[30],
											send_colour[29],
											send_colour[28],
											send_colour[27],
											send_colour[26],
											send_colour[25],
											send_colour[24],
											send_colour[23],
											send_colour[22],
											send_colour[21],
											send_colour[20],
											send_colour[19],
											send_colour[18],
											send_colour[17],
											send_colour[16],
											send_colour[15],
											send_colour[14],
											send_colour[13],
											send_colour[12],
											send_colour[11],
											send_colour[10],
											send_colour[9],
											send_colour[8],
											send_colour[7],
											send_colour[6],
											send_colour[5],
											send_colour[4],
											send_colour[3],
											send_colour[2],
											send_colour[1],
											send_colour[0]};
    wire [10:0] row_start [49:0];   // Each Shape to Control: 10 for each shape
    wire [10:0] row_end [49:0];     // Each Shape to Control: 10 for each shape
	 wire [10:0] square_send_bottom_left_corner_x_pos [6:0];
	 wire [10:0] square_send_bottom_left_corner_y_pos [6:0];
	 wire [10:0] block_send_bottom_left_corner_x_pos [26:0];
	 wire [10:0] block_send_bottom_left_corner_y_pos [26:0];
	 wire [10:0] spike_send_bottom_left_corner_x_pos [72:0]; 
	 wire [10:0] spike_send_bottom_left_corner_y_pos [72:0]; 
	 wire [2:0] obstacle_colour [99:0];
	 wire [10:0] obstacle_delay_counter [99:0];
	 wire [10:0] obstacle_bottom_left_corner_x_pos = x_level[0];
	 wire [10:0] obstacle_bottom_left_corner_y_pos [99:0];
	 wire [10:0] obstacle_score_value [99:0];
	 wire [10:0] obstacle_send_bottom_left_corner_x_pos [99:0];
	 wire [10:0] obstacle_send_bottom_left_corner_y_pos [99:0];
	 wire [109:0] obstacle_draw_start_pos [99:0];
	 wire [109:0] obstacle_draw_end_pos [99:0];
	 wire [10:0] move_counter = 1'd1;
	 wire is_jump_button_pressed;
	 wire is_spike_hit;
	 // Shapes: Drawing Specifications
	 // INDEX:
	 // Square & Block: row_start[9:0]; row_end[9:0]
	 // Spike: row_start[19:10]; row_end[19:10]
	 // Checkmark: row_start[29:20]; row_end[29:20]
	 // X Symbol [2 Parts]: Left side: row_start[39:30]; row_end[39:30]
	 // X Symbol [2 Parts]: Right side: row_start[49:40]; row_end[49:40]
	 // Square & Block: 
    assign row_start[0] = 8'd0; // ROW 1: 10 full
    assign row_end[0] = 8'd9;
    assign row_start[1] = 8'd0; // ROW 2: 10 full
    assign row_end[1] = 8'd9;
    assign row_start[2] = 8'd0; // ROW 3: 10 full
    assign row_end[2] = 8'd9;
    assign row_start[3] = 8'd0; // ROW 4: 10 full
    assign row_end[3] = 8'd9; 
    assign row_start[4] = 8'd0; // ROW 5: 10 full
    assign row_end[4] = 8'd9;
    assign row_start[5] = 8'd0; // ROW 6: 10 full
    assign row_end[5] = 8'd9;
    assign row_start[6] = 8'd0; // ROW 7: 10 full
    assign row_end[6] = 8'd9;
    assign row_start[7] = 8'd0; // ROW 8: 10 full
    assign row_end[7] = 8'd9;
    assign row_start[8] = 8'd0; // ROW 9: 10 full
    assign row_end[8] = 8'd9;
    assign row_start[9] = 8'd0; // ROW 10: 10 full
    assign row_end[9] = 8'd9;
	 // Spike:
	 assign row_start[10] = 8'd4; // ROW 1: 4 blank, 2 full, 4 blank
    assign row_end[10] = 8'd5;
    assign row_start[11] = 8'd4; // ROW 2: 4 blank, 2 full, 4 blank
    assign row_end[11] = 8'd5;
    assign row_start[12] = 8'd3; // ROW 3: 3 blank, 4 full, 3 blank
    assign row_end[12] = 8'd6;
    assign row_start[13] = 8'd3; // ROW 4: 3 blank, 4 full, 3 blank
    assign row_end[13] = 8'd6;
    assign row_start[14] = 8'd2; // ROW 5: 2 blank, 6 full, 2 blank
    assign row_end[14] = 8'd7;
    assign row_start[15] = 8'd2; // ROW 6: 2 blank, 6 full 2 blank
    assign row_end[15] = 8'd7;
    assign row_start[16] = 8'd1; // ROW 7: 1 blank, 8 full, 1 blank
    assign row_end[16] = 8'd8;
    assign row_start[17] = 8'd1; // ROW 8: 1 blank, 8 full, 1 blank
    assign row_end[17] = 8'd8;
    assign row_start[18] = 8'd0; // ROW 9: 10 full
    assign row_end[18] = 8'd9;
    assign row_start[19] = 8'd0; // ROW 10: 10 full
    assign row_end[19] = 8'd9;
	 // Checkmark:
	 assign row_start[20] = empty_row_of_pixels; // ROW 1: 10 blank
    assign row_end[20] = empty_row_of_pixels;
    assign row_start[21] = 8'd9; // ROW 2: 9 blank, 1 full
    assign row_end[21] = 8'd9; 
    assign row_start[22] = 8'd8; // ROW 3: 8 blank, 2 full
    assign row_end[22] = 8'd9;
    assign row_start[23] = 8'd7; // ROW 4: 7 blank, 3 full
    assign row_end[23] = 8'd9;
    assign row_start[24] = 8'd6; // ROW 5: 6 blank, 3 full, 1 blank
    assign row_end[24] = 8'd8;
    assign row_start[25] = 8'd5; // ROW 6: 5 blank, 3 full, 2 blank
    assign row_end[25] = 8'd7;
    assign row_start[26] = 8'd4; // ROW 7: 4 blank, 3 full, 3 blank
    assign row_end[26] = 8'd6;
    assign row_start[27] = 8'd0; // ROW 8: 6 full, 4 blank
    assign row_end[27] = 8'd5;
    assign row_start[28] = 8'd1; // ROW 9: 1 blank, 4 full, 5 blank
    assign row_end[28] = 8'd4;
    assign row_start[29] = 8'd2; // ROW 10: 2 blank, 2 full, 6 blank
    assign row_end[29] = 8'd3;				
	 // X symbol [2 Parts]: Left side
	 assign row_start[30] = 8'd0; // ROW 1: 2 full, 8 blank
    assign row_end[30] = 8'd1;
    assign row_start[31] = 8'd0; // ROW 2: 3 full, 7 blank
    assign row_end[31] = 8'd2; 
    assign row_start[32] = 8'd1; // ROW 3: 1 blank, 3 full, 6 blank
    assign row_end[32] = 8'd3;
    assign row_start[33] = 8'd2; // ROW 4: 2 blank, 3 full, 5 blank
    assign row_end[33] = 8'd4;
    assign row_start[34] = 8'd3; // ROW 5: 3 blank, 2 full, 5 blank
    assign row_end[34] = 8'd4;
    assign row_start[35] = 8'd3; // ROW 6: 3 blank, 2 full, 5 blank
    assign row_end[35] = 8'd4;
    assign row_start[36] = 8'd2; // ROW 7: 2 blank, 3 full, 5 blank
    assign row_end[36] = 8'd4;
    assign row_start[37] = 8'd1; // ROW 8: 1 blank, 3 full, 6 blank
    assign row_end[37] = 8'd3;
    assign row_start[38] = 8'd0; // ROW 9: 3 full, 7 blank
    assign row_end[38] = 8'd2;
    assign row_start[39] = 8'd0; // ROW 10: 2 full, 8 blank
    assign row_end[39] = 8'd1;
	 // X symbol [2 Parts]: Right side
	 assign row_start[40] = 8'd8; // ROW 1: 8 blank, 2 full
    assign row_end[40] = 8'd9;
    assign row_start[41] = 8'd7; // ROW 2: 7 blank, 3 full
    assign row_end[41] = 8'd9; 
    assign row_start[42] = 8'd6; // ROW 3: 6 blank, 3 full, 1 blank
    assign row_end[42] = 8'd8;
    assign row_start[43] = 8'd5; // ROW 4: 5 blank, 3 full, 2 blank
    assign row_end[43] = 8'd7;
    assign row_start[44] = 8'd5; // ROW 5: 5 blank, 2 full, 3 blank
    assign row_end[44] = 8'd6;
    assign row_start[45] = 8'd5; // ROW 6: 5 blank, 2 full, 3 blank
    assign row_end[45] = 8'd6;
    assign row_start[46] = 8'd5; // ROW 7: 5 blank, 3 full, 2 blank
    assign row_end[46] = 8'd7;
    assign row_start[47] = 8'd6; // ROW 8: 6 blank, 3 full, 1 blank
    assign row_end[47] = 8'd8;
    assign row_start[48] = 8'd7; // ROW 9: 7 blank, 3 full
    assign row_end[48] = 8'd9;
    assign row_start[49] = 8'd8; // ROW 10: 8 blank, 2 full 
    assign row_end[49] = 8'd9;
	 // Shapes: Drawing designations
	 // Square & Block: 
	 wire [109:0] square_and_block_draw_start_pos = {row_start[9][10:0], 
																	 row_start[8][10:0], 
																	 row_start[7][10:0],
																	 row_start[6][10:0],
																	 row_start[5][10:0],
																	 row_start[4][10:0],
																	 row_start[3][10:0],
																	 row_start[2][10:0],
																	 row_start[1][10:0],
																	 row_start[0][10:0]};
	 wire [109:0] square_and_block_draw_end_pos = {row_end[9][10:0], 
																  row_end[8][10:0], 
																  row_end[7][10:0],
																  row_end[6][10:0],
																  row_end[5][10:0],
																  row_end[4][10:0],
																  row_end[3][10:0],
																  row_end[2][10:0],
																  row_end[1][10:0],
																  row_end[0][10:0]};
	 // Spike:
	 wire [109:0] spike_draw_start_pos = {row_start[19][10:0], 
													  row_start[18][10:0], 
													  row_start[17][10:0],
													  row_start[16][10:0],
													  row_start[15][10:0],
													  row_start[14][10:0],
													  row_start[13][10:0],
													  row_start[12][10:0],
													  row_start[11][10:0],
													  row_start[10][10:0]};
	 wire [109:0] spike_draw_end_pos = {row_end[19][10:0], 
													row_end[18][10:0], 
													row_end[17][10:0],
													row_end[16][10:0],
													row_end[15][10:0],
													row_end[14][10:0],
													row_end[13][10:0],
													row_end[12][10:0],
													row_end[11][10:0],
													row_end[10][10:0]};
	 // Checkmark:
	 wire [109:0] checkmark_draw_start_pos = {row_start[29][10:0], 
															row_start[28][10:0], 
															row_start[27][10:0],
															row_start[26][10:0],
															row_start[25][10:0],
															row_start[24][10:0],
															row_start[23][10:0],
															row_start[22][10:0],
															row_start[21][10:0],
															row_start[20][10:0]};
    wire [109:0] checkmark_draw_end_pos = {row_end[29][10:0], 
														 row_end[28][10:0], 
														 row_end[27][10:0],
														 row_end[26][10:0],
														 row_end[25][10:0],
														 row_end[24][10:0],
														 row_end[23][10:0],
														 row_end[22][10:0],
														 row_end[21][10:0],
														 row_end[20][10:0]};	
	 // X symbol [2 Parts]: Left side	 
	 wire [109:0] x_symbol_left_side_draw_start_pos = {row_start[39][10:0], 
																		row_start[38][10:0], 
																		row_start[37][10:0],
																		row_start[36][10:0],
																		row_start[35][10:0],
																		row_start[34][10:0],
																		row_start[33][10:0],
																		row_start[32][10:0],
																		row_start[31][10:0],
																		row_start[30][10:0]};
	 wire [109:0] x_symbol_left_side_draw_end_pos = {row_end[39][10:0], 
																	 row_end[38][10:0], 
																	 row_end[37][10:0],
																	 row_end[36][10:0],
																	 row_end[35][10:0],
																	 row_end[34][10:0],
																	 row_end[33][10:0],
																	 row_end[32][10:0],
																	 row_end[31][10:0],
																	 row_end[30][10:0]};	
    // X symbol [2 Parts]: Right side
	 wire [109:0] x_symbol_right_side_draw_start_pos = {row_start[49][10:0], 
																		 row_start[48][10:0], 
																		 row_start[47][10:0],
																		 row_start[46][10:0],
																		 row_start[45][10:0],
																		 row_start[44][10:0],
																		 row_start[43][10:0],
																		 row_start[42][10:0],
																		 row_start[41][10:0],
																		 row_start[40][10:0]};																	 
	 wire [109:0] x_symbol_right_side_draw_end_pos = {row_end[49][10:0], 
																	  row_end[48][10:0], 
																	  row_end[47][10:0],
																	  row_end[46][10:0],
																	  row_end[45][10:0],
																	  row_end[44][10:0],
																	  row_end[43][10:0],
																	  row_end[42][10:0],
																	  row_end[41][10:0],
																	  row_end[40][10:0]};
	 // Shapes: Colour designations															  
	 assign obstacle_colour[0] = spike_colour;
	 assign obstacle_colour[1] = spike_colour;
	 assign obstacle_colour[2] = spike_colour;
	 assign obstacle_colour[3] = spike_colour;
	 assign obstacle_colour[4] = block_colour;
	 assign obstacle_colour[5] = spike_colour;
	 assign obstacle_colour[6] = spike_colour;
	 assign obstacle_colour[7] = spike_colour;
	 assign obstacle_colour[8] = block_colour;
	 assign obstacle_colour[9] = spike_colour;
    assign obstacle_colour[10] = spike_colour;
	 assign obstacle_colour[11] = spike_colour;
	 assign obstacle_colour[12] = spike_colour;
	 assign obstacle_colour[13] = spike_colour;
	 assign obstacle_colour[14] = spike_colour;
	 assign obstacle_colour[15] = spike_colour;
	 assign obstacle_colour[16] = block_colour;
	 assign obstacle_colour[17] = spike_colour;
	 assign obstacle_colour[18] = spike_colour;
	 assign obstacle_colour[19] = spike_colour;
	 assign obstacle_colour[20] = block_colour;
	 assign obstacle_colour[21] = spike_colour;
	 assign obstacle_colour[22] = spike_colour;
	 assign obstacle_colour[23] = spike_colour;
	 assign obstacle_colour[24] = spike_colour;
	 assign obstacle_colour[25] = spike_colour;
	 assign obstacle_colour[26] = spike_colour;
	 assign obstacle_colour[27] = spike_colour;
	 assign obstacle_colour[28] = block_colour;
	 assign obstacle_colour[29] = spike_colour;
	 assign obstacle_colour[30] = spike_colour;
	 assign obstacle_colour[31] = spike_colour;
	 assign obstacle_colour[32] = spike_colour;
	 assign obstacle_colour[33] = block_colour;
	 assign obstacle_colour[34] = spike_colour;
	 assign obstacle_colour[35] = spike_colour;
	 assign obstacle_colour[36] = spike_colour;
	 assign obstacle_colour[37] = spike_colour;
	 assign obstacle_colour[38] = block_colour;
	 assign obstacle_colour[39] = spike_colour;
	 assign obstacle_colour[40] = spike_colour;
	 assign obstacle_colour[41] = spike_colour;
	 assign obstacle_colour[42] = spike_colour;
	 assign obstacle_colour[43] = block_colour;
	 assign obstacle_colour[44] = spike_colour;
	 assign obstacle_colour[45] = spike_colour;
	 assign obstacle_colour[46] = spike_colour;
	 assign obstacle_colour[47] = block_colour;
	 assign obstacle_colour[48] = spike_colour;
	 assign obstacle_colour[49] = spike_colour;
	 assign obstacle_colour[50] = block_colour;
	 assign obstacle_colour[51] = spike_colour;
	 assign obstacle_colour[52] = spike_colour;
	 assign obstacle_colour[53] = spike_colour;
	 assign obstacle_colour[54] = spike_colour;
	 assign obstacle_colour[55] = block_colour;
	 assign obstacle_colour[56] = spike_colour;
	 assign obstacle_colour[57] = spike_colour;
	 assign obstacle_colour[58] = block_colour;
	 assign obstacle_colour[59] = block_colour;
	 assign obstacle_colour[60] = block_colour;
	 assign obstacle_colour[61] = spike_colour;
	 assign obstacle_colour[62] = spike_colour;
	 assign obstacle_colour[63] = spike_colour;
	 assign obstacle_colour[64] = spike_colour;
	 assign obstacle_colour[65] = spike_colour;
	 assign obstacle_colour[66] = block_colour;
	 assign obstacle_colour[67] = spike_colour;
	 assign obstacle_colour[68] = spike_colour;
	 assign obstacle_colour[69] = spike_colour;
	 assign obstacle_colour[70] = spike_colour;
	 assign obstacle_colour[71] = block_colour;
	 assign obstacle_colour[72] = spike_colour;
	 assign obstacle_colour[73] = spike_colour;
	 assign obstacle_colour[74] = spike_colour;
	 assign obstacle_colour[75] = spike_colour;
	 assign obstacle_colour[76] = block_colour;
	 assign obstacle_colour[77] = spike_colour;
	 assign obstacle_colour[78] = spike_colour;
	 assign obstacle_colour[79] = spike_colour;
	 assign obstacle_colour[80] = spike_colour;
	 assign obstacle_colour[81] = block_colour;
	 assign obstacle_colour[82] = spike_colour;
	 assign obstacle_colour[83] = block_colour;
	 assign obstacle_colour[84] = spike_colour;
	 assign obstacle_colour[85] = block_colour;
	 assign obstacle_colour[86] = spike_colour;
	 assign obstacle_colour[87] = block_colour;
	 assign obstacle_colour[88] = spike_colour;
	 assign obstacle_colour[89] = block_colour;
	 assign obstacle_colour[90] = spike_colour;
	 assign obstacle_colour[91] = block_colour;
	 assign obstacle_colour[92] = spike_colour;
	 assign obstacle_colour[93] = block_colour;
	 assign obstacle_colour[94] = spike_colour;
	 assign obstacle_colour[95] = block_colour;
	 assign obstacle_colour[96] = spike_colour;
	 assign obstacle_colour[97] = block_colour;
	 assign obstacle_colour[98] = spike_colour;
	 assign obstacle_colour[99] = block_colour;
	 // Shapes: Delay counter interval designation
	 assign obstacle_delay_counter[0] = 8'd0;
	 assign obstacle_delay_counter[1] = 8'd5;
	 assign obstacle_delay_counter[2] = 8'd10;
	 assign obstacle_delay_counter[3] = 8'd11;
	 assign obstacle_delay_counter[4] = 8'd16;
	 assign obstacle_delay_counter[5] = 8'd17;
	 assign obstacle_delay_counter[6] = 8'd18;
	 assign obstacle_delay_counter[7] = 8'd19;
	 assign obstacle_delay_counter[8] = 8'd20;
	 assign obstacle_delay_counter[9] = 8'd25;
	 assign obstacle_delay_counter[10] = 8'd26;
	 assign obstacle_delay_counter[11] = 8'd31;
	 assign obstacle_delay_counter[12] = 8'd36;
	 assign obstacle_delay_counter[13] = 8'd40;
	 assign obstacle_delay_counter[14] = 8'd44;
	 assign obstacle_delay_counter[15] = 8'd45;
	 assign obstacle_delay_counter[16] = 8'd51;
	 assign obstacle_delay_counter[17] = 8'd52;
	 assign obstacle_delay_counter[18] = 8'd53;
	 assign obstacle_delay_counter[19] = 8'd54;
	 assign obstacle_delay_counter[20] = 8'd55;
	 assign obstacle_delay_counter[21] = 8'd60;
	 assign obstacle_delay_counter[22] = 8'd61;
	 assign obstacle_delay_counter[23] = 8'd69;
	 assign obstacle_delay_counter[24] = 8'd76;
	 assign obstacle_delay_counter[25] = 8'd80;
	 assign obstacle_delay_counter[26] = 8'd84;
	 assign obstacle_delay_counter[27] = 8'd85;
	 assign obstacle_delay_counter[28] = 8'd93;
	 assign obstacle_delay_counter[29] = 8'd94;
	 assign obstacle_delay_counter[30] = 8'd95;
	 assign obstacle_delay_counter[31] = 8'd96;
	 assign obstacle_delay_counter[32] = 8'd97;
	 assign obstacle_delay_counter[33] = 8'd97;
	 assign obstacle_delay_counter[34] = 8'd98;
	 assign obstacle_delay_counter[35] = 8'd99;
	 assign obstacle_delay_counter[36] = 8'd100;
	 assign obstacle_delay_counter[37] = 8'd101;
	 assign obstacle_delay_counter[38] = 8'd101;
	 assign obstacle_delay_counter[39] = 8'd102;
	 assign obstacle_delay_counter[40] = 8'd103;
	 assign obstacle_delay_counter[41] = 8'd104;
	 assign obstacle_delay_counter[42] = 8'd105;
	 assign obstacle_delay_counter[43] = 8'd105;
	 assign obstacle_delay_counter[44] = 8'd106;
	 assign obstacle_delay_counter[45] = 8'd107;
	 assign obstacle_delay_counter[46] = 8'd108;
	 assign obstacle_delay_counter[47] = 8'd109;
	 assign obstacle_delay_counter[48] = 8'd113;
	 assign obstacle_delay_counter[49] = 8'd121;
	 assign obstacle_delay_counter[50] = 8'd129;
	 assign obstacle_delay_counter[51] = 8'd130;
	 assign obstacle_delay_counter[52] = 8'd131;
	 assign obstacle_delay_counter[53] = 8'd132;
	 assign obstacle_delay_counter[54] = 8'd137;
	 assign obstacle_delay_counter[55] = 8'd138;
	 assign obstacle_delay_counter[56] = 8'd140;
	 assign obstacle_delay_counter[57] = 8'd145;
	 assign obstacle_delay_counter[58] = 8'd151;
	 assign obstacle_delay_counter[59] = 8'd155;
	 assign obstacle_delay_counter[60] = 8'd156;
	 assign obstacle_delay_counter[61] = 8'd156;
	 assign obstacle_delay_counter[62] = 8'd160;
	 assign obstacle_delay_counter[63] = 8'd161;
	 assign obstacle_delay_counter[64] = 8'd166;
	 assign obstacle_delay_counter[65] = 8'd173;
	 assign obstacle_delay_counter[66] = 8'd179;
	 assign obstacle_delay_counter[67] = 8'd180;
	 assign obstacle_delay_counter[68] = 8'd181;
	 assign obstacle_delay_counter[69] = 8'd182;
	 assign obstacle_delay_counter[70] = 8'd183;
	 assign obstacle_delay_counter[71] = 8'd183;
	 assign obstacle_delay_counter[72] = 8'd184;
	 assign obstacle_delay_counter[73] = 8'd185;
	 assign obstacle_delay_counter[74] = 8'd186;
	 assign obstacle_delay_counter[75] = 8'd187;
	 assign obstacle_delay_counter[76] = 8'd187;
	 assign obstacle_delay_counter[77] = 8'd188;
	 assign obstacle_delay_counter[78] = 8'd189;
	 assign obstacle_delay_counter[79] = 8'd190;
	 assign obstacle_delay_counter[80] = 8'd191;
	 assign obstacle_delay_counter[81] = 8'd191;
	 assign obstacle_delay_counter[82] = 8'd192;
	 assign obstacle_delay_counter[83] = 8'd192;
	 assign obstacle_delay_counter[84] = 8'd193;
	 assign obstacle_delay_counter[85] = 8'd193;
	 assign obstacle_delay_counter[86] = 8'd194;
	 assign obstacle_delay_counter[87] = 8'd194;
	 assign obstacle_delay_counter[88] = 8'd195;
	 assign obstacle_delay_counter[89] = 8'd195;
	 assign obstacle_delay_counter[90] = 8'd196;
	 assign obstacle_delay_counter[91] = 8'd196;
	 assign obstacle_delay_counter[92] = 8'd197;
	 assign obstacle_delay_counter[93] = 8'd197;
	 assign obstacle_delay_counter[94] = 8'd198;
	 assign obstacle_delay_counter[95] = 8'd198;
	 assign obstacle_delay_counter[96] = 8'd199;
	 assign obstacle_delay_counter[97] = 8'd199;
	 assign obstacle_delay_counter[98] = 8'd200;
	 assign obstacle_delay_counter[99] = 8'd200;
	 // Shapes: Y-position designation
	 assign obstacle_bottom_left_corner_y_pos[0] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[1] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[2] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[3] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[4] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[5] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[6] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[7] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[8] = y_level[1];
	 assign obstacle_bottom_left_corner_y_pos[9] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[10] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[11] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[12] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[13] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[14] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[15] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[16] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[17] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[18] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[19] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[20] = y_level[1];
	 assign obstacle_bottom_left_corner_y_pos[21] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[22] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[23] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[24] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[25] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[26] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[27] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[28] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[29] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[30] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[31] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[32] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[33] = y_level[1];
	 assign obstacle_bottom_left_corner_y_pos[34] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[35] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[36] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[37] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[38] = y_level[2];
	 assign obstacle_bottom_left_corner_y_pos[39] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[40] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[41] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[42] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[43] = y_level[1];
	 assign obstacle_bottom_left_corner_y_pos[44] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[45] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[46] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[47] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[48] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[49] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[50] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[51] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[52] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[53] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[54] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[55] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[56] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[57] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[58] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[59] = y_level[1];
	 assign obstacle_bottom_left_corner_y_pos[60] = y_level[1];
	 assign obstacle_bottom_left_corner_y_pos[61] = y_level[2];
	 assign obstacle_bottom_left_corner_y_pos[62] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[63] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[64] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[65] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[66] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[67] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[68] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[69] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[70] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[71] = y_level[1];
	 assign obstacle_bottom_left_corner_y_pos[72] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[73] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[74] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[75] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[76] = y_level[2];
	 assign obstacle_bottom_left_corner_y_pos[77] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[78] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[79] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[80] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[81] = y_level[3];
	 assign obstacle_bottom_left_corner_y_pos[82] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[83] = y_level[3];
	 assign obstacle_bottom_left_corner_y_pos[84] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[85] = y_level[3];
	 assign obstacle_bottom_left_corner_y_pos[86] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[87] = y_level[3];
	 assign obstacle_bottom_left_corner_y_pos[88] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[89] = y_level[3];
	 assign obstacle_bottom_left_corner_y_pos[90] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[91] = y_level[3];
	 assign obstacle_bottom_left_corner_y_pos[92] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[93] = y_level[3];
	 assign obstacle_bottom_left_corner_y_pos[94] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[95] = y_level[3];
	 assign obstacle_bottom_left_corner_y_pos[96] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[97] = y_level[3];
	 assign obstacle_bottom_left_corner_y_pos[98] = y_level[0];
	 assign obstacle_bottom_left_corner_y_pos[99] = y_level[3];
	 // Shapes: Score value designation
	 assign obstacle_score_value[0] = spike_score_value;
	 assign obstacle_score_value[1] = spike_score_value;
	 assign obstacle_score_value[2] = spike_score_value;
	 assign obstacle_score_value[3] = spike_score_value;
	 assign obstacle_score_value[4] = block_score_value;
	 assign obstacle_score_value[5] = spike_score_value;
	 assign obstacle_score_value[6] = spike_score_value;
	 assign obstacle_score_value[7] = spike_score_value;
	 assign obstacle_score_value[8] = block_score_value;
	 assign obstacle_score_value[9] = spike_score_value;
	 assign obstacle_score_value[10] = spike_score_value;
	 assign obstacle_score_value[11] = spike_score_value;
	 assign obstacle_score_value[12] = spike_score_value;
	 assign obstacle_score_value[13] = spike_score_value;
	 assign obstacle_score_value[14] = spike_score_value;
	 assign obstacle_score_value[15] = spike_score_value;
	 assign obstacle_score_value[16] = block_score_value;
	 assign obstacle_score_value[17] = spike_score_value;
	 assign obstacle_score_value[18] = spike_score_value;
	 assign obstacle_score_value[19] = spike_score_value;
	 assign obstacle_score_value[20] = block_score_value;
	 assign obstacle_score_value[21] = spike_score_value;
	 assign obstacle_score_value[22] = spike_score_value;
	 assign obstacle_score_value[23] = spike_score_value;
	 assign obstacle_score_value[24] = spike_score_value;
	 assign obstacle_score_value[25] = spike_score_value;
	 assign obstacle_score_value[26] = spike_score_value;
	 assign obstacle_score_value[27] = spike_score_value;
	 assign obstacle_score_value[28] = block_score_value;
	 assign obstacle_score_value[29] = spike_score_value;
	 assign obstacle_score_value[30] = block_score_value;
	 assign obstacle_score_value[31] = block_score_value;
	 assign obstacle_score_value[32] = spike_score_value;
	 assign obstacle_score_value[33] = block_score_value;
	 assign obstacle_score_value[34] = spike_score_value;
	 assign obstacle_score_value[35] = block_score_value;
	 assign obstacle_score_value[36] = block_score_value;
	 assign obstacle_score_value[37] = spike_score_value;
	 assign obstacle_score_value[38] = block_score_value;
	 assign obstacle_score_value[39] = spike_score_value;
	 assign obstacle_score_value[40] = spike_score_value;
	 assign obstacle_score_value[41] = spike_score_value;
	 assign obstacle_score_value[42] = spike_score_value;
	 assign obstacle_score_value[43] = block_score_value;
	 assign obstacle_score_value[44] = spike_score_value;
	 assign obstacle_score_value[45] = spike_score_value;
	 assign obstacle_score_value[46] = spike_score_value;
	 assign obstacle_score_value[47] = block_score_value;
	 assign obstacle_score_value[48] = spike_score_value;
	 assign obstacle_score_value[49] = spike_score_value;
	 assign obstacle_score_value[50] = block_score_value;
	 assign obstacle_score_value[51] = spike_score_value;
	 assign obstacle_score_value[52] = spike_score_value;
	 assign obstacle_score_value[53] = spike_score_value;
	 assign obstacle_score_value[54] = spike_score_value;
	 assign obstacle_score_value[55] = block_score_value;
	 assign obstacle_score_value[56] = spike_score_value;
	 assign obstacle_score_value[57] = spike_score_value;
	 assign obstacle_score_value[58] = block_score_value;
	 assign obstacle_score_value[59] = block_score_value;
	 assign obstacle_score_value[60] = block_score_value;
	 assign obstacle_score_value[61] = spike_score_value;
	 assign obstacle_score_value[62] = spike_score_value;
	 assign obstacle_score_value[63] = spike_score_value;
	 assign obstacle_score_value[64] = spike_score_value;
	 assign obstacle_score_value[65] = spike_score_value;
	 assign obstacle_score_value[66] = block_score_value;
	 assign obstacle_score_value[67] = spike_score_value;
	 assign obstacle_score_value[68] = spike_score_value;
	 assign obstacle_score_value[69] = spike_score_value;
	 assign obstacle_score_value[70] = spike_score_value;
	 assign obstacle_score_value[71] = block_score_value;
	 assign obstacle_score_value[72] = spike_score_value;
	 assign obstacle_score_value[73] = spike_score_value;
	 assign obstacle_score_value[74] = spike_score_value;
	 assign obstacle_score_value[75] = spike_score_value;
	 assign obstacle_score_value[76] = block_score_value;
	 assign obstacle_score_value[77] = spike_score_value;
	 assign obstacle_score_value[78] = spike_score_value;
	 assign obstacle_score_value[79] = spike_score_value;
	 assign obstacle_score_value[80] = spike_score_value;
	 assign obstacle_score_value[81] = block_score_value;
	 assign obstacle_score_value[82] = spike_score_value;
	 assign obstacle_score_value[83] = block_score_value;
	 assign obstacle_score_value[84] = spike_score_value;
	 assign obstacle_score_value[85] = block_score_value;
	 assign obstacle_score_value[86] = spike_score_value;
	 assign obstacle_score_value[87] = block_score_value;
	 assign obstacle_score_value[88] = spike_score_value;
	 assign obstacle_score_value[89] = block_score_value;
	 assign obstacle_score_value[90] = spike_score_value;
	 assign obstacle_score_value[91] = block_score_value;
	 assign obstacle_score_value[92] = spike_score_value;
	 assign obstacle_score_value[93] = block_score_value;
	 assign obstacle_score_value[94] = spike_score_value;
	 assign obstacle_score_value[95] = block_score_value;
	 assign obstacle_score_value[96] = spike_score_value;
	 assign obstacle_score_value[97] = block_score_value;
	 assign obstacle_score_value[98] = spike_score_value;
	 assign obstacle_score_value[99] = block_score_value;
	 // Shapes: [Spike] X-Position sent designation
	 assign spike_send_bottom_left_corner_x_pos[0] = obstacle_send_bottom_left_corner_x_pos[0];
	 assign spike_send_bottom_left_corner_x_pos[1] = obstacle_send_bottom_left_corner_x_pos[1];
	 assign spike_send_bottom_left_corner_x_pos[2] = obstacle_send_bottom_left_corner_x_pos[2];
	 assign spike_send_bottom_left_corner_x_pos[3] = obstacle_send_bottom_left_corner_x_pos[3];
	 assign spike_send_bottom_left_corner_x_pos[4] = obstacle_send_bottom_left_corner_x_pos[5];
	 assign spike_send_bottom_left_corner_x_pos[5] = obstacle_send_bottom_left_corner_x_pos[6];
	 assign spike_send_bottom_left_corner_x_pos[6] = obstacle_send_bottom_left_corner_x_pos[7];
	 assign spike_send_bottom_left_corner_x_pos[7] = obstacle_send_bottom_left_corner_x_pos[9];
	 assign spike_send_bottom_left_corner_x_pos[8] = obstacle_send_bottom_left_corner_x_pos[10];
	 assign spike_send_bottom_left_corner_x_pos[9] = obstacle_send_bottom_left_corner_x_pos[11];
	 assign spike_send_bottom_left_corner_x_pos[10] = obstacle_send_bottom_left_corner_x_pos[12];
	 assign spike_send_bottom_left_corner_x_pos[11] = obstacle_send_bottom_left_corner_x_pos[13];
	 assign spike_send_bottom_left_corner_x_pos[12] = obstacle_send_bottom_left_corner_x_pos[14];
	 assign spike_send_bottom_left_corner_x_pos[13] = obstacle_send_bottom_left_corner_x_pos[15];
	 assign spike_send_bottom_left_corner_x_pos[14] = obstacle_send_bottom_left_corner_x_pos[17];
	 assign spike_send_bottom_left_corner_x_pos[15] = obstacle_send_bottom_left_corner_x_pos[18];
	 assign spike_send_bottom_left_corner_x_pos[16] = obstacle_send_bottom_left_corner_x_pos[19];
	 assign spike_send_bottom_left_corner_x_pos[17] = obstacle_send_bottom_left_corner_x_pos[21];
	 assign spike_send_bottom_left_corner_x_pos[18] = obstacle_send_bottom_left_corner_x_pos[22];
	 assign spike_send_bottom_left_corner_x_pos[19] = obstacle_send_bottom_left_corner_x_pos[23];
	 assign spike_send_bottom_left_corner_x_pos[20] = obstacle_send_bottom_left_corner_x_pos[24];
	 assign spike_send_bottom_left_corner_x_pos[21] = obstacle_send_bottom_left_corner_x_pos[25];
	 assign spike_send_bottom_left_corner_x_pos[22] = obstacle_send_bottom_left_corner_x_pos[26];
	 assign spike_send_bottom_left_corner_x_pos[23] = obstacle_send_bottom_left_corner_x_pos[27];
	 assign spike_send_bottom_left_corner_x_pos[24] = obstacle_send_bottom_left_corner_x_pos[29];
	 assign spike_send_bottom_left_corner_x_pos[25] = obstacle_send_bottom_left_corner_x_pos[30];
	 assign spike_send_bottom_left_corner_x_pos[26] = obstacle_send_bottom_left_corner_x_pos[31];
	 assign spike_send_bottom_left_corner_x_pos[27] = obstacle_send_bottom_left_corner_x_pos[32];
	 assign spike_send_bottom_left_corner_x_pos[28] = obstacle_send_bottom_left_corner_x_pos[34];
	 assign spike_send_bottom_left_corner_x_pos[29] = obstacle_send_bottom_left_corner_x_pos[35];
	 assign spike_send_bottom_left_corner_x_pos[30] = obstacle_send_bottom_left_corner_x_pos[36];
	 assign spike_send_bottom_left_corner_x_pos[31] = obstacle_send_bottom_left_corner_x_pos[37];
	 assign spike_send_bottom_left_corner_x_pos[32] = obstacle_send_bottom_left_corner_x_pos[39];
	 assign spike_send_bottom_left_corner_x_pos[33] = obstacle_send_bottom_left_corner_x_pos[40];
	 assign spike_send_bottom_left_corner_x_pos[34] = obstacle_send_bottom_left_corner_x_pos[41];
	 assign spike_send_bottom_left_corner_x_pos[35] = obstacle_send_bottom_left_corner_x_pos[42];
	 assign spike_send_bottom_left_corner_x_pos[36] = obstacle_send_bottom_left_corner_x_pos[44];
	 assign spike_send_bottom_left_corner_x_pos[37] = obstacle_send_bottom_left_corner_x_pos[45];
	 assign spike_send_bottom_left_corner_x_pos[38] = obstacle_send_bottom_left_corner_x_pos[46];
	 assign spike_send_bottom_left_corner_x_pos[39] = obstacle_send_bottom_left_corner_x_pos[48];
	 assign spike_send_bottom_left_corner_x_pos[40] = obstacle_send_bottom_left_corner_x_pos[49];
	 assign spike_send_bottom_left_corner_x_pos[41] = obstacle_send_bottom_left_corner_x_pos[51];
	 assign spike_send_bottom_left_corner_x_pos[42] = obstacle_send_bottom_left_corner_x_pos[52];
	 assign spike_send_bottom_left_corner_x_pos[43] = obstacle_send_bottom_left_corner_x_pos[53];
	 assign spike_send_bottom_left_corner_x_pos[44] = obstacle_send_bottom_left_corner_x_pos[54];
	 assign spike_send_bottom_left_corner_x_pos[45] = obstacle_send_bottom_left_corner_x_pos[56];
	 assign spike_send_bottom_left_corner_x_pos[46] = obstacle_send_bottom_left_corner_x_pos[57];
	 assign spike_send_bottom_left_corner_x_pos[47] = obstacle_send_bottom_left_corner_x_pos[61];
	 assign spike_send_bottom_left_corner_x_pos[48] = obstacle_send_bottom_left_corner_x_pos[62];
	 assign spike_send_bottom_left_corner_x_pos[49] = obstacle_send_bottom_left_corner_x_pos[63];
	 assign spike_send_bottom_left_corner_x_pos[50] = obstacle_send_bottom_left_corner_x_pos[64];
	 assign spike_send_bottom_left_corner_x_pos[51] = obstacle_send_bottom_left_corner_x_pos[65];
	 assign spike_send_bottom_left_corner_x_pos[52] = obstacle_send_bottom_left_corner_x_pos[67];
	 assign spike_send_bottom_left_corner_x_pos[53] = obstacle_send_bottom_left_corner_x_pos[68];
	 assign spike_send_bottom_left_corner_x_pos[54] = obstacle_send_bottom_left_corner_x_pos[69];
	 assign spike_send_bottom_left_corner_x_pos[55] = obstacle_send_bottom_left_corner_x_pos[70];
	 assign spike_send_bottom_left_corner_x_pos[56] = obstacle_send_bottom_left_corner_x_pos[72];
	 assign spike_send_bottom_left_corner_x_pos[57] = obstacle_send_bottom_left_corner_x_pos[73];
	 assign spike_send_bottom_left_corner_x_pos[58] = obstacle_send_bottom_left_corner_x_pos[74];
	 assign spike_send_bottom_left_corner_x_pos[59] = obstacle_send_bottom_left_corner_x_pos[75];
	 assign spike_send_bottom_left_corner_x_pos[60] = obstacle_send_bottom_left_corner_x_pos[77];
	 assign spike_send_bottom_left_corner_x_pos[61] = obstacle_send_bottom_left_corner_x_pos[78];
	 assign spike_send_bottom_left_corner_x_pos[62] = obstacle_send_bottom_left_corner_x_pos[79];
	 assign spike_send_bottom_left_corner_x_pos[63] = obstacle_send_bottom_left_corner_x_pos[80];
	 assign spike_send_bottom_left_corner_x_pos[64] = obstacle_send_bottom_left_corner_x_pos[82];
	 assign spike_send_bottom_left_corner_x_pos[65] = obstacle_send_bottom_left_corner_x_pos[84];
	 assign spike_send_bottom_left_corner_x_pos[66] = obstacle_send_bottom_left_corner_x_pos[86];
	 assign spike_send_bottom_left_corner_x_pos[67] = obstacle_send_bottom_left_corner_x_pos[88];
	 assign spike_send_bottom_left_corner_x_pos[68] = obstacle_send_bottom_left_corner_x_pos[90];
	 assign spike_send_bottom_left_corner_x_pos[69] = obstacle_send_bottom_left_corner_x_pos[92];
	 assign spike_send_bottom_left_corner_x_pos[70] = obstacle_send_bottom_left_corner_x_pos[94];
	 assign spike_send_bottom_left_corner_x_pos[71] = obstacle_send_bottom_left_corner_x_pos[96];
	 assign spike_send_bottom_left_corner_x_pos[72] = obstacle_send_bottom_left_corner_x_pos[98];
	 // Shapes: [Spike] Y-Position sent designation
	 assign spike_send_bottom_left_corner_y_pos[0] = obstacle_send_bottom_left_corner_y_pos[0];
	 assign spike_send_bottom_left_corner_y_pos[1] = obstacle_send_bottom_left_corner_y_pos[1];
	 assign spike_send_bottom_left_corner_y_pos[2] = obstacle_send_bottom_left_corner_y_pos[2];
	 assign spike_send_bottom_left_corner_y_pos[3] = obstacle_send_bottom_left_corner_y_pos[3];
	 assign spike_send_bottom_left_corner_y_pos[4] = obstacle_send_bottom_left_corner_y_pos[5];
	 assign spike_send_bottom_left_corner_y_pos[5] = obstacle_send_bottom_left_corner_y_pos[6];
	 assign spike_send_bottom_left_corner_y_pos[6] = obstacle_send_bottom_left_corner_y_pos[7];
	 assign spike_send_bottom_left_corner_y_pos[7] = obstacle_send_bottom_left_corner_y_pos[9];
	 assign spike_send_bottom_left_corner_y_pos[8] = obstacle_send_bottom_left_corner_y_pos[10];
	 assign spike_send_bottom_left_corner_y_pos[9] = obstacle_send_bottom_left_corner_y_pos[11];
	 assign spike_send_bottom_left_corner_y_pos[10] = obstacle_send_bottom_left_corner_y_pos[12];
	 assign spike_send_bottom_left_corner_y_pos[11] = obstacle_send_bottom_left_corner_y_pos[13];
	 assign spike_send_bottom_left_corner_y_pos[12] = obstacle_send_bottom_left_corner_y_pos[14];
	 assign spike_send_bottom_left_corner_y_pos[13] = obstacle_send_bottom_left_corner_y_pos[15];
	 assign spike_send_bottom_left_corner_y_pos[14] = obstacle_send_bottom_left_corner_y_pos[17];
	 assign spike_send_bottom_left_corner_y_pos[15] = obstacle_send_bottom_left_corner_y_pos[18];
	 assign spike_send_bottom_left_corner_y_pos[16] = obstacle_send_bottom_left_corner_y_pos[19];
	 assign spike_send_bottom_left_corner_y_pos[17] = obstacle_send_bottom_left_corner_y_pos[21];
	 assign spike_send_bottom_left_corner_y_pos[18] = obstacle_send_bottom_left_corner_y_pos[22];
	 assign spike_send_bottom_left_corner_y_pos[19] = obstacle_send_bottom_left_corner_y_pos[23];
	 assign spike_send_bottom_left_corner_y_pos[20] = obstacle_send_bottom_left_corner_y_pos[24];
	 assign spike_send_bottom_left_corner_y_pos[21] = obstacle_send_bottom_left_corner_y_pos[25];
	 assign spike_send_bottom_left_corner_y_pos[22] = obstacle_send_bottom_left_corner_y_pos[26];
	 assign spike_send_bottom_left_corner_y_pos[23] = obstacle_send_bottom_left_corner_y_pos[27];
	 assign spike_send_bottom_left_corner_y_pos[24] = obstacle_send_bottom_left_corner_y_pos[29];
	 assign spike_send_bottom_left_corner_y_pos[25] = obstacle_send_bottom_left_corner_y_pos[30];
	 assign spike_send_bottom_left_corner_y_pos[26] = obstacle_send_bottom_left_corner_y_pos[31];
	 assign spike_send_bottom_left_corner_y_pos[27] = obstacle_send_bottom_left_corner_y_pos[32];
	 assign spike_send_bottom_left_corner_y_pos[28] = obstacle_send_bottom_left_corner_y_pos[34];
	 assign spike_send_bottom_left_corner_y_pos[29] = obstacle_send_bottom_left_corner_y_pos[35];
	 assign spike_send_bottom_left_corner_y_pos[30] = obstacle_send_bottom_left_corner_y_pos[36];
	 assign spike_send_bottom_left_corner_y_pos[31] = obstacle_send_bottom_left_corner_y_pos[37];
	 assign spike_send_bottom_left_corner_y_pos[32] = obstacle_send_bottom_left_corner_y_pos[39];
	 assign spike_send_bottom_left_corner_y_pos[33] = obstacle_send_bottom_left_corner_y_pos[40];
	 assign spike_send_bottom_left_corner_y_pos[34] = obstacle_send_bottom_left_corner_y_pos[41];
	 assign spike_send_bottom_left_corner_y_pos[35] = obstacle_send_bottom_left_corner_y_pos[42];
	 assign spike_send_bottom_left_corner_y_pos[36] = obstacle_send_bottom_left_corner_y_pos[44];
	 assign spike_send_bottom_left_corner_y_pos[37] = obstacle_send_bottom_left_corner_y_pos[45];
	 assign spike_send_bottom_left_corner_y_pos[38] = obstacle_send_bottom_left_corner_y_pos[46];
	 assign spike_send_bottom_left_corner_y_pos[39] = obstacle_send_bottom_left_corner_y_pos[48];
	 assign spike_send_bottom_left_corner_y_pos[40] = obstacle_send_bottom_left_corner_y_pos[49];
	 assign spike_send_bottom_left_corner_y_pos[41] = obstacle_send_bottom_left_corner_y_pos[51];
	 assign spike_send_bottom_left_corner_y_pos[42] = obstacle_send_bottom_left_corner_y_pos[52];
	 assign spike_send_bottom_left_corner_y_pos[43] = obstacle_send_bottom_left_corner_y_pos[53];
	 assign spike_send_bottom_left_corner_y_pos[44] = obstacle_send_bottom_left_corner_y_pos[54];
	 assign spike_send_bottom_left_corner_y_pos[45] = obstacle_send_bottom_left_corner_y_pos[56];
	 assign spike_send_bottom_left_corner_y_pos[46] = obstacle_send_bottom_left_corner_y_pos[57];
	 assign spike_send_bottom_left_corner_y_pos[47] = obstacle_send_bottom_left_corner_y_pos[61];
	 assign spike_send_bottom_left_corner_y_pos[48] = obstacle_send_bottom_left_corner_y_pos[62];
	 assign spike_send_bottom_left_corner_y_pos[49] = obstacle_send_bottom_left_corner_y_pos[63];
	 assign spike_send_bottom_left_corner_y_pos[50] = obstacle_send_bottom_left_corner_y_pos[64];
	 assign spike_send_bottom_left_corner_y_pos[51] = obstacle_send_bottom_left_corner_y_pos[65];
	 assign spike_send_bottom_left_corner_y_pos[52] = obstacle_send_bottom_left_corner_y_pos[67];
	 assign spike_send_bottom_left_corner_y_pos[53] = obstacle_send_bottom_left_corner_y_pos[68];
	 assign spike_send_bottom_left_corner_y_pos[54] = obstacle_send_bottom_left_corner_y_pos[69];
	 assign spike_send_bottom_left_corner_y_pos[55] = obstacle_send_bottom_left_corner_y_pos[70];
	 assign spike_send_bottom_left_corner_y_pos[56] = obstacle_send_bottom_left_corner_y_pos[72];
	 assign spike_send_bottom_left_corner_y_pos[57] = obstacle_send_bottom_left_corner_y_pos[73];
	 assign spike_send_bottom_left_corner_y_pos[58] = obstacle_send_bottom_left_corner_y_pos[74];
	 assign spike_send_bottom_left_corner_y_pos[59] = obstacle_send_bottom_left_corner_y_pos[75];
	 assign spike_send_bottom_left_corner_y_pos[60] = obstacle_send_bottom_left_corner_y_pos[77];
	 assign spike_send_bottom_left_corner_y_pos[61] = obstacle_send_bottom_left_corner_y_pos[78];
	 assign spike_send_bottom_left_corner_y_pos[62] = obstacle_send_bottom_left_corner_y_pos[79];
	 assign spike_send_bottom_left_corner_y_pos[63] = obstacle_send_bottom_left_corner_y_pos[80];
	 assign spike_send_bottom_left_corner_y_pos[64] = obstacle_send_bottom_left_corner_y_pos[82];
	 assign spike_send_bottom_left_corner_y_pos[65] = obstacle_send_bottom_left_corner_y_pos[84];
	 assign spike_send_bottom_left_corner_y_pos[66] = obstacle_send_bottom_left_corner_y_pos[86];
	 assign spike_send_bottom_left_corner_y_pos[67] = obstacle_send_bottom_left_corner_y_pos[88];
	 assign spike_send_bottom_left_corner_y_pos[68] = obstacle_send_bottom_left_corner_y_pos[90];
	 assign spike_send_bottom_left_corner_y_pos[69] = obstacle_send_bottom_left_corner_y_pos[92];
	 assign spike_send_bottom_left_corner_y_pos[70] = obstacle_send_bottom_left_corner_y_pos[94];
	 assign spike_send_bottom_left_corner_y_pos[71] = obstacle_send_bottom_left_corner_y_pos[96];
	 assign spike_send_bottom_left_corner_y_pos[72] = obstacle_send_bottom_left_corner_y_pos[98];
	 // Shapes: [Block] X-Position sent designation
	 assign block_send_bottom_left_corner_x_pos[0] = obstacle_send_bottom_left_corner_x_pos[4];
	 assign block_send_bottom_left_corner_x_pos[1] = obstacle_send_bottom_left_corner_x_pos[8];
	 assign block_send_bottom_left_corner_x_pos[2] = obstacle_send_bottom_left_corner_x_pos[16];
	 assign block_send_bottom_left_corner_x_pos[3] = obstacle_send_bottom_left_corner_x_pos[20];
	 assign block_send_bottom_left_corner_x_pos[4] = obstacle_send_bottom_left_corner_x_pos[28];
	 assign block_send_bottom_left_corner_x_pos[5] = obstacle_send_bottom_left_corner_x_pos[33];
	 assign block_send_bottom_left_corner_x_pos[6] = obstacle_send_bottom_left_corner_x_pos[38];
	 assign block_send_bottom_left_corner_x_pos[7] = obstacle_send_bottom_left_corner_x_pos[43];
	 assign block_send_bottom_left_corner_x_pos[8] = obstacle_send_bottom_left_corner_x_pos[47];
	 assign block_send_bottom_left_corner_x_pos[9] = obstacle_send_bottom_left_corner_x_pos[50];
	 assign block_send_bottom_left_corner_x_pos[10] = obstacle_send_bottom_left_corner_x_pos[55];
	 assign block_send_bottom_left_corner_x_pos[11] = obstacle_send_bottom_left_corner_x_pos[58];
	 assign block_send_bottom_left_corner_x_pos[12] = obstacle_send_bottom_left_corner_x_pos[59];
	 assign block_send_bottom_left_corner_x_pos[13] = obstacle_send_bottom_left_corner_x_pos[60];
	 assign block_send_bottom_left_corner_x_pos[14] = obstacle_send_bottom_left_corner_x_pos[66];
	 assign block_send_bottom_left_corner_x_pos[15] = obstacle_send_bottom_left_corner_x_pos[71];
	 assign block_send_bottom_left_corner_x_pos[16] = obstacle_send_bottom_left_corner_x_pos[76];
	 assign block_send_bottom_left_corner_x_pos[17] = obstacle_send_bottom_left_corner_x_pos[81];
	 assign block_send_bottom_left_corner_x_pos[18] = obstacle_send_bottom_left_corner_x_pos[83];
	 assign block_send_bottom_left_corner_x_pos[19] = obstacle_send_bottom_left_corner_x_pos[85];
	 assign block_send_bottom_left_corner_x_pos[20] = obstacle_send_bottom_left_corner_x_pos[87];
	 assign block_send_bottom_left_corner_x_pos[21] = obstacle_send_bottom_left_corner_x_pos[89];
	 assign block_send_bottom_left_corner_x_pos[22] = obstacle_send_bottom_left_corner_x_pos[91];
	 assign block_send_bottom_left_corner_x_pos[23] = obstacle_send_bottom_left_corner_x_pos[93];
	 assign block_send_bottom_left_corner_x_pos[24] = obstacle_send_bottom_left_corner_x_pos[95];
	 assign block_send_bottom_left_corner_x_pos[25] = obstacle_send_bottom_left_corner_x_pos[97];
	 assign block_send_bottom_left_corner_x_pos[26] = obstacle_send_bottom_left_corner_x_pos[99];
	 // Shapes: [Block] Y-Position sent designation
	 assign block_send_bottom_left_corner_y_pos[0] = obstacle_send_bottom_left_corner_y_pos[4];
	 assign block_send_bottom_left_corner_y_pos[1] = obstacle_send_bottom_left_corner_y_pos[8];
	 assign block_send_bottom_left_corner_y_pos[2] = obstacle_send_bottom_left_corner_y_pos[16];
	 assign block_send_bottom_left_corner_y_pos[3] = obstacle_send_bottom_left_corner_y_pos[20];
	 assign block_send_bottom_left_corner_y_pos[4] = obstacle_send_bottom_left_corner_y_pos[28];
	 assign block_send_bottom_left_corner_y_pos[5] = obstacle_send_bottom_left_corner_y_pos[33];
	 assign block_send_bottom_left_corner_y_pos[6] = obstacle_send_bottom_left_corner_y_pos[38];
	 assign block_send_bottom_left_corner_y_pos[7] = obstacle_send_bottom_left_corner_y_pos[43];
	 assign block_send_bottom_left_corner_y_pos[8] = obstacle_send_bottom_left_corner_y_pos[47];
	 assign block_send_bottom_left_corner_y_pos[9] = obstacle_send_bottom_left_corner_y_pos[50];
	 assign block_send_bottom_left_corner_y_pos[10] = obstacle_send_bottom_left_corner_y_pos[55];
	 assign block_send_bottom_left_corner_y_pos[11] = obstacle_send_bottom_left_corner_y_pos[58];
	 assign block_send_bottom_left_corner_y_pos[12] = obstacle_send_bottom_left_corner_y_pos[59];
	 assign block_send_bottom_left_corner_y_pos[13] = obstacle_send_bottom_left_corner_y_pos[60];
	 assign block_send_bottom_left_corner_y_pos[14] = obstacle_send_bottom_left_corner_y_pos[66];
	 assign block_send_bottom_left_corner_y_pos[15] = obstacle_send_bottom_left_corner_y_pos[71];
	 assign block_send_bottom_left_corner_y_pos[16] = obstacle_send_bottom_left_corner_y_pos[76];
	 assign block_send_bottom_left_corner_y_pos[17] = obstacle_send_bottom_left_corner_y_pos[81];
	 assign block_send_bottom_left_corner_y_pos[18] = obstacle_send_bottom_left_corner_y_pos[83];
	 assign block_send_bottom_left_corner_y_pos[19] = obstacle_send_bottom_left_corner_y_pos[85];
	 assign block_send_bottom_left_corner_y_pos[20] = obstacle_send_bottom_left_corner_y_pos[87];
	 assign block_send_bottom_left_corner_y_pos[21] = obstacle_send_bottom_left_corner_y_pos[89];
	 assign block_send_bottom_left_corner_y_pos[22] = obstacle_send_bottom_left_corner_y_pos[91];
	 assign block_send_bottom_left_corner_y_pos[23] = obstacle_send_bottom_left_corner_y_pos[93];
	 assign block_send_bottom_left_corner_y_pos[24] = obstacle_send_bottom_left_corner_y_pos[95];
	 assign block_send_bottom_left_corner_y_pos[25] = obstacle_send_bottom_left_corner_y_pos[97];
	 assign block_send_bottom_left_corner_y_pos[26] = obstacle_send_bottom_left_corner_y_pos[99];
	 // Shapes: Drawing start position designation
	 assign obstacle_draw_start_pos[0] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[1] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[2] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[3] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[4] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[5] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[6] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[7] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[8] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[9] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[10] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[11] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[12] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[13] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[14] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[15] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[16] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[17] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[18] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[19] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[20] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[21] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[22] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[23] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[24] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[25] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[26] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[27] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[28] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[29] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[30] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[31] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[32] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[33] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[34] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[35] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[36] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[37] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[38] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[39] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[40] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[41] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[42] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[43] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[44] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[45] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[46] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[47] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[48] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[49] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[50] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[51] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[52] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[53] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[54] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[55] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[56] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[57] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[58] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[59] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[60] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[61] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[62] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[63] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[64] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[65] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[66] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[67] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[68] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[69] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[70] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[71] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[72] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[73] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[74] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[75] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[76] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[77] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[78] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[79] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[80] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[81] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[82] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[83] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[84] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[85] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[86] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[87] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[88] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[89] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[90] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[91] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[92] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[93] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[94] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[95] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[96] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[97] = square_and_block_draw_start_pos;
	 assign obstacle_draw_start_pos[98] = spike_draw_start_pos;
	 assign obstacle_draw_start_pos[99] = square_and_block_draw_start_pos;
	 // Shapes: Drawing end position designation
	 assign obstacle_draw_end_pos[0] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[1] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[2] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[3] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[4] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[5] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[6] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[7] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[8] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[9] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[10] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[11] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[12] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[13] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[14] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[15] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[16] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[17] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[18] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[19] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[20] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[21] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[22] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[23] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[24] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[25] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[26] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[27] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[28] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[29] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[30] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[31] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[32] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[33] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[34] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[35] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[36] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[37] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[38] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[39] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[40] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[41] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[42] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[43] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[44] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[45] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[46] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[47] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[48] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[49] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[50] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[51] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[52] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[53] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[54] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[55] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[56] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[57] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[58] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[59] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[60] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[61] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[62] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[63] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[64] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[65] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[66] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[67] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[68] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[69] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[70] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[71] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[72] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[73] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[74] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[75] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[76] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[77] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[78] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[79] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[80] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[81] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[82] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[83] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[84] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[85] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[86] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[87] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[88] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[89] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[90] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[91] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[92] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[93] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[94] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[95] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[96] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[97] = square_and_block_draw_end_pos;
	 assign obstacle_draw_end_pos[98] = spike_draw_end_pos;
	 assign obstacle_draw_end_pos[99] = square_and_block_draw_end_pos;
	 
	 wire [296:0] all_block_send_bottom_left_corner_x_pos =  {block_send_bottom_left_corner_x_pos[26],
																				 block_send_bottom_left_corner_x_pos[25],
																				 block_send_bottom_left_corner_x_pos[24],
																				 block_send_bottom_left_corner_x_pos[23],
																				 block_send_bottom_left_corner_x_pos[22],
																				 block_send_bottom_left_corner_x_pos[21],
																				 block_send_bottom_left_corner_x_pos[20],
																				 block_send_bottom_left_corner_x_pos[19],
																				 block_send_bottom_left_corner_x_pos[18],
																				 block_send_bottom_left_corner_x_pos[17],
																				 block_send_bottom_left_corner_x_pos[16],
																				 block_send_bottom_left_corner_x_pos[15],
																				 block_send_bottom_left_corner_x_pos[14],
																				 block_send_bottom_left_corner_x_pos[13],
																				 block_send_bottom_left_corner_x_pos[12],
																				 block_send_bottom_left_corner_x_pos[11],
																				 block_send_bottom_left_corner_x_pos[10],
																				 block_send_bottom_left_corner_x_pos[9],
																				 block_send_bottom_left_corner_x_pos[8],
																				 block_send_bottom_left_corner_x_pos[7],
																				 block_send_bottom_left_corner_x_pos[6],
																				 block_send_bottom_left_corner_x_pos[5],
																				 block_send_bottom_left_corner_x_pos[4],
																				 block_send_bottom_left_corner_x_pos[3],
																				 block_send_bottom_left_corner_x_pos[2],
																				 block_send_bottom_left_corner_x_pos[1],
																				 block_send_bottom_left_corner_x_pos[0]};
	
	 wire [296:0] all_block_send_bottom_left_corner_y_pos =  {block_send_bottom_left_corner_y_pos[26],
																				 block_send_bottom_left_corner_y_pos[25],
																				 block_send_bottom_left_corner_y_pos[24],
																				 block_send_bottom_left_corner_y_pos[23],
																				 block_send_bottom_left_corner_y_pos[22],
																				 block_send_bottom_left_corner_y_pos[21],
																				 block_send_bottom_left_corner_y_pos[20],
																				 block_send_bottom_left_corner_y_pos[19],
																				 block_send_bottom_left_corner_y_pos[18],
																				 block_send_bottom_left_corner_y_pos[17],
																				 block_send_bottom_left_corner_y_pos[16],
																				 block_send_bottom_left_corner_y_pos[15],
																				 block_send_bottom_left_corner_y_pos[14],
																				 block_send_bottom_left_corner_y_pos[13],
																				 block_send_bottom_left_corner_y_pos[12],
																				 block_send_bottom_left_corner_y_pos[11],
																				 block_send_bottom_left_corner_y_pos[10],
																				 block_send_bottom_left_corner_y_pos[9],
																				 block_send_bottom_left_corner_y_pos[8],
																				 block_send_bottom_left_corner_y_pos[7],
																				 block_send_bottom_left_corner_y_pos[6],
																				 block_send_bottom_left_corner_y_pos[5],
																				 block_send_bottom_left_corner_y_pos[4],
																				 block_send_bottom_left_corner_y_pos[3],
																				 block_send_bottom_left_corner_y_pos[2],
																				 block_send_bottom_left_corner_y_pos[1],
																				 block_send_bottom_left_corner_y_pos[0]};
																		 
	 wire [802:0] all_spike_send_bottom_left_corner_x_pos = {spike_send_bottom_left_corner_x_pos[72],
																		      spike_send_bottom_left_corner_x_pos[71],
																		      spike_send_bottom_left_corner_x_pos[70],
																		      spike_send_bottom_left_corner_x_pos[69],
																		      spike_send_bottom_left_corner_x_pos[68],
																		      spike_send_bottom_left_corner_x_pos[67],
																		      spike_send_bottom_left_corner_x_pos[66],
																				spike_send_bottom_left_corner_x_pos[65],
																				spike_send_bottom_left_corner_x_pos[64],
																				spike_send_bottom_left_corner_x_pos[63],
																				spike_send_bottom_left_corner_x_pos[62],
																				spike_send_bottom_left_corner_x_pos[61],
																				spike_send_bottom_left_corner_x_pos[60],
																				spike_send_bottom_left_corner_x_pos[59],
																			   spike_send_bottom_left_corner_x_pos[58],
																				spike_send_bottom_left_corner_x_pos[57],
																				spike_send_bottom_left_corner_x_pos[56],
																				spike_send_bottom_left_corner_x_pos[55],
																				spike_send_bottom_left_corner_x_pos[54],
																				spike_send_bottom_left_corner_x_pos[53],
																				spike_send_bottom_left_corner_x_pos[52],
																				spike_send_bottom_left_corner_x_pos[51],
																				spike_send_bottom_left_corner_x_pos[50],
																				spike_send_bottom_left_corner_x_pos[49],
																				spike_send_bottom_left_corner_x_pos[48],
																				spike_send_bottom_left_corner_x_pos[47],
																				spike_send_bottom_left_corner_x_pos[46],
																				spike_send_bottom_left_corner_x_pos[45],
																				spike_send_bottom_left_corner_x_pos[44],
																				spike_send_bottom_left_corner_x_pos[43],
																				spike_send_bottom_left_corner_x_pos[42],
																				spike_send_bottom_left_corner_x_pos[41],
																				spike_send_bottom_left_corner_x_pos[40],
																				spike_send_bottom_left_corner_x_pos[39],
																				spike_send_bottom_left_corner_x_pos[38],
																				spike_send_bottom_left_corner_x_pos[37],
																				spike_send_bottom_left_corner_x_pos[36],
																				spike_send_bottom_left_corner_x_pos[35],
																			   spike_send_bottom_left_corner_x_pos[34],
																				spike_send_bottom_left_corner_x_pos[33],
																				spike_send_bottom_left_corner_x_pos[32],
																				spike_send_bottom_left_corner_x_pos[31],
																				spike_send_bottom_left_corner_x_pos[30],
																				spike_send_bottom_left_corner_x_pos[29],
																				spike_send_bottom_left_corner_x_pos[28],
																				spike_send_bottom_left_corner_x_pos[27],
																				spike_send_bottom_left_corner_x_pos[26],
																				spike_send_bottom_left_corner_x_pos[25],
																				spike_send_bottom_left_corner_x_pos[24],
																				spike_send_bottom_left_corner_x_pos[23],
																				spike_send_bottom_left_corner_x_pos[22],
																				spike_send_bottom_left_corner_x_pos[21],
																				spike_send_bottom_left_corner_x_pos[20],
																				spike_send_bottom_left_corner_x_pos[19],
																				spike_send_bottom_left_corner_x_pos[18],
																				spike_send_bottom_left_corner_x_pos[17],
																				spike_send_bottom_left_corner_x_pos[16],
																				spike_send_bottom_left_corner_x_pos[15],
																				spike_send_bottom_left_corner_x_pos[14],
																				spike_send_bottom_left_corner_x_pos[13],
																				spike_send_bottom_left_corner_x_pos[12],
																				spike_send_bottom_left_corner_x_pos[11],
																				spike_send_bottom_left_corner_x_pos[10],
																				spike_send_bottom_left_corner_x_pos[9],
																				spike_send_bottom_left_corner_x_pos[8],
																				spike_send_bottom_left_corner_x_pos[7],
																				spike_send_bottom_left_corner_x_pos[6],
																				spike_send_bottom_left_corner_x_pos[5],
																				spike_send_bottom_left_corner_x_pos[4],
																				spike_send_bottom_left_corner_x_pos[3],
																				spike_send_bottom_left_corner_x_pos[2],
																			   spike_send_bottom_left_corner_x_pos[1],
																				spike_send_bottom_left_corner_x_pos[0]};
																		 
	 wire [802:0] all_spike_send_bottom_left_corner_y_pos = {spike_send_bottom_left_corner_y_pos[72],
																				spike_send_bottom_left_corner_y_pos[71],
																				spike_send_bottom_left_corner_y_pos[70],
																				spike_send_bottom_left_corner_y_pos[69],
																				spike_send_bottom_left_corner_y_pos[68],
																				spike_send_bottom_left_corner_y_pos[67],
																				spike_send_bottom_left_corner_y_pos[66],
																				spike_send_bottom_left_corner_y_pos[65],
																				spike_send_bottom_left_corner_y_pos[64],
																				spike_send_bottom_left_corner_y_pos[63],
																				spike_send_bottom_left_corner_y_pos[62],
																				spike_send_bottom_left_corner_y_pos[61],
																				spike_send_bottom_left_corner_y_pos[60],
																				spike_send_bottom_left_corner_y_pos[59],
																				spike_send_bottom_left_corner_y_pos[58],
																				spike_send_bottom_left_corner_y_pos[57],
																				spike_send_bottom_left_corner_y_pos[56],
																				spike_send_bottom_left_corner_y_pos[55],
																				spike_send_bottom_left_corner_y_pos[54],
																				spike_send_bottom_left_corner_y_pos[53],
																				spike_send_bottom_left_corner_y_pos[52],
																				spike_send_bottom_left_corner_y_pos[51],
																				spike_send_bottom_left_corner_y_pos[50],
																				spike_send_bottom_left_corner_y_pos[49],
																				spike_send_bottom_left_corner_y_pos[48],
																				spike_send_bottom_left_corner_y_pos[47],
																				spike_send_bottom_left_corner_y_pos[46],
																				spike_send_bottom_left_corner_y_pos[45],
																				spike_send_bottom_left_corner_y_pos[44],
																				spike_send_bottom_left_corner_y_pos[43],
																				spike_send_bottom_left_corner_y_pos[42],
																				spike_send_bottom_left_corner_y_pos[41],
																				spike_send_bottom_left_corner_y_pos[40],
																				spike_send_bottom_left_corner_y_pos[39],
																				spike_send_bottom_left_corner_y_pos[38],
																				spike_send_bottom_left_corner_y_pos[37],
																				spike_send_bottom_left_corner_y_pos[36],
																				spike_send_bottom_left_corner_y_pos[35],
																				spike_send_bottom_left_corner_y_pos[34],
																				spike_send_bottom_left_corner_y_pos[33],
																				spike_send_bottom_left_corner_y_pos[32],
																				spike_send_bottom_left_corner_y_pos[31],
																				spike_send_bottom_left_corner_y_pos[30],
																				spike_send_bottom_left_corner_y_pos[29],
																				spike_send_bottom_left_corner_y_pos[28],
																				spike_send_bottom_left_corner_y_pos[27],
																				spike_send_bottom_left_corner_y_pos[26],
																				spike_send_bottom_left_corner_y_pos[25],
																				spike_send_bottom_left_corner_y_pos[24],
																				spike_send_bottom_left_corner_y_pos[23],
																				spike_send_bottom_left_corner_y_pos[22],
																				spike_send_bottom_left_corner_y_pos[21],
																				spike_send_bottom_left_corner_y_pos[20],
																				spike_send_bottom_left_corner_y_pos[19],
																				spike_send_bottom_left_corner_y_pos[18],
																				spike_send_bottom_left_corner_y_pos[17],
																				spike_send_bottom_left_corner_y_pos[16],
																				spike_send_bottom_left_corner_y_pos[15],
																				spike_send_bottom_left_corner_y_pos[14],
																				spike_send_bottom_left_corner_y_pos[13],
																				spike_send_bottom_left_corner_y_pos[12],
																				spike_send_bottom_left_corner_y_pos[11],
																				spike_send_bottom_left_corner_y_pos[10],
																				spike_send_bottom_left_corner_y_pos[9],
																				spike_send_bottom_left_corner_y_pos[8],
																				spike_send_bottom_left_corner_y_pos[7],
																				spike_send_bottom_left_corner_y_pos[6],
																				spike_send_bottom_left_corner_y_pos[5],
																				spike_send_bottom_left_corner_y_pos[4],
																				spike_send_bottom_left_corner_y_pos[3],
																				spike_send_bottom_left_corner_y_pos[2],
																				spike_send_bottom_left_corner_y_pos[1],
																				spike_send_bottom_left_corner_y_pos[0]};
	
	 genvar obstacle_inst;
	 generate
	 for (obstacle_inst = 0; obstacle_inst < 100; obstacle_inst = obstacle_inst + 1) // num_obstacles = 100
	 begin: obstacle
			 shape inst(
			 // Input
			 .score_value(obstacle_score_value[obstacle_inst]),
			 .load_delay_counter(delay_counter_interval * obstacle_delay_counter[obstacle_inst]),
			 .load_move_counter(move_counter),
			 .clock(CLOCK_50),
			 .reset(reset[obstacle_inst]),
			 .draw_start(draw_start[obstacle_inst]),
			 .is_obstacle(1'd1),
			 .load_colour(obstacle_colour[obstacle_inst]),
			 .load_bottom_left_corner_x_pos(obstacle_bottom_left_corner_x_pos),
			 .load_bottom_left_corner_y_pos(obstacle_bottom_left_corner_y_pos[obstacle_inst]),
			 .load_num_pixels_vertical(shape_num_pixels_vertical),
			 .load_num_pixels_horizontal(shape_num_pixels_horizontal),
			 .load_pixel_draw_start_pos(obstacle_draw_start_pos[obstacle_inst]),
			 .load_pixel_draw_end_pos(obstacle_draw_end_pos[obstacle_inst]),
			 // Output
			 .draw_done(draw_done[obstacle_inst]),
			 .send_colour(send_colour[obstacle_inst][2:0]),
			 .send_x(send_x[obstacle_inst][10:0]),
			 .send_y(send_y[obstacle_inst][10:0]),
			 .send_bottom_left_corner_x_pos(obstacle_send_bottom_left_corner_x_pos[obstacle_inst]),
			 .send_bottom_left_corner_y_pos(obstacle_send_bottom_left_corner_y_pos[obstacle_inst]),
			 .shape_gone(shape_gone[obstacle_inst][10:0])
			 );
	 end	
	 endgenerate
	 
	 control main_control(
    //Input
    .clock(CLOCK_50),
	 .god_mode(SW[15]),
	 .load_start_switch(SW[16]),
	 .load_jump_button(KEY[3]),
	 .load_is_spike_hit(is_spike_hit),
	 .draw_done(draw_done),
    .load_counter(counter),
    .load_colour(real_send_colour),   
    .load_x(real_send_x),
    .load_y(real_send_y), 
	 .load_shape_gone(real_shape_gone),
	 // Output
	 .send_update_screen(update_screen),
	 .enable(writeEn),
	 .main_send_colour(colour),
	 .main_send_x(x),
	 .main_send_y(y),
	 .reset(reset),
    .draw_start(draw_start),
	 .send_is_jump_button_pressed(is_jump_button_pressed),
	 .attempts_1s_column(attempts_1s_column),
    .attempts_10s_column(attempts_10s_column),
    .score_1s_column(score_1s_column),
    .score_10s_column(score_10s_column)
    );
	 
	 	 
	 
	 block_detector main_block_detector(
	 // Input
	 .clock(CLOCK_50),
	 .reset(reset[100]),
	 .load_block_bottom_left_corner_x_pos(all_block_send_bottom_left_corner_x_pos),
	 .load_block_bottom_left_corner_y_pos(all_block_send_bottom_left_corner_y_pos),
	 .load_is_jump_button_pressed(is_jump_button_pressed),
	 .update_screen(update_screen),
	 .load_move_counter(move_counter),
	 // Output
	 .send_square_bottom_left_corner_x_pos(square_bottom_left_corner_x_pos_detector),
	 .send_square_bottom_left_corner_y_pos(square_bottom_left_corner_y_pos_detector)
	 );
	 
	 spike_detector main_spike_detector(
	 // Input
	 .clock(CLOCK_50),
	 .reset(reset[101]),
	 .load_spike_bottom_left_corner_x_pos(all_spike_send_bottom_left_corner_x_pos),
	 .load_spike_bottom_left_corner_y_pos(all_spike_send_bottom_left_corner_y_pos),
	 .load_square_bottom_left_corner_x_pos(square_bottom_left_corner_x_pos_detector),
	 .load_square_bottom_left_corner_y_pos(square_bottom_left_corner_y_pos_detector),
	 .load_is_jump_button_pressed(is_jump_button_pressed),
	 .update_screen(update_screen),
	 .load_move_counter(move_counter),
	 // Output
	 .is_spike_hit(is_spike_hit)
	 );
	 
 	 FPS_counter main_FPS_counter(
    // Input
    .clock(CLOCK_50),
    .selected_frame_rate(SW[3:0]),
    // Output
    .send_counter(counter),
    .send_delay_counter_interval(delay_counter_interval)
	 );
	 
	 wire [3:0] attempts_1s_column;
	 wire [3:0] attempts_10s_column;
	 wire [3:0] score_1s_column;
	 wire [3:0] score_10s_column;
	 
	 hex_display main_attempts_1s_column(
	 .value(attempts_1s_column), 
	 .value_to_hex(HEX[0])
	 );
	 
	 hex_display main_attempts_10s_column(
	 .value(attempts_10s_column), 
	 .value_to_hex(HEX[1])
	 );
	 
	 hex_display main_score_1s_column(
	 .value(score_1s_column), 
	 .value_to_hex(HEX[2])
	 );
	 
	 hex_display main_score_10s_column(
	 .value(attemtps_10s_column), 
	 .value_to_hex(HEX[3])
	 );
	 
	 clear_screen main_clear_screen(
	 // Input
	 .clock(CLOCK_50),
	 .draw_start(draw_start[110]),
	 .load_colour(screen_colour),
	 .load_num_pixels_vertical(display_num_pixels_vertical),
	 .load_num_pixels_horizontal(display_num_pixels_horizontal),
	 // Output
	 .draw_done(draw_done[110]),
	 .send_colour(send_colour[110][2:0]),
	 .send_x(send_x[110][10:0]),
	 .send_y(send_y[110][10:0])
	 );
	 
	 VGA_adapter VGA(
	 // Input
	 .resetn(resetn),
	 .clock(CLOCK_50),
	 .colour(colour),
	 .x(x),
	 .y(y),
	 .plot(writeEn),
	 // Output
	 .VGA_R(VGA_R),
	 .VGA_G(VGA_G),
	 .VGA_B(VGA_B),
	 .VGA_HS(VGA_HS),
	 .VGA_VS(VGA_VS),
	 .VGA_BLANK(VGA_BLANK_N),
	 .VGA_SYNC(VGA_SYNC_N),
	 .VGA_CLK(VGA_CLK)
    );
	 
	 wire null_score_value = 1'd0;
	 wire null_delay_counter = 1'd0;
	 wire null_move_counter = 1'd0;
	 wire obstacle_yes = 1'd1;
	 wire obstacle_no = 1'd0;
	 wire [9:0] null_shape_gone;
	 wire [2:0] null_send_bottom_left_corner_x_pos;
	 wire [2:0] null_send_bottom_left_corner_y_pos;
	 
	 shape checkmark(
	 // Input
	 .score_value(null_score_value),
	 .load_delay_counter(null_delay_counter),
	 .load_move_counter(null_move_counter),
    .clock(CLOCK_50),
	 .reset(reset[0]),
    .draw_start(draw_start[107]),
	 .is_obstacle(1'd0),
    .load_colour(checkmark_colour),
    .load_bottom_left_corner_x_pos(x_level[1]),
    .load_bottom_left_corner_y_pos(y_level[8]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos(checkmark_draw_start_pos),
    .load_pixel_draw_end_pos(checkmark_draw_end_pos),
	 // Output
	 .draw_done(draw_done[107]),
    .send_colour(send_colour[107][2:0]),
    .send_x(send_x[107][10:0]),
    .send_y(send_y[107][10:0]),
	 .send_bottom_left_corner_x_pos(null_send_bottom_left_corner_x_pos[0]),
	 .send_bottom_left_corner_y_pos(null_send_bottom_left_corner_y_pos[0]),
	 .shape_gone(null_shape_gone[0])
    );

	 shape x_symbol_left_side(
	 // Input
	 .score_value(null_score_value),
	 .load_delay_counter(null_delay_counter),
	 .load_move_counter(null_move_counter),
    .clock(CLOCK_50),
	 .reset(reset[108]),
    .draw_start(draw_start[108]),
	 .is_obstacle(1'd0),
    .load_colour(x_symbol_colour),
    .load_bottom_left_corner_x_pos(x_level[1]),
    .load_bottom_left_corner_y_pos(y_level[8]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos(x_symbol_left_side_draw_start_pos),
    .load_pixel_draw_end_pos(x_symbol_left_side_draw_end_pos),
	 // Output
	 .draw_done(draw_done[108]),
    .send_colour(send_colour[108][2:0]),
    .send_x(send_x[108][10:0]),
    .send_y(send_y[108][10:0]),
	 .send_bottom_left_corner_x_pos(null_send_bottom_left_corner_x_pos[1]),
	 .send_bottom_left_corner_y_pos(null_send_bottom_left_corner_y_pos[1]),
	 .shape_gone(null_shape_gone[1])
    );
	 
	 shape x_symbol_right_side(
	 // Input
	 .score_value(null_score_value),
	 .load_delay_counter(null_delay_counter),
	 .load_move_counter(null_move_counter),
    .clock(CLOCK_50),
	 .reset(reset[109]),
    .draw_start(draw_start[109]),
	 .is_obstacle(1'd0),
    .load_colour(x_symbol_colour),
    .load_bottom_left_corner_x_pos(x_level[1]),
    .load_bottom_left_corner_y_pos(y_level[8]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos(x_symbol_right_side_draw_start_pos),
    .load_pixel_draw_end_pos(x_symbol_right_side_draw_end_pos),
	 // Output
	 .draw_done(draw_done[109]),
    .send_colour(send_colour[109][2:0]),
    .send_x(send_x[109][10:0]),
    .send_y(send_y[109][10:0]),
	 .send_bottom_left_corner_x_pos(null_send_bottom_left_corner_x_pos[2]),
	 .send_bottom_left_corner_y_pos(null_send_bottom_left_corner_y_pos[2]),
	 .shape_gone(null_shape_gone[2])
    );
	 
	 shape Square_frame_1(
	 // Input
	 .score_value(null_score_value),
	 .load_delay_counter(null_delay_counter),
	 .load_move_counter(null_move_counter),
    .clock(CLOCK_50),
	 .reset(reset[100]),
    .draw_start(draw_start[100]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(square_bottom_left_corner_x_pos_detector),
    .load_bottom_left_corner_y_pos(square_bottom_left_corner_y_pos_detector),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos(square_and_block_draw_start_pos),
    .load_pixel_draw_end_pos(square_and_block_draw_end_pos),
	 // Output
	 .draw_done(draw_done[100]),
    .send_colour(send_colour[100][2:0]),
    .send_x(send_x[100][10:0]),
    .send_y(send_y[100][10:0]),
	 .send_bottom_left_corner_x_pos(square_send_bottom_left_corner_x_pos[0]),
	 .send_bottom_left_corner_y_pos(square_send_bottom_left_corner_y_pos[0]),
	 .shape_gone(null_shape_gone[3])
    );
	 
	 shape Square_frame_2(
	 // Input
	 .score_value(null_score_value),
	 .load_delay_counter(null_delay_counter),
	 .load_move_counter(null_move_counter),
    .clock(CLOCK_50),
	 .reset(reset[101]),
    .draw_start(draw_start[101]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(square_bottom_left_corner_x_pos_detector),
    .load_bottom_left_corner_y_pos(square_bottom_left_corner_y_pos_detector - 8'd5),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos(square_and_block_draw_start_pos),
    .load_pixel_draw_end_pos(square_and_block_draw_end_pos),
	 // Output
	 .draw_done(draw_done[101]),
    .send_colour(send_colour[101][2:0]),
    .send_x(send_x[101][10:0]),
    .send_y(send_y[101][10:0]),
	 .send_bottom_left_corner_x_pos(square_send_bottom_left_corner_x_pos[1]),
	 .send_bottom_left_corner_y_pos(square_send_bottom_left_corner_y_pos[1]),
	 .shape_gone(null_shape_gone[4])
    );
	 
	 shape Square_frame_3(
	 // Input
	 .score_value(null_score_value),
	 .load_delay_counter(null_delay_counter),
	 .load_move_counter(null_move_counter),
    .clock(CLOCK_50),
	 .reset(reset[102]),
    .draw_start(draw_start[102]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(square_bottom_left_corner_x_pos_detector),
    .load_bottom_left_corner_y_pos(square_bottom_left_corner_y_pos_detector - 8'd10),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos(square_and_block_draw_start_pos),
    .load_pixel_draw_end_pos(square_and_block_draw_end_pos),
	 // Output
	 .draw_done(draw_done[102]),
    .send_colour(send_colour[102][2:0]),
    .send_x(send_x[102][10:0]),
    .send_y(send_y[102][10:0]),
	 .send_bottom_left_corner_x_pos(square_send_bottom_left_corner_x_pos[2]),
	 .send_bottom_left_corner_y_pos(square_send_bottom_left_corner_y_pos[2]),
	 .shape_gone(null_shape_gone[5])
    );
	 
	 shape Square_frame_4(
	 // Input
	 .score_value(null_score_value),
	 .load_delay_counter(null_delay_counter),
	 .load_move_counter(null_move_counter),
    .clock(CLOCK_50),
	 .reset(reset[103]),
    .draw_start(draw_start[103]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(square_bottom_left_corner_x_pos_detector),
    .load_bottom_left_corner_y_pos(square_bottom_left_corner_y_pos_detector - 8'd15),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos(square_and_block_draw_start_pos),
    .load_pixel_draw_end_pos(square_and_block_draw_end_pos),
	 // Output
	 .draw_done(draw_done[103]),
    .send_colour(send_colour[103][2:0]),
    .send_x(send_x[103][10:0]),
    .send_y(send_y[103][10:0]),
	 .send_bottom_left_corner_x_pos(square_send_bottom_left_corner_x_pos[3]),
	 .send_bottom_left_corner_y_pos(square_send_bottom_left_corner_y_pos[3]),
	 .shape_gone(null_shape_gone[6])
    );
	 
	 shape Square_frame_5(
	 // Input
	 .score_value(null_score_value),
	 .load_delay_counter(null_delay_counter),
	 .load_move_counter(null_move_counter),
    .clock(CLOCK_50),
	 .reset(reset[104]),
    .draw_start(draw_start[104]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(square_bottom_left_corner_x_pos_detector),
    .load_bottom_left_corner_y_pos(square_bottom_left_corner_y_pos_detector - 8'd10),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos(square_and_block_draw_start_pos),
    .load_pixel_draw_end_pos(square_and_block_draw_end_pos),
	 // Output
	 .draw_done(draw_done[104]),
    .send_colour(send_colour[104][2:0]),
    .send_x(send_x[104][10:0]),
    .send_y(send_y[104][10:0]),
	 .send_bottom_left_corner_x_pos(square_send_bottom_left_corner_x_pos[4]),
	 .send_bottom_left_corner_y_pos(square_send_bottom_left_corner_y_pos[4]),
	 .shape_gone(null_shape_gone[7])
    );
	 
	 shape Square_frame_6(
	 // Input
	 .score_value(null_score_value),
	 .load_delay_counter(null_delay_counter),
	 .load_move_counter(null_move_counter),
    .clock(CLOCK_50),
	 .reset(reset[105]),
    .draw_start(draw_start[105]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(square_bottom_left_corner_x_pos_detector),
    .load_bottom_left_corner_y_pos(square_bottom_left_corner_y_pos_detector - 8'd5),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos(square_and_block_draw_start_pos),
    .load_pixel_draw_end_pos(square_and_block_draw_end_pos),
	 // Output
	 .draw_done(draw_done[105]),
    .send_colour(send_colour[105][2:0]),
    .send_x(send_x[105][10:0]),
    .send_y(send_y[105][10:0]),
	 .send_bottom_left_corner_x_pos(square_send_bottom_left_corner_x_pos[5]),
	 .send_bottom_left_corner_y_pos(square_send_bottom_left_corner_y_pos[5]),
	 .shape_gone(null_shape_gone[8])
    );
	 
	 shape Square_frame_7(
	 // Input
	 .score_value(null_score_value),
	 .load_delay_counter(null_delay_counter),
	 .load_move_counter(null_move_counter),
    .clock(CLOCK_50),
	 .reset(reset[106]),
    .draw_start(draw_start[106]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(square_bottom_left_corner_x_pos_detector),
    .load_bottom_left_corner_y_pos(square_bottom_left_corner_y_pos_detector),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos(square_and_block_draw_start_pos),
    .load_pixel_draw_end_pos(square_and_block_draw_end_pos),
	 // Output
	 .draw_done(draw_done[106]),
    .send_colour(send_colour[106][2:0]),
    .send_x(send_x[106][10:0]),
    .send_y(send_y[106][10:0]),
	 .send_bottom_left_corner_x_pos(square_send_bottom_left_corner_x_pos[6]),
	 .send_bottom_left_corner_y_pos(square_send_bottom_left_corner_y_pos[6]),
	 .shape_gone(null_shape_gone[9])
    );
		 
endmodule
	 