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
		input slave2_ack
    );

reg [3:0] slave_index;

always @(*) begin
	slave_index = 0;
	if( master_uds || master_lds ) begin
		if( master_addr < 32'h100000 ) begin
			slave_index = 1;
		end else
		if( master_addr < 32'h100100 ) begin
			slave_index = 2;
		end
	end
end

assign master_read[15:0] =
	(slave_index == 1 ) ? slave1_read[15:0] :
	(slave_index == 2 ) ? slave2_read[15:0] :
		16'd0;

assign master_ack =
	(slave_index == 1 ) ? slave1_ack :
	(slave_index == 2 ) ? slave2_ack :
		1'd0;

assign slave1_write[15:0] = master_write[15:0];
assign slave2_write[15:0] = master_write[15:0];

assign slave1_addr[23:0] = master_addr[23:0];
assign slave2_addr[7:0]  = master_addr[7:0];

assign slave1_uds = (slave_index == 1 ) ? master_uds : 1'b0;
assign slave1_lds = (slave_index == 1 ) ? master_lds : 1'b0;

assign slave2_uds = (slave_index == 2 ) ? master_uds : 1'b0;
assign slave2_lds = (slave_index == 2 ) ? master_lds : 1'b0;

endmodule