module block_detector(
// Input
clock,
reset,
load_curr_shape_id,
load_block_bottom_left_corner_x_pos,
load_block_bottom_left_corner_y_pos,
update_screen,
load_move_counter,
// Output
square_bottom_left_corner_x_pos,
square_bottom_left_corner_y_pos
);

	input clock;
	input reset;
	input update_screen;
	input [10:0] load_move_counter;
	input [10:0] load_curr_shape_id;
	input [54:0] load_block_bottom_left_corner_x_pos; 
	input [54:0] load_block_bottom_left_corner_y_pos;
	
	output reg [10:0] square_bottom_left_corner_x_pos;  
	output reg [10:0] square_bottom_left_corner_y_pos;   
	
	reg [10:0] move = 1'd0;
	reg modify_square_pos_up = 1'd0;
	reg [10:0] main_square_bottom_left_corner_x_pos = 8'd59;
	reg [10:0] main_square_bottom_left_corner_y_pos = 8'd89;
	
	wire [10:0] block_bottom_left_corner_x_pos [4:0];
	wire [10:0] block_bottom_left_corner_y_pos [4:0];
	wire [10:0] orig_square_bottom_left_corner_x_pos = 8'd59;
	wire [10:0] orig_square_bottom_left_corner_y_pos = 8'd89;
	
	initial square_bottom_left_corner_x_pos = main_square_bottom_left_corner_x_pos;
	initial square_bottom_left_corner_y_pos = main_square_bottom_left_corner_y_pos;
	
	integer i;
	integer main_block;
	
	assign block_bottom_left_corner_x_pos[0] = load_block_bottom_left_corner_x_pos[10:0];
	assign block_bottom_left_corner_x_pos[1] = load_block_bottom_left_corner_x_pos[21:11];
	assign block_bottom_left_corner_x_pos[2] = load_block_bottom_left_corner_x_pos[32:22];
	assign block_bottom_left_corner_x_pos[3] = load_block_bottom_left_corner_x_pos[43:33];
	assign block_bottom_left_corner_x_pos[4] = load_block_bottom_left_corner_x_pos[54:44];
	
	assign block_bottom_left_corner_y_pos[0] = load_block_bottom_left_corner_y_pos[10:0];
	assign block_bottom_left_corner_y_pos[1] = load_block_bottom_left_corner_y_pos[21:11];
	assign block_bottom_left_corner_y_pos[2] = load_block_bottom_left_corner_y_pos[32:22];
	assign block_bottom_left_corner_y_pos[3] = load_block_bottom_left_corner_y_pos[43:33];
	assign block_bottom_left_corner_y_pos[4] = load_block_bottom_left_corner_y_pos[54:44];
	
	// Updates origin point
	always @ (*)
	begin
	    square_bottom_left_corner_x_pos <= main_square_bottom_left_corner_x_pos;
	    square_bottom_left_corner_y_pos <= main_square_bottom_left_corner_y_pos;
   end
	 
	always @ (posedge clock)
   begin
		 if (reset)
		 begin
		     move <= 1'd0;
			  main_square_bottom_left_corner_x_pos <= orig_square_bottom_left_corner_x_pos;
			  main_square_bottom_left_corner_y_pos <= orig_square_bottom_left_corner_y_pos;
		 end
       else if (update_screen)
		 begin
			 if (modify_square_pos_up)
			 begin
				 main_square_bottom_left_corner_y_pos <= main_square_bottom_left_corner_y_pos - 8'd10;
				 modify_square_pos_up <= 1'd0;
			 end
			 // As y -> infinity, pixel goes down
			 // As y -> 0, pixel goes up
			 if (!(((block_bottom_left_corner_x_pos[main_block] - move) >= main_square_bottom_left_corner_x_pos) &&
				 	 ((block_bottom_left_corner_x_pos[main_block] - move) <= (main_square_bottom_left_corner_x_pos + 8'd9))) &&
					main_square_bottom_left_corner_y_pos < orig_square_bottom_left_corner_y_pos)
			 begin
					main_square_bottom_left_corner_y_pos <= main_square_bottom_left_corner_y_pos + 8'd10;
			 end
			 move <= move + load_move_counter;
		 end
		 for (i = 0; i < 5; i = i + 1)
		 begin
			 if ((((block_bottom_left_corner_x_pos[i] - move) >= main_square_bottom_left_corner_x_pos) &&
				  ((block_bottom_left_corner_x_pos[i] - move) <= (main_square_bottom_left_corner_x_pos + 8'd9))) ||
				  (((block_bottom_left_corner_x_pos[i] - move) >= main_square_bottom_left_corner_x_pos - 8'd9) &&
				  ((block_bottom_left_corner_x_pos[i] - move) <= (main_square_bottom_left_corner_x_pos))) &&
				    !modify_square_pos_up)
				  begin
				  if (block_bottom_left_corner_y_pos[i] == main_square_bottom_left_corner_y_pos)
					   modify_square_pos_up <= 1'd1;
						main_block = i;
				  end
		 end
	end

	
endmodule 