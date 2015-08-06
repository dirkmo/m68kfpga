`timescale 1ns / 1ps

module boot_device(
		input clk,
		input reset_n,
		
		input [15:0] data_write,
		output [15:0] data_read,
		input [23:0] addr,
		input uds,
		input lds,
		input rw,
		output ack,
		
		output reg bootmode
    );

	wire [15:0] mem_read;
	wire [23:0] mem_addr;
	wire mem_ack;
	
	reg [15:0] boot_read;
	
	memory mem (
    .clk(clk),
    .reset_n(reset_n),
    .data_write(data_write),
    .data_read(mem_read),
    .addr(addr),
    .uds(uds),
	 .lds(lds),
    .rw(rw),
    .ack(mem_ack)
    );
	 

	// n_uds = 0 --> Byte auf gerade Adresse, data[15:8]
	// n_lds = 0 --> Byte auf ungerader Adresse, data[7:0]

	// Lesezugriff auf Adresse < 0x1000 liefert Bootstrapcode, sonst RAM-Zugriff 
	wire bootmode_read = bootmode && (addr < 24'h1000);
	
	assign data_read[7:0] =
		bootmode_read ? boot_read[7:0] : mem_read[7:0];

	assign data_read[15:8] =
		bootmode_read ? boot_read[15:8] : mem_read[15:8];

	assign ack = bootmode ? (uds || lds) : mem_ack;


	wire bootmode_end_cmd = (addr[23:0] == 'd0) && uds && lds && (data_write[15:0] == 16'hA9A9) && (rw == 1'b0);
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
	
	reg uds_r, lds_r;
	wire ds_ne = ( {uds_r, lds_r} == 2'b11 ) && ( {uds, lds} == 2'b00 );
	always @(posedge clk) uds_r <= uds;
	always @(posedge clk) lds_r <= lds;

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
				24'h000002: boot_read[15:0] = 16'h2000;
				24'h000004: boot_read[15:0] = 16'h0000;
				24'h000006: boot_read[15:0] = 16'h0000;
				24'h000008: boot_read[15:0] = 16'h13FC;
				24'h00000A: boot_read[15:0] = 16'h0041;
				24'h00000C: boot_read[15:0] = 16'h0010;
				24'h00000E: boot_read[15:0] = 16'h0000;
				24'h000000: boot_read[15:0] = 16'h4EFA;
				24'h000010: boot_read[15:0] = 16'hFFF6;			
			endcase
		end else begin
		end
	end



endmodule
