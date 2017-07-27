module clear_screen(
// Input
clock,
draw_start,
load_colour,
load_num_pixels_vertical,
load_num_pixels_horizontal,
// Output
draw_done,
send_colour,
send_x,
send_y
);

    input clock;                             
    input draw_start;                        
    input [2:0] load_colour;                 
    input [10:0] load_num_pixels_vertical;   // Y-Dimension of shape
    input [10:0] load_num_pixels_horizontal; // X-Dimension of shape
	 
	 output reg draw_done = 1'd0;  
	 output reg [2:0] send_colour; 
    output reg [10:0] send_x;     
	 output reg [10:0] send_y;     
	 
	 wire [10:0] top_left_corner_x_pos = 1'd0; // Origin point
	 wire [10:0] top_left_corner_y_pos = 1'd0; 
	 wire [10:0] right_offscreen_x_pos = 8'd160;
	
	 reg [10:0] curr_x_pos = 1'd0;             
    reg [10:0] curr_y_pos = 1'd0;             
    reg [10:0] num_rows_done = 1'd0;          
	 
	 // Determines colour to be sent
	 always@(*)
	 begin
			case (load_colour)
			3'b000: send_colour = 3'b000;  // Black
			3'b001: send_colour = 3'b001;  // Dark Blue
			3'b010: send_colour = 3'b010;  // Light Green
			3'b011: send_colour = 3'b011;  // Light Blue
			3'b100: send_colour = 3'b100;  // Red
			3'b101: send_colour = 3'b101;  // Pink
			3'b110: send_colour = 3'b110;  // Yellow
		   3'b111: send_colour = 3'b111;  // White
			endcase
	 end
    
	 // Determines pixel coordinate
	 always @ (posedge clock) 
    begin
        if (draw_start && !draw_done) 
        begin
            if (curr_x_pos == load_num_pixels_horizontal)
            begin
                curr_y_pos <= curr_y_pos + 1'd1; // Move on to the next row					 
					 num_rows_done <= num_rows_done + 1'd1;
					 if (num_rows_done == load_num_pixels_vertical)
					 begin
						  draw_done <= 1'd1;
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
        if (draw_start && !draw_done)
        begin
				send_x <= top_left_corner_x_pos + curr_x_pos;
			   send_y <= top_left_corner_y_pos + curr_y_pos;
        end
		  else if (!draw_start || draw_done)
		  begin
			   send_x <= right_offscreen_x_pos;
				send_y <= 1'd0;
		  end 
    end
endmodule