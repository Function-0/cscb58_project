module project(
// Input
CLOCK_50,
SW,
KEY,
// Output
LEDR,
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

	 output [17:0] LEDR;   // LEDR[17:0]
	 // VGA Adapter Arguments:
	 output VGA_CLK;       // VGA Clock
	 output VGA_HS;        // VGA H_SYNC
	 output VGA_VS;        // VGA V_SYN
	 output VGA_BLANK_N;   // VGA BLANK
	 output VGA_SYNC_N;    // VGA SYNC
	 output [10:0] VGA_R;  // VGA Red[10:0]
	 output [10:0] VGA_G;  // VGA Green[10:0]
	 output [10:0] VGA_B;  // VGA Blue[10:0]
	 wire [2:0] colour;    // Control to VGA 
	 wire [10:0] x;        // Control to VGA: 0 - 160 pixels [X-Dimension]
	 wire [10:0] y;        // Control to VGA: 0 - 120 pixels [Y-Dimension]
    wire resetn = SW[17]; // To VGA: Active logic-0
	 wire writeEn = 1'b1;  // To VGA: VGA adapter always ON
	 // VGA Adapter Parameters:
    // defparam VGA.RESOLUTION = "160x120";
    // defparam VGA.MONOCHROME = "FALSE";
    // defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    // defparam VGA.BACKGROUND_IMAGE = "black.mif";
    // defparam VGA.BACKGROUND_IMAGE = "impossible_game_title_card.mif";
	 
	 wire [25:0] counter;       // 60 FPS to Control: 0 - 833332 Positive-edged clock signals
	 wire update_screen;        // Control to Block Detector
	 wire [10:0] curr_shape_id; // Control to Block Detector
	 
	 // Constants:
    // Colours:
    wire [2:0] black = 3'b000;       // 3'b000 = Black
    wire [2:0] dark_blue = 3'b001;   // 3'b001 = Dark Blue
    wire [2:0] light_green = 3'b010; // 3'b010 = Light Green
    wire [2:0] light_blue = 3'b011;  // 3'b011 = Light Blue
    wire [2:0] red = 3'b100;         // 3'b100 = Red
    wire [2:0] pink = 3'b101;        // 3'b101 = Pink
    wire [2:0] yellow = 3'b110;      // 3'b110 = Yellow
    wire [2:0] white = 3'b111;       // 3'b111 = White
	 // Shapes: Colour designations
	 wire [2:0] square_colour = red;
	 wire [2:0] spike_colour = white;
	 wire [2:0] block_colour = black;
	 // Shapes: Standard dimensions
	 wire [10:0] main_num_rows = 8'd10;         // 10 pixels vertical
    wire [10:0] main_num_columns = 8'd10;      // 10 pixels horizonal
	 wire [10:0] display_num_rows = 11'd120;    // 120 pixels vertical
	 wire [10:0] display_num_columns = 11'd160; // 160 pixels horizontal
	 wire [10:0] empty_row = -8'd1;
    // Player: Idle position
	 wire [10:0] main_bottom_corner_x_pos_detector; // From Block Detector
	 wire [10:0] main_bottom_corner_y_pos_detector; // From Block Detector
 	 // Block Detector to each Shape (Square frame)
    wire [10:0] main_bottom_corner_x_pos = main_bottom_corner_x_pos_detector; 
	 // Block Detector to each Shape (Square frame)
    wire [10:0] main_bottom_corner_y_pos = main_bottom_corner_y_pos_detector; 
    // Obstacles: y-positions
    wire [10:0] y_level [6:0];
    assign y_level[0] = 8'd90;    // HEIGHT: LOW
    assign y_level[1] = 8'd80;    //       |
    assign y_level[2] = 8'd70;    //       |
    assign y_level[3] = 8'd60;    //       |
    assign y_level[4] = 8'd50;    //       |
    assign y_level[5] = 8'd40;    //       |
    assign y_level[6] = 8'd30;    // HEIGHT: HIGH
	 // Obstacles: x-positions
	 wire [10:0] x_level [20:0];
	 assign x_level[0] = 11'd160;  // RIGHT DISPLACEMENT: LOW   
	 assign x_level[1] = 11'd170;  //           |               OFFSCREEN
	 assign x_level[2] = 11'd180;  //           |                   |
	 assign x_level[3] = 11'd190;  //           |                   |
	 assign x_level[4] = 11'd200;  //           |                   |
	 assign x_level[5] = 11'd210;  //           |                   |
	 assign x_level[6] = 11'd220;  //           |                   |
	 assign x_level[7] = 11'd230;  //           |                   |
	 assign x_level[8] = 11'd240;  //           |                   | 
	 assign x_level[9] = 11'd250;  //           |                   |
	 assign x_level[10] = 11'd260; //           |                   |
	 assign x_level[11] = 11'd270; //           |                   |
	 assign x_level[12] = 11'd280; //           |                   |
	 assign x_level[13] = 11'd290; //           |                   |
	 assign x_level[14] = 11'd300; //           |                   |
	 assign x_level[15] = 11'd310; //           |                   |
	 assign x_level[16] = 11'd320; //           |                   |
	 assign x_level[17] = 11'd330; //           |                   |
	 assign x_level[18] = 11'd340; //           |                   |
	 assign x_level[19] = 11'd350; //           |                   |
	 assign x_level[20] = 11'd360; // RIGHT DISPLACEMENT: HIGH  OFFSCREEN
	 
	 wire [10:0] send_bottom_corner_x_pos [6:0]; // Each Shape (Square frame) to Block Detector
	 wire [10:0] send_bottom_corner_y_pos [6:0]; // Each Shape (Square frame) to Block Detector
	 // Increase size of the following wires if more shapes are required
    wire [17:0] draw_start;        // Control to each Shape
    wire [17:0] draw_done;         // Each Shape to Control
    wire [10:0] send_x [17:0];     // Each Shape to Control
    wire [10:0] send_y [17:0];     // Each Shape to Control
    wire [2:0] send_colour [17:0]; // Each Shape to Control
    wire [10:0] row_start [169:0]; // Each Shape to Control: 10 for each shape
    wire [10:0] row_end [169:0];   // Each Shape to Control: 10 for each shape
	 wire [10:0] ignore_send_bottom_corner_x_pos [9:0]; // Each Shape (Obstacle) to NULL
	 wire [10:0] ignore_send_bottom_corner_y_pos [9:0]; // Each Shape (Obstacle) to NULL
	
	 // Shapes: Drawing Specifications
	 // INDEX:
	 // Square & Block: row_start[9:0]; row_end[9:0]
	 // Spike: row_start[19:10]; row_end[19:10]
	 // SPARE[0]: row_start[29:20]; row_end[29:20]
	 // SPARE[1]: row_start[39:30]; row_end[39:30]
	 // SPARE[2]: row_start[49:40]; row_end[49:40]
	 // SPARE[3]: row_start[59:50]; row_end[59:50]
	 // SPARE[4]: row_start[69:60]; row_end[69:60]
	 // SPARE[5]: row_start[79:70]; row_end[79:70]
	 // SPARE[6]: row_start[89:80]; row_end[89:80]
	 // SPARE[7]: row_start[99:90]; row_end[99:90]
	 // SPARE[8]: row_start[109:100]; row_end[109:100]
	 // SPARE[9]: row_start[119:110]; row_end[119:110]
	 // SPARE[10]: row_start[129:120]; row_end[129:120]
	 // SPARE[11]: row_start[139:130]; row_end[139:130]
	 // SPARE[12]: row_start[149:140]; row_end[149:140]
	 // SPARE[13]: row_start[159:150]; row_end[159:150]
    // SPARE[14]: row_start[169:160]; row_end[169:160]
	 // Square & Block: 
    assign row_start[0] = 8'd1; // ROW 1: 10 full
    assign row_end[0] = 8'd10;
    assign row_start[1] = 8'd1; // ROW 2: 10 full
    assign row_end[1] = 8'd10;
    assign row_start[2] = 8'd1; // ROW 3: 10 full
    assign row_end[2] = 8'd10;
    assign row_start[3] = 8'd1; // ROW 4: 10 full
    assign row_end[3] = 8'd10; 
    assign row_start[4] = 8'd1; // ROW 5: 10 full
    assign row_end[4] = 8'd10;
    assign row_start[5] = 8'd1; // ROW 6: 10 full
    assign row_end[5] = 8'd10;
    assign row_start[6] = 8'd1; // ROW 7: 10 full
    assign row_end[6] = 8'd10;
    assign row_start[7] = 8'd1; // ROW 8: 10 full
    assign row_end[7] = 8'd10;
    assign row_start[8] = 8'd1; // ROW 9: 10 full
    assign row_end[8] = 8'd10;
    assign row_start[9] = 8'd1; // ROW 10: 10 full
    assign row_end[9] = 8'd10;
	 // Spike:
	 assign row_start[10] = 8'd5; // ROW 1: 4 blank, 2 full, 4 blank
    assign row_end[10] = 8'd6;
    assign row_start[11] = 8'd5; // ROW 2: 4 blank, 2 full, 4 blank
    assign row_end[11] = 8'd6;
    assign row_start[12] = 8'd4; // ROW 3: 3 blank, 4 full, 3 blank
    assign row_end[12] = 8'd7;
    assign row_start[13] = 8'd4; // ROW 4: 3 blank, 4 full, 3 blank
    assign row_end[13] = 8'd7;
    assign row_start[14] = 8'd3; // ROW 5: 2 blank, 6 full, 2 blank
    assign row_end[14] = 8'd8;
    assign row_start[15] = 8'd3; // ROW 6: 2 blank, 6 full 2 blank
    assign row_end[15] = 8'd8;
    assign row_start[16] = 8'd2; // ROW 7: 1 blank, 8 full, 1 blank
    assign row_end[16] = 8'd9;
    assign row_start[17] = 8'd2; // ROW 8: 1 blank, 8 full, 1 blank
    assign row_end[17] = 8'd9;
    assign row_start[18] = 8'd1; // ROW 9: 10 full
    assign row_end[18] = 8'd10;
    assign row_start[19] = 8'd1; // ROW 10: 10 full
    assign row_end[19] = 8'd10;
	 // SPARE[0]:
    assign row_start[20] = 8'd1; // ROW 1: 10 full
    assign row_end[20] = 8'd10;
    assign row_start[21] = 8'd1; // ROW 2: 10 full
    assign row_end[21] = 8'd10;
    assign row_start[22] = 8'd1; // ROW 3: 10 full
    assign row_end[22] = 8'd10;
    assign row_start[23] = 8'd1; // ROW 4: 10 full
    assign row_end[23] = 8'd10;
    assign row_start[24] = 8'd1; // ROW 5: 10 full
    assign row_end[24] = 8'd10;
    assign row_start[25] = 8'd1; // ROW 6: 10 full
    assign row_end[25] = 8'd10;
    assign row_start[26] = 8'd1; // ROW 7: 10 full
    assign row_end[26] = 8'd10;
    assign row_start[27] = 8'd1; // ROW 8: 10 full
    assign row_end[27] = 8'd10;
    assign row_start[28] = 8'd1; // ROW 9: 10 full
    assign row_end[28] = 8'd10;
    assign row_start[29] = 8'd1; // ROW 10: 10 full
    assign row_end[29] = 8'd10;
	 // SPARE[1]:
    assign row_start[30] = 8'd1; // ROW 1: 10 full
    assign row_end[30] = 8'd10;
    assign row_start[31] = 8'd1; // ROW 2: 10 full
    assign row_end[31] = 8'd10;
    assign row_start[32] = 8'd1; // ROW 3: 10 full
    assign row_end[32] = 8'd10;
    assign row_start[33] = 8'd1; // ROW 4: 10 full
    assign row_end[33] = 8'd10;
    assign row_start[34] = 8'd1; // ROW 5: 10 full
    assign row_end[34] = 8'd10;
    assign row_start[35] = 8'd1; // ROW 6: 10 full
    assign row_end[35] = 8'd10;
    assign row_start[36] = 8'd1; // ROW 7: 10 full
    assign row_end[36] = 8'd10;
    assign row_start[37] = 8'd1; // ROW 8: 10 full
    assign row_end[37] = 8'd10;
    assign row_start[38] = 8'd1; // ROW 9: 10 full
    assign row_end[38] = 8'd10;
    assign row_start[39] = 8'd1; // ROW 10: 10 full
    assign row_end[39] = 8'd10;
	 // SPARE[2]:
	 assign row_start[40] = 8'd1; // ROW 1: 10 full
    assign row_end[40] = 8'd10;
    assign row_start[41] = 8'd1; // ROW 2: 10 full
    assign row_end[41] = 8'd10;
    assign row_start[42] = 8'd1; // ROW 3: 10 full
    assign row_end[42] = 8'd10; 
    assign row_start[43] = 8'd1; // ROW 4: 10 full
    assign row_end[43] = 8'd10;
    assign row_start[44] = 8'd1; // ROW 5: 10 full
    assign row_end[44] = 8'd10;
    assign row_start[45] = 8'd1; // ROW 6: 10 full
    assign row_end[45] = 8'd10;
    assign row_start[46] = 8'd1; // ROW 7: 10 full
    assign row_end[46] = 8'd10;
    assign row_start[47] = 8'd1; // ROW 8: 10 full
    assign row_end[47] = 8'd10;
    assign row_start[48] = 8'd1; // ROW 9: 10 full
    assign row_end[48] = 8'd10;
    assign row_start[49] = 8'd1; // ROW 10: 10 full
    assign row_end[49] = 8'd10;
	 // SPARE[3]:
	 assign row_start[50] = 8'd1; // ROW 1: 10 full
    assign row_end[50] = 8'd10;
    assign row_start[51] = 8'd1; // ROW 2: 10 full
    assign row_end[51] = 8'd10;
    assign row_start[52] = 8'd1; // ROW 3: 10 full
    assign row_end[52] = 8'd10;
    assign row_start[53] = 8'd1; // ROW 4: 10 full
    assign row_end[53] = 8'd10;
    assign row_start[54] = 8'd1; // ROW 5: 10 full
    assign row_end[54] = 8'd10;
    assign row_start[55] = 8'd1; // ROW 6: 10 full
    assign row_end[55] = 8'd10;
    assign row_start[56] = 8'd1; // ROW 7: 10 full
    assign row_end[56] = 8'd10;
    assign row_start[57] = 8'd1; // ROW 8: 10 full
    assign row_end[57] = 8'd10;
    assign row_start[58] = 8'd1; // ROW 9: 10 full
    assign row_end[58] = 8'd10;
    assign row_start[59] = 8'd1; // ROW 10: 10 full
    assign row_end[59] = 8'd10;
	 // SPARE[4]:
    assign row_start[60] = 8'd1; // ROW 1: 10 full
    assign row_end[60] = 8'd10;
    assign row_start[61] = 8'd1; // ROW 2: 10 full
    assign row_end[61] = 8'd10;
    assign row_start[62] = 8'd1; // ROW 3: 10 full
    assign row_end[62] = 8'd10;
    assign row_start[63] = 8'd1; // ROW 4: 10 full
    assign row_end[63] = 8'd10;  
    assign row_start[64] = 8'd1; // ROW 5: 10 full
    assign row_end[64] = 8'd10;
    assign row_start[65] = 8'd1; // ROW 6: 10 full
    assign row_end[65] = 8'd10;
    assign row_start[66] = 8'd1; // ROW 7: 10 full
    assign row_end[66] = 8'd10;
    assign row_start[67] = 8'd1; // ROW 8: 10 full
    assign row_end[67] = 8'd10;
    assign row_start[68] = 8'd1; // ROW 9: 10 full
    assign row_end[68] = 8'd10;
    assign row_start[69] = 8'd1; // ROW 10: 10 full
    assign row_end[69] = 8'd10;
	 // SPARE[5]:
    assign row_start[70] = 8'd1; // ROW 1: 10 full
    assign row_end[70] = 8'd10;
    assign row_start[71] = 8'd1; // ROW 2: 10 full
    assign row_end[71] = 8'd10;
    assign row_start[72] = 8'd1; // ROW 3: 10 full
    assign row_end[72] = 8'd10; 
    assign row_start[73] = 8'd1; // ROW 4: 10 full
    assign row_end[73] = 8'd10;
    assign row_start[74] = 8'd1; // ROW 5: 10 full
    assign row_end[74] = 8'd10;
    assign row_start[75] = 8'd1; // ROW 6: 10 full
    assign row_end[75] = 8'd10;
    assign row_start[76] = 8'd1; // ROW 7: 10 full
    assign row_end[76] = 8'd10;
    assign row_start[77] = 8'd1; // ROW 8: 10 full
    assign row_end[77] = 8'd10;
    assign row_start[78] = 8'd1; // ROW 9: 10 full
    assign row_end[78] = 8'd10;
    assign row_start[79] = 8'd1; // ROW 10: 10 full
    assign row_end[79] = 8'd10;
	 // SPARE[6]:
    assign row_start[80] = 8'd1; // ROW 1: 10 full
    assign row_end[80] = 8'd10;
    assign row_start[81] = 8'd1; // ROW 2: 10 full
    assign row_end[81] = 8'd10;
    assign row_start[82] = 8'd1; // ROW 3: 10 full
    assign row_end[82] = 8'd10; 
    assign row_start[83] = 8'd1; // ROW 4: 10 full
    assign row_end[83] = 8'd10;
    assign row_start[84] = 8'd1; // ROW 5: 10 full
    assign row_end[84] = 8'd10;
    assign row_start[85] = 8'd1; // ROW 6: 10 full
    assign row_end[85] = 8'd10;
    assign row_start[86] = 8'd1; // ROW 7: 10 full
    assign row_end[86] = 8'd10;
    assign row_start[87] = 8'd1; // ROW 8: 10 full
    assign row_end[87] = 8'd10;
    assign row_start[88] = 8'd1; // ROW 9: 10 full
    assign row_end[88] = 8'd10;
    assign row_start[89] = 8'd1; // ROW 10: 10 full
    assign row_end[89] = 8'd10;
	 // SPARE[7]:
    assign row_start[90] = 8'd1; // ROW 1: 10 full
    assign row_end[90] = 8'd10;
    assign row_start[91] = 8'd1; // ROW 2: 10 full
    assign row_end[91] = 8'd10;
    assign row_start[92] = 8'd1; // ROW 3: 10 full
    assign row_end[92] = 8'd10;
    assign row_start[93] = 8'd1; // ROW 4: 10 full
    assign row_end[93] = 8'd10;
    assign row_start[94] = 8'd1; // ROW 5: 10 full
    assign row_end[94] = 8'd10;
    assign row_start[95] = 8'd1; // ROW 6: 10 full
    assign row_end[95] = 8'd10;
    assign row_start[96] = 8'd1; // ROW 7: 10 full
    assign row_end[96] = 8'd10;
    assign row_start[97] = 8'd1; // ROW 8: 10 full
    assign row_end[97] = 8'd10;
    assign row_start[98] = 8'd1; // ROW 9: 10 full
    assign row_end[98] = 8'd10;
    assign row_start[99] = 8'd1; // ROW 10: 10 full
    assign row_end[99] = 8'd10;
	 // SPARE[8]:
	 assign row_start[100] = 8'd1; // ROW 1: 10 full
    assign row_end[100] = 8'd10;
    assign row_start[101] = 8'd1; // ROW 2: 10 full
    assign row_end[101] = 8'd10;
    assign row_start[102] = 8'd1; // ROW 3: 10 full
    assign row_end[102] = 8'd10;
    assign row_start[103] = 8'd1; // ROW 4: 10 full
    assign row_end[103] = 8'd10;
    assign row_start[104] = 8'd1; // ROW 5: 10 full
    assign row_end[104] = 8'd10;
    assign row_start[105] = 8'd1; // ROW 6: 10 full
    assign row_end[105] = 8'd10;
    assign row_start[106] = 8'd1; // ROW 7: 10 full
    assign row_end[106] = 8'd10;
    assign row_start[107] = 8'd1; // ROW 8: 10 full
    assign row_end[107] = 8'd10;
    assign row_start[108] = 8'd1; // ROW 9: 10 full
    assign row_end[108] = 8'd10;
    assign row_start[109] = 8'd1; // ROW 10: 10 full
    assign row_end[109] = 8'd10;
	 // SPARE[9]:
	 assign row_start[110] = 8'd1; // ROW 1: 10 full
    assign row_end[110] = 8'd10;
    assign row_start[111] = 8'd1; // ROW 2: 10 full
    assign row_end[111] = 8'd10;
    assign row_start[112] = 8'd1; // ROW 3: 10 full
    assign row_end[112] = 8'd10;
    assign row_start[113] = 8'd1; // ROW 4: 10 full
    assign row_end[113] = 8'd10;
    assign row_start[114] = 8'd1; // ROW 5: 10 full
    assign row_end[114] = 8'd10;
    assign row_start[115] = 8'd1; // ROW 6: 10 full
    assign row_end[115] = 8'd10;
    assign row_start[116] = 8'd1; // ROW 7: 10 full
    assign row_end[116] = 8'd10;
    assign row_start[117] = 8'd1; // ROW 8: 10 full
    assign row_end[117] = 8'd10;
    assign row_start[118] = 8'd1; // ROW 9: 10 full
    assign row_end[118] = 8'd10;
    assign row_start[119] = 8'd1; // ROW 10: 10 full
    assign row_end[119] = 8'd10;
	 // SPARE[10]:
    assign row_start[120] = 8'd1; // ROW 1: 10 full
    assign row_end[120] = 8'd10;
    assign row_start[121] = 8'd1; // ROW 2: 10 full
    assign row_end[121] = 8'd10;
    assign row_start[122] = 8'd1; // ROW 3: 10 full
    assign row_end[122] = 8'd10;
    assign row_start[123] = 8'd1; // ROW 4: 10 full
    assign row_end[123] = 8'd10;
    assign row_start[124] = 8'd1; // ROW 5: 10 full
    assign row_end[124] = 8'd10;
    assign row_start[125] = 8'd1; // ROW 6: 10 full
    assign row_end[125] = 8'd10;
    assign row_start[126] = 8'd1; // ROW 7: 10 full
    assign row_end[126] = 8'd10;
    assign row_start[127] = 8'd1; // ROW 8: 10 full
    assign row_end[127] = 8'd10;
    assign row_start[128] = 8'd1; // ROW 9: 10 full
    assign row_end[128] = 8'd10;
    assign row_start[129] = 8'd1; // ROW 10: 10 full
    assign row_end[129] = 8'd10;
	 // SPARE[11]:
    assign row_start[130] = 8'd5; // ROW 1: 4 blank, 2 full, 4 blank
    assign row_end[130] = 8'd6;
    assign row_start[131] = 8'd5; // ROW 2: 4 blank, 2 full, 4 blank
    assign row_end[131] = 8'd6;
    assign row_start[132] = 8'd4; // ROW 3: 3 blank, 4 full, 3 blank
    assign row_end[132] = 8'd7;
    assign row_start[133] = 8'd4; // ROW 4: 3 blank, 4 full, 3 blank
    assign row_end[133] = 8'd7;
    assign row_start[134] = 8'd3; // ROW 5: 2 blank, 6 full, 2 blank
    assign row_end[134] = 8'd8;
    assign row_start[135] = 8'd3; // ROW 6: 2 blank, 6 full 2 blank
    assign row_end[135] = 8'd8;
    assign row_start[136] = 8'd2; // ROW 7: 1 blank, 8 full, 1 blank
    assign row_end[136] = 8'd9;
    assign row_start[137] = 8'd2; // ROW 8: 1 blank, 8 full, 1 blank
    assign row_end[137] = 8'd9;
    assign row_start[138] = 8'd1; // ROW 9: 10 full
    assign row_end[138] = 8'd10;
    assign row_start[139] = 8'd1; // ROW 10: 10 full
    assign row_end[139] = 8'd10;
	 // SPARE[12]:
    assign row_start[140] = 8'd5; // ROW 1: 4 blank, 2 full, 4 blank
    assign row_end[140] = 8'd6;
    assign row_start[141] = 8'd5; // ROW 2: 4 blank, 2 full, 4 blank
    assign row_end[141] = 8'd6;
    assign row_start[142] = 8'd4; // ROW 3: 3 blank, 4 full, 3 blank
    assign row_end[142] = 8'd7;
    assign row_start[143] = 8'd4; // ROW 4: 3 blank, 4 full, 3 blank
    assign row_end[143] = 8'd7;
    assign row_start[144] = 8'd3; // ROW 5: 2 blank, 6 full, 2 blank
    assign row_end[144] = 8'd8;
    assign row_start[145] = 8'd3; // ROW 6: 2 blank, 6 full 2 blank
    assign row_end[145] = 8'd8;
    assign row_start[146] = 8'd2; // ROW 7: 1 blank, 8 full, 1 blank
    assign row_end[146] = 8'd9;
    assign row_start[147] = 8'd2; // ROW 8: 1 blank, 8 full, 1 blank
    assign row_end[147] = 8'd9;
    assign row_start[148] = 8'd1; // ROW 9: 10 full
    assign row_end[148] = 8'd10;
    assign row_start[149] = 8'd1; // ROW 10: 10 full
    assign row_end[149] = 8'd10;
	 // SPARE[13]:
    assign row_start[150] = 8'd5; // ROW 1: 4 blank, 2 full, 4 blank
    assign row_end[150] = 8'd6;
    assign row_start[151] = 8'd5; // ROW 2: 4 blank, 2 full, 4 blank
    assign row_end[151] = 8'd6;
    assign row_start[152] = 8'd4; // ROW 3: 3 blank, 4 full, 3 blank
    assign row_end[152] = 8'd7;
    assign row_start[153] = 8'd4; // ROW 4: 3 blank, 4 full, 3 blank
    assign row_end[153] = 8'd7;
    assign row_start[154] = 8'd3; // ROW 5: 2 blank, 6 full, 2 blank
    assign row_end[154] = 8'd8;
    assign row_start[155] = 8'd3; // ROW 6: 2 blank, 6 full 2 blank
    assign row_end[155] = 8'd8;
    assign row_start[156] = 8'd2; // ROW 7: 1 blank, 8 full, 1 blank
    assign row_end[156] = 8'd9;
    assign row_start[157] = 8'd2; // ROW 8: 1 blank, 8 full, 1 blank
    assign row_end[157] = 8'd9;
    assign row_start[158] = 8'd1; // ROW 9: 10 full
    assign row_end[158] = 8'd10;
    assign row_start[159] = 8'd1; // ROW 10: 10 full
    assign row_end[159] = 8'd10;
	 // SPARE[14]:
    assign row_start[160] = 8'd5; // ROW 1: 4 blank, 2 full, 4 blank
    assign row_end[160] = 8'd6;
    assign row_start[161] = 8'd5; // ROW 2: 4 blank, 2 full, 4 blank
    assign row_end[161] = 8'd6;
    assign row_start[162] = 8'd4; // ROW 3: 3 blank, 4 full, 3 blank
    assign row_end[162] = 8'd7;
    assign row_start[163] = 8'd4; // ROW 4: 3 blank, 4 full, 3 blank
    assign row_end[163] = 8'd7;
    assign row_start[164] = 8'd3; // ROW 5: 2 blank, 6 full, 2 blank
    assign row_end[164] = 8'd8;
    assign row_start[165] = 8'd3; // ROW 6: 2 blank, 6 full 2 blank
    assign row_end[165] = 8'd8;
    assign row_start[166] = 8'd2; // ROW 7: 1 blank, 8 full, 1 blank
    assign row_end[166] = 8'd9;
    assign row_start[167] = 8'd2; // ROW 8: 1 blank, 8 full, 1 blank
    assign row_end[167] = 8'd9;
    assign row_start[168] = 8'd1; // ROW 9: 10 full
    assign row_end[168] = 8'd10;
    assign row_start[169] = 8'd1; // ROW 10: 10 full
    assign row_end[169] = 8'd10;
	 
	 // 1. vga_adapter VGA [For Actual Program]
    // 2. fake_VGA_adapter VGA [For Modelsim Compatibility]
	 fake_VGA_adapter VGA(
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
	 
    frames_per_second_60 FPS(
	 // Input
    .clock(CLOCK_50),
	 // Output
    .send_counter(counter)
    );

	 clear_screen black_screen(
	 // Input
	 .clock(CLOCK_50),
	 .draw_start(draw_start[0]),
	 .load_colour(black),
	 .load_num_rows(display_num_rows),
	 .load_num_columns(display_num_columns),
	 // Output
	 .send_colour(send_colour[0][2:0]),
	 .send_x(send_x[0][10:0]),
	 .send_y(send_y[0][10:0]),
	 .draw_done(draw_done[0])
	 );
	 
	 shape Square_frame_1(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[1]),
    .load_colour(white),
    .load_bottom_corner_x_pos(main_bottom_corner_x_pos),
    .load_bottom_corner_y_pos(main_bottom_corner_y_pos),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd0),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[1][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[1][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[1][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[1]),
	 .send_bottom_corner_x_pos(send_bottom_corner_x_pos[0]),
	 .send_bottom_corner_y_pos(send_bottom_corner_y_pos[0])
    );
	 
	 shape Square_frame_2(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[2]),
    .load_colour(square_colour),
    .load_bottom_corner_x_pos(main_bottom_corner_x_pos),
    .load_bottom_corner_y_pos(main_bottom_corner_y_pos - 8'd5),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd0),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[2][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[2][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[2][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[2]),
	 .send_bottom_corner_x_pos(send_bottom_corner_x_pos[1]),
	 .send_bottom_corner_y_pos(send_bottom_corner_y_pos[1])
    );
	 
	 shape Square_frame_3(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[3]),
    .load_colour(square_colour),
    .load_bottom_corner_x_pos(main_bottom_corner_x_pos),
    .load_bottom_corner_y_pos(main_bottom_corner_y_pos - 8'd10),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd0),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[3][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[3][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[3][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[3]),
	 .send_bottom_corner_x_pos(send_bottom_corner_x_pos[2]),
	 .send_bottom_corner_y_pos(send_bottom_corner_y_pos[2])
    );
	 
	 shape Square_frame_4(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[4]),
    .load_colour(square_colour),
    .load_bottom_corner_x_pos(main_bottom_corner_x_pos),
    .load_bottom_corner_y_pos(main_bottom_corner_y_pos - 8'd15),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd0),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[4][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[4][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[4][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[4]),
	 .send_bottom_corner_x_pos(send_bottom_corner_x_pos[3]),
	 .send_bottom_corner_y_pos(send_bottom_corner_y_pos[3])
    );
	 
	 shape Square_frame_5(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[5]),
    .load_colour(square_colour),
    .load_bottom_corner_x_pos(main_bottom_corner_x_pos),
    .load_bottom_corner_y_pos(main_bottom_corner_y_pos - 8'd10),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd0),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[5][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[5][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[5][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[5]),
	 .send_bottom_corner_x_pos(send_bottom_corner_x_pos[4]),
	 .send_bottom_corner_y_pos(send_bottom_corner_y_pos[4])
    );
	 
	 shape Square_frame_6(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[6]),
    .load_colour(square_colour),
    .load_bottom_corner_x_pos(main_bottom_corner_x_pos),
    .load_bottom_corner_y_pos(main_bottom_corner_y_pos - 8'd5),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd0),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[6][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[6][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[6][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[6]),
	 .send_bottom_corner_x_pos(send_bottom_corner_x_pos[5]),
	 .send_bottom_corner_y_pos(send_bottom_corner_y_pos[5])
    );
	 
	 shape Square_frame_7(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[7]),
    .load_colour(square_colour),
    .load_bottom_corner_x_pos(main_bottom_corner_x_pos),
    .load_bottom_corner_y_pos(main_bottom_corner_y_pos),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd0),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[7][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[7][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[7][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[7]),
	 .send_bottom_corner_x_pos(send_bottom_corner_x_pos[6]),
	 .send_bottom_corner_y_pos(send_bottom_corner_y_pos[6])
    );
	 
	 shape Block_1(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[8]),
    .load_colour(white),
    .load_bottom_corner_x_pos(x_level[0]),
    .load_bottom_corner_y_pos(y_level[0]),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd1),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[8][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[8][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[8][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[8]),
	 .send_bottom_corner_x_pos(ignore_send_bottom_corner_x_pos[0]),
	 .send_bottom_corner_y_pos(ignore_send_bottom_corner_y_pos[0])
    );
	 
	 shape Block_2(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[9]),
    .load_colour(block_colour),
    .load_bottom_corner_x_pos(x_level[1]),
    .load_bottom_corner_y_pos(y_level[3]),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd1),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[9][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[9][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[9][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[9]),
	 .send_bottom_corner_x_pos(ignore_send_bottom_corner_x_pos[1]),
	 .send_bottom_corner_y_pos(ignore_send_bottom_corner_y_pos[1])
    );
	 
	 shape Block_3(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[10]),
    .load_colour(block_colour),
    .load_bottom_corner_x_pos(x_level[2]),
    .load_bottom_corner_y_pos(y_level[5]),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd1),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[10][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[10][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[10][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[10]),
	 .send_bottom_corner_x_pos(ignore_send_bottom_corner_x_pos[2]),
	 .send_bottom_corner_y_pos(ignore_send_bottom_corner_y_pos[2])
    );
	 
	 shape Block_4(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[11]),
    .load_colour(block_colour),
    .load_bottom_corner_x_pos(x_level[3]),
    .load_bottom_corner_y_pos(y_level[3]),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd1),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[11][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[11][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[11][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[11]),
	 .send_bottom_corner_x_pos(ignore_send_bottom_corner_x_pos[3]),
	 .send_bottom_corner_y_pos(ignore_send_bottom_corner_y_pos[3])
    );
	 
	 shape Block_5(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[12]),
    .load_colour(block_colour),
    .load_bottom_corner_x_pos(x_level[4]),
    .load_bottom_corner_y_pos(y_level[0]),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd1),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[9][10:0], 
							row_start[8][10:0], 
							row_start[7][10:0],
							row_start[6][10:0],
							row_start[5][10:0],
							row_start[4][10:0],
							row_start[3][10:0],
							row_start[2][10:0],
							row_start[1][10:0],
							row_start[0][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[9][10:0], 
						 row_end[8][10:0], 
						 row_end[7][10:0],
						 row_end[6][10:0],
						 row_end[5][10:0],
						 row_end[4][10:0],
						 row_end[3][10:0],
						 row_end[2][10:0],
						 row_end[1][10:0],
						 row_end[0][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[12][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[12][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[12][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[12]),
	 .send_bottom_corner_x_pos(ignore_send_bottom_corner_x_pos[4]),
	 .send_bottom_corner_y_pos(ignore_send_bottom_corner_y_pos[4])
    );

	 shape Spike_1(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[13]),
    .load_colour(white),
    .load_bottom_corner_x_pos(x_level[5]),
    .load_bottom_corner_y_pos(y_level[0]),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd1),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[19][10:0], 
							row_start[18][10:0], 
							row_start[17][10:0],
							row_start[16][10:0],
							row_start[15][10:0],
							row_start[14][10:0],
							row_start[13][10:0],
							row_start[12][10:0],
							row_start[11][10:0],
							row_start[10][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[19][10:0], 
						 row_end[18][10:0], 
						 row_end[17][10:0],
						 row_end[16][10:0],
						 row_end[15][10:0],
						 row_end[14][10:0],
						 row_end[13][10:0],
						 row_end[12][10:0],
						 row_end[11][10:0],
						 row_end[10][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[13][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[13][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[13][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[13]),
	 .send_bottom_corner_x_pos(ignore_send_bottom_corner_x_pos[5]),
	 .send_bottom_corner_y_pos(ignore_send_bottom_corner_y_pos[5])
    );

	 shape Spike_2(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[14]),
    .load_colour(spike_colour),
    .load_bottom_corner_x_pos(x_level[6]),
    .load_bottom_corner_y_pos(y_level[3]),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd1),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[19][10:0], 
							row_start[18][10:0], 
							row_start[17][10:0],
							row_start[16][10:0],
							row_start[15][10:0],
							row_start[14][10:0],
							row_start[13][10:0],
							row_start[12][10:0],
							row_start[11][10:0],
							row_start[10][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[19][10:0], 
						 row_end[18][10:0], 
						 row_end[17][10:0],
						 row_end[16][10:0],
						 row_end[15][10:0],
						 row_end[14][10:0],
						 row_end[13][10:0],
						 row_end[12][10:0],
						 row_end[11][10:0],
						 row_end[10][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[14][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[14][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[14][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[14]),
	 .send_bottom_corner_x_pos(ignore_send_bottom_corner_x_pos[6]),
	 .send_bottom_corner_y_pos(ignore_send_bottom_corner_y_pos[6])
    );

	 shape Spike_3(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[15]),
    .load_colour(spike_colour),
    .load_bottom_corner_x_pos(x_level[7]),
    .load_bottom_corner_y_pos(y_level[5]),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd1),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[19][10:0], 
							row_start[18][10:0], 
							row_start[17][10:0],
							row_start[16][10:0],
							row_start[15][10:0],
							row_start[14][10:0],
							row_start[13][10:0],
							row_start[12][10:0],
							row_start[11][10:0],
							row_start[10][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[19][10:0], 
						 row_end[18][10:0], 
						 row_end[17][10:0],
						 row_end[16][10:0],
						 row_end[15][10:0],
						 row_end[14][10:0],
						 row_end[13][10:0],
						 row_end[12][10:0],
						 row_end[11][10:0],
						 row_end[10][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[15][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[15][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[15][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[15]),
	 .send_bottom_corner_x_pos(ignore_send_bottom_corner_x_pos[7]),
	 .send_bottom_corner_y_pos(ignore_send_bottom_corner_y_pos[7])
    );

	 shape Spike_4(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[16]),
    .load_colour(spike_colour),
    .load_bottom_corner_x_pos(x_level[8]),
    .load_bottom_corner_y_pos(y_level[3]),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd1),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[19][10:0], 
							row_start[18][10:0], 
							row_start[17][10:0],
							row_start[16][10:0],
							row_start[15][10:0],
							row_start[14][10:0],
							row_start[13][10:0],
							row_start[12][10:0],
							row_start[11][10:0],
							row_start[10][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[19][10:0], 
						 row_end[18][10:0], 
						 row_end[17][10:0],
						 row_end[16][10:0],
						 row_end[15][10:0],
						 row_end[14][10:0],
						 row_end[13][10:0],
						 row_end[12][10:0],
						 row_end[11][10:0],
						 row_end[10][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[16][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[16][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[16][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[16]),
	 .send_bottom_corner_x_pos(ignore_send_bottom_corner_x_pos[8]),
	 .send_bottom_corner_y_pos(ignore_send_bottom_corner_y_pos[8])
    );
	 
	 shape Spike_5(
	 // Input
    .clock(CLOCK_50),
    .draw_start(
		       // draw_start[<shape_id>]
					 draw_start[17]),
    .load_colour(spike_colour),
    .load_bottom_corner_x_pos(x_level[9]),
    .load_bottom_corner_y_pos(y_level[0]),
    .load_num_rows(main_num_rows),
    .load_num_columns(main_num_columns),
    .is_obstacle(1'd1),
    .load_row_start({
		            // row_start[<row_start_id>][<row_start_value>]
							row_start[19][10:0], 
							row_start[18][10:0], 
							row_start[17][10:0],
							row_start[16][10:0],
							row_start[15][10:0],
							row_start[14][10:0],
							row_start[13][10:0],
							row_start[12][10:0],
							row_start[11][10:0],
							row_start[10][10:0]}),
    .load_row_end({
	             // row_end[<row_end_id>][<row_end_value>]
						 row_end[19][10:0], 
						 row_end[18][10:0], 
						 row_end[17][10:0],
						 row_end[16][10:0],
						 row_end[15][10:0],
						 row_end[14][10:0],
						 row_end[13][10:0],
						 row_end[12][10:0],
						 row_end[11][10:0],
						 row_end[10][10:0]}),
	 // Output
    .send_colour(
				  // send_colour[<shape_id>][<colour_value>]
					  send_colour[17][2:0]),
    .send_x(
		   // send_x[<shape_id>][<x_value>]
				send_x[17][10:0]),
    .send_y(
	      // send_y[<shape_id>][<y_value>]
				send_y[17][10:0]),
    .draw_done(
				// draw_done[<shape_id>]
					draw_done[17]),
	 .send_bottom_corner_x_pos(ignore_send_bottom_corner_x_pos[9]),
	 .send_bottom_corner_y_pos(ignore_send_bottom_corner_y_pos[9])
    );

	 // Control
    control main_control(
	 // Input
    .clock(CLOCK_50),
    .load_counter(counter),
    .load_button_pressed(KEY[3]),
    .draw_done(draw_done),
    .load_send_x({
					// send_x[<shape_id>][<x_value>]
						send_x[17][10:0], 
						send_x[16][10:0], 
						send_x[15][10:0], 
						send_x[14][10:0], 
						send_x[13][10:0], 
						send_x[12][10:0], 
						send_x[11][10:0], 
						send_x[10][10:0], 
						send_x[9][10:0], 
						send_x[8][10:0], 
						send_x[7][10:0], 
						send_x[6][10:0], 
						send_x[5][10:0], 
						send_x[4][10:0], 
						send_x[3][10:0], 
						send_x[2][10:0], 
						send_x[1][10:0], 
						send_x[0][10:0]}),
    .load_send_y({
					// send_y[<shape_id>][<y_value>]
						send_y[17][10:0], 
						send_y[16][10:0], 
						send_y[15][10:0], 
						send_y[14][10:0], 
						send_y[13][10:0], 
						send_y[12][10:0], 
						send_y[11][10:0], 
						send_y[10][10:0], 
						send_y[9][10:0], 
						send_y[8][10:0], 
						send_y[7][10:0], 
						send_y[6][10:0], 
						send_y[5][10:0], 
						send_y[4][10:0], 
						send_y[3][10:0], 
						send_y[2][10:0], 
						send_y[1][10:0], 
						send_y[0][10:0]}),
    .load_send_colour({
						  // send_colour[<shape_id>][<colour_value>]
							  send_colour[17][2:0], 
							  send_colour[16][2:0], 
							  send_colour[15][2:0], 
							  send_colour[14][2:0], 
							  send_colour[13][2:0], 
							  send_colour[12][2:0], 
							  send_colour[11][2:0], 
							  send_colour[10][2:0], 
							  send_colour[9][2:0], 
							  send_colour[8][2:0], 
							  send_colour[7][2:0], 
							  send_colour[6][2:0], 
							  send_colour[5][2:0], 
							  send_colour[4][2:0], 
							  send_colour[3][2:0], 
							  send_colour[2][2:0], 
							  send_colour[1][2:0], 
							  send_colour[0][2:0]}),
	 // Output
    .draw_start(draw_start),
    .send_x_VGA(x),
    .send_y_VGA(y),
    .send_colour_VGA(colour),
	 .send_curr_shape_id(curr_shape_id),
	 .send_update_screen(update_screen)
    );
	 

	 block_detector main_block_detector(
	 // Input
	 .clock(CLOCK_50),
	 .load_send_x({ // Blocks x_values
               // send_x[<shape_id>][<x_value>]	
	               send_x[12][10:0], 
						send_x[11][10:0], 
						send_x[10][10:0], 
						send_x[9][10:0], 
						send_x[8][10:0]}),
	 .load_send_y({ // Blocks y_values
	            // send_y[<shape_id>][<x_value>]
	               send_y[12][10:0], 
						send_y[11][10:0], 
						send_y[10][10:0], 
						send_y[9][10:0], 
						send_y[8][10:0]}),
	 .load_curr_shape_id(curr_shape_id),
	 .load_curr_bottom_x_pos({ // Square frames x_values
							     // send_bottom_corner_x_pos[<shape_id>][<x_value>]		
									  send_bottom_corner_x_pos[6][10:0],
									  send_bottom_corner_x_pos[5][10:0],
									  send_bottom_corner_x_pos[4][10:0],
									  send_bottom_corner_x_pos[3][10:0],
									  send_bottom_corner_x_pos[2][10:0],
									  send_bottom_corner_x_pos[1][10:0],
									  send_bottom_corner_x_pos[0][10:0]}),
	 .load_curr_bottom_y_pos({ // Square frames y_values
							      // send_bottom_corner_y_pos[<shape_id>][<y_value>]
									   send_bottom_corner_y_pos[6][10:0],
									   send_bottom_corner_y_pos[5][10:0],
									   send_bottom_corner_y_pos[4][10:0],
									   send_bottom_corner_y_pos[3][10:0],
									   send_bottom_corner_y_pos[2][10:0],
 									   send_bottom_corner_y_pos[1][10:0],
 									   send_bottom_corner_y_pos[0][10:0]}),
	 .update_screen(update_screen),
	 // Output
	 .main_bottom_corner_x_pos(main_bottom_corner_x_pos_detector),
	 .main_bottom_corner_y_pos(main_bottom_corner_y_pos_detector) 
);
endmodule

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

module clear_screen(
// Input
clock,
draw_start,
load_colour,
load_num_rows,
load_num_columns,
// Output
send_colour,
send_x,
send_y,
draw_done,
);

    input clock;                   // 50 MHz clock
    input draw_start;              // From Control: Activates drawing process
    input [2:0] load_colour;       // Shape's colour [Pixel colour]
    input [10:0] load_num_rows;    // X-Dimension of shape
    input [10:0] load_num_columns; // Y-Dimension of shape
	 
	 // Modify our current x_ and y_values, since we count from zero
	 reg [10:0] curr_x_pos = 1'd0;
    reg [10:0] curr_y_pos = 1'd0;
	 
	 // Modify our X- and Y-Dimensions of the shape, since we count from zero
    wire [10:0] num_rows = load_num_rows - 8'd1;
    wire [10:0] num_columns = load_num_columns - 8'd1;
	 
	 // Starting x_value used to draw from
	 wire [10:0] bottom_corner_x_pos = 1'd0;
	 // Starting y_value used to draw from. Note that (0, 0) is at top left corner of display.
	 wire [10:0] bottom_corner_y_pos = 1'd0;
	 
	 // To Control: Sends shape's colour [Pixel colour]
	 output reg [2:0] send_colour;
	 initial send_colour = load_colour; 
	 // To Control: Sends shape's current x_value
    output reg [10:0] send_x;
	 initial send_x = bottom_corner_x_pos + curr_x_pos;
	 // To Control: Sends shape's current y_value
	 output reg [10:0] send_y;
	 initial send_y = bottom_corner_y_pos + curr_y_pos;
	 // To Control: Indicates that the drawing process is done
	 output reg draw_done = 1'd0; 
    // Holds the total amount of rows completed for the shape
    reg [10:0] num_rows_done = 1'd0;
	 // Indicates when we have completed drawing the current row of the shape
    reg row_done = 1'd0;
	 
    // For every Positive-edged clock signal
	 always @ (posedge clock) 
    begin
		  // If Control has send the signal to draw, and we have not finished drawing yet 
        if (draw_start && !draw_done) 
            begin
				// If we have reached the end of the current row
            if (curr_x_pos == num_columns)
            begin
					 // Reset the current x_value
					 curr_x_pos = 1'd0;
					 curr_x_pos = curr_x_pos - 8'd1;
					 // Indicate that we have completed the current row
					 row_done <= 1'd1;
					 // Increment the total number of rows completed
					 num_rows_done <= num_rows_done + 1'd1;
					 // If we have completed all the rows required for the shape
					 if (num_rows_done == num_rows)
					 begin
						  // Indicate to Control that the drawing process is done
						  draw_done <= 1'd1;
					 end
            end
				// If the current row has been completed
            if (row_done)
                begin
					 // Move on to the next row
                curr_y_pos <= curr_y_pos + 1'd1;
					 // Reset the row done indicator
                row_done <= 1'd0;
                end
			   // Else, move on to the next column, in the current row
            else
                curr_x_pos <= curr_x_pos + 1'd1;
            end
		  // Else, reset all values required to drawing the shape
        else
        begin
            curr_x_pos <= 1'd0;
            curr_y_pos <= 1'd0;
            row_done <= 1'd0;
            draw_done <= 1'd0;
            num_rows_done <= 1'd0;
        end
    end
	 
    // For every Positive-edged clock signal
    always @ (*)
    begin
		  // If Control has send the signal to draw, and we have not finished drawing yet 
        if (draw_start && !draw_done)
        begin
				// Send to Control where a new pixel should be drawn
				send_x <= bottom_corner_x_pos + curr_x_pos;
			   send_y <= bottom_corner_y_pos + curr_y_pos;
        end
    end
endmodule


module shape(
// Input
clock,
draw_start,
load_colour,
load_bottom_corner_x_pos,
load_bottom_corner_y_pos,
load_num_rows,
load_num_columns,
is_obstacle,
load_row_start,
load_row_end,
// Output
send_colour,
send_x,
send_y,
draw_done,
send_bottom_corner_x_pos,
send_bottom_corner_y_pos
);

    input clock;                           // 50 MHz clock
    input draw_start;                      // From Control: Activates drawing process
    input [2:0] load_colour;               // Shape's colour [Pixel colour]
    input [10:0] load_bottom_corner_x_pos; // Starting x_value to draw from
    input [10:0] load_bottom_corner_y_pos; // Starting y_value to draw from
    input [10:0] load_num_rows;            // X-Dimension of shape
    input [10:0] load_num_columns;         // Y-Dimension of shape
    input is_obstacle;                     // Indicates if given shape is an obstacle
	 // x_values to start drawing from, based on current row number
    input [109:0] load_row_start;
	 // x_values to stop drawing from, based on current row number 
    input [109:0] load_row_end; 
	 
	 // Modify our current x_ and y_values, since we count from zero
	 reg [10:0] curr_x_pos = 1'd0;
    reg [10:0] curr_y_pos = 1'd0;
	 
	 // Modify our X- and Y-Dimensions of the shape, since we count from zero
    wire [10:0] num_rows = load_num_rows;
    wire [10:0] num_columns = load_num_columns - 8'd1;
	 
	 // Starting x_value used to draw from
	 wire [10:0] bottom_corner_x_pos = load_bottom_corner_x_pos;
	 output reg [10:0] send_bottom_corner_x_pos;
	 initial send_bottom_corner_x_pos = bottom_corner_x_pos;
	 // Starting y_value used to draw from. Note that (0, 0) is at top left corner of display.
	 wire [10:0] bottom_corner_y_pos = load_bottom_corner_y_pos - load_num_rows;
	 output reg [10:0] send_bottom_corner_y_pos;
	 initial send_bottom_corner_y_pos = bottom_corner_y_pos;
	 
	 // Increment size to move a shape right-to-left across the display. Applies only to 
	 // obstacle shapes
	 reg [10:0] move = 8'd0;
	 
	 // To Control: Sends shape's colour [Pixel colour]
	 output reg [2:0] send_colour;
	 initial send_colour = load_colour; 
	 // To Control: Sends shape's current x_value
    output reg [10:0] send_x;
	 initial send_x = bottom_corner_x_pos + curr_x_pos + move;
	 // To Control: Sends shape's current y_value
	 output reg [10:0] send_y;
	 initial send_y = bottom_corner_y_pos + curr_y_pos;
	 // To Control: Indicates that the drawing process is done
	 output reg draw_done = 1'd0; 
	 

    
    // Holds the total amount of rows completed for the shape
    reg [10:0] num_rows_done = 1'd0;
	 // Indicates when we have completed drawing the current row of the shape
    reg row_done = 1'd0;

	 // Reassign x_value to start drawing from, based on current row number. Allows for easier
	 // access to x_values
	 wire [10:0] row_end [9:0];
	 assign row_end[0] = load_row_end[10:0];   // ROW 1
	 assign row_end[1] = load_row_end[21:11];  //  |
	 assign row_end[2] = load_row_end[32:22];  //  |
	 assign row_end[3] = load_row_end[43:33];  //  |
	 assign row_end[4] = load_row_end[54:44];  //  |
	 assign row_end[5] = load_row_end[65:55];  //  |
	 assign row_end[6] = load_row_end[76:66];  //  |
	 assign row_end[7] = load_row_end[87:77];  //  |
	 assign row_end[8] = load_row_end[98:88];  //  |
	 assign row_end[9] = load_row_end[109:99]; // ROW 10
	 
	 // Reassign x_value to stop drawing from, based on current row number. Allows for easier
	 // access to x_values
	 wire [10:0] row_start [9:0];
    assign row_start[0] = load_row_start[10:0];   // ROW 1
	 assign row_start[1] = load_row_start[21:11];  //  |
	 assign row_start[2] = load_row_start[32:22];  //  |
	 assign row_start[3] = load_row_start[43:33];  //  |
	 assign row_start[4] = load_row_start[54:44];  //  |
	 assign row_start[5] = load_row_start[65:55];  //  |
	 assign row_start[6] = load_row_start[76:66];  //  |
	 assign row_start[7] = load_row_start[87:77];  //  |
	 assign row_start[8] = load_row_start[98:88];  //  |
	 assign row_start[9] = load_row_start[109:99]; // ROW 10
	 
    // For every Positive-edged clock signal
	 always @ (posedge clock) 
    begin
		  // If Control has send the signal to draw, and we have not finished drawing yet 
        if (draw_start && !draw_done) 
            begin
				// If we have reached the end of the current row
            if (curr_x_pos == num_columns)
            begin
					 // Reset the current x_value
					 curr_x_pos = 1'd0;
					 curr_x_pos = curr_x_pos - 8'd1;
					 // Indicate that we have completed the current row
					 row_done <= 1'd1;
					 // Increment the total number of rows completed
					 num_rows_done <= num_rows_done + 1'd1;
					 // If we have completed all the rows required for the shape
					 if (num_rows_done == num_rows)
					 begin
						  // Indicate to Control that the drawing process is done
						  draw_done <= 1'd1;
						  // If the shape is an obstacle
						  if (is_obstacle)
								// The shape will be drawn 1 pixel more to the left the 
								// next time it is drawn
								move <= move + 8'd2;
					 end
            end
				// If the current row has been completed
            if (row_done)
                begin
					 // Move on to the next row
                curr_y_pos <= curr_y_pos + 1'd1;
					 // Reset the row done indicator
                row_done <= 1'd0;
                end
			   // Else, move on to the next column, in the current row
            else
                curr_x_pos <= curr_x_pos + 1'd1;
            end
		  // Else, reset all values required to drawing the shape
        else
        begin
            curr_x_pos = 1'd0;
            curr_y_pos <= 1'd0;
            row_done <= 1'd0;
            draw_done <= 1'd0;
            num_rows_done <= 1'd0;
        end
    end
	 
    // For every Positive-edged clock signal
    always @ (*)
    begin
		  // If Control has send the signal to draw, and we have not finished drawing yet 
        if (draw_start && !draw_done)
        begin
				// If the current x_value is between the range where a pixel should be drawn
				// [row_start, row_end](inclusive), based on the current row number 
            if ((curr_x_pos >= row_start[curr_y_pos]) &&
                (curr_x_pos <= row_end[curr_y_pos]))
            begin
				// Send to Control where a new pixel should be drawn
				send_x <= bottom_corner_x_pos + curr_x_pos - move;
			   send_y <= bottom_corner_y_pos + curr_y_pos;
            end
        end
    end
endmodule

module frames_per_second_60(
// Input
clock,
// Output
send_counter);

    input clock; // 50 MHz clock
	 
	 // Holds the counter's value: NOTE: 1 Hz = 1 Fps; Since 5,000,000 / 60 = 833333.333
	 // Therefore, our counter must max to decimal 833332 
    output reg [25:0] send_counter = 25'd833332;
	 
	 // For every Positive-edged clock signal
    always @ (posedge clock)
    begin
			// If our counter has the value of zero
         if (send_counter == 25'd0)
				  // Reset the counter
      	     send_counter <= 25'd833332;
			// Else, decrement the counter's value
         else
      	     send_counter <= send_counter - 8'd1;
    end
endmodule

module block_detector(
// Input
clock,
load_send_x,
load_send_y,
load_curr_shape_id,
load_curr_bottom_x_pos,
load_curr_bottom_y_pos,
update_screen,
// Output
main_bottom_corner_x_pos,
main_bottom_corner_y_pos
);

	input clock;
	input [54:0] load_send_x;        // Current x_value for current block being drawn
	input [54:0] load_send_y;        // Current y_value for current block being drawn
	input [10:0] load_curr_shape_id; // Current shape that is being drawn
	// Current x_value for current square frame being drawn
	input [76:0] load_curr_bottom_x_pos; 
	// Current y_value for current square frame being drawn
	input [76:0] load_curr_bottom_y_pos;
	wire [10:0] orig_bottom_corner_x_pos = 8'd50; // IDLE square frame's original x_value
   wire [10:0] orig_bottom_corner_y_pos = 8'd90; // IDLE square frame's original y_value
	output reg [10:0] main_bottom_corner_x_pos;   // IDLE square frame's x_value
	initial main_bottom_corner_x_pos = orig_bottom_corner_x_pos;
	output reg [10:0] main_bottom_corner_y_pos;   // IDLE square frame's y_value
	initial main_bottom_corner_y_pos = orig_bottom_corner_y_pos;
	// Reassign each square frame's current sending x_value. 
	// Allows for easier access to x_values
	wire [10:0] curr_bottom_x_pos [6:0];
	assign curr_bottom_x_pos[0] = load_curr_bottom_x_pos[10:0];  // Square_frame_1
	assign curr_bottom_x_pos[1] = load_curr_bottom_x_pos[21:11]; // Square_frame_2
	assign curr_bottom_x_pos[2] = load_curr_bottom_x_pos[32:22]; // Square_frame_3
	assign curr_bottom_x_pos[3] = load_curr_bottom_x_pos[43:33]; // Square_frame_4
	assign curr_bottom_x_pos[4] = load_curr_bottom_x_pos[54:44]; // Square_frame_5
	assign curr_bottom_x_pos[5] = load_curr_bottom_x_pos[65:55]; // Square_frame_6
	assign curr_bottom_x_pos[6] = load_curr_bottom_x_pos[76:66]; // Square_frame_7
	// Reassign each square frame's current sending y_value. 
	// Allows for easier access to y_values
	wire [10:0] curr_bottom_y_pos [6:0];
	assign curr_bottom_y_pos[0] = load_curr_bottom_y_pos[10:0];  // Square_frame_1
	assign curr_bottom_y_pos[1] = load_curr_bottom_y_pos[21:11]; // Square_frame_2
	assign curr_bottom_y_pos[2] = load_curr_bottom_y_pos[32:22]; // Square_frame_3
	assign curr_bottom_y_pos[3] = load_curr_bottom_y_pos[43:33]; // Square_frame_4
	assign curr_bottom_y_pos[4] = load_curr_bottom_y_pos[54:44]; // Square_frame_5
	assign curr_bottom_y_pos[5] = load_curr_bottom_y_pos[65:55]; // Square_frame_6
	assign curr_bottom_y_pos[6] = load_curr_bottom_y_pos[76:66]; // Square_frame_7
   // Reassign each block's current sending x_value. Allows for easier access to x_values
	wire [10:0] send_x [4:0];
	assign send_x[0] = load_send_x[10:0];  // Block_1
	assign send_x[1] = load_send_x[21:11]; // Block_2
	assign send_x[2] = load_send_x[32:22]; // Block_3
	assign send_x[3] = load_send_x[43:33]; // Block_4
	assign send_x[4] = load_send_x[54:44]; // Block_5
	// Reassign each block's current sending y_value. Allows for easier access to y_values
	wire [10:0] send_y [4:0];
	assign send_y[0] = load_send_y[10:0];  // Block_1
	assign send_y[1] = load_send_y[21:11]; // Block_2
	assign send_y[2] = load_send_y[32:22]; // Block_3
	assign send_y[3] = load_send_y[43:33]; // Block_4 
	assign send_y[4] = load_send_y[54:44]; // Block_5
	
	// Determines current square frame being drawn
	wire curr_shape_id = load_curr_shape_id - 8'd1;
	// Determines current block being drawn
	wire block_curr_shape_id = curr_shape_id - 8'd8;
	reg num_hit = 1'd0;       // Number of times a square frame has hit a block [pixel-wise]
	reg size_increase = 1'd0; // Square frame y_(shift)_value
	// Current Block's x_ and y_values
	reg [10:0] main_send_x;
	reg [10:0] main_send_y;
	// Current Square frame's x_ and y_values
	reg [10:0] main_curr_bottom_x_pos;
	reg [10:0] main_curr_bottom_y_pos;
	input update_screen;
	
	// When a variable inside this always block is changed
	always @ (*)
	begin
	// Determines which block's x_ and y_values we will check
	if ((block_curr_shape_id >= 0) && (block_curr_shape_id <= 4))
		 begin
	    main_send_x <= send_x[block_curr_shape_id];
		 main_send_y <= send_y[block_curr_shape_id];
		 end
	// Determines which square frame's x_ and y_values we will check
	if ((curr_shape_id >= 0) && (curr_shape_id <= 6))
	    begin
		 main_curr_bottom_x_pos <= curr_bottom_x_pos[curr_shape_id];
		 main_curr_bottom_y_pos <= curr_bottom_y_pos[curr_shape_id];
		 end
	end

	// When a variable inside this always block is changed
	always @ (*)
	begin
	// If the current block has drawn a pixel within both the x_ and y_range of the
	// current square frame that has been drawn
   if ((main_send_x >= main_bottom_corner_x_pos) && 
	    (main_send_x <= main_bottom_corner_x_pos + 8'd10) &&
		 (main_send_y == main_bottom_corner_y_pos - 8'd11))
		 // Increase the pixel hit counter 
		 num_hit <= num_hit + 1'd1;
   // If the screen has been updated
	if (update_screen)
	    // If there were any block collisions
	    if (num_hit > 0)
			  begin
			  size_increase <= size_increase + 8'd10; // Increase shift value
			  // Modify IDLE Square frame's original x_ and y_values
		     main_bottom_corner_x_pos <= orig_bottom_corner_x_pos + size_increase;
			  main_bottom_corner_y_pos <= orig_bottom_corner_y_pos + size_increase;
			  end
		 // Else, if it is possible to reduce the shift value
		 else if (size_increase != 1'd0)
			  size_increase <= size_increase - 8'd10; // Reduce the shift value
		 num_hit <= 1'd0; // Reset the hit counter
	end
endmodule

module control(
// Input
clock,
load_counter,
load_button_pressed,
draw_done,
load_send_x,
load_send_y,
load_send_colour,
// Output
draw_start,
send_x_VGA,
send_y_VGA,
send_colour_VGA,
send_curr_shape_id,
send_update_screen
);

	input clock;               // 50 MHz clock
	input [25:0] load_counter; // From 60 FPS: Holds the current counter's value
	input load_button_pressed; // From KEY[3]: Holds the button's current position
	// From each shape: Holds each shape's status on if they have finish drawing their shape
	input [17:0] draw_done;
	// From each shape: Holds each shape's sending x_value
	input [197:0] load_send_x; 
	// From each shape: Holds each shape's sending y_value
	input [197:0] load_send_y;
	// From each shape: Holds each shape's sending colour_value
	input [53:0] load_send_colour;

	// To each shape: Indicates when a shape is allowed to start drawing
	output reg [18:0] draw_start;
	// To VGA: Sends the x_value of the pixel to display
	output reg [10:0] send_x_VGA;
	// To VGA: Sends the y_value of the pixel to display
	output reg [10:0] send_y_VGA;
	// To VGA: Sends the colour of the pixel to display
	output reg [2:0] send_colour_VGA;
	// Indicates when the screen should be updated [based on the 60 FPS counter]
	reg update_screen = 1'd1;
	output reg send_update_screen;
   initial send_update_screen	= update_screen; // Control to Block Detector
	
	// Constants to indicate when the draw signal is ON or OFF
	reg draw_start_on = 1'd1;
	reg draw_start_off = 1'd0;
	// Indicates when a button has been pressed
	reg is_button_pressed = 1'd0;
	
	// Reassign each shape's sending x_value. Allows for easier access to x_values
	wire [10:0] send_x [18:0];
	assign send_x[0] = load_send_x[10:0];     // Background
	assign send_x[1] = load_send_x[21:11];    // Square_frame_1
	assign send_x[2] = load_send_x[32:22];    // Square_frame_2
	assign send_x[3] = load_send_x[43:33];    // Square_frame_3
	assign send_x[4] = load_send_x[54:44];    // Square_frame_4
	assign send_x[5] = load_send_x[65:55];    // Square_frame_5
	assign send_x[6] = load_send_x[76:66];    // Square_frame_6 
	assign send_x[7] = load_send_x[87:77];    // Square_frame_7
	assign send_x[8] = load_send_x[98:88];    // Block_1 
	assign send_x[9] = load_send_x[109:99];   // Block_2  
	assign send_x[10] = load_send_x[120:110]; // Block_3  
	assign send_x[11] = load_send_x[131:121]; // Block_4 
	assign send_x[12] = load_send_x[142:132]; // Block_5 
	assign send_x[13] = load_send_x[153:143]; // Spike_1
	assign send_x[14] = load_send_x[164:154]; // Spike_2 
	assign send_x[15] = load_send_x[175:165]; // Spike_3 
	assign send_x[16] = load_send_x[186:176]; // Spike_4
	assign send_x[17] = load_send_x[197:187]; // Spike_5
	assign send_x[18] = 1'd0; // NULL
	
	// Reassign each shape's sending y_value. Allows for easier access to y_values
	wire [10:0] send_y [18:0];
	assign send_y[0] = load_send_y[10:0];     // Background
	assign send_y[1] = load_send_y[21:11];    // Square_frame_1
	assign send_y[2] = load_send_y[32:22];    // Square_frame_2
	assign send_y[3] = load_send_y[43:33];    // Square_frame_3 
	assign send_y[4] = load_send_y[54:44];    // Square_frame_4
	assign send_y[5] = load_send_y[65:55];    // Square_frame_5 
	assign send_y[6] = load_send_y[76:66];    // Square_frame_6
	assign send_y[7] = load_send_y[87:77];    // Square_frame_7
	assign send_y[8] = load_send_y[98:88];    // Block_1  
	assign send_y[9] = load_send_y[109:99];   // Block_2 
	assign send_y[10] = load_send_y[120:110]; // Block_3 
	assign send_y[11] = load_send_y[131:121]; // Block_4 
	assign send_y[12] = load_send_y[142:132]; // Block_5 
	assign send_y[13] = load_send_y[153:143]; // Spike_1 
	assign send_y[14] = load_send_y[164:154]; // Spike_2
	assign send_y[15] = load_send_y[175:165]; // Spike_3
	assign send_y[16] = load_send_y[186:176]; // Spike_4
	assign send_y[17] = load_send_y[197:187]; // Spike_5
	assign send_y[18] = 1'd0; // NULL
	
	// Reassign each shape's sending colour_value. Allows for easier access to colour_values
	wire [2:0] send_colour [18:0];
	assign send_colour[0] = load_send_colour[2:0];    // Background 
	assign send_colour[1] = load_send_colour[5:3];    // Square_frame_1 
	assign send_colour[2] = load_send_colour[8:6];    // Square_frame_2
	assign send_colour[3] = load_send_colour[11:9];   // Square_frame_3
	assign send_colour[4] = load_send_colour[14:12];  // Square_frame_4
	assign send_colour[5] = load_send_colour[17:15];  // Square_frame_5
	assign send_colour[6] = load_send_colour[20:18];  // Square_frame_6
	assign send_colour[7] = load_send_colour[23:21];  // Square_frame_7
	assign send_colour[8] = load_send_colour[26:24];  // Block_1  
	assign send_colour[9] = load_send_colour[29:27];  // Block_2 
	assign send_colour[10] = load_send_colour[32:30]; // Block_3 
	assign send_colour[11] = load_send_colour[35:33]; // Block_4 
	assign send_colour[12] = load_send_colour[38:36]; // Block_5  
	assign send_colour[13] = load_send_colour[41:39]; // Spike_1 
	assign send_colour[14] = load_send_colour[44:42]; // Spike_2
	assign send_colour[15] = load_send_colour[47:45]; // Spike_3
	assign send_colour[16] = load_send_colour[50:48]; // Spike_4 
	assign send_colour[17] = load_send_colour[53:51]; // Spike_5
	assign send_colour[18] = 1'd0; // NULL
	
	// Shape IDs: Used to distinguish between different shape modules
	wire [10:0] shape [18:0];
	assign shape[0] = 8'd0;   // Background
	assign shape[1] = 8'd1;   // Square_frame_1
	assign shape[2] = 8'd2;   // Square_frame_2
	assign shape[3] = 8'd3;   // Square_frame_3
	assign shape[4] = 8'd4;   // Square_frame_4
	assign shape[5] = 8'd5;   // Square_frame_5
	assign shape[6] = 8'd6;   // Square_frame_6
	assign shape[7] = 8'd7;   // Square_frame_7
	assign shape[8] = 8'd8;   // Block_1
	assign shape[9] = 8'd9;   // Block_2
	assign shape[10] = 8'd10; // Block_3
	assign shape[11] = 8'd11; // Block_4
	assign shape[12] = 8'd12; // Block_5
	assign shape[13] = 8'd13; // Spike_1 
	assign shape[14] = 8'd14; // Spike_2 
	assign shape[15] = 8'd15; // Spike_3 
	assign shape[16] = 8'd16; // Spike_4 
	assign shape[17] = 8'd17; // Spike_5 
	assign shape[18] = 8'd18; // NULL
	 
   // Used to cycle through each shape ID
	reg [10:0] curr_shape_id = 8'd0;
	output reg [10:0] send_curr_shape_id;
	initial send_curr_shape_id = curr_shape_id; // Control to Block Detector
	// Used to cycle through each shape ID referring to the square animation
	reg [10:0] curr_shape_id_for_square = 8'd1;
	reg main_draw_done; // Holds the draw done signal from the current shape ID
	reg is_square_animation_req = 1'd0;
	reg draw_square_frame = 1'd0;
	
	// When a variable inside this always block is changed
	always @ (posedge clock)
	begin
		 // If the counter has the value of zero
		 if (load_counter == 25'd0)
			  // Indicate that the screen needs to be updated
			  update_screen <= 1'd1;
		 // Else, the screen does not need to be updated
		 else
			  update_screen <= 1'd0;
		 send_update_screen <= update_screen;
	end

	
	// When a variable inside this always block is changed
	always @ (posedge clock)
	begin
	    // If the button has been pressed [Logic-0 => Pressed]
		 if (!load_button_pressed)
			  // Indicate that the button has been pressed
			  is_button_pressed <= 1'd1;
		 // If we can update the screen
		 if (update_screen)
		 begin
			// Clear the screen
			curr_shape_id <= shape[0]; // Background
			// If the button was pressed
			if (is_button_pressed)
			begin
			   // The square animation is required
				is_square_animation_req <= 1'd1;
			end
		 end
		 // If the screen has been cleared [OR] the 1 square frame to be drawn for this round
		 // of update screen has been completed
		 if ((main_draw_done && (curr_shape_id == shape[0])) || 
		     (main_draw_done && draw_square_frame))
		 begin
           // If the square animation is required and the 1 square frame has been drawn
			  if (is_square_animation_req && draw_square_frame)
			  begin
				   draw_square_frame <= 1'd0; // Reset the 1 square frame drawn indicator
					curr_shape_id <= shape[8]; // Move to the 1st obstacle to display
					// Move to the next square frame to animate at the next round of update screen
					curr_shape_id_for_square <= curr_shape_id_for_square + 1'd1;
					// If all square frames have been displayed
					if (curr_shape_id_for_square == shape[8])
					begin
					    // The square animation is no longer required
						 is_square_animation_req <= 1'd0;
						 // Reset the square frame indicator
						 curr_shape_id_for_square <= 1'd1;
						 // Reset the button pressed indicator
						 is_button_pressed <= 1'd0;
				   end
			  end
			  // Else if, the square animation is required
			  else if (is_square_animation_req)
			  begin
			      // Move to the next square frame to animate
					curr_shape_id <= curr_shape_id_for_square;
					// Indicate that the 1 square frame has been drawn
					draw_square_frame <= 1'd1;
			  end
			  // Else, move to the 1st obstacle to display
			  else 
				   curr_shape_id <= shape[8];
		 end
		 // Else, if the current obstacle has been drawn, and there are more obstacles to be
		 // drawn
		 else if (main_draw_done && (curr_shape_id != shape[18]) && !draw_square_frame)
		     // Move to the next obstacle to display
			  curr_shape_id <= curr_shape_id + 1'd1;  

	end

	// When a variable inside this always block is changed
	always@(*)
	begin
		// Reassign each of the following connections based on the current shape ID
		main_draw_done <= draw_done[curr_shape_id];
		send_colour_VGA <= send_colour[curr_shape_id];
		send_y_VGA <= send_y[curr_shape_id];
		send_x_VGA <= send_x[curr_shape_id];
	end

	// When a variable inside this always block is changed
	always@(*)
	begin
		// If the current shape ID's draw start signal matches the current shape ID's draw done
		// signal, and said draw done signal is ON
		if ((draw_start[curr_shape_id] == main_draw_done) && (main_draw_done))
			// The current shape ID has drawn its shape. Therefore, stop drawing its shape
			draw_start[curr_shape_id] = draw_start_off;
		// Else, the current shape ID has not drawn its shape yet
		else
			draw_start[curr_shape_id] = draw_start_on;
	end
endmodule
