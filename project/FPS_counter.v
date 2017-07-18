module FPS_counter(
// Input
clock,
// Output
send_counter);

    input clock;

	 // FPS table: 1 Hz = 1 Fps
	 // 50,000,000 / 60 [FPS] = 833333.333
	 // 50,000,000 / 55 [FPS] = 909090.909
	 // 50,000,000 / 50 [FPS] = 1000000
	 // 50,000,000 / 45 [FPS] = 1111111.111
	 // 50,000,000 / 40 [FPS] = 1250000
	 // 50,000,000 / 35 [FPS] = 1428571.429
	 // 50,000,000 / 30 [FPS] = 1666666.667
	 // 50,000,000 / 25 [FPS] = 2000000
	 // 50,000,000 / 20 [FPS] = 2500000
	 // 50,000,000 / 15 [FPS] = 3333333.333
	 // 50,000,000 / 10 [FPS] = 5000000
	 // 50,000,000 /  5 [FPS] = 10000000
	 // 50,000,000 /  1 [FPS] = 50000000
    output reg [24:0] send_counter = 25'd21000;//25'd10000000;
	 
    always @ (posedge clock)
    begin
         if (send_counter == 1'd0)
      	    send_counter <= 25'd21000;//25'd10000000;
         else
      	    send_counter <= send_counter - 1'd1;
    end
endmodule