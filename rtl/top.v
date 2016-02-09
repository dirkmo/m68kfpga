`timescale 1ns / 1ps

// top cell for Digilent Spartan 3 Starter Kit

module top(
   input clk_50mhz, 
   input reset, 
   
	output uart_tx, 
   input uart_rx, 
	
	output uart_tx2,
	
	output [7:0] leds,
	 
	output [17:0] ram_addr,
	inout  [31:0] ram_data,
	output [1:0] ram_ce_n,
	output [1:0] ram_ub_n,
	output [1:0] ram_lb_n,
	output ram_we_n,
	output ram_oe_n
	);

	wire reset_n = ~reset;
	
	
	reg [23:0] clk_r;
	always @(posedge clk_50mhz) begin
		clk_r <= clk_r + 1'b1;
	end
	
	initial begin
		clk_r <= 0;
	end
	
	/*
	wire clk = fpga_clk;
	wire clk = clk_r[0]; // 2^1 = 25 MHz
	wire clk = clk_r[1]; // 2^2 = 12,5 MHz
	wire clk = clk_r[2]; // 2^3 = 6,25 MHz
	wire clk = clk_r[3]; // 2^4 = 3,125 MHz
	wire clk = clk_r[4]; // 2^5 = 32 -> 1,5625 MHz
	*/	
	wire clk = clk_r[0]; // 2^1 = 25 MHz
	assign uart_tx2 = uart_tx;
	
	wire ram_data_is_output;
	wire [31:0] ram_data_write;
	
	assign ram_data[31:0] = ram_data_is_output ? ram_data_write[31:0] : 32'hzzzzzzzz;

	wire [1:0] complex_ram_we_n;
	wire [1:0] complex_ram_oe_n;

	assign ram_we_n = complex_ram_we_n[0] && complex_ram_we_n[1]; // board has a common RAM /WE pin
	assign ram_oe_n = complex_ram_oe_n[0] && complex_ram_oe_n[1]; // board has a common RAM /OE pin

	system computer (
		 .clk(clk), 
		 .reset_n(reset_n), 
		 .tx(uart_tx), 
		 .rx(uart_rx), 
		 .leds(leds[7:0]),
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
