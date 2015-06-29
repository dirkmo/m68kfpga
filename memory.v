`timescale 1ns / 1ps

module memory(
		input clk,
		input reset_n,
		
		input [15:0] data_write,
		output [15:0] data_read,
		input [23:0] addr,
		input [1:0] ds,
		input rw,
		output reg ack

    );

	reg [15:0] mem[8191:0];
	
	assign data_read = mem[addr];

	integer i;
	always @(posedge clk) begin
		ack = 1'b0;
		if( ~reset_n ) begin
			for( i = 0; i < 8192; i = i+1 ) begin
				mem[i] <= 16'd0;
			end
		end else if( rw == 0 ) begin
			if( ds[0] == 0 ) begin
				mem[ addr ][7:0] <= data_write[7:0];
			end
			if( ds[1] == 0 ) begin
				mem[ addr ][15:8] <= data_write[15:8];
			end
			if( ds[1:0] != 2'b11 ) ack = 1'b1;
		end else if ( rw == 1 ) begin
			ack = 1'b1;
		end
	end


endmodule
