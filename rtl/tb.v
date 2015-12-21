`timescale 1ns / 1ps

module tb;

	// Inputs
	reg clk;
	reg reset_n;
	reg rx_avail_clear;
	
	wire rx;
	wire [31:0] ram_data_read;
	wire rx_avail;
	
	// Outputs
	wire tx;
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
	
	reg [15:0] uart_tx_reg;
	reg uart_uds_reg;
	reg uart_lds_reg;
	reg uart_rw;
	wire uart_tx_active;
	
	uart tbuart (
    .clk(clk), 
    .reset_n(reset_n), 
    .rx(tx), 
    .tx(rx), 
	 .addr(0),
	 .rw(uart_rw),
	 .uds(uart_uds_reg),
	 .lds(uart_lds_reg),
    .rx_avail(rx_avail), 
	 .tx_active(uart_tx_active),
    .rx_avail_clear_i(rx_avail_clear),
	 .data_write(uart_tx_reg[15:0])
    );
	
	top uut (
		.clk(clk), 
		.reset_n(reset_n), 
		.tx(tx), 
		.rx(rx), 
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
	
	task uart_putc;
	input [7:0] c;
	begin
		while( uart_tx_active ) #10;
		uart_tx_reg[15:8] = c[7:0];
		uart_uds_reg = 1'b1; #10;
		uart_uds_reg = 1'b0; #10;
	end
	endtask

	initial begin
		// Initialize Inputs
		clk = 0;
		reset_n = 0;
		rx_avail_clear = 1;
		uart_uds_reg = 0;
		uart_lds_reg = 0;
		#100;
		rx_avail_clear = 0;
		reset_n = 1;

		while( 1 ) begin
			while ( ~rx_avail ) #10;
			$display("rx: %d", tbuart.rx_reg[7:0] );
			$stop;
			//uart_putc( tbuart.rx_reg[7:0] + 8'd1 );
			rx_avail_clear = 1; #10; rx_avail_clear = 0; #10;
		end
	
		#100000;
		$finish;
	end
      
endmodule

