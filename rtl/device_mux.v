`timescale 1ns / 1ps

module device_mux(
		input clk,
		input reset_n,
		
		// Master CPU
		input [15:0] master_write,
		output [15:0] master_read,
		input [31:0] master_addr,
		input master_uds,
		input master_lds,
		output master_ack,
		
		// Slave #1 	RAM 16 MB
		input [15:0] slave1_read,
		output [15:0] slave1_write,
		output [23:0] slave1_addr,
		output slave1_uds,
		output slave1_lds,
		input slave1_ack,

		// Slave #2		UART
		input [15:0] slave2_read,
		output [15:0] slave2_write,
		output [7:0] slave2_addr,
		output slave2_uds,
		output slave2_lds,
		input slave2_ack,
		
		// Slave #3		LEDs
		input [15:0] slave3_read,
		output [15:0] slave3_write,
		output [7:0] slave3_addr,
		output slave3_uds,
		output slave3_lds,
		input slave3_ack,
		
		// Slave #4		SPI
		input [15:0] slave4_read,
		output [15:0] slave4_write,
		output [7:0] slave4_addr,
		output slave4_uds,
		output slave4_lds,
		input slave4_ack,
		
		// Slave #5		Timer
		input [15:0] slave5_read,
		output [15:0] slave5_write,
		output [7:0] slave5_addr,
		output slave5_uds,
		output slave5_lds,
		input slave5_ack
		
    );

reg [3:0] slave_index;

always @(*) begin
	slave_index = 0;
	if( master_uds || master_lds ) begin
		// 0x000000 .. 0x0FFFFF Slave #1
		if( master_addr < 32'h100000 ) begin
			slave_index = 1;
		end else
		// 0x100000 .. 0x1000FF Slave #2
		if( master_addr < 32'h100100 ) begin
			slave_index = 2;
		end else
		// 0x100100 .. 0x1001FF Slave #3
		if( master_addr < 32'h100200 ) begin
			slave_index = 3;
		end else
		// 0x100200 .. 0x1002FF Slave #4
		if( master_addr < 32'h100300 ) begin
			slave_index = 4;
		end else
		// 0x100300 .. 0x1003FF Slave #5
		if( master_addr < 32'h100400 ) begin
			slave_index = 5;
		end
	end
end

assign master_read[15:0] =
	(slave_index == 1 ) ? slave1_read[15:0] :
	(slave_index == 2 ) ? slave2_read[15:0] :
	(slave_index == 3 ) ? slave3_read[15:0] :
	(slave_index == 4 ) ? slave4_read[15:0] :
	(slave_index == 5 ) ? slave5_read[15:0] :
		16'd0;

assign master_ack =
	(slave_index == 1 ) ? slave1_ack :
	(slave_index == 2 ) ? slave2_ack :
	(slave_index == 3 ) ? slave3_ack :
	(slave_index == 4 ) ? slave4_ack :
	(slave_index == 5 ) ? slave5_ack :
		1'd0;

assign slave1_write[15:0] = master_write[15:0];
assign slave2_write[15:0] = master_write[15:0];
assign slave3_write[15:0] = master_write[15:0];
assign slave4_write[15:0] = master_write[15:0];
assign slave5_write[15:0] = master_write[15:0];

assign slave1_addr[23:0] = master_addr[23:0];
assign slave2_addr[7:0]  = master_addr[7:0];
assign slave3_addr[7:0]  = master_addr[7:0];
assign slave4_addr[7:0]  = master_addr[7:0];
assign slave5_addr[7:0]  = master_addr[7:0];

assign slave1_uds = (slave_index == 1 ) ? master_uds : 1'b0;
assign slave1_lds = (slave_index == 1 ) ? master_lds : 1'b0;

assign slave2_uds = (slave_index == 2 ) ? master_uds : 1'b0;
assign slave2_lds = (slave_index == 2 ) ? master_lds : 1'b0;

assign slave3_uds = (slave_index == 3 ) ? master_uds : 1'b0;
assign slave3_lds = (slave_index == 3 ) ? master_lds : 1'b0;

assign slave4_uds = (slave_index == 4 ) ? master_uds : 1'b0;
assign slave4_lds = (slave_index == 4 ) ? master_lds : 1'b0;

assign slave5_uds = (slave_index == 5 ) ? master_uds : 1'b0;
assign slave5_lds = (slave_index == 5 ) ? master_lds : 1'b0;

endmodule
