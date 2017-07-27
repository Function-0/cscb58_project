module control(
// Input
clock,
god_mode,
load_start_switch,
load_jump_button,
draw_done,
load_shape_gone,
load_counter,
load_colour,
load_x,
load_y,
load_is_spike_hit,
// Output
send_update_screen,
enable,
main_send_colour,
main_send_x,
main_send_y,
reset,
draw_start,
send_is_jump_button_pressed,
attempts_1s_column,
attempts_10s_column,
score_1s_column,
score_10s_column
);

	input clock;     
	input load_start_switch; // SW[0]
   input load_jump_button;  // KEY[3]	
	input [110:0] draw_done;
	input [25:0] load_counter; 
	input [332:0] load_colour;
	input [1220:0] load_x; 
	input [1220:0] load_y;
	input [1099:0] load_shape_gone;
	input load_is_spike_hit;
	input god_mode;
	
	reg is_spike_hit;
	always @ (*)
	begin
			if (god_mode)
				is_spike_hit <= 1'd0;
			else
				is_spike_hit <= load_is_spike_hit;
	end
	output reg [10:0] attempts_1s_column;
	output reg [10:0] attempts_10s_column;
	output reg [10:0] score_1s_column;
	output reg [10:0] score_10s_column;
	output reg send_update_screen;
	output reg enable = 1'd0;
	output reg [2:0] main_send_colour;
	output reg [10:0] main_send_x;
	output reg [10:0] main_send_y;
	output reg [110:0] reset;
	output reg [110:0] draw_start;
	
	wire [2:0] send_colour [110:0];
	wire [10:0] send_x [110:0];
	wire [10:0] send_y [110:0];
	wire [10:0] shape [110:0];
   wire [10:0] shape_gone [99:0];	
	
	
	reg main_draw_done = 1'd0; 
	reg is_start_switch_pressed = 1'd0;
	reg is_jump_button_pressed = 1'd0;
	
	reg game_previous_state = 1'd0;
	reg draw_square_frame = 1'd0;
	reg draw_start_off = 1'd0;
	reg draw_start_on = 1'd1;
   reg update_screen = 1'd0;
	reg [10:0] curr_shape_id = 8'd0;
	reg [10:0] curr_shape_id_for_square = 8'd100;
	reg [10:0] square_frame_delay_counter = 1'd0;
	
	output reg send_is_jump_button_pressed;
	
	always @ (*)
	begin
	    send_is_jump_button_pressed <= is_jump_button_pressed;
	end
	

	integer i;
	
	genvar j;
	generate
	for (j = 0; j < 111; j = j + 1)
	begin: some_name_again_2
		 assign send_x[j] = load_x[(j * 11) + 10: (j * 11)];
		 assign send_y[j] = load_y[(j * 11) + 10: (j * 11)];
	end
	endgenerate
	
	
	genvar k;
	generate
	for (k = 0; k < 111; k = k + 1)
	begin: some_name_again_3
		 assign send_colour[k] = load_colour[(k * 3) + 2: (k * 3)];
	end
	endgenerate
	
	genvar m;
	generate
	for (m = 0; m < 111; m = m + 1)
	begin: some_name_again_4
		 assign shape[m] = m;
	end
	endgenerate
	
	genvar n;
	generate
	for (n = 0; n < 100; n = n + 1)
	begin: some_name_again_5
		 assign shape_gone[n] = load_shape_gone[(n * 11) + 10:(n * 11)];
	end
	endgenerate
	
	reg [7:0] score;
	reg [7:0] attempts;
	always @ (*)
	begin
		 attempts_1s_column <= attempts[3:0];
		 attempts_10s_column <= attempts[7:4];
		 score_1s_column <= score[3:0];
		 score_10s_column <= score[7:4];
	end
	always @ (*)
	begin
	       score = (shape_gone[0] +
						 shape_gone[1] +
						 shape_gone[2] +
						 shape_gone[3] +
						 shape_gone[4] +
						 shape_gone[5] +
						 shape_gone[6] +
						 shape_gone[7] +
						 shape_gone[8] +
						 shape_gone[9] +
						 shape_gone[10] +
						 shape_gone[11] +
						 shape_gone[12] +
						 shape_gone[13] +
						 shape_gone[14] +
						 shape_gone[15] +
						 shape_gone[16] +
						 shape_gone[17] +
						 shape_gone[18] +
						 shape_gone[19] +
						 shape_gone[20] +
						 shape_gone[21] +
						 shape_gone[22] +
						 shape_gone[23] +
						 shape_gone[24] +
						 shape_gone[25] +
						 shape_gone[26] +
						 shape_gone[27] +
						 shape_gone[28] +
						 shape_gone[29] +
						 shape_gone[30] +
						 shape_gone[31] +
						 shape_gone[32] +
						 shape_gone[33] +
						 shape_gone[34] +
						 shape_gone[35] +
						 shape_gone[36] +
						 shape_gone[37] +
						 shape_gone[38] +
						 shape_gone[39] +
						 shape_gone[40] +
						 shape_gone[41] +
						 shape_gone[42] +
						 shape_gone[43] +
						 shape_gone[44] +
						 shape_gone[45] +
						 shape_gone[46] +
						 shape_gone[47] +
						 shape_gone[48] +
						 shape_gone[49] +
						 shape_gone[50] +
						 shape_gone[51] +
						 shape_gone[52] +
						 shape_gone[53] +
						 shape_gone[54] +
						 shape_gone[55] +
						 shape_gone[56] +
						 shape_gone[57] +
						 shape_gone[58] +
						 shape_gone[59] +
						 shape_gone[60] +
						 shape_gone[61] +
						 shape_gone[62] +
						 shape_gone[63] +
						 shape_gone[64] +
						 shape_gone[65] +
						 shape_gone[66] +
						 shape_gone[67] +
						 shape_gone[68] +
						 shape_gone[69] +
						 shape_gone[70] +
						 shape_gone[71] +
						 shape_gone[72] +
						 shape_gone[73] +
						 shape_gone[74] +
						 shape_gone[75] +
						 shape_gone[76] +
						 shape_gone[77] +
						 shape_gone[78] +
						 shape_gone[79] +
						 shape_gone[80] +
						 shape_gone[81] +
						 shape_gone[82] +
						 shape_gone[83] +
						 shape_gone[84] +
						 shape_gone[85] +
						 shape_gone[86] +
						 shape_gone[87] +
						 shape_gone[88] +
						 shape_gone[89] +
						 shape_gone[90] +
						 shape_gone[91] +
						 shape_gone[92] +
						 shape_gone[93] +
						 shape_gone[94] +
						 shape_gone[95] +
						 shape_gone[96] +
						 shape_gone[97] +
						 shape_gone[98] +
						 shape_gone[99]);
		end
	
	// Updates signal value
	always @ (posedge clock)
	begin
		 if (load_counter == 25'd0)
			  update_screen <= 1'd1;
		 else
			  update_screen <= 1'd0;
	end
	
	// Updates signal values
	always @ (*)
	begin
	    send_update_screen <= update_screen;
	end

	// Determines which shape to draw next
	always @ (posedge clock)
	begin
	   if (!load_start_switch && is_spike_hit)
		 begin
			 if (game_previous_state)
			 begin
				 attempts <= attempts + 1'd1;
				 // Clear the screen
				 curr_shape_id <= shape[110]; // Black_screen
				 draw_start[110] <= 1'd1;
				 // Disable VGA adapter
				 if (main_draw_done)
				 begin
					  draw_start[110] <= 1'd0;
					  enable <= 1'd0;
					  game_previous_state <= 1'd0;
				 end
          end
			 else
			 begin
			    // Reset all shapes positions
				 for (i = 0; i < 111; i = i + 1)
				 begin
					 reset[i] <= 1'd1;
					 draw_start[i] <= 1'd0; // Do not allow any modules to be drawn
				 end
		    end
		 end
		 else if (load_start_switch && !game_previous_state)
		 begin
		    // Enable VGA adapter
		    curr_shape_id <= shape[110]; // Black_screen
			 enable <= 1'd1;
			 game_previous_state <= 1'd1;
			 // Stop reseting all shapes positions
			 for (i = 0; i < 111; i = i + 1)
				   reset[i] <= 1'd0;
		 end
		if (game_previous_state)
		begin
		   // Leave shape[16] always on until screen is updated
			if (curr_shape_id == shape[101])
			    draw_start[101] <= draw_start_on;
			else if ((draw_start[curr_shape_id] == main_draw_done) && main_draw_done)
				 draw_start[curr_shape_id] <= draw_start_off;
			else
				 draw_start[curr_shape_id] <= draw_start_on;
	   end
		if (load_start_switch && !is_spike_hit)
		begin
			 if (!load_jump_button)
				  is_jump_button_pressed <= 1'd1;
			 if (update_screen)
			 begin
				draw_start[101] <= draw_start_off;
				curr_shape_id <= shape[110]; // Black_screen
			 end
			 if (main_draw_done && 
				 ((curr_shape_id == shape[110]) || draw_square_frame))
			 begin
				  if (is_jump_button_pressed && draw_square_frame)
				  begin
						draw_square_frame <= 1'd0; 
						curr_shape_id <= shape[0]; // Block_1
						// Move to next square frame
						if (!((square_frame_delay_counter >= 4) &&
							 (square_frame_delay_counter <= 40)))
							 curr_shape_id_for_square <= curr_shape_id_for_square + 1'd1;
						if (curr_shape_id_for_square == shape[106]) // Square_frame_7 [IDLE]
						begin
							 is_jump_button_pressed <= 1'd0;
							 curr_shape_id_for_square <= 1'd0;
							 square_frame_delay_counter = 1'd0;
						end
						square_frame_delay_counter = square_frame_delay_counter + 1'd1;
				  end
				  else if (is_jump_button_pressed)
				  begin
						curr_shape_id <= curr_shape_id_for_square;
						draw_square_frame <= 1'd1;
				  end
				  else 
						curr_shape_id <= shape[0]; 
			 end
			 else if (main_draw_done && (curr_shape_id < shape[100]))
				  curr_shape_id <= curr_shape_id + 1'd1;  
		end
	end
   
	// Updates main connections
	always@(*)
	begin
		main_draw_done <= draw_done[curr_shape_id];
		main_send_colour <= send_colour[curr_shape_id];
		main_send_y <= send_y[curr_shape_id];
		main_send_x <= send_x[curr_shape_id];
	end

endmodule