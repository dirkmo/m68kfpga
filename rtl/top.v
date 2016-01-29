`timescale 1ns / 1ps

// top cell for Digilent Spartan 3 Starter Kit

module top(
   input fpga_clk, 
   input reset_n, 
   
	output tx, 
   input rx, 
	
	output [7:0] leds,
	 
	output [17:0] ram_addr,
	inout  [31:0] ram_data,
	output [1:0] ram_ce_n,
	output [1:0] ram_ub_n,
	output [1:0] ram_lb_n,
	output ram_we_n,
	output ram_oe_n
	);


	reg [12:0] clk_r;
	always @(posedge fpga_clk) begin
		clk_r <= clk_r + 1'b1;
	end
	
	wire clk = clk_r[12];
	
	wire ram_data_is_output;
	wire ram_data_write;
	
	assign ram_data = ram_data_is_output ? ram_data_write : 32'hzzzzzzzz;

	wire [1:0] complex_ram_we_n;
	wire [1:0] complex_ram_oe_n;

	assign ram_we_n = complex_ram_we_n[0] && complex_ram_we_n[1]; // board has a common RAM /WE pin
	assign ram_oe_n = complex_ram_oe_n[0] && complex_ram_oe_n[1]; // board has a common RAM /OE pin

	system computer (
		 .clk(clk), 
		 .reset_n(reset_n), 
		 .tx(tx), 
		 .rx(rx), 
		 .leds(leds),
		 .ram_addr(ram_addr), 
		 .ram_data_read(ram_data), 
		 .ram_data_write(ram_data_write), 
		 .ram_data_is_output(ram_data_is_output), 
		 .ram_ce_n(ram_ce_n), 
		 .ram_ub_n(ram_ub_n), 
		 .ram_lb_n(ram_lb_n), 
		 .ram_we_n(complex_ram_we_n), 
		 .ram_oe_n(complex_ram_oe_n)
		 );
	 
	 
	
endmodule
