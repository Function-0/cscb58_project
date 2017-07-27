module spike_detector(
// Input
clock,
reset,
load_spike_bottom_left_corner_x_pos,
load_spike_bottom_left_corner_y_pos,
load_square_bottom_left_corner_x_pos,
load_square_bottom_left_corner_y_pos,
load_is_jump_button_pressed,
update_screen,
load_move_counter,
// Output
is_spike_hit
);

	input clock;
	input reset;
	input update_screen;
	input load_is_jump_button_pressed;
	input [10:0] load_move_counter;
	input [10:0] load_square_bottom_left_corner_x_pos;
	input [10:0] load_square_bottom_left_corner_y_pos;
	input [802:0] load_spike_bottom_left_corner_x_pos; 
	input [802:0] load_spike_bottom_left_corner_y_pos;
	  
	output reg is_spike_hit = 1'd0;
	
	reg [10:0] move = 1'd0;

	wire [10:0] spike_bottom_left_corner_x_pos [72:0];
	wire [10:0] spike_bottom_left_corner_y_pos [72:0];
	
	integer i; // To check each spike's data
	
	// Index each spikes coordinates
	genvar j;
	generate
	for (j = 0; j < 73; j = j + 1)
	begin: Some_name
		 assign spike_bottom_left_corner_x_pos[j] = load_spike_bottom_left_corner_x_pos[(j * 11) + 10: (j * 11)];
		 assign spike_bottom_left_corner_y_pos[j] = load_spike_bottom_left_corner_y_pos[(j * 11) + 10: (j * 11)];
	end
	endgenerate

	 
	always @ (posedge clock)
   begin
		 if (reset)
		 begin
		     move <= 1'd0;
			  is_spike_hit <= 1'd0;
		 end
       else if (update_screen && !is_spike_hit)
		 begin	 
		 for (i = 0; i < 73; i = i + 1)
		 begin
			 // If a spike is near the player, AND
			 //    no other spike has been detected near the player
			 if ( (
			      ((load_spike_bottom_left_corner_x_pos[i] - move) >= load_square_bottom_left_corner_x_pos - 8'd9) &&
			      ((load_spike_bottom_left_corner_x_pos[i] - move) <= load_square_bottom_left_corner_x_pos + 8'd9)
					) && !is_spike_hit)
				  begin
				  // If the near spike is on the same y_level as the player
				  if (load_spike_bottom_left_corner_y_pos[i] == load_square_bottom_left_corner_y_pos)
					   is_spike_hit <= 1'd1;
				  end
		 end
		 move <= move + load_move_counter;
		 end
	end
endmodule 