`timescale 1ns / 1ps

module tb_top;

	// Inputs
	reg fpga_clk;
	reg reset;
	reg rx;

	// Outputs
	wire tx;
	wire [7:0] leds;
	wire [17:0] ram_addr;
	wire [1:0] ram_ce_n;
	wire [1:0] ram_ub_n;
	wire [1:0] ram_lb_n;
	wire ram_we_n;
	wire ram_oe_n;

	// Bidirs
	wire [31:0] ram_data;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.fpga_clk(fpga_clk), 
		.reset(reset), 
		.tx(tx), 
		.rx(rx), 
		.leds(leds), 
		.ram_addr(ram_addr), 
		.ram_data(ram_data), 
		.ram_ce_n(ram_ce_n), 
		.ram_ub_n(ram_ub_n), 
		.ram_lb_n(ram_lb_n), 
		.ram_we_n(ram_we_n), 
		.ram_oe_n(ram_oe_n)
	);
	
	wire [31:0] ram_data_read;
	assign ram_data[31:0] = ram_oe_n ? 32'dz : ram_data_read[31:0];

	memory mem1 (
		.clk(fpga_clk), 
		.reset_n(~reset), 
		.data_write(ram_data[31:16]), 
		.data_read(ram_data_read[31:16]), 
		.addr(ram_addr), 
		.uds(~ram_ub_n[1]), 
		.lds(~ram_lb_n[1]), 
		.rw(ram_we_n)
   );
	
	memory mem0 (
		.clk(fpga_clk), 
		.reset_n(~reset), 
		.data_write(/*ram_data[15:0]*/), 
		.data_read(ram_data_read[15:0]), 
		.addr(ram_addr), 
		.uds(~ram_ub_n[0]), 
		.lds(~ram_lb_n[0]), 
		.rw(ram_we_n)
   );

	always #5 fpga_clk = ~fpga_clk;

	initial begin
		// Initialize Inputs
		fpga_clk = 0;
		reset = 1;
		rx = 0;

		// Wait 100 ns for global reset to finish
		#1000;
		reset = 0;
		
		#3000;
		$finish;
	end
      
endmodule

