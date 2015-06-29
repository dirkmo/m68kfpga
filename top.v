`timescale 1ns / 1ps


module top(
    input clk,
	 input reset_n,
	 output tx,
	 input rx
    );

	wire rw;
	wire master_ack;

	wire [15:0] master_write;
	wire [15:0] master_read;
	wire [31:0] master_addr;
	wire uds_n;
	wire lds_n;
	wire [2:0] ipl_n = 3'b111;

	TG68 cpu (
    .clk(clk), 
    .reset( reset_n ), 
    .clkena_in(1'b1), 
    .data_in(master_read), 
    .IPL( ipl_n[2:0] ), 
    .dtack( ~master_ack ), 
    .addr(master_addr), 
    .data_out(master_write), 
    .as(), 
    .uds(uds_n), 
    .lds(lds_n), 
    .rw(rw), 
    .drive_data()
    );

	wire [15:0] mem_write;
	wire [15:0] mem_read;
	wire [23:0] mem_addr;
	wire [1:0] mem_ds;
	
	boot_device mem (
    .clk(clk), 
    .reset_n(reset_n), 
    .data_write(mem_write), 
    .data_read(mem_read), 
    .addr(mem_addr), 
    .ds(mem_ds), 
    .rw(rw), 
    .ack(mem_ack),
	 .bootmode(bootmode)
    );

	wire [15:0] uart1_write;
	wire [15:0] uart1_read;
	wire [7:0] uart1_addr;
	
	uart uart1 (
    .clk(clk), 
    .reset_n(reset_n), 
    .rx(rx), 
    .tx(tx), 
    .data_write(uart1_write), 
    .data_read(uart1_read), 
    .addr(uart1_addr), 
    .ds(uart1_ds), 
    .rw(rw), 
    .ack(uart1_ack), 
    .tx_active(uart1_tx_active), 
    .rx_avail(uart1_rx_avail), 
    .rx_avail_clear_i(1'b0)
    );

	
	device_mux mux (
    .clk(clk), 
    .reset_n(reset_n), 
    
	 .master_write(master_write), 
    .master_read(master_read), 
    .master_addr(master_addr), 
    .master_ds( { ~uds_n, ~lds_n } ), 
    .master_ack( master_ack ), 
	 
    .slave1_read(mem_read), 
    .slave1_write(mem_write), 
    .slave1_addr(mem_addr), 
    .slave1_ds(mem_ds), 
    .slave1_ack(mem_ack), 

    .slave2_read(uart1_read), 
    .slave2_write(uart1_write), 
    .slave2_addr(uart1_addr), 
    .slave2_ds(uart1_ds), 
    .slave2_ack(uart1_ack)
    );



endmodule
