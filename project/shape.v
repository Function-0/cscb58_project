module shape(
// Input
load_max_counter_value,
load_move_counter,
clock,
reset,
draw_start,
is_obstacle,
load_colour,
load_bottom_left_corner_x_pos,
load_bottom_left_corner_y_pos,
load_num_pixels_vertical,
load_num_pixels_horizontal,
load_pixel_draw_start_pos,
load_pixel_draw_end_pos,
// Output
draw_done,
send_colour,
send_x,
send_y,
send_bottom_left_corner_x_pos,
send_bottom_left_corner_y_pos
);
    
	 input [10:0] load_move_counter;
    input clock; 
	 input reset;	 
    input draw_start;                           
    input is_obstacle;
	 input [2:0] load_colour;
    input [10:0] load_bottom_left_corner_x_pos; // Origin point
    input [10:0] load_bottom_left_corner_y_pos;
	 input [10:0] load_num_pixels_vertical;      // Y-Dimension of shape
    input [10:0] load_num_pixels_horizontal;    // X-Dimension of shape
    input [109:0] load_pixel_draw_start_pos;    // For each row of the shape
    input [109:0] load_pixel_draw_end_pos; 
	 input [25:0] load_max_counter_value;
	 
	 reg [25:0] max_counter_value;
	 initial max_counter_value = load_max_counter_value;
	 
	 output reg draw_done = 1'd0; 
	 output reg [2:0] send_colour;
	 output reg [10:0] send_x;
	 output reg [10:0] send_y;
	 output reg [10:0] send_bottom_left_corner_x_pos;
	 output reg [10:0] send_bottom_left_corner_y_pos;
	 
	 wire [10:0] row_start [9:0]; // Array of load_pixel_draw_start_pos
	 wire [10:0] row_end [9:0];   // Array of load_pixel_draw_end_pos
	 wire [10:0] right_offscreen_x_pos = 8'd160;
	 
	 reg shape_out_of_bounds = 1'd0;
	 reg [10:0] curr_x_pos = 1'd0;
    reg [10:0] curr_y_pos = 1'd0;
	 reg [10:0] move = 1'd0;
	 reg [10:0] num_rows_done = 1'd0;
	 reg [10:0] bottom_left_corner_y_pos_minus_9_pixels;
	 reg [10:0] shape_out_of_bounds_calculation = 1'd0;
	 
	 initial send_bottom_left_corner_x_pos = load_bottom_left_corner_x_pos;
	 initial send_bottom_left_corner_y_pos = load_bottom_left_corner_y_pos;
	 initial send_x = load_bottom_left_corner_x_pos + curr_x_pos + move;
	 initial send_y = load_bottom_left_corner_y_pos + curr_y_pos;
	 
	 // DO NOT MODIFY
	 initial bottom_left_corner_y_pos_minus_9_pixels = load_bottom_left_corner_y_pos - 8'd9;

    assign row_start[0] = load_pixel_draw_start_pos[10:0];  
	 assign row_start[1] = load_pixel_draw_start_pos[21:11];
	 assign row_start[2] = load_pixel_draw_start_pos[32:22]; 
	 assign row_start[3] = load_pixel_draw_start_pos[43:33]; 
	 assign row_start[4] = load_pixel_draw_start_pos[54:44]; 
	 assign row_start[5] = load_pixel_draw_start_pos[65:55];
	 assign row_start[6] = load_pixel_draw_start_pos[76:66]; 
	 assign row_start[7] = load_pixel_draw_start_pos[87:77];
	 assign row_start[8] = load_pixel_draw_start_pos[98:88];  
	 assign row_start[9] = load_pixel_draw_start_pos[109:99]; 
	 
	 assign row_end[0] = load_pixel_draw_end_pos[10:0];   
	 assign row_end[1] = load_pixel_draw_end_pos[21:11]; 
	 assign row_end[2] = load_pixel_draw_end_pos[32:22];  
	 assign row_end[3] = load_pixel_draw_end_pos[43:33];  
	 assign row_end[4] = load_pixel_draw_end_pos[54:44];  
	 assign row_end[5] = load_pixel_draw_end_pos[65:55];  
	 assign row_end[6] = load_pixel_draw_end_pos[76:66]; 
	 assign row_end[7] = load_pixel_draw_end_pos[87:77];
	 assign row_end[8] = load_pixel_draw_end_pos[98:88];  
	 assign row_end[9] = load_pixel_draw_end_pos[109:99]; 
	 
	 // Determines colour to be sent
	 always@(*)
	 begin
			case (load_colour)
			3'b000: send_colour = 3'b000;  // 3'b000 = Black
			3'b001: send_colour = 3'b001;  // 3'b001 = Dark Blue
			3'b010: send_colour = 3'b010;  // 3'b010 = Light Green
			3'b011: send_colour = 3'b011;  // 3'b011 = Light Blue
			3'b100: send_colour = 3'b100;  // 3'b100 = Red
			3'b101: send_colour = 3'b101;  // 3'b101 = Pink
			3'b110: send_colour = 3'b110;  // 3'b110 = Yellow
		   3'b111: send_colour = 3'b111;  // 3'b111 = White
			endcase
	 end
	 
	 always @ (posedge clock)
    begin
         if (max_counter_value != 1'd0)
      	    max_counter_value <= max_counter_value - 1'd1;
	 end
	 
	 // Updates calculation
    always @ (*)
    begin
		 bottom_left_corner_y_pos_minus_9_pixels <= load_bottom_left_corner_y_pos - 8'd9;
    end
	 
	 // Updates origin point
	 always @ (*)
	 begin
		  send_bottom_left_corner_x_pos <= load_bottom_left_corner_x_pos;
		  send_bottom_left_corner_y_pos <= load_bottom_left_corner_y_pos;
	 end
	 
	 // Determines pixel coordinate
	 always @ (posedge clock) 
    begin
	     if (reset && is_obstacle)
		  begin
				move = 1'd0; // DO NOT MODIFY
				shape_out_of_bounds = 1'd0; // DO NOT MODIFY
		  end
        if (draw_start && !draw_done && (max_counter_value == 1'd0)) 
            begin
            if (curr_x_pos == load_num_pixels_horizontal)
            begin
                curr_y_pos <= curr_y_pos + 1'd1; // Move on to the next row
					 num_rows_done <= num_rows_done + 1'd1;
					 if (num_rows_done == load_num_pixels_vertical)
					 begin
						  draw_done <= 1'd1;
						  shape_out_of_bounds_calculation <= load_bottom_left_corner_x_pos - move;
						  if (is_obstacle)
								move = move + load_move_counter; // DO NOT MODIFY
						  // Verilog stores values unsigned:
						  // -1 <=> 11'd2048
						  // -48 <=> 11'd2000
					  // if ((load_bottom_left_corner_x_pos - move) < 1'd0    )
						  if (shape_out_of_bounds_calculation > 11'd2000)
							   shape_out_of_bounds = 1'd1;
//						  if (shape_out_of_bounds_calculation > 11'd0)
//							   shape_out_of_bounds = 1'd1;
					 end
					 curr_x_pos <= 1'd0; // Reset current x_value
            end
            else 
                curr_x_pos <= curr_x_pos + 1'd1; // Move on to next column
            end
        else if (!draw_start)
        begin
            curr_x_pos <= 1'd0;
            curr_y_pos <= 1'd0;
				num_rows_done <= 1'd0;
            draw_done <= 1'd0;
        end
    end
	 
	 // Sends pixel coordinate
    always @ (*)
    begin
        if (draw_start && !draw_done && !shape_out_of_bounds)
        begin
            if ((curr_x_pos >= row_start[curr_y_pos]) &&
                (curr_x_pos <= row_end[curr_y_pos]))
            begin
				send_x <= load_bottom_left_corner_x_pos + curr_x_pos - move;
			   send_y <= bottom_left_corner_y_pos_minus_9_pixels + curr_y_pos;
            end
				else
				begin
					send_x <= right_offscreen_x_pos;
					send_y <= 1'd0;
				end
        end
		  else if (!draw_start || draw_done || shape_out_of_bounds)
		  begin
			   send_x <= right_offscreen_x_pos;
				send_y <= 1'd0;
		  end
    end
endmodule
