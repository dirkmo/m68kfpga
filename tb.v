`timescale 1ns / 1ps


module tb;

	// Inputs
	reg clk;
	reg reset_n;
	reg rx;

	// Outputs
	wire tx;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk(clk), 
		.reset_n(reset_n), 
		.tx(tx), 
		.rx(rx)
	);

	always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		reset_n = 0;
		rx = 0;

		#100;
		reset_n = 1;
		
		#10000;

		$finish;
	end
      
endmodule

