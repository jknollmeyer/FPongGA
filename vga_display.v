`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Boston University
// Engineer: Zafar M. Takhirov
// 
// Create Date:    12:59:40 04/12/2011 
// Design Name: EC311 Support Files
// Module Name:    vga_display 
// Project Name: Lab5 / Lab6 / Project
// Target Devices: xc6slx16-3csg324
// Tool versions: XILINX ISE 13.3
// Description: 
//
// Dependencies: vga_controller_640_60
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_display(
		input rst, // global reset
		input clk, // 100MHz clk
		input up,
		input down,
		input left,
		input right,
		input[2:0] R_control,
		input[2:0] G_control,
		input[1:0] B_control,
		output reg [2:0] R, // color outputs to show on display (current pixel)
		output reg [2:0] G, 
		output reg [1:0] B,
		output wire [6:0] seven_output,
		output wire [3:0] AN,
		output HS, // Synchronization signals  
		output VS
		);

	
	// controls:
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank
	wire ball;	// the ball you want to display
	wire player; //player's paddle
	wire computer; //computer's paddle
	
	// memory interface:
	wire [14:0] addra;
	wire [7:0] douta;
	
	wire [2:0] R2, G2;
	wire [1:0] B2;
	wire endgame;
	
	/////////////////////////////////////////
	// State machine parameters	
	parameter S_IDLE = 0;	// 0000 - no button pushed
	parameter S_UP = 1;		// 0001 - the first button pushed	
	parameter S_DOWN = 2;	// 0010 - the second button pushed
	parameter S_LEFT = 4; 	// 0100 - and so on	
	parameter S_RIGHT = 8;	// 1000 - and so on
	
	reg [3:0] state, next_state;
	////////////////////////////////////////	
		
	reg signed [10:0] player_y, computer_y;		//current position variables (top left corner)
	reg signed [10:0] ball_width, player_width, player_height, computer_width, computer_height;
	reg signed [10:0] ball_x, ball_y, ball_x_speed, ball_y_speed, player_speed, computer_speed;
	reg slow_clk;					// clock for position update
	reg [8:0] computer_score, player_score;

	binary_to_segment b2s(
		.player_score(player_score),
		.cpu_score(computer_score),
		.clk(clk), 
		.seven_output(seven_output),
		.AN(AN)
		);
	initial begin					// initial position of stuff	
		ball_x = 300; 
		ball_y = 200;
		player_y = 180;
		computer_y = 180;
		ball_x_speed = 10;
		ball_y_speed = 10;
	
		ball_width = 10;
		player_width = 20;
		player_height = 120;
		computer_width = 20;
		computer_height = 120;
		player_speed = 8;
		computer_speed = 8;
		
		computer_score = 0;
		player_score = 0;
		
	end	

	////////////////////////////////////////////	
	// slow clock for position update - optional
	reg [22:0] slow_count;	
	always @ (posedge clk)begin
		slow_count = slow_count + 1'b1;	
		slow_clk = slow_count[21];
	end	
	/////////////////////////////////////////
	
	
	/////////////////////////////////////////////////////
	// Slow Clock for vga controller
	parameter N = 2;	// parameter for clock division
	reg clk_25Mhz;
	reg [N-1:0] count;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
	end
	/////////////////////////////////////////////////////

	///////////////////////////////////////////
	// State Machine	
	always @ (posedge slow_clk)begin
		state = next_state;
	end

	always @ (posedge slow_clk) begin
		//state machine for player paddle
		case (state)
			S_IDLE: next_state = {right,left,down,up}; // if input is 0000
			S_UP: begin	// if input is 0001
				if (player_y - player_speed > 0 )
				begin
					player_y = player_y - player_speed;	
				end
				next_state = {right,left,down,up};
			end	
			S_DOWN: begin // if input is 0010
				if (player_y + player_speed + player_height < 480 )
				begin
					player_y = player_y + player_speed;	
				end
				next_state = {right,left,down,up};
			end
			/*S_LEFT: begin // if input is 0100
				if (computer_y + computer_speed + computer_height < 480 )
				begin
					computer_y = computer_y + computer_speed;	
				end
			next_state = {right,left,down,up};
			end*/
			/*S_RIGHT: begin //if input is 1000
				if (computer_y - computer_speed > 0 )
				begin
					computer_y = computer_y - computer_speed;	
				end
			next_state = {right,left,down,up};
			end*/
		endcase
		if(ball_x_speed > 0) begin
			if((ball_y - 60 > computer_y) && (computer_y + computer_speed + computer_height) < 480 ) computer_y = computer_y + computer_speed;
			else if((ball_y - 60 < computer_y) && (computer_y - computer_speed > 0 )) computer_y = computer_y - computer_speed;
		end
		else
			if((computer_y - 60) > 250) computer_y = computer_y - computer_speed;
			else if((computer_y - 60) < 230) computer_y = computer_y + computer_speed;
	end
	
	always @ (posedge slow_clk) begin		
		//ball movement
		
		//bounce off top
		if(ball_y + ball_y_speed < 20 || ball_y + ball_y_speed > 460)
		begin
			ball_y_speed = -1 * ball_y_speed;
		end
		
		
		//no paddle collision
		//computer score -> reset
		if(ball_x + ball_x_speed < 20) 
		begin
			ball_x = 300; 
			ball_y = 200;
			ball_x_speed = -1 * ball_x_speed;
			computer_score  = computer_score + 1;
			if(computer_score == 8) begin
				computer_score = 0;
				player_score = 0;
			end
		end
		//player score -> reset
		else if(ball_x + ball_x_speed + ball_width > 620)
		begin
			ball_x = 300; 
			ball_y = 200;
			ball_x_speed = -1 * ball_x_speed;
			player_score = player_score + 1;
			if(player_score == 8) begin
				computer_score = 0;
				player_score = 0;
			end
		end
		else if(ball_x + ball_x_speed < 60 & ball_x + ball_x_speed > 20 & ball_y + ball_y_speed < player_y + player_height & ball_y + ball_y_speed + ball_width > player_y)
		begin
			ball_x_speed = -1 * ball_x_speed;
		end
		else if(ball_x + ball_x_speed + ball_width > 580 & ball_x + ball_x_speed + ball_width < 600 & ball_y + ball_y_speed < computer_y + computer_height & ball_y + ball_y_speed + ball_width > computer_y)
		begin
			ball_x_speed = -1 * ball_x_speed;
		end

		ball_x = ball_x + ball_x_speed;
		ball_y = ball_y + ball_y_speed;
		
	end
	
	// Call driver
	vga_controller_640_60 vc(
		.rst(rst), 
		.pixel_clk(clk_25Mhz), 
		.HS(HS), 
		.VS(VS), 
		.hcounter(hcount), 
		.vcounter(vcount), 
		.blank(blank));
	
	// create a ball:
	assign ball = ~blank & (hcount >= ball_x & hcount <= ball_x + ball_width & vcount >= ball_y & vcount <= ball_y + ball_width);
	
	//create a player paddle:
	assign player = ~blank & (hcount >= 40 & hcount <= player_width + 40 & vcount >= player_y & vcount <= player_y + player_height);
	
	//create computer paddle:
	assign computer = ~blank & (hcount >= 580 & hcount <= 600 & vcount >= computer_y & vcount <= computer_y + computer_height);
	
	//create outer border
	assign border = ~blank & (hcount <= 20 || hcount >= 620 || vcount >= 460 || vcount <= 20);
	
	assign endgame = (player_score > 5 || computer_score > 5);
	
	// send colors:
	always @ (posedge clk) begin
		if(endgame)begin
			R = 0;
			G = 0;
			B = 0;
		end
		else if (ball || player || computer || border) begin	// make colors appear
			R = R_control;
			G = G_control;
			B = B_control;
		end
		else begin	// if you are outside the valid region
			R = 0;
			G = 0;
			B = 0;
		end
	end
	
//	vga_bsprite sprites_mem(
//		.x0(0+100), 
//		.y0(0+100),
//		.x1(343+100),
//		.y1(47+100),
//		.hc(hcount), 
//		.vc(vcount), 
//		.mem_value(douta), 
//		.rom_addr(addra), 
//		.R(R2), 
//		.G(G2), 
//		.B(B2), 
//		.blank(blank)
//	);
//	
//	game_over mem_1(
//		.clka(clk_25Mhz), // input clka
//		.addra(addra), // input [14 : 0] addra
//		.douta(douta) // output [7 : 0] douta
//	);

endmodule
