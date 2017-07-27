module FPS_counter(
// Input
clock,
selected_frame_rate,
// Output
send_counter,
send_delay_counter_interval);

    input clock;
	 input [3:0] selected_frame_rate;
	 
	 output reg [25:0] send_counter;
	 output reg [49:0] send_delay_counter_interval;
	 
	 reg [25:0] max_counter;
	 
	 always @ (*)
	 begin
		 send_delay_counter_interval <= max_counter * 8'd10;
	 end
	 
	 always @ (*)
	 begin
	    // FPS table: 1 Hz = 1 FPS
		 case (selected_frame_rate)
		 4'b0000: max_counter = 26'd50000000; // 50,000,000 / 1 [FPS]
		 4'b0001: max_counter = 26'd10000000; // 50,000,000 / 5 [FPS]
		 4'b0010: max_counter = 26'd5000000;  // 50,000,000 / 10 [FPS]
		 4'b0011: max_counter = 26'd3333333;  // 50,000,000 / 15 [FPS]
		 4'b0100: max_counter = 26'd2500000;  // 50,000,000 / 20 [FPS]
		 4'b0101: max_counter = 26'd2000000;  // 50,000,000 / 25 [FPS]
		 4'b0110: max_counter = 26'd1666667;  // 50,000,000 / 30 [FPS]
		 4'b0111: max_counter = 26'd1428571;  // 50,000,000 / 35 [FPS]
		 4'b1000: max_counter = 26'd1250000;  // 50,000,000 / 40 [FPS]
		 4'b1001: max_counter = 26'd1111111;  // 50,000,000 / 45 [FPS]
		 4'b1010: max_counter = 26'd1000000;  // 50,000,000 / 50 [FPS]
		 4'b1011: max_counter = 26'd909091;   // 50,000,000 / 55 [FPS]
		 4'b1100: max_counter = 26'd833333;   // 50,000,000 / 60 [FPS]
		 default: max_counter = 26'd5000000;  // 50,000,000 / 10 [FPS]
		 endcase
	 end
	 
    always @ (posedge clock)
    begin
         if (send_counter != 1'd0)
			    send_counter <= send_counter - 1'd1;
         else
      	    send_counter <= max_counter;
    end
endmodule

