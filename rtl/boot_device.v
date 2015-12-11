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
		
		output reg bootmode,
		
		// SRAM Signale
		output [17:0] ram_addr,
		input  [31:0] ram_data_read,
		output [31:0] ram_data_write,
		output ram_data_is_output,
		output [1:0] ram_ce_n,
		output [1:0] ram_ub_n,
		output [1:0] ram_lb_n,
		output [1:0] ram_we_n,
		output [1:0] ram_oe_n
    );

	wire [15:0] sram_read;
	wire sram_ack;
	wire sram_uds;
	wire sram_lds;
	wire sram_rw;
	
	reg [15:0] boot_read;
	
	sram_if sram (
    .clk(clk), 
    .reset_n(reset_n), 
	 
    .data_write(data_write), 
    .data_read(sram_read), 
    .addr(addr[19:0]), 
    .uds(sram_uds), 
    .lds(sram_lds), 
    .rw(rw), 
    .ack(sram_ack), 
	 
    .ram_addr( ram_addr[17:0] ), 
    .ram_data_read( ram_data_read[31:0] ), 
    .ram_data_write( ram_data_write[31:0] ), 
    .ram_data_is_output( ram_data_is_output ), 
    .ram_ce_n( ram_ce_n[1:0] ), 
    .ram_ub_n( ram_ub_n[1:0] ), 
    .ram_lb_n( ram_lb_n[1:0] ), 
    .ram_we_n( ram_we_n[1:0] ), 
    .ram_oe_n( ram_oe_n[1:0] )
   );

	// n_uds = 0 --> Byte auf gerade Adresse, data[15:8]
	// n_lds = 0 --> Byte auf ungerader Adresse, data[7:0]

	// Lesezugriff auf Adresse < 0x1000 liefert Bootstrapcode, sonst RAM-Zugriff 
	wire bootmode_read = bootmode && (addr < 24'h1000);
	
	assign sram_uds = bootmode_read ? 1'b0 : uds;
	assign sram_lds = bootmode_read ? 1'b0 : lds;
	assign sram_rw  = bootmode_read ? 1'b1 : rw;
	
	assign data_read[7:0] =
		bootmode_read ? boot_read[7:0] : sram_read[7:0];

	assign data_read[15:8] =
		bootmode_read ? boot_read[15:8] : sram_read[15:8];

	assign ack = bootmode_read ? (uds || lds) : sram_ack;


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
			case( { addr[23:1], 1'b0 }  )
`include "../sw/main.v"
			endcase
		end else begin
		end
	end



endmodule
