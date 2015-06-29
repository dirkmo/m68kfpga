`timescale 1ns / 1ps

module boot_device(
		input clk,
		input reset_n,
		
		input [15:0] data_write,
		output [15:0] data_read,
		input [23:0] addr,
		input [1:0] ds,
		input rw,
		output ack,
		
		output reg bootmode
    );

	wire [15:0] mem_write;
	wire [15:0] mem_read;
	wire [23:0] mem_addr;
	wire [1:0] mem_ds = bootmode ? 2'b11 : ds[1:0];
	wire mem_ack;
	
	reg [15:0] boot_read;
	
	memory mem (
    .clk(clk),
    .reset_n(reset_n),
    .data_write(mem_write),
    .data_read(mem_read),
    .addr(addr),
    .ds(mem_ds),
    .rw(rw),
    .ack(mem_ack)
    );
	 
	assign data_read[7:0] =
		bootmode ? boot_read[7:0] : mem_read[7:0];

	assign data_read[15:8] =
		bootmode ? boot_read[15:8] : mem_read[15:8];

	assign ack = bootmode ? (ds[0]||ds[1]) : mem_ack;


	wire bootmode_end_cmd = (addr[23:0] == 'd0) && (ds[1:0] == 2'b11) && (data_write[15:0] == 16'hA9A9);
	reg bootmode_done;

	always @(posedge clk) begin
		bootmode_done <= bootmode_done;
		if( ~reset_n ) begin
			bootmode_done <= 0;
		end else
		if(bootmode_end_cmd) begin
			bootmode_done <= 1;
		end
	end
	
	reg [1:0] ds_r;
	wire ds_ne = (ds_r[1:0] == 2'b11) && (ds[1:0] == 2'b00);
	always @(posedge clk) ds_r[1:0] <= ds[1:0];

	always @(posedge clk) begin
		bootmode <= bootmode;
		if( ~reset_n ) begin
			bootmode <= 1'b1;
		end else begin
			if(bootmode_done && ds_ne) begin
				bootmode <= 1'b0;
			end
		end
	end

	always @(posedge clk) begin
		boot_read[15:0] = 16'h0000;
		if( bootmode ) begin
			case( addr[23:0] )
				24'h000000: boot_read[15:0] = 16'h0000;
				24'h000002: boot_read[15:0] = 16'h0400;
				24'h000004: boot_read[15:0] = 16'h0000;
				24'h000006: boot_read[15:0] = 16'h0008;
				24'h000008: boot_read[15:0] = 16'h323C;
				24'h00000A: boot_read[15:0] = 16'hA9A9;
				24'h00000C: boot_read[15:0] = 16'h303C;
				24'h00000E: boot_read[15:0] = 16'h0000;
				24'h000010: boot_read[15:0] = 16'h31C0;
				24'h000012: boot_read[15:0] = 16'h0000;
				24'h000014: boot_read[15:0] = 16'h31C1;
				24'h000016: boot_read[15:0] = 16'h0000;
				24'h000018: boot_read[15:0] = 16'h31C0;
				24'h00001A: boot_read[15:0] = 16'h0000;
			endcase
		end else begin
		end
	end



endmodule
