`timescale 1ns / 1ps

module intctrl(
		input clk,
		input reset_n,
		
		input [15:0] data_write,
		output reg [15:0] data_read,
		input [7:0] addr,
		input uds,
		input lds,
		input rw,
		output reg ack,
		input as,
		input cpu_int,
		
		output [2:0] ipl_n,
		
		input [1:0] interrupts
);

/*	Register map
	
	0: intctrl ctrl reg RW
		- bit 0: interrupts enabled (1) / disabled (0)
	4: interrupt enables RW
		- bit 0: enable interrupt 0
		- bit 1: enable interrupt 1
		- bit 2: ...
	8: interrupt status RW
		- bit 0: interrupt 0 status (0: no int, 1: int)
		...
	
*/

wire signal_int; // signal interrupt to cpu. for setting data_read[] and ack.

reg [7:0] int_en; // interrupts enable
reg global_int_enable; // all interrupts on/off
reg [7:0] int_status;

wire [7:0] int_masked = int_en & int_status;

wire int_active = (int_masked != 0);

always @(posedge clk) begin
	ack <= 1'b0;
	data_read[15:0] <= 0;
	if( ~reset_n ) begin
		int_en <= 0;
		global_int_enable <= 0;
	end else
	if( rw ) begin // read from intctrl -->
		// 0..3 intctrl ctrl reg
		if( addr[7:1] == 7'd0 ) begin
			ack <= 1'b1;
			if( uds ) begin // 0: byte 3 (MSB)
			end
			if( lds ) begin // 1: byte 2
			end
		end else
		if( addr[7:1] == 7'd1 ) begin
			ack <= 1'b1;
			if( uds ) begin // 2: byte 1
			end
			if( lds ) begin // 3: byte 0 (LSB)
				data_read[7:0] <= { 6'd0, global_int_enable };
			end
		end else
		// 4..7 interrupt enables
		if( addr[7:1] == 7'd2 ) begin
			ack <= 1'b1;
			if( uds ) begin // 4: byte 3 (MSB)
				//data_read[15:8] <= int_en[31:24];
			end
			if( lds ) begin // 5: byte 2
				//data_read[7:0] <= int_en[23:16];
			end
		end else
		if( addr[7:1] == 7'd3 ) begin
			ack <= 1'b1;
			if( uds ) begin // 6: byte 1
				//data_read[15:8] <= int_en[15:8];
			end
			if( lds ) begin // 7: byte 0 (LSB)
				data_read[7:0] <= int_en[7:0];
			end
		end else
		// 8..11 interrupt status
		if( addr[7:1] == 7'd4 ) begin
			ack <= 1'b1;
			if( uds ) begin // 8: byte 3 (MSB)
				//data_read[15:8] <= int_status[31:24];
			end
			if( lds ) begin // 9: byte 2
				//data_read[7:0] <= int_status[23:16];
			end
		end else
		if( addr[7:1] == 7'd5 ) begin
			ack <= 1'b1;
			if( uds ) begin // 10: byte 1
				//data_read[15:8] <= int_status[15:8];
			end
			if( lds ) begin // 11: byte 0 (LSB)
				data_read[7:0] <= int_status[7:0];
			end
		end
	end else begin // write to intctrl -->
		// 0..3 intctrl ctrl reg
		if( addr[7:1] == 7'd0 ) begin
			ack <= 1'b1;
			if( uds ) begin // 0: byte 0 (MSB)
			end
			if( lds ) begin // 1: byte 1
			end
		end else
		if( addr[7:1] == 7'd1 ) begin
			ack <= 1'b1;
			if( uds ) begin // 2: byte 2
			end
			if( lds ) begin // 3: byte 3 (LSB)
				global_int_enable <= data_write[0];
			end
		end else
		// 4..7 interrupt enables
		if( addr[7:1] == 7'd2 ) begin
			ack <= 1;
			if( uds ) begin // 0: byte 0 (MSB)
				//int_en[31:24] <= data_write[15:8];
			end
			if( lds ) begin // 1: byte 1
				//int_en[23:16] <= data_write[7:0];
			end
		end else
		if( addr[7:1] == 7'd3 ) begin
			ack <= 1'b1;
			if( uds ) begin // 2: byte 2
				//int_en[15:8] <= data_write[15:8];
			end
			if( lds ) begin // 3: byte 3 (LSB)
				int_en[7:0] <= data_write[7:0];
			end
		end else
		// 8..11 interrupt status
		if( addr[7:1] == 7'd4 ) begin
			ack <= 1'b1;
			// int_status is written in a seperate always block
		end else
		if( addr[7:1] == 7'd5 ) begin
			ack <= 1'b1;
			// int_status is written in a seperate always block
		end
	end
end

always @(posedge clk) begin : int_status_handling
	if( ~reset_n ) begin
		int_status <= 0;
	end else // interrupt registration
	if( global_int_enable && (interrupts != 0) ) begin
		int_status[interrupts] <= int_en[interrupts];
	end else // int_status write
	if( ~rw ) begin // write to interrupt status
		// 8..11 interrupt status
		if( addr[7:1] == 7'd4 ) begin
			if( uds ) begin // 8: byte 3 (MSB)
				//int_status[31:24] <= data_write[15:8];
			end
			if( lds ) begin // 9: byte 2
				//int_status[23:16] <= data_write[7:0];
			end
			// ack generation in different always block
		end else
		if( addr[7:1] == 7'd5 ) begin
			if( uds ) begin // 10: byte 1
				//int_status[15:8] <= data_write[15:8];
			end
			if( lds ) begin // 11: byte 0 (LSB)
				int_status[7:0] <= data_write[7:0];
			end
			// ack generation in different always block
		end
	end
end

// interrupt priority level generation. Lower interrupt indicies are signaled first.
// ipl_n == 6: Auto Int 1 Vector at addr 0x64
// ipl_n == 5: Auto Int 2 Vector at addr 0x68
// ipl_n == 4: Auto Int 3 Vector at addr 0x6C
// ipl_n == 3: Auto Int 4 Vector at addr 0x70
// ipl_n == 2: Auto Int 5 Vector at addr 0x74
// ipl_n == 1: Auto Int 6 Vector at addr 0x78
// ipl_n == 0: Auto Int 7 Vector at addr 0x7C NMI

assign ipl_n[2:0] =	global_int_enable ?
								int_status[0] ? 3'd6 :
								int_status[1] ? 3'd6 :
								3'b111
							: 3'b111;

endmodule
