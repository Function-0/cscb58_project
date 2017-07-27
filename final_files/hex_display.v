module hex_display(
value, 
value_to_hex);

	input [3:0] value;
	
	output reg [6:0] value_to_hex;
	
	always @(*)
	begin
		case (value) 
			4'd0 : value_to_hex = 7'b1000000; 
			4'd1 : value_to_hex = 7'b1111001;
			4'd2 : value_to_hex = 7'b0100100;
			4'd3 : value_to_hex = 7'b0110000;
			4'd4 : value_to_hex = 7'b0011001;
			4'd5 : value_to_hex = 7'b0010010;
			4'd6 : value_to_hex = 7'b0000010;
			4'd7 : value_to_hex = 7'b1111000;
			4'd8 : value_to_hex = 7'b0000000;
			4'd9 : value_to_hex = 7'b0011000;
			4'd10 : value_to_hex = 7'b0001000; // A
			4'd11 : value_to_hex = 7'b0000011; // B
			4'd12 : value_to_hex = 7'b1000110; // C
			4'd13 : value_to_hex = 7'b0100001; // D
			4'd14 : value_to_hex = 7'b0000110; // E
			4'd15 : value_to_hex = 7'b0001110; // F
		endcase
	end
endmodule
