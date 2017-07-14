module control(
// Input
clock,
load_start_switch,
load_jump_button,
draw_done,
load_counter,
load_colour,
load_x,
load_y,
// Output
send_update_screen,
enable,
main_send_colour,
main_send_x,
main_send_y,
send_curr_shape_id,
reset,
draw_start
);

	input clock;     
	input load_start_switch; // SW[0]
   input load_jump_button;  // KEY[3]	
	input [17:0] draw_done;
	input [24:0] load_counter; 
	input [53:0] load_colour;
	input [197:0] load_x; 
	input [197:0] load_y;
	
	output reg send_update_screen;
	output reg enable = 1'd0;
	output reg [2:0] main_send_colour;
	output reg [10:0] main_send_x;
	output reg [10:0] main_send_y;
	output reg [10:0] send_curr_shape_id;
	output reg [17:0] reset;
	output reg [17:0] draw_start;
	
	wire [2:0] send_colour [17:0];
	wire [10:0] send_x [17:0];
	wire [10:0] send_y [17:0];
	wire [10:0] shape [17:0]; 
	
	
	reg main_draw_done = 1'd0; 
	reg is_start_switch_pressed = 1'd0;
	reg is_jump_button_pressed = 1'd0;
	reg game_previous_state = 1'd0;
	reg draw_square_frame = 1'd0;
	reg draw_start_off = 1'd0;
	reg draw_start_on = 1'd1;
   reg update_screen = 1'd0;
	reg [10:0] curr_shape_id = 8'd17;
	reg [10:0] curr_shape_id_for_square = 8'd0;
	
   initial send_update_screen	= update_screen; 
	initial send_curr_shape_id = curr_shape_id; 
	
	integer i;
	
	assign send_x[0] = load_x[10:0];     // Square_frame_1
	assign send_x[1] = load_x[21:11];    // Square_frame_2
	assign send_x[2] = load_x[32:22];    // Square_frame_3
	assign send_x[3] = load_x[43:33];    // Square_frame_4
	assign send_x[4] = load_x[54:44];    // Square_frame_5
	assign send_x[5] = load_x[65:55];    // Square_frame_6
	assign send_x[6] = load_x[76:66];    // Square_frame_7 [IDLE]
	assign send_x[7] = load_x[87:77];    // Block_1
	assign send_x[8] = load_x[98:88];    // Block_2
	assign send_x[9] = load_x[109:99];   // Block_3  
	assign send_x[10] = load_x[120:110]; // Block_4  
	assign send_x[11] = load_x[131:121]; // Block_5 
	assign send_x[12] = load_x[142:132]; // Spike_1
	assign send_x[13] = load_x[153:143]; // Spike_2
	assign send_x[14] = load_x[164:154]; // Spike_3 
	assign send_x[15] = load_x[175:165]; // Spike_4 
	assign send_x[16] = load_x[186:176]; // Spike_5
	assign send_x[17] = load_x[197:187]; // Black_screen
	
	assign send_y[0] = load_y[10:0];     // Square_frame_1
	assign send_y[1] = load_y[21:11];    // Square_frame_2
	assign send_y[2] = load_y[32:22];    // Square_frame_3
	assign send_y[3] = load_y[43:33];    // Square_frame_4 
	assign send_y[4] = load_y[54:44];    // Square_frame_5
	assign send_y[5] = load_y[65:55];    // Square_frame_6 
	assign send_y[6] = load_y[76:66];    // Square_frame_7 [IDLE]
	assign send_y[7] = load_y[87:77];    // Block_1
	assign send_y[8] = load_y[98:88];    // Block_2
	assign send_y[9] = load_y[109:99];   // Block_3
	assign send_y[10] = load_y[120:110]; // Block_4 
	assign send_y[11] = load_y[131:121]; // Block_5 
	assign send_y[12] = load_y[142:132]; // Spike_1
	assign send_y[13] = load_y[153:143]; // Spike_2 
	assign send_y[14] = load_y[164:154]; // Spike_3
	assign send_y[15] = load_y[175:165]; // Spike_4
	assign send_y[16] = load_y[186:176]; // Spike_5
	assign send_y[17] = load_y[197:187]; // Black_screen
	
	assign send_colour[0] = load_colour[2:0];    // Square_frame_1 
	assign send_colour[1] = load_colour[5:3];    // Square_frame_2 
	assign send_colour[2] = load_colour[8:6];    // Square_frame_3
	assign send_colour[3] = load_colour[11:9];   // Square_frame_4
	assign send_colour[4] = load_colour[14:12];  // Square_frame_5
	assign send_colour[5] = load_colour[17:15];  // Square_frame_6
	assign send_colour[6] = load_colour[20:18];  // Square_frame_7 [IDLE]
	assign send_colour[7] = load_colour[23:21];  // Block_1
	assign send_colour[8] = load_colour[26:24];  // Block_2
	assign send_colour[9] = load_colour[29:27];  // Block_3 
	assign send_colour[10] = load_colour[32:30]; // Block_4 
	assign send_colour[11] = load_colour[35:33]; // Block_5 
	assign send_colour[12] = load_colour[38:36]; // Spike_1 
	assign send_colour[13] = load_colour[41:39]; // Spike_2 
	assign send_colour[14] = load_colour[44:42]; // Spike_3
	assign send_colour[15] = load_colour[47:45]; // Spike_4
	assign send_colour[16] = load_colour[50:48]; // Spike_5 
	assign send_colour[17] = load_colour[53:51]; // Black_screen
	
	// Shape IDs: Used to distinguish between different shape modules
	assign shape[0] = 8'd0;   // Square_frame_1
	assign shape[1] = 8'd1;   // Square_frame_2
	assign shape[2] = 8'd2;   // Square_frame_3
	assign shape[3] = 8'd3;   // Square_frame_4
	assign shape[4] = 8'd4;   // Square_frame_5
	assign shape[5] = 8'd5;   // Square_frame_6
	assign shape[6] = 8'd6;   // Square_frame_7 [IDLE]
	assign shape[7] = 8'd7;   // Block_1
	assign shape[8] = 8'd8;   // Block_2
	assign shape[9] = 8'd9;   // Block_3
	assign shape[10] = 8'd10; // Block_4
	assign shape[11] = 8'd11; // Block_5
	assign shape[12] = 8'd12; // Spike_1
	assign shape[13] = 8'd13; // Spike_2 
	assign shape[14] = 8'd14; // Spike_3 
	assign shape[15] = 8'd15; // Spike_4 
	assign shape[16] = 8'd16; // Spike_5 
	assign shape[17] = 8'd17; // Black_screen 
	
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
		 send_curr_shape_id <= curr_shape_id;
	end

	// Determines which shape to draw next
	always @ (posedge clock)
	begin
	   if (!load_start_switch)
		 begin
			 if (game_previous_state)
			 begin
				 // Clear the screen
				 curr_shape_id <= shape[17]; // Black_screen
				 draw_start[17] <= 1'd1;
				 // Disable VGA adapter
				 if (main_draw_done)
				 begin
					  draw_start[17] <= 1'd0;
					  enable <= 1'd0;
					  game_previous_state <= 1'd0;
				 end
          end
			 else
			 begin
			    // Reset all shapes positions
				 for (i = 0; i < 18; i = i + 1)
					 reset[i] <= 1'd1;
				 // Do not allow any modules to be drawn
				 for (i = 0; i < 18; i = i + 1)
				    draw_start[i] <= 1'd0;
		    end
		 end
		 else if (load_start_switch && !game_previous_state)
		 begin
		    // Enable VGA adapter
		    curr_shape_id <= shape[17]; // Black_screen
			 enable <= 1'd1;
			 game_previous_state <= 1'd1;
			 // Stop reseting all shapes positions
			 for (i = 0; i < 18; i = i + 1)
				   reset[i] <= 1'd0;
		 end
		if (game_previous_state)
		begin
		   // Leave shape[16] always on until screen is updated
			if (curr_shape_id == shape[16])
			    draw_start[16] <= draw_start_on;
			else if ((draw_start[curr_shape_id] == main_draw_done) && main_draw_done)
				 draw_start[curr_shape_id] <= draw_start_off;
			else
				 draw_start[curr_shape_id] <= draw_start_on;
	   end
		if (load_start_switch)
		begin
			 if (!load_jump_button)
				  is_jump_button_pressed <= 1'd1;
			 if (update_screen)
			 begin
				draw_start[16] <= draw_start_off;
				curr_shape_id <= shape[17]; // Black_screen
			 end
			 if (main_draw_done && 
				 ((curr_shape_id == shape[17]) || draw_square_frame))
			 begin
				  if (is_jump_button_pressed && draw_square_frame)
				  begin
						draw_square_frame <= 1'd0; 
						curr_shape_id <= shape[7]; // Block_1
						// Move to next square frame
						curr_shape_id_for_square <= curr_shape_id_for_square + 1'd1;
						if (curr_shape_id_for_square == shape[6]) // Square_frame_7 [IDLE]
						begin
							 is_jump_button_pressed <= 1'd0;
							 curr_shape_id_for_square <= 1'd0;
						end
				  end
				  else if (is_jump_button_pressed)
				  begin
						curr_shape_id <= curr_shape_id_for_square;
						draw_square_frame <= 1'd1;
				  end
				  else 
						curr_shape_id <= shape[6]; // Square_frame_7 [IDLE]
			 end
			 else if (main_draw_done && (curr_shape_id < shape[16]))
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