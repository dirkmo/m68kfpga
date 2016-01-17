`timescale 1ns / 1ps

module sram_if(
		input clk,
		input reset_n,
		
		input [15:0] data_write,
		output [15:0] data_read,
		input [19:0] addr,
		input uds, // 15:8, even address
		input lds, // 7:0, odd address
		input rw,
		output ack,
		
		output [17:0] ram_addr,
		input  [31:0] ram_data_read,
		output reg [31:0] ram_data_write,
		output reg ram_data_is_output,
		output reg [1:0] ram_ce_n,
		output reg [1:0] ram_ub_n,
		output reg [1:0] ram_lb_n,
		output reg [1:0] ram_we_n,
		output reg [1:0] ram_oe_n

    );

	reg [31:0] data_read_from_ram; // Daten die aus RAM0+1 gelesen wurden

	wire ram_index = addr[1]; // RAM0 (ram_index=0) oder RAM1 (ram_index=1)
	wire ram0_ce = ~ram_index;
	wire ram1_ce = ram_index;
	
	wire read_ack;
	wire write_ack;
	assign ack = read_ack || write_ack;

	assign ram_addr[17:0] = addr[19:2];

	// CPU Interface data read
	reg data_read_done; // Daten aus RAM gelesen
	wire read_access = ( rw && (uds || lds) );
	// select upper or lower 16 bits for reading
	assign data_read[15:0] = read_access ? ( ram_index ? data_read_from_ram[31:16] : data_read_from_ram[15:0] ) : 16'hX;
	assign read_ack = data_read_done;

	// CPU Interface data write
	reg data_write_done;
	wire write_access = (~rw && (uds || lds) );
	assign write_ack = data_write_done;
	
	
	//----------------------------------------------------------------
	// RAM Interface
	
	wire [1:0] write_ce_n = { ~ram1_ce, ~ram0_ce };
	wire [1:0] write_ub_n;
	wire [1:0] write_lb_n;
	wire [1:0] write_we_n;
	
	assign write_ub_n[0] = ~(ram0_ce && uds);
	assign write_ub_n[1] = ~(ram1_ce && uds);
	
	assign write_lb_n[0] = ~(ram0_ce && lds);
	assign write_lb_n[1] = ~(ram1_ce && lds);
	
	assign write_we_n[0] = ~(ram0_ce && ~rw);
	assign write_we_n[1] = ~(ram1_ce && ~rw);
	
	
	reg [2:0] state;
	always @(posedge clk) begin
		
		ram_ce_n[1:0] <= 2'b11;
		ram_ub_n[1:0] <= 2'b11;
		ram_lb_n[1:0] <= 2'b11;
		ram_we_n[1:0] <= 2'b11;
		ram_oe_n[1:0] <= 2'b11;
		data_read_done <= 0;
		data_write_done <= 0;
		ram_data_write <= 32'd0;
		ram_data_is_output <= 1'b0;
		
		state <= 'd0;

		if( ~reset_n ) begin
		
		end else	if ( read_access ) begin // Read access
			ram_ce_n[1:0] <= 2'b00;
			ram_ub_n[1:0] <= 2'b00;
			ram_lb_n[1:0] <= 2'b00;
			ram_oe_n[1:0] <= 2'b00;
			ram_we_n[1:0] <= 2'b11;
			case( state )
				'd0: begin
					state <= 'd1;
				end
				'd1: begin
					data_read_from_ram[31:0] <= ram_data_read[31:0];
					state <= 'd2;
				end
				'd2: begin
					ram_ce_n[1:0] <= 2'b11;
					ram_ub_n[1:0] <= 2'b11;
					ram_lb_n[1:0] <= 2'b11;
					ram_oe_n[1:0] <= 2'b11;
					data_read_done <= 1;
					state <= 'd2;
				end
				default:	begin
					state <= 'd2;
					$stop;
				end
			endcase
		end else if ( write_access ) begin // Write access
			ram_ce_n[1:0] <= write_ce_n[1:0];
			ram_ub_n[1:0] <= write_ub_n[1:0];
			ram_lb_n[1:0] <= write_lb_n[1:0];
			ram_oe_n[1:0] <= 2'b11;
			ram_we_n[1:0] <= write_we_n[1:0];
			ram_data_write[31:24] <= ram1_ce && uds ? data_write[15:8] : 8'd0; // LSB, 0
			ram_data_write[23:16] <= ram1_ce && lds ? data_write[7:0]  : 8'd0;
			ram_data_write[15:8]  <= ram0_ce && uds ? data_write[15:8] : 8'd0;
			ram_data_write[7:0]   <= ram0_ce && lds ? data_write[7:0]  : 8'd0; // MSB, 3
			ram_data_is_output <= 1'b1;
			case( state )
				'd0: begin
					state <= 'd1;
					ram_data_is_output <= 1'b1;
				end
				'd1: begin
					ram_ce_n[1:0] <= 2'b11;
					ram_ub_n[1:0] <= 2'b11;
					ram_lb_n[1:0] <= 2'b11;
					ram_we_n[1:0] <= 2'b11;
					ram_data_is_output <= 1'b0;
					data_write_done <= 1;
					state <= 'd1;
				end
				default:	state <= 'd1;
			endcase
		
		end
	end
	

endmodule
