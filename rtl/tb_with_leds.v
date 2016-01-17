`timescale 1ns / 1ps

module tb_with_leds;

	// Inputs
	reg clk;
	reg reset_n;

	wire [31:0] ram_data_read;


	// Outputs
	wire [17:0] ram_addr;
	wire [31:0] ram_data_write;
	wire ram_data_is_output;
	wire [1:0] ram_ce_n;
	wire [1:0] ram_ub_n;
	wire [1:0] ram_lb_n;
	wire [1:0] ram_we_n;
	wire [1:0] ram_oe_n;

	memory mem1 (
		.clk(clk), 
		.reset_n(reset_n), 
		.data_write(ram_data_write[31:16]), 
		.data_read(ram_data_read[31:16]), 
		.addr(ram_addr), 
		.uds(~ram_ub_n[1]), 
		.lds(~ram_lb_n[1]), 
		.rw(ram_we_n[1])
   );
	
	memory mem0 (
		.clk(clk), 
		.reset_n(reset_n), 
		.data_write(ram_data_write[15:0]), 
		.data_read(ram_data_read[15:0]), 
		.addr(ram_addr), 
		.uds(~ram_ub_n[0]), 
		.lds(~ram_lb_n[0]), 
		.rw(ram_we_n[0])
   );
	
	wire [7:0] leds;
	
	system uut (
		.clk(clk), 
		.reset_n(reset_n), 
		//.tx(tx), 
		//.rx(rx), 
		.leds(leds),
		.ram_addr(ram_addr), 
		.ram_data_read(ram_data_read), 
		.ram_data_write(ram_data_write), 
		.ram_data_is_output(ram_data_is_output), 
		.ram_ce_n(ram_ce_n), 
		.ram_ub_n(ram_ub_n), 
		.ram_lb_n(ram_lb_n), 
		.ram_we_n(ram_we_n), 
		.ram_oe_n(ram_oe_n)
	);
	
	always #5 clk = ~clk;

	always @(*) begin
		if( uut.mem.bootmode_end_cmd ) begin
			$display("Boot mode end");
			$finish;
		end
	end		
	
	integer leds_alt;
	
	initial begin
		clk = 0;
		reset_n = 0;

		#100;
		reset_n = 1;
		leds_alt = leds;
		
		while(1) begin
			#10;
			if ( leds != leds_alt ) begin
				$display("%X", leds );
				leds_alt = leds;
				$stop;
			end
		end

		#100000;
		$finish;
	end
      
endmodule

