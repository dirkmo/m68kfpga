`timescale 1ns / 1ps


module top(
    input clk,
	 input reset_n,
	 output tx,
	 input rx
    );

	reg cpu_reset_n;
	wire rw;
	wire dtack_n;

	wire [15:0] master_write;
	wire [15:0] master_read;
	wire [31:0] master_addr;
	wire uds_n;
	wire lds_n;
	wire [2:0] ipl_n;

	TG68 cpu (
    .clk(clk), 
    .reset( reset_n ), 
    .clkena_in(1'b1), 
    .data_in(master_read), 
    .IPL( ipl_n[2:0] ), 
    .dtack(dtack && 1'b0), 
    .addr(master_addr), 
    .data_out(master_write), 
    .as(), 
    .uds(uds_n), 
    .lds(lds_n), 
    .rw(rw), 
    .drive_data()
    );

	uart uart1 (
    .clk(clk), 
    .reset_n(reset_n), 
    .rx(rx), 
    .tx(tx), 
    .data_write(uart1_write), 
    .data_read(uart1_read), 
    .addr(uart1_addr), 
    .ds(uart1_ds), 
    .rw(uart1_rw), 
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
    .master_ds( uds_n && lds_n ), 
    .master_ack( dtack_n ), 
	 
    .slave1_read(slave1_read), 
    .slave1_write(slave1_write), 
    .slave1_addr(slave1_addr), 
    .slave1_ds(slave1_ds), 
    .slave1_ack(slave1_ack), 

    .slave2_read(uart1_read), 
    .slave2_write(uart1_write), 
    .slave2_addr(uart1_addr), 
    .slave2_ds(uart1_ds), 
    .slave2_ack(uart1_ack)
    );



endmodule
