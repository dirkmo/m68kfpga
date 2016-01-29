`timescale 1ns / 1ns

module leds_dev(
		input clk,
		input reset_n,
		
		input [15:0] data_write,
		output reg [15:0] data_read,
		input [7:0] addr,
		input uds,
		input lds,
		input rw,
		output reg ack,

		output reg [7:0] leds
    );

	always @(posedge clk) begin
		data_read[15:0] = 16'h0;
		ack = 1'b0;

		if( ~reset_n ) begin
			leds = 8'd0;
		end else
		if( rw ) begin // read from leds reg
			if( addr[7:1] == 7'd0 ) begin
				if( uds ) begin // addr 0
					data_read[15:8] = leds[7:0];
					ack = 1'b1;
				end
				if( lds ) begin // addr 1
					data_read[7:0] = 8'd0;
					ack = 1'b1;
				end
			end
		end else begin // write to leds reg
			if( addr[7:1] == 7'd0 ) begin
				if( uds ) begin // addr 0
					leds[7:0] = data_write[15:8];
					ack = 1'b1;
				end
				if( lds ) begin // addr 1
					ack = 1'b1;
				end
			end // if( addr[7:0] == 8'd0 )
		end // write to leds reg
	end

endmodule
