module testing(
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
    // defparam VGA.RESOLUTION = "160x120";
    // defparam VGA.MONOCHROME = "FALSE";
    // defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    // defparam VGA.BACKGROUND_IMAGE = "black.mif";
    // defparam VGA.BACKGROUND_IMAGE = "impossible_game_title_card.mif";
	 
	 wire [24:0] counter;       // FPS to Control
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
	 // Shapes: Colour designations
	 wire [2:0] square_colour = red;
	 wire [2:0] spike_colour = white;
	 wire [2:0] block_colour = yellow;
	 // Shapes: Standard dimensions
	 wire [10:0] shape_num_pixels_vertical = 8'd9;        // 10 pixels vertical
    wire [10:0] shape_num_pixels_horizontal = 8'd9;      // 10 pixels horizonal
	 wire [10:0] display_num_pixels_vertical = 11'd119;   // 120 pixels vertical
	 wire [10:0] display_num_pixels_horizontal = 11'd159; // 160 pixels horizontal
	 wire [10:0] empty_row_of_pixels = 8'd10;
    // Player: Idle position
	 wire [10:0] square_bottom_left_corner_x_pos_detector;
	 wire [10:0] square_bottom_left_corner_y_pos_detector;
    wire [10:0] square_bottom_left_corner_x_pos = 8'd59; // square_bottom_left_corner_x_pos_detector; 
    wire [10:0] square_bottom_left_corner_y_pos = 8'd89; // square_bottom_left_corner_y_pos_detector; 
    // Obstacles: y-positions
    wire [10:0] y_level [6:0];
    assign y_level[0] = 8'd89;    // HEIGHT: LOW
    assign y_level[1] = 8'd79;    //       |
    assign y_level[2] = 8'd69;    //       |
    assign y_level[3] = 8'd59;    //       |
    assign y_level[4] = 8'd49;    //       |
    assign y_level[5] = 8'd39;    //       |
    assign y_level[6] = 8'd29;    // HEIGHT: HIGH
	 // Obstacles: x-positions
	 wire [10:0] x_level [20:0];
	 assign x_level[0] = 11'd89;   // RIGHT DISPLACEMENT: LOW   
	 assign x_level[1] = 11'd99;   //           |
	 assign x_level[2] = 11'd109;  //           |
	 assign x_level[3] = 11'd119;  //           |
	 assign x_level[4] = 11'd129;  //           |
	 assign x_level[5] = 11'd139;  //           |
	 assign x_level[6] = 11'd149;  //           |
	 assign x_level[7] = 11'd159;  //           |
	 assign x_level[8] = 11'd169;  //           |
	 assign x_level[9] = 11'd179;  //           |
	 assign x_level[10] = 11'd189; //           |
	 assign x_level[11] = 11'd199; //           |
	 assign x_level[12] = 11'd209; //           |
	 assign x_level[13] = 11'd219; //           |
	 assign x_level[14] = 11'd229; //           |
	 assign x_level[15] = 11'd239; //           |
	 assign x_level[16] = 11'd249; //           |
	 assign x_level[17] = 11'd259; //           |
	 assign x_level[18] = 11'd269; //           |
	 assign x_level[19] = 11'd279; //           |
	 assign x_level[20] = 11'd289; // RIGHT DISPLACEMENT: HIGH
	 // Increase size of the following wires if more shape modules are required
    wire [17:0] draw_start;        // Control to each Shape
    wire [17:0] draw_done;         // Each Shape to Control
	 wire [17:0] reset;             // Control to each Shape
    wire [10:0] send_x [17:0];     // Each Shape to Control
    wire [10:0] send_y [17:0];     // Each Shape to Control
    wire [2:0] send_colour [17:0]; // Each Shape to Control
    wire [10:0] row_start [129:0]; // Each Shape to Control: 10 for each shape
    wire [10:0] row_end [129:0];   // Each Shape to Control: 10 for each shape
	 wire [10:0] send_bottom_left_corner_x_pos [16:0]; // Each Shape to detectors
	 wire [10:0] send_bottom_left_corner_y_pos [16:0]; // Each Shape to detectors
	
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
	 
	 FPS_counter FPS(
	 // Input
    .clock(CLOCK_50),
	 // Output
    .send_counter(counter)
    );
	 
	 wire [10:0] test_x;
	 wire [10:0] test_y;
	 wire [10:0] move_counter = 8'd5;
	 
	 block_detector main_block_detector(
	 .clock(CLOCK_50),
	 .reset(reset[17]),
	 .load_curr_shape_id(curr_shape_id),
	 .load_block_bottom_left_corner_x_pos({send_bottom_left_corner_x_pos[11][10:0],
														send_bottom_left_corner_x_pos[10][10:0],
														send_bottom_left_corner_x_pos[9][10:0],
														send_bottom_left_corner_x_pos[8][10:0],
														send_bottom_left_corner_x_pos[7][10:0]}),
	 .load_block_bottom_left_corner_y_pos({send_bottom_left_corner_y_pos[11][10:0],
														send_bottom_left_corner_y_pos[10][10:0],
														send_bottom_left_corner_y_pos[9][10:0],
														send_bottom_left_corner_y_pos[8][10:0],
														send_bottom_left_corner_y_pos[7][10:0]}),
	 .update_screen(update_screen),
	 .load_move_counter(move_counter),
	 .square_bottom_left_corner_x_pos(test_x),
	 .square_bottom_left_corner_y_pos(test_y)
	 );

    control main_control(
	 // Input
    .clock(CLOCK_50),
	 .load_start_switch(SW[0]),
	 .load_jump_button(KEY[3]),
	 .draw_done(draw_done),
    .load_counter(counter),
    .load_colour({send_colour[17][2:0], 
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
    .load_x({send_x[17][10:0], 
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
    .load_y({send_y[17][10:0], 
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
	 // Output
	 .send_update_screen(update_screen),
	 .enable(writeEn),
	 .main_send_colour(colour),
	 .main_send_x(x),
	 .main_send_y(y),
	 .send_curr_shape_id(curr_shape_id),
	 .reset(reset),
    .draw_start(draw_start)
    );
	 
	 clear_screen Black_screen(
	 // Input
	 .clock(CLOCK_50),
	 .draw_start(draw_start[17]),
	 .load_colour(black),
	 .load_num_pixels_vertical(display_num_pixels_vertical),
	 .load_num_pixels_horizontal(display_num_pixels_horizontal),
	 // Output
	 .draw_done(draw_done[17]),
	 .send_colour(send_colour[17][2:0]),
	 .send_x(send_x[17][10:0]),
	 .send_y(send_y[17][10:0])
	 );
	 
	 
	 shape Square_frame_1(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[0]),
    .draw_start(draw_start[0]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(test_x),//square_bottom_left_corner_x_pos),
    .load_bottom_left_corner_y_pos(test_y),//square_bottom_left_corner_y_pos),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
										  row_start[5][10:0],
										  row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
										  row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[0]),
    .send_colour(send_colour[0][2:0]),
    .send_x(send_x[0][10:0]),
    .send_y(send_y[0][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[0]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[0])
    );
	 
	 shape Square_frame_2(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[1]),
    .draw_start(draw_start[1]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(test_x),//square_bottom_left_corner_x_pos),
    .load_bottom_left_corner_y_pos(test_y - 8'd5),//square_bottom_left_corner_y_pos - 8'd5),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
										  row_start[5][10:0],
										  row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
										  row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[1]),
    .send_colour(send_colour[1][2:0]),
    .send_x(send_x[1][10:0]),
    .send_y(send_y[1][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[1]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[1])
    );
	 
	 shape Square_frame_3(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[2]),
    .draw_start(draw_start[2]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(test_x),//square_bottom_left_corner_x_pos),
    .load_bottom_left_corner_y_pos(test_y - 8'd10),//square_bottom_left_corner_y_pos - 8'd10),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
										  row_start[5][10:0],
										  row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
										  row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[2]),
    .send_colour(send_colour[2][2:0]),
    .send_x(send_x[2][10:0]),
    .send_y(send_y[2][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[2]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[2])
    );
	 
	 shape Square_frame_4(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[3]),
    .draw_start(draw_start[3]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(test_x),//square_bottom_left_corner_x_pos),
    .load_bottom_left_corner_y_pos(test_y - 8'd15),//square_bottom_left_corner_y_pos - 8'd15),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
										  row_start[5][10:0],
										  row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
										  row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[3]),
    .send_colour(send_colour[3][2:0]),
    .send_x(send_x[3][10:0]),
    .send_y(send_y[3][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[3]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[3])
    );
	 
	 shape Square_frame_5(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[4]),
    .draw_start(draw_start[4]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(test_x),//square_bottom_left_corner_x_pos),
    .load_bottom_left_corner_y_pos(test_y - 8'd10),//square_bottom_left_corner_y_pos - 8'd10),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
										  row_start[5][10:0],
										  row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
										  row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[4]),
    .send_colour(send_colour[4][2:0]),
    .send_x(send_x[4][10:0]),
    .send_y(send_y[4][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[4]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[4])
    );
	 
	 shape Square_frame_6(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[5]),
    .draw_start(draw_start[5]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(test_x),//square_bottom_left_corner_x_pos),
    .load_bottom_left_corner_y_pos(test_y - 8'd5),//square_bottom_left_corner_y_pos - 8'd5),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
										  row_start[5][10:0],
										  row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
										  row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[5]),
    .send_colour(send_colour[5][2:0]),
    .send_x(send_x[5][10:0]),
    .send_y(send_y[5][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[5]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[5])
    );
	 
	 shape Square_frame_7(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[6]),
    .draw_start(draw_start[6]),
	 .is_obstacle(1'd0),
    .load_colour(square_colour),
    .load_bottom_left_corner_x_pos(test_x),//square_bottom_left_corner_x_pos),
    .load_bottom_left_corner_y_pos(test_y),//square_bottom_left_corner_y_pos),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
										  row_start[5][10:0],
										  row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
										  row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[6]),
    .send_colour(send_colour[6][2:0]),
    .send_x(send_x[6][10:0]),
    .send_y(send_y[6][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[6]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[6])
    );
	 
	 shape Block_1(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[7]),
    .draw_start(draw_start[7]),
	 .is_obstacle(1'd1),
    .load_colour(block_colour),
    .load_bottom_left_corner_x_pos(x_level[0] - 8'd20),
    .load_bottom_left_corner_y_pos(y_level[0]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
								        row_start[5][10:0],
									     row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
							           row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[7]),
    .send_colour(send_colour[7][2:0]),
    .send_x(send_x[7][10:0]),
    .send_y(send_y[7][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[7]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[7])
    );
	 
	 shape Block_2(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[8]),
    .draw_start(draw_start[8]),
	 .is_obstacle(1'd1),
    .load_colour(block_colour),
    .load_bottom_left_corner_x_pos(x_level[1]),
    .load_bottom_left_corner_y_pos(y_level[3]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
								        row_start[5][10:0],
									     row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
							           row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[8]),
    .send_colour(send_colour[8][2:0]),
    .send_x(send_x[8][10:0]),
    .send_y(send_y[8][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[8]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[8])
    );
	 
	 shape Block_3(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[9]),
    .draw_start(draw_start[9]),
	 .is_obstacle(1'd1),
    .load_colour(block_colour),
    .load_bottom_left_corner_x_pos(x_level[2]),
    .load_bottom_left_corner_y_pos(y_level[5]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
								        row_start[5][10:0],
									     row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
							           row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[9]),
    .send_colour(send_colour[9][2:0]),
    .send_x(send_x[9][10:0]),
    .send_y(send_y[9][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[9]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[9])
    );
	 
	 shape Block_4(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[10]),
    .draw_start(draw_start[10]),
	 .is_obstacle(1'd1),
    .load_colour(block_colour),
    .load_bottom_left_corner_x_pos(x_level[3]),
    .load_bottom_left_corner_y_pos(y_level[3]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
								        row_start[5][10:0],
									     row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
							           row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[10]),
    .send_colour(send_colour[10][2:0]),
    .send_x(send_x[10][10:0]),
    .send_y(send_y[10][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[10]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[10])
    );
	 
	 shape Block_5(
	 // Input
	 .load_max_counter_value(1'd0),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[11]),
    .draw_start(draw_start[11]),
	 .is_obstacle(1'd1),
    .load_colour(block_colour),
    .load_bottom_left_corner_x_pos(x_level[4]),
    .load_bottom_left_corner_y_pos(y_level[0]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[9][10:0], 
										  row_start[8][10:0], 
										  row_start[7][10:0],
										  row_start[6][10:0],
								        row_start[5][10:0],
									     row_start[4][10:0],
										  row_start[3][10:0],
										  row_start[2][10:0],
										  row_start[1][10:0],
							           row_start[0][10:0]}),
    .load_pixel_draw_end_pos({row_end[9][10:0], 
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
	 .draw_done(draw_done[11]),
    .send_colour(send_colour[11][2:0]),
    .send_x(send_x[11][10:0]),
    .send_y(send_y[11][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[11]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[11])
    );
	 
	 shape Spike_1(
	 // Input
	 .load_max_counter_value(50'd500000000),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[12]),
    .draw_start(draw_start[12]),
	 .is_obstacle(1'd1),
    .load_colour(spike_colour),
    .load_bottom_left_corner_x_pos(x_level[5]),
    .load_bottom_left_corner_y_pos(y_level[0]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[19][10:0], 
										  row_start[18][10:0], 
										  row_start[17][10:0],
										  row_start[16][10:0],
										  row_start[15][10:0],
										  row_start[14][10:0],
										  row_start[13][10:0],
										  row_start[12][10:0],
										  row_start[11][10:0],
										  row_start[10][10:0]}),
    .load_pixel_draw_end_pos({row_end[19][10:0], 
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
	 .draw_done(draw_done[12]),
    .send_colour(send_colour[12][2:0]),
    .send_x(send_x[12][10:0]),
    .send_y(send_y[12][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[12]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[12])
    );
	 
	 shape Spike_2(
	 // Input
	 .load_max_counter_value(50'd500000000),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[13]),
    .draw_start(draw_start[13]),
	 .is_obstacle(1'd1),
    .load_colour(spike_colour),
    .load_bottom_left_corner_x_pos(x_level[6]),
    .load_bottom_left_corner_y_pos(y_level[3]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[19][10:0], 
										  row_start[18][10:0], 
										  row_start[17][10:0],
										  row_start[16][10:0],
										  row_start[15][10:0],
										  row_start[14][10:0],
										  row_start[13][10:0],
										  row_start[12][10:0],
										  row_start[11][10:0],
										  row_start[10][10:0]}),
    .load_pixel_draw_end_pos({row_end[19][10:0], 
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
	 .draw_done(draw_done[13]),
    .send_colour(send_colour[13][2:0]),
    .send_x(send_x[13][10:0]),
    .send_y(send_y[13][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[13]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[13])
    );
	 
	 shape Spike_3(
	 // Input
	 .load_max_counter_value(50'd500000000),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[14]),
    .draw_start(draw_start[14]),
	 .is_obstacle(1'd1),
    .load_colour(spike_colour),
    .load_bottom_left_corner_x_pos(x_level[7]),
    .load_bottom_left_corner_y_pos(y_level[5]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[19][10:0], 
										  row_start[18][10:0], 
										  row_start[17][10:0],
										  row_start[16][10:0],
										  row_start[15][10:0],
										  row_start[14][10:0],
										  row_start[13][10:0],
										  row_start[12][10:0],
										  row_start[11][10:0],
										  row_start[10][10:0]}),
    .load_pixel_draw_end_pos({row_end[19][10:0], 
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
	 .draw_done(draw_done[14]),
    .send_colour(send_colour[14][2:0]),
    .send_x(send_x[14][10:0]),
    .send_y(send_y[14][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[14]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[14])
    );
	 
	 shape Spike_4(
	 // Input
	 .load_max_counter_value(50'd500000000),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[15]),
    .draw_start(draw_start[15]),
	 .is_obstacle(1'd1),
    .load_colour(spike_colour),
    .load_bottom_left_corner_x_pos(x_level[8]),
    .load_bottom_left_corner_y_pos(y_level[3]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[19][10:0], 
										  row_start[18][10:0], 
										  row_start[17][10:0],
										  row_start[16][10:0],
										  row_start[15][10:0],
										  row_start[14][10:0],
										  row_start[13][10:0],
										  row_start[12][10:0],
										  row_start[11][10:0],
										  row_start[10][10:0]}),
    .load_pixel_draw_end_pos({row_end[19][10:0], 
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
	 .draw_done(draw_done[15]),
    .send_colour(send_colour[15][2:0]),
    .send_x(send_x[15][10:0]),
    .send_y(send_y[15][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[15]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[15])
    );
	 
	 shape Spike_5(
	 // Input
	 .load_max_counter_value(50'd500000000),
	 .load_move_counter(move_counter),
    .clock(CLOCK_50),
	 .reset(reset[16]),
    .draw_start(draw_start[16]),
	 .is_obstacle(1'd1),
    .load_colour(spike_colour),
    .load_bottom_left_corner_x_pos(x_level[9]),
    .load_bottom_left_corner_y_pos(y_level[0]),
    .load_num_pixels_vertical(shape_num_pixels_vertical),
    .load_num_pixels_horizontal(shape_num_pixels_horizontal),
    .load_pixel_draw_start_pos({row_start[19][10:0], 
										  row_start[18][10:0], 
										  row_start[17][10:0],
										  row_start[16][10:0],
										  row_start[15][10:0],
										  row_start[14][10:0],
										  row_start[13][10:0],
										  row_start[12][10:0],
										  row_start[11][10:0],
										  row_start[10][10:0]}),
    .load_pixel_draw_end_pos({row_end[19][10:0], 
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
	 .draw_done(draw_done[16]),
    .send_colour(send_colour[16][2:0]),
    .send_x(send_x[16][10:0]),
    .send_y(send_y[16][10:0]),
	 .send_bottom_left_corner_x_pos(send_bottom_left_corner_x_pos[16]),
	 .send_bottom_left_corner_y_pos(send_bottom_left_corner_y_pos[16])
    );
endmodule