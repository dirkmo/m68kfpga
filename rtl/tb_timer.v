`timescale 1ns / 1ps



module tb_timer;

	// Inputs
	reg clk;
	reg reset_n;
	reg [15:0] data_write;
	reg [7:0] addr;
	reg uds;
	reg lds;
	reg rw;

	// Outputs
	wire [15:0] data_read;
	wire ack;
	wire overflow;

	// Instantiate the Unit Under Test (UUT)
	timer uut (
		.clk(clk), 
		.reset_n(reset_n), 
		.data_write(data_write), 
		.data_read(data_read), 
		.addr(addr), 
		.uds(uds), 
		.lds(lds), 
		.rw(rw), 
		.ack(ack), 
		.overflow(overflow)
	);

	always #10 clk=~clk;

	task write;
	input [7:0] addr_in;
	input [15:0] data;
	input lds_in;
	input uds_in;
	begin
		addr = addr_in;
		data_write = { data[7:0], data[15:8] };
		rw = 0;
		uds = uds_in; lds = lds_in; while(ack == 0) #10; uds = 0; lds = 0; rw = 1; while(ack) #10;
	end
	endtask

	initial begin
		// Initialize Inputs
		clk = 0;
		reset_n = 0;
		data_write = 0;
		addr = 0;
		uds = 0;
		lds = 0;
		rw = 1;

		#100;
		reset_n = 1;
      #100;
		
		// timer reg
		write( 0, 16'd0, 1, 1 );
		write( 2, 16'd0, 1, 1 );

		// cmp reg
		write( 4, 16'h0000, 1, 1 );
		write( 6, 16'h0100, 1, 1 );
		
		// ctrl reg
		write( 8, { 8'b0, 2'b00, 5'b00000, 1'b1 }, 0, 1 );
		#1000;

		write( 8, { 8'b0, 2'b00, 5'b00001, 1'b1 }, 0, 1 );
		#1000;

		write( 8, { 8'b0, 2'b00, 5'b00010, 1'b1 }, 0, 1 );
		#1000;


		$finish;
	end
      
endmodule

