`timescale 1ns / 1ps

module fifo_tb;

	// Inputs
	reg clk;
	reg reset_n;
	reg [7:0] data_in;
	reg push;
	reg pop;

	// Outputs
	wire [7:0] data_out;
	wire empty;
	wire full;

	// Instantiate the Unit Under Test (UUT)
	fifo uut (
		.clk(clk), 
		.reset_n(reset_n), 
		.data_in(data_in), 
		.data_out(data_out), 
		.push(push), 
		.pop(pop), 
		.empty(empty), 
		.full(full)
	);

	always #10 clk = ~clk;
	
	integer benchpos;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset_n = 0;
		data_in = 0;
		push = 0;
		pop = 0;
		#100;
		reset_n = 1;

		if( ~uut.empty ) $stop;
		
		benchpos = 0;
		pop = 1; #20; pop = 0; #20;
		
		if( ~uut.empty ) $stop;
		#100;
		
		benchpos = 1;
		data_in = 0;
		push = 1; #100; push = 0; #20;

		if( uut.empty || uut.full ) $stop;
		
		#100;
		
		benchpos = 2;
		data_in = 1;
		push = 1; #20; push = 0; #20;
		if( uut.empty || uut.full ) $stop;
		
		#100;
		
		benchpos = 3;
		data_in = 2;
		push = 1; #20; push = 0; #20;
		if( uut.empty || uut.full ) $stop;
		#100;
		
		benchpos = 4;
		data_in = 3;
		push = 1; #20; push = 0; #20;
		if( uut.empty || ~uut.full ) $stop;
		#100;
		
		benchpos = 5;
		data_in = 1;
		push = 1; #20; push = 0; #20;
		if( uut.empty || ~uut.full ) $stop;
		
		if( uut.data_out != 0 ) $stop;
		pop = 1; #20; pop = 0; #20;
		if( uut.data_out != 1 ) $stop;
		if( uut.empty ) $stop;
		if( uut.full ) $stop;
		
		pop = 1; #20; pop = 0; #20;
		if( uut.data_out != 2 ) $stop;
		if( uut.empty ) $stop;
		if( uut.full ) $stop;

		pop = 1; #20; pop = 0; #20;
		if( uut.data_out != 3 ) $stop;
		if( uut.empty ) $stop;
		if( uut.full ) $stop;

		pop = 1; #20; pop = 0; #20;
		if( ~uut.empty ) $stop;
		if( uut.full ) $stop;

		
		$finish;

	end
      
endmodule

