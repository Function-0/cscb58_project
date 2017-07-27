module block_detector(
// Input
clock,
reset,
load_block_bottom_left_corner_x_pos,
load_block_bottom_left_corner_y_pos,
load_is_jump_button_pressed,
update_screen,
load_move_counter,
// Output
send_square_bottom_left_corner_x_pos,
send_square_bottom_left_corner_y_pos
);

	input clock;
	input reset;
	input update_screen;
	input [10:0] load_move_counter;
	input [296:0] load_block_bottom_left_corner_x_pos; 
	input [296:0] load_block_bottom_left_corner_y_pos;
	input load_is_jump_button_pressed;
	
	output reg [10:0] send_square_bottom_left_corner_x_pos;  
	output reg [10:0] send_square_bottom_left_corner_y_pos;   
	
	reg [10:0] move = 1'd0;
	reg modify_square_pos_up = 1'd0;
	// Current player idle position
	reg [10:0] main_send_square_bottom_left_corner_x_pos = 8'd59;
	reg [10:0] main_send_square_bottom_left_corner_y_pos = 8'd99;
	
	wire [10:0] block_bottom_left_corner_x_pos [26:0];
	wire [10:0] block_bottom_left_corner_y_pos [26:0];
	// Original player idle position
	wire [10:0] orig_send_square_bottom_left_corner_x_pos = 8'd59;
	wire [10:0] orig_send_square_bottom_left_corner_y_pos = 8'd99;
	
	integer i;          // To check each block's data
	integer main_block; // The current block that is near the player
	
	// Index each blocks coordinates
	genvar j;
	generate
	for (j = 0; j < 27; j = j + 1)
	begin: some_name_again
		 assign block_bottom_left_corner_x_pos[j] = load_block_bottom_left_corner_x_pos[(j * 11) + 10: (j * 11)];
		 assign block_bottom_left_corner_y_pos[j] = load_block_bottom_left_corner_y_pos[(j * 11) + 10: (j * 11)];
	end
	endgenerate

	
	// Updates origin point
	always @ (*)
	begin
	    send_square_bottom_left_corner_x_pos <= main_send_square_bottom_left_corner_x_pos;
	    send_square_bottom_left_corner_y_pos <= main_send_square_bottom_left_corner_y_pos;
   end
	 
	always @ (posedge clock)
   begin
		 if (reset)
		 begin
		     move <= 1'd0;
			  modify_square_pos_up <= 1'd0;
			  main_send_square_bottom_left_corner_x_pos <= orig_send_square_bottom_left_corner_x_pos;
			  main_send_square_bottom_left_corner_y_pos <= orig_send_square_bottom_left_corner_y_pos;
		 end
       else if (update_screen)
		 begin
		    // NOTE: 
			 // > As y -> infinity, pixel goes down
			 // > As y -> 0, pixel goes up
			 if (modify_square_pos_up)
			 begin
				 main_send_square_bottom_left_corner_y_pos <= main_send_square_bottom_left_corner_y_pos - 8'd10;
				 modify_square_pos_up <= 1'd0;
			 end
			 // If the current block that was near the player is no longer near the player, AND
			 //    the player's idle position is higher than what the original's player's idle position is, AND
			 //    the player is not in a jumping animation
			 if ( !(
			       ((block_bottom_left_corner_x_pos[main_block] - move) >= main_send_square_bottom_left_corner_x_pos - 8'd9) &&
			       ((block_bottom_left_corner_x_pos[main_block] - move) <= (main_send_square_bottom_left_corner_x_pos + 8'd9))
					 ) &&
					  (main_send_square_bottom_left_corner_y_pos < orig_send_square_bottom_left_corner_y_pos)
					   && !load_is_jump_button_pressed)
			 begin
					main_send_square_bottom_left_corner_y_pos <= main_send_square_bottom_left_corner_y_pos + 8'd10;
			 end
			 move <= move + load_move_counter;
		 end
		 for (i = 0; i < 27; i = i + 1)
		 begin
			 // If a block is near the player, AND
			 //    no other block has been detected near the player
			 if ( (
			      ((block_bottom_left_corner_x_pos[i] - move) >= main_send_square_bottom_left_corner_x_pos - 8'd9) &&
			      ((block_bottom_left_corner_x_pos[i] - move) <= (main_send_square_bottom_left_corner_x_pos + 8'd9))
					) &&
				    !modify_square_pos_up)
				  begin
				  // If the near block is on the same y_level as the player
				  if (block_bottom_left_corner_y_pos[i] == main_send_square_bottom_left_corner_y_pos)
					   modify_square_pos_up <= 1'd1;
				      main_block = i;
				  end
		 end
	end
endmodule 