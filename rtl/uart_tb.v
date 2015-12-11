`timescale 1ns / 1ps


module uart_tb;

	// Inputs
	reg clk;
	reg reset_n;
	reg rx;
	reg [7:0] data_write;
	reg [7:0] addr;
	reg ds;
	reg rw;
	reg rx_avail_clear_i;

	// Outputs
	wire tx;
	wire [7:0] data_read;
	wire ack;
	wire tx_active;
	wire rx_avail;

	// Instantiate the Unit Under Test (UUT)
	uart uut (
		.clk(clk), 
		.reset_n(reset_n), 
		.rx(rx), 
		.tx(tx), 
		.data_write(data_write), 
		.data_read(data_read), 
		.addr(addr), 
		.ds(ds), 
		.rw(rw), 
		.ack(ack), 
		.tx_active(tx_active), 
		.rx_avail(rx_avail), 
		.rx_avail_clear_i(rx_avail_clear_i)
	);
	
	always #5 clk = ~clk;
	
	integer data;
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset_n = 0;
		rx = 0;
		data_write = 0;
		addr = 0;
		ds = 0;
		rw = 0;
		rx_avail_clear_i = 0;

		#10;
		reset_n = 1;
		#10;
		
      addr = 0;
		data_write = 65;
		ds = 1;
		while( ack == 0 ) #10;
		ds = 0;
		#100;
		
		rw = 1;
		addr = 1;
		data = 1;
		while( data == 1) begin
			ds = 1;
			while( ack == 0 ) #10;
			data = data_read[1];
			#10;
			ds = 0;
		end 


		$finish;
	end
      
endmodule

