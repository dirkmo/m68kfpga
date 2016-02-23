`timescale 1ns / 1ps

module tb_spi;

	// Inputs
	reg clk;
	reg reset_n;
	reg [15:0] data_write;
	reg [7:0] addr;
	reg uds;
	reg lds;
	reg rw;
	wire spi_miso;

	// Outputs
	wire [15:0] data_read;
	wire ack;
	wire spi_mosi;
	wire spi_clk;
	wire [2:0] spi_cs_n;
	wire spi_active;

	// Instantiate the Unit Under Test (UUT)
	spi uut (
		.clk(clk), 
		.reset_n(reset_n), 
		.data_write(data_write), 
		.data_read(data_read), 
		.addr(addr), 
		.uds(uds), 
		.lds(lds), 
		.rw(rw), 
		.ack(ack), 
		.spi_mosi(spi_mosi), 
		.spi_clk(spi_clk), 
		.spi_miso(spi_miso), 
		.spi_cs_n(spi_cs_n),
		.spi_active(spi_active)
	);

	always #5 clk = ~clk;

	reg [7:0] miso_reg;
	always @(negedge spi_clk) begin
		if( spi_cs_n[0] == 1 ) begin
		end else begin
			miso_reg[7:0] <= { miso_reg[6:0], 1'b0 };
		end
	end
	
	assign spi_miso = miso_reg[7];

	initial begin
		// Initialize Inputs
		clk = 0;
		reset_n = 0;
		data_write = 0;
		addr = 0;
		uds = 0;
		lds = 0;
		rw = 0;

		#100;
		miso_reg = 8'd1;
		reset_n = 1;

		data_write[7:0] = 8'b0001_0010;
		lds = 1; #10; lds = 0;

		#100;

		data_write[15:8] = 8'd1;
		uds = 1; #10; uds = 0;
		
		while( ~spi_active ) #10; while( spi_active ) #10;

		miso_reg[7:0] = 8'd254;
		data_write[15:8] = 8'd254;
		uds = 1; #10; uds = 0;	
		while( ~spi_active ) #10; while( spi_active ) #10;

		$finish;

	end
      
endmodule

