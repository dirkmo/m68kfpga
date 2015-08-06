`timescale 1ns / 1ps

module memory(
		input clk,
		input reset_n,
		
		input [15:0] data_write,
		output [15:0] data_read,
		input [23:0] addr,
		input uds, // 15:8, even address
		input lds, // 7:0, odd address
		input rw,
		output reg ack

    );


	// ds[1:0] = (odd byte, even byte) = (lds, uds) = (7:0, 15:8)

	reg [15:0] mem[8191:0];
	
	wire addr_valid = addr < 'd8192;
	
	assign data_read = mem[addr];
	
	reg uds_r, lds_r;
	always @(posedge clk) uds_r <= uds;
	always @(posedge clk) lds_r <= lds;
	
	wire uds_pe = (uds_r == 1'b0) && (uds == 1'b1);
	wire lds_pe = (lds_r == 1'b0) && (lds == 1'b1);


	always @(posedge clk) begin
		ack <= 1'b0;
		if( ~reset_n ) begin
		end else if( rw == 0 ) begin
			if( lds_pe ) begin
				mem[ addr ][7:0] <= data_write[7:0];
			end
			if( uds_pe ) begin
				mem[ addr ][15:8] <= data_write[15:8];
			end
			if( uds_pe || lds_pe ) ack <= 1'b1;
		end else if ( rw == 1 && addr_valid ) begin
			ack <= 1'b1;
		end
	end


endmodule
