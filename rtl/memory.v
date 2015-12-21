`timescale 1ns / 1ps

module memory
	#(DEPTH=17)
	(
		input clk,
		input reset_n,
		
		input [15:0] data_write,
		output [15:0] data_read,
		input [DEPTH:0] addr,
		input uds, // 15:8, even address
		input lds, // 7:0, odd address
		input rw,
		output reg ack

    );

	// ds[1:0] = (odd byte, even byte) = (lds, uds) = (7:0, 15:8)

	reg [15:0] mem[2**DEPTH-1:0];
	
	wire addr_valid = addr < 2**DEPTH;
	
	wire l_acc = lds && addr_valid;
	wire u_acc = uds && addr_valid;
	
	assign data_read[7:0] = l_acc ? mem[addr][7:0] : 8'dX;
	assign data_read[15:8] = u_acc ? mem[addr][15:8] : 8'dX;
	
	always @( posedge l_acc ) $display("%m: loread %06X: %02X", addr, data_read[7:0] );
	always @( posedge u_acc ) $display("%m: hiread %06X: %02X", addr, data_read[15:8] );

	always @(addr) begin
		if( (lds || uds) && !addr_valid ) $stop; // Bus error!
	end

	
	reg uds_r, lds_r;
	always @(posedge clk) uds_r <= uds;
	always @(posedge clk) lds_r <= lds;
	
	wire uds_pe = (uds_r == 1'b0) && (uds == 1'b1);
	wire lds_pe = (lds_r == 1'b0) && (lds == 1'b1);


	always @(posedge clk) begin
		ack <= 1'b0;
		if( ~reset_n ) begin
		end else if( addr_valid ) begin
			if( rw == 0 ) begin /* write */
				if( lds_pe ) begin
					mem[ addr ][7:0] <= data_write[7:0];
					$display("%m: lowrite %06X: %02X", addr, data_write[7:0] );
				end
				if( uds_pe ) begin
					mem[ addr ][15:8] <= data_write[15:8];
					$display("%m: hiwrite %06X: %02X", addr, data_write[15:8] );
				end
				if( uds_pe || lds_pe ) ack <= 1'b1;
			end else if ( (rw == 1) && (l_acc || u_acc) ) begin /* read ack */
				ack <= 1'b1;
			end
		end
	end


endmodule
