`timescale 1ns / 1ps

module spi(
	input clk,
	input reset_n,

	input [15:0] data_write,
	output reg [15:0] data_read,
	input [7:0] addr,
	input uds,
	input lds,
	input rw,
	output reg ack,
	
	output spi_mosi,
	output spi_clk,
	input spi_miso,
	output [2:0] spi_cs_n,
	output spi_active
);

reg [15:0] clk_counter;
reg [2:0] clk_div;
reg [2:0] spi_cs_reg;
reg [7:0] rx_reg;
reg [7:0] tx_reg;

wire active;
assign spi_active = active;
reg start;
//reg cpol; // 0: idle clock low, 1: idle clock high
//reg cpha; // 0: data capture on first clk edge, 1: data capture on second clk edge
reg tx_out;

assign spi_mosi = active ? tx_out : 1'b0; // MSB first
assign spi_clk = active ? clk_counter[  16'd1 << clk_div[2:0] ] : 1'b0;

assign spi_cs_n[2:0] =	spi_cs_reg==1 ? 3'b110 : 
								spi_cs_reg==2 ? 3'b101 : 
								spi_cs_reg==3 ? 3'b011 :  3'b111;

always @(posedge clk) begin
	ack <= 1'b0;
	start <= 0;
	if( ~reset_n ) begin
		//cpol <= 0;
		//cpha <= 1;
		clk_div <= 0;
	end else
	if( rw ) begin // read from spi
		if( addr[7:1] == 7'd0 ) begin
			if( uds ) begin // 0: RX REG
				if( ~active ) begin
					data_read[15:8] <= rx_reg[7:0];
					ack <= 1'b1;
				end
			end
			if( lds ) begin // 1: CTRL REG: CS_N[6:4], CLK_DIV[3:1], active
				data_read[7:0] <= { spi_cs_reg[2:0], clk_div[2:0], active };
				ack <= 1'b1;
			end
		end
	end else begin // write to spi
		if( addr[7:1] == 7'd0 ) begin
			if( uds ) begin // 0: TX REG
				if( ~active ) begin
					start <= 1;
					tx_reg <= data_write[15:8];
					ack <= 1'b1;
				end
			end
			if( lds ) begin // 1: CTRL REG: CS_N[6:4], CLK_DIV[3:1], active
				if( ~active ) begin
					clk_div[2:0] <= data_write[3:1];
					spi_cs_reg[2:0] <= data_write[6:4];
					ack <= 1'b1;
				end
			end
		end // if( addr[7:0] == 8'd0 )
	end
end

always @(posedge clk) begin
	if( ~reset_n ) begin
		clk_counter <= 0;//cpol;
	end else
	if( active ) begin
		clk_counter <= clk_counter + 1'b1;
	end
end

reg spi_clk_r;
always @(posedge clk) spi_clk_r <= spi_clk;
wire spi_clk_ne = { spi_clk_r, spi_clk } == 2'b10;
wire spi_clk_pe = { spi_clk_r, spi_clk } == 2'b01;

//wire out_at_rising_edge = (~cpol && cpha) || (cpol && ~cpha);
//wire tx_clk_tick = out_at_rising_edge ? spi_clk_pe : spi_clk_ne;
wire tx_clk_tick = spi_clk_ne; // tx-out at falling edge
wire rx_clk_tick = spi_clk_pe; // rx-in at rising edge

reg [3:0] state_tx;
assign active = (state_tx != 0);

always @(posedge clk) begin
	if( ~reset_n ) begin
		state_tx <= 0;
		tx_out <= 'b0;
	end else begin
		case ( state_tx )
			0: if( start ) begin
				state_tx <= 'd1;
			end
			1: begin
					tx_out <= tx_reg[7]; // output Bit 7
					if( tx_clk_tick ) begin
						state_tx <= 'd2;
						tx_out <= tx_reg[6];
					end
			end
			2: if( tx_clk_tick ) begin
				state_tx <= 'd3;
				tx_out <= tx_reg[5];
			end
			3: if( tx_clk_tick ) begin
				state_tx <= 'd4;
				tx_out <= tx_reg[4];
			end
			4: if( tx_clk_tick ) begin
				state_tx <= 'd5;
				tx_out <= tx_reg[3];
			end
			5: if( tx_clk_tick ) begin
				state_tx <= 'd6;
				tx_out <= tx_reg[2];
			end
			6: if( tx_clk_tick ) begin
				state_tx <= 'd7;
				tx_out <= tx_reg[1];
			end
			7: if( tx_clk_tick ) begin
				state_tx <= 'd8;
				tx_out <= tx_reg[0];
			end
			8: if( tx_clk_tick ) begin
				state_tx <= 'd0;
				tx_out <= 'b0;
			end
			default: state_tx <= 0;
		endcase
	end
end

reg [3:0] state_rx;

always @(posedge clk) begin
	if( ~reset_n ) begin
		state_rx <= 0;
	end else begin
		case ( state_rx )
			0: if( start ) begin
				state_rx <= 'd1;
			end
			1: if( rx_clk_tick ) begin
				rx_reg[7] <= spi_miso;
				state_rx <= 'd2;
			end
			2: if( rx_clk_tick ) begin
				rx_reg[6] <= spi_miso;
				state_rx <= 'd3;
			end
			3: if( rx_clk_tick ) begin
				rx_reg[5] <= spi_miso;
				state_rx <= 'd4;
			end
			4: if( rx_clk_tick ) begin
				rx_reg[4] <= spi_miso;
				state_rx <= 'd5;
			end
			5: if( rx_clk_tick ) begin
				rx_reg[3] <= spi_miso;
				state_rx <= 'd6;
			end
			6: if( rx_clk_tick ) begin
				rx_reg[2] <= spi_miso;
				state_rx <= 'd7;
			end
			7: if( rx_clk_tick ) begin
				rx_reg[1] <= spi_miso;
				state_rx <= 'd8;
			end
			8: if( rx_clk_tick ) begin
				rx_reg[0] <= spi_miso;
				state_rx <= 'd0;
				//$display("rx: %02X (%d)", { rx_reg[7:1], spi_miso }, { rx_reg[7:1], spi_miso } );
			end
			default: state_rx <= 0;
		endcase
	end
end


endmodule
