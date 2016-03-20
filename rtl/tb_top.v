`timescale 1ns / 1ps

module tb_top;

	// Inputs
	reg fpga_clk;
	reg reset;
	reg spi_miso;

	// Outputs
	wire uart_tx;
	wire uart_rx;
	wire [7:0] leds;
	wire [17:0] ram_addr;
	wire [1:0] ram_ce_n;
	wire [1:0] ram_ub_n;
	wire [1:0] ram_lb_n;
	wire ram_we_n;
	wire ram_oe_n;
	wire spi_mosi;
	wire spi_clk;
	wire [2:0] spi_cs_n;

	// Bidirs
	wire [31:0] ram_data;

	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk_50mhz(fpga_clk), 
		.reset(reset), 
		.uart_tx(uart_tx), 
		.uart_rx(uart_rx), 
		.leds(leds), 
		.ram_addr(ram_addr), 
		.ram_data(ram_data), 
		.ram_ce_n(ram_ce_n), 
		.ram_ub_n(ram_ub_n), 
		.ram_lb_n(ram_lb_n), 
		.ram_we_n(ram_we_n), 
		.ram_oe_n(ram_oe_n),
		.spi_miso(spi_miso),
		.spi_mosi(spi_mosi),
		.spi_clk(spi_clk),
		.spi_cs_n(spi_cs_n),
		.boot_sel(0)
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
		.data_write(ram_data[15:0]), 
		.data_read(ram_data_read[15:0]), 
		.addr(ram_addr), 
		.uds(~ram_ub_n[0]), 
		.lds(~ram_lb_n[0]), 
		.rw(ram_we_n)
   );

	reg rx_avail_clear;
	reg [15:0] uart_tx_reg;
	reg uart_uds_reg;
	reg uart_lds_reg;
	reg uart_rw;
	wire uart_tx_active;
	reg uart_clk;
	
	uart #(.SYS_CLK('d12_500_000),.BAUDRATE('d115200)) tbuart (
    .clk(uut.computer.clk), 
    .reset_n(~reset), 
    .rx(uart_tx), 
    .tx(uart_rx), 
	 .addr(3),
	 .rw(uart_rw),
	 .uds(uart_uds_reg),
	 .lds(uart_lds_reg),
	 .tx_active(uart_tx_active),
    .rx_avail_clear_i(rx_avail_clear),
	 .data_write(uart_tx_reg[15:0])
    );

	always #10 fpga_clk = ~fpga_clk;

	
	integer clockcount;
	integer resetzeit;
	initial begin
		clockcount = 0;
		resetzeit = 0;
		while( clockcount < 20 ) begin
			@(posedge uut.computer.clk) clockcount = clockcount + 1;
		end
		resetzeit = 1;
	end
	
	task uart_putc;
	input [7:0] c;
	begin
		while( uart_tx_active ) #10;
		uart_tx_reg[7:0] = c[7:0];
		uart_rw = 0;
		uart_lds_reg = 1'b1; #10;
		//@(posedge uut.computer.clk); #10;
		@(posedge tbuart.ack) #10;
		uart_lds_reg = 1'b0;
		uart_rw = 1;
	end
	endtask

	
	initial begin
		// Initialize Inputs
		fpga_clk = 0;
		uart_clk = 0;
		reset = 1;
		rx_avail_clear = 1;
		uart_uds_reg = 0;
		uart_lds_reg = 0;
		uart_rw = 1;

		#100
		reset = 0;
		while(uut.computer.reset_n==0)#10;
		
		rx_avail_clear = 0;
		uart_putc(65);
		
		
		#100000;
		$finish;
	end
      
endmodule

