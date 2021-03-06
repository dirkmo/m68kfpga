`timescale 1ns / 1ps


module system(
	input clk,
	input reset_n,
	
	// UART
	output tx,
	input rx,
	
	// LEDs
	output [7:0] leds,
	
	// SRAM Signale
	output [17:0] ram_addr,
	input  [31:0] ram_data_read,
	output [31:0] ram_data_write,
	output ram_data_is_output,
	output [1:0] ram_ce_n,
	output [1:0] ram_ub_n,
	output [1:0] ram_lb_n,
	output [1:0] ram_we_n,
	output [1:0] ram_oe_n,
	
	// SPI
	input spi_miso,
	output spi_mosi,
	output spi_clk,
	output [2:0] spi_cs_n,
	
	input boot_sel
);

	wire rw;
	wire master_ack;

	wire [15:0] master_write;
	wire [15:0] master_read;
	wire [31:0] master_addr;
	wire uds_n;
	wire lds_n;
	wire [2:0] ipl_n;
	wire as_n;
	reg boot_sel_r;
	
	always@(posedge clk) begin
		if(~reset_n) begin
			boot_sel_r <= boot_sel;
		end
	end

	TG68 cpu (
    .clk(clk), 
    .reset( reset_n ), 
    .clkena_in(1'b1), 
    .data_in(master_read), 
    .IPL( ipl_n[2:0] ), 
    .dtack( ~master_ack ), 
    .addr(master_addr), 
    .data_out(master_write), 
    .as(as_n), 
    .uds(uds_n), 
    .lds(lds_n), 
    .rw(rw), 
    .drive_data()
    );

	// n_uds = 0 --> Byte auf gerade Adresse, data[15:8]
	// n_lds = 0 --> Byte auf ungerader Adresse, data[7:0]

	wire [15:0] mem_write;
	wire [15:0] mem_read;
	wire [23:0] mem_addr;
	wire mem_uds, mem_lds;
	
	boot_device mem (
    .clk(clk), 
    .reset_n(reset_n), 
    .data_write(mem_write), 
    .data_read(mem_read), 
    .addr(mem_addr), 
    .uds(mem_uds), 
	 .lds(mem_lds),
    .rw(rw), 
    .ack(mem_ack),
	 .bootmode(bootmode),
	 .boot_sel(boot_sel_r),
	 
	// SRAM Signale
	 .ram_addr( ram_addr[17:0] ),
	 .ram_data_read( ram_data_read[31:0] ),
	 .ram_data_write( ram_data_write[31:0] ),
	 .ram_data_is_output( ram_data_is_output ),
	 .ram_ce_n( ram_ce_n[1:0] ),
	 .ram_ub_n( ram_ub_n[1:0] ),
	 .ram_lb_n( ram_lb_n[1:0] ),
	 .ram_we_n( ram_we_n[1:0] ),
	 .ram_oe_n( ram_oe_n[1:0] )
    );

	wire [15:0] uart1_write;
	wire [15:0] uart1_read;
	wire [7:0] uart1_addr;
	wire uart1_uds, uart1_lds;
	wire [1:0] uart_interrupt;
	
	uart #(.SYS_CLK('d12_500_000),.BAUDRATE('d115200)) uart1
	(
    .clk(clk), 
    .reset_n(reset_n), 
    .rx(rx), 
    .tx(tx), 
    .data_write(uart1_write), 
    .data_read(uart1_read), 
    .addr(uart1_addr), 
    .uds(uart1_uds), 
	 .lds(uart1_lds), 
    .rw(rw), 
    .ack(uart1_ack), 
    .tx_active(uart1_tx_active), 
    .rx_avail_clear_i(1'b0),
	 .interrupt(uart_interrupt[1:0])
    );

	wire [15:0] leds_write;
	wire [15:0] leds_read;
	wire [7:0] leds_addr;
	wire leds_uds, leds_lds;
	
	leds_dev leds1(
	 .clk(clk), 
    .reset_n(reset_n), 
    .data_write(leds_write), 
    .data_read(leds_read), 
    .addr(leds_addr), 
    .uds(leds_uds), 
	 .lds(leds_lds), 
    .rw(rw), 
    .ack(leds_ack),
	 .leds(leds)
	 );
	
	wire [15:0] spi_write;
	wire [15:0] spi_read;
	wire [7:0] spi_addr;
	wire spi_uds, spi_lds;
	
	spi spi1 (
    .clk(clk), 
    .reset_n(reset_n), 
    .data_write(spi_write), 
    .data_read(spi_read), 
    .addr(spi_addr), 
    .uds(spi_uds), 
    .lds(spi_lds), 
    .rw(rw), 
    .ack(spi_ack), 
    .spi_mosi(spi_mosi), 
    .spi_clk(spi_clk), 
    .spi_miso(spi_miso), 
    .spi_cs_n(spi_cs_n),
    .spi_active(spi_active)
    );

	wire [15:0] timer_write;
	wire [15:0] timer_read;
	wire [7:0] timer_addr;
	wire timer_uds, timer_lds;
	wire timer_interrupt;
	
	timer timer1 (
		.clk(clk),
		.reset_n(reset_n),
		.data_write(timer_write),
		.data_read(timer_read),
		.addr(timer_addr),
		.uds(timer_uds),
		.lds(timer_lds),
		.rw(rw),
		.ack(timer_ack),
		.interrupt(timer_interrupt)
	);
	
	wire [1:0] interrupts = { uart_interrupt[1:0], timer_interrupt };
	wire [15:0] intctrl_write;
	wire [15:0] intctrl_read;
	wire [7:0] intctrl_addr;
	wire intctrl_uds, intctrl_lds;
	
	intctrl intctrl1 (
		.clk(clk), 
		.reset_n(reset_n), 
		.data_write(intctrl_write), 
		.data_read(intctrl_read), 
		.addr(intctrl_addr), 
		.uds(intctrl_uds), 
		.lds(intctrl_lds), 
		.rw(rw), 
		.ack(intctrl_ack), 
		.as(~as_n),
		.ipl_n(ipl_n), 
		.interrupts( interrupts )
    );
	
	device_mux mux (
    .clk(clk), 
    .reset_n(reset_n),
	 .as(~as_n),
    
	 .master_write(master_write), 
    .master_read(master_read), 
    .master_addr(master_addr), 
    .master_uds( ~uds_n ), 
	 .master_lds( ~lds_n ), 
    .master_ack( master_ack ), 
	 
    .slave1_read(mem_read), 
    .slave1_write(mem_write), 
    .slave1_addr(mem_addr), 
    .slave1_uds(mem_uds), 
	 .slave1_lds(mem_lds),
    .slave1_ack(mem_ack), 

    .slave2_read(uart1_read), 
    .slave2_write(uart1_write), 
    .slave2_addr(uart1_addr), 
    .slave2_uds(uart1_uds), 
	 .slave2_lds(uart1_lds), 
    .slave2_ack(uart1_ack),
	 
    .slave3_read(leds_read), 
    .slave3_write(leds_write), 
    .slave3_addr(leds_addr), 
    .slave3_uds(leds_uds), 
	 .slave3_lds(leds_lds), 
    .slave3_ack(leds_ack),

    .slave4_read(spi_read), 
    .slave4_write(spi_write), 
    .slave4_addr(spi_addr), 
    .slave4_uds(spi_uds), 
	 .slave4_lds(spi_lds), 
    .slave4_ack(spi_ack),
	 
	 .slave5_read(timer_read), 
    .slave5_write(timer_write), 
    .slave5_addr(timer_addr), 
    .slave5_uds(timer_uds), 
	 .slave5_lds(timer_lds), 
    .slave5_ack(timer_ack),

	 .slave6_read(intctrl_read), 
    .slave6_write(intctrl_write), 
    .slave6_addr(intctrl_addr), 
    .slave6_uds(intctrl_uds), 
	 .slave6_lds(intctrl_lds), 
    .slave6_ack(intctrl_ack)
   );


	always @( posedge master_ack ) begin
		if( ~uds_n || ~lds_n ) begin
			if( rw ) begin
				$display( "read $%06x: %04X, %d", master_addr, master_read, $time );
			end else begin
				$display( "writ $%06x: %04X, %d", master_addr, master_write, $time );
			end
		end
	end

endmodule
