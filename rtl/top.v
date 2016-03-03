`timescale 1ns / 1ps

// top cell for Digilent Spartan 3 Starter Kit

module top(
   input clk_50mhz, 
   input reset, 
   
	output uart_tx, 
   input uart_rx, 
		
	output [7:0] leds,
	 
	output [17:0] ram_addr,
	inout  [31:0] ram_data,
	output [1:0] ram_ce_n,
	output [1:0] ram_ub_n,
	output [1:0] ram_lb_n,
	output ram_we_n,
	output ram_oe_n,
	
	// SPI
	input spi_miso,
	output spi_mosi,
	output spi_clk,
	output [2:0] spi_cs_n,
	
	input boot_sel
	
);

	reg [1:0] counter = 0;
	always @(posedge clk_50mhz) counter <= counter + 1;

	wire clk_25mhz = counter[0];
	wire clk_12_5mhz = counter[1];


	reg [7:0] reset_count = 0;
	wire reset_n = (reset_count == 8'hFF);

	always @(posedge clk_12_5mhz) begin
		if( reset )
			reset_count <= 0;
		else if( reset_n ) begin
		end else begin
			reset_count <= reset_count + 1;
		end
	end

	wire ram_data_is_output;
	wire [31:0] ram_data_write;
	
	assign ram_data[31:0] = ram_data_is_output ? ram_data_write[31:0] : 32'hzzzzzzzz;

	wire [1:0] complex_ram_we_n;
	wire [1:0] complex_ram_oe_n;

	assign ram_we_n = complex_ram_we_n[0] && complex_ram_we_n[1]; // board has a common RAM /WE pin
	assign ram_oe_n = complex_ram_oe_n[0] && complex_ram_oe_n[1]; // board has a common RAM /OE pin

	system computer (
		 .clk(clk_12_5mhz), 
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
		 .ram_oe_n(complex_ram_oe_n),
		 	// SPI
 		 .spi_miso(spi_miso),
		 .spi_mosi(spi_mosi),
		 .spi_clk(spi_clk),
		 .spi_cs_n(spi_cs_n),
		 .boot_sel(boot_sel)
	);

endmodule
