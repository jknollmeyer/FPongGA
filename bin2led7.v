//////////////////////////////////////////////////////////////////////////////////
// Company: 		Boston University
// Engineer:		Zafar Takhirov
// 
// Create Date:		11/18/2015
// Design Name: 	EC311 Support Files
// Module Name:    	binary_to_segment
// Project Name: 	Lab4 / Project
// Description:
//					This module receives a 4-bit input and converts it to 7-segment
//					LED (HEX)
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: INCOMPLETE CODE
//
//////////////////////////////////////////////////////////////////////////////////

module binary_to_segment(
	input[2:0] player_score, 
	input[2:0] cpu_score, 
	input clk, 
	output reg [6:0] seven_output, 
	output reg [3:0] AN
	);	

reg[6:0] seven_1;
reg[6:0] seven_2;
reg[6:0] seven_3;
reg[6:0] seven_4; //Assume MSB is A, and LSB is G	
reg[10:0] clk_count; //25 bits is enough for ~2 cycles/second division
reg[1:0] LED_route;
//assign AN[selection] = 0'b1;
wire count_max = &clk_count;
initial begin	//Initial block, used for correct simulations	
	AN=4'b1111;
	clk_count = 0;
	LED_route = 0;
	seven_1 = 7'b1111110;
	seven_2 = 7'b1111110;
	seven_3 = 7'b1111110;
	seven_4 = 7'b1111110;
end

always @ (posedge clk) begin

	if(count_max) begin
		clk_count = 0;
		case(cpu_score)	
			0: seven_1 = 7'b0000001;
			1: seven_1 = 7'b1001111;
			2: seven_1 = 7'b0010010;
			3: seven_1 = 7'b0000110;
			4: seven_1 = 7'b1001100;
			5: seven_1 = 7'b0100100;
			6: seven_1 = 7'b0100000;
			7: seven_1 = 7'b0001111;
			8: seven_1 = 7'b0000000;
			9: seven_1 = 7'b0001100;
			//15: seven = 7'b0111000; // This will show F	
			//remember 0 means ‘‘light-up’’
			default: seven_1 = 7'b1111110;//Something here	
			//Something here	
		endcase
		case(player_score)	
			0: seven_4 = 7'b0000001;
			1: seven_4 = 7'b1001111;
			2: seven_4 = 7'b0010010;
			3: seven_4 = 7'b0000110;
			4: seven_4 = 7'b1001100;
			5: seven_4 = 7'b0100100;
			6: seven_4 = 7'b0100000;
			7: seven_4 = 7'b0001111;
			8: seven_4 = 7'b0000000;
			9: seven_4 = 7'b0001100;
			//15: seven = 7'b0111000; // This will show F	
			//remember 0 means ‘‘light-up’’
			default: seven_4 = 7'b1111110;//Something here	
			//Something here	
		endcase
		case(LED_route)
			2'b00:begin AN = 4'b1110; seven_output = seven_1; end
			2'b01:begin AN = 4'b1101; seven_output = seven_2; end
			2'b10:begin AN = 4'b1011; seven_output = seven_3; end
			2'b11:begin AN = 4'b0111; seven_output = seven_4; end
			default: AN = 4'b1111;
		endcase
		LED_route = LED_route + 2'b01;
		//AN = 4'b0000;
		//AN[selection] = 1'b0;

	end
	else clk_count = clk_count + 1'b1;
end
endmodule	