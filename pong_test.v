`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:05:41 12/18/2015
// Design Name:   vga_display
// Module Name:   X:/EC311/Pong/pong_test.v
// Project Name:  Pong
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vga_display
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module pong_test;

	// Inputs
	reg rst;
	reg clk;
	reg up;
	reg down;
	reg left;
	reg right;
	reg [2:0] R_control;
	reg [2:0] G_control;
	reg [1:0] B_control;

	// Outputs
	wire [2:0] R;
	wire [2:0] G;
	wire [1:0] B;
	wire [6:0] seven_output;
	wire [3:0] AN;
	wire HS;
	wire VS;

	// Instantiate the Unit Under Test (UUT)
	vga_display uut (
		.rst(rst), 
		.clk(clk), 
		.up(up), 
		.down(down), 
		.left(left), 
		.right(right), 
		.R_control(R_control), 
		.G_control(G_control), 
		.B_control(B_control), 
		.R(R), 
		.G(G), 
		.B(B), 
		.seven_output(seven_output), 
		.AN(AN), 
		.HS(HS), 
		.VS(VS)
	);
	integer i = 0;
	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;
		up = 0;
		down = 0;
		left = 0;
		right = 0;
		R_control = 1;
		G_control = 1;
		B_control = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		for(i= 0; i< 2**15; i = i + 1) begin
			#1 clk = clk + 1;
			if(clk % 4 == 0) up = up + 1;
			if(clk % 8 == 0) down = down + 1;
			if(clk % 16 == 0) left = left + 1;
			if(clk % 32 == 0) right = right + 1;
			if(clk % 64 == 0) rst = rst + 1;
		end
	end
      
endmodule

