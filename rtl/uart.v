`timescale 1ns / 1ns

module uart(
		input clk,
		input reset_n,
		
		input rx,
		output reg tx,

		input [15:0] data_write,
		output reg [15:0] data_read,
		input [7:0] addr,
		input uds,
		input lds,
		input rw,
		output reg ack,

		output tx_active,
		
		output wire rx_avail,
		input rx_avail_clear_i
    );

reg [7:0] tx_reg;
reg [7:0] rx_reg;
reg tx_start;
reg rx_is_being_read; // high when rx_reg is being read, for resetting rx_avail_flag in status[]

wire [7:0] status;

reg rx_avail_flag;
assign rx_avail = rx_avail_flag;

always @(posedge clk) begin
	data_read[15:0] = 16'h0;
	ack = 1'b0;
	tx_start = 0;
	rx_is_being_read = 1'b0;
	if( ~reset_n ) begin
	end else
	if( rw ) begin // read from uart
		if( addr[7:1] == 7'd0 ) begin
			if( uds ) begin // 0: UART RXTX
				data_read[15:8] = rx_reg[7:0];
				rx_is_being_read = 1'b1;
				ack = 1'b1;
			end
			if( lds ) begin // 1: UART STATUS
				data_read[7:0] = status[7:0];
				ack = 1'b1;
			end
		end
	end else begin // write to uart
		if( addr[7:1] == 7'd0 ) begin
			if( uds ) begin // 0: UART RXTX
				if( tx_active == 0 ) begin
					tx_reg[7:0] = data_write[15:8];
					tx_start = 1;
					ack = 1'b1;
				end
			end
			if( lds ) begin // 1: UART STATUS
				ack = 1'b1;
			end
		end // if( addr[7:0] == 8'd0 )
	end // write to uart
end


//----------------------------------------------------------
// Baudratengenerator
// 50 MHz
// 115200 Baud
// 50.000.000 / 115.200 = 434,03 -> 9 Bit

`define TICK 434

reg [8:0] baud;

wire tick = (baud[8:0] == `TICK);

always @(posedge clk) begin
	if(tx_start || tick) begin
		baud <= 0;
	end else begin
		baud <= baud + 9'd1;
	end
end

//----------------------------------------------------------
// UART TX


reg [3:0] state_tx;

assign tx_active = (state_tx != 0) || tx_start;

always @(posedge clk) begin
	state_tx <= state_tx;
	if( ~reset_n ) begin
		tx_reg <= 0;
		state_tx <= 0;
	end else begin
		case (state_tx)
			0: begin
				if( tx_start ) begin // start bit
					tx <= 0;
					state_tx <= 1;
				end
			end
			1: if( tick ) begin
				tx <= tx_reg[0];
				state_tx <= 2;
			end
			2: if( tick ) begin
				tx <= tx_reg[1];
				state_tx <= 3;
			end
			3: if( tick ) begin
				tx <= tx_reg[2];
				state_tx <= 4;
			end
			4: if( tick ) begin
				tx <= tx_reg[3];
				state_tx <= 5;
			end
			5: if( tick ) begin
				tx <= tx_reg[4];
				state_tx <= 6;
			end
			6: if( tick ) begin
				tx <= tx_reg[5];
				state_tx <= 7;
			end
			7: if( tick ) begin
				tx <= tx_reg[6];
				state_tx <= 8;
			end
			8: if( tick ) begin
				tx <= tx_reg[7];
				state_tx <= 9;
			end
			9: if( tick ) begin
				tx <= 1;
				state_tx <= 10;
			end
			10: if( tick ) begin
				tx <= 1;
				state_tx <= 11;
			end
			11: if( tick ) begin
				state_tx <= 0;
			end
		endcase
	end
end

//----------------------------------------------------------
// UART RX


reg [8:0] baud_rx;
reg baud_start;

wire baud_reset = (baud_rx[8:0] == `TICK);
wire tick_rx = (baud_rx[8:0] == `TICK/2);

always @(posedge clk) begin
	if(baud_start || baud_reset ) begin
		baud_rx <= 0;
	end else begin
		baud_rx <= baud_rx + 9'd1;
	end
end


reg [3:0] state_rx;
reg rx_avail_tick;

always @(posedge clk) begin
	state_rx <= state_rx;
	baud_start <= 0;
	rx_avail_tick <= 0;
	if( ~reset_n ) begin
		state_rx <= 0;
		rx_reg <= 0;
	end else begin
		case ( state_rx )
			0: // IDLE
			begin
				if( rx == 0 ) begin
					baud_start <= 1; // start des Stoppbits
					state_rx <= 1;
				end
			end
			1: // Start Bit
			if( tick_rx ) begin
				state_rx <= 2;
				if(rx == 1) begin
					state_rx <= 0; // Stoppbit nicht mehr 0, daher zurck in IDLE
				end
			end
			2: // Bit 0
			if( tick_rx ) begin
				rx_reg[0] <= rx;
				state_rx <= 3;
			end
			3: // Bit 1
			if( tick_rx ) begin
				rx_reg[1] <= rx;
				state_rx <= 4;
			end
			4: // Bit 2
			if( tick_rx ) begin
				rx_reg[2] <= rx;
				state_rx <= 5;
			end
			5: // Bit 3
			if( tick_rx ) begin
				rx_reg[3] <= rx;
				state_rx <= 6;
			end
			6: // Bit 4
			if( tick_rx ) begin
				rx_reg[4] <= rx;
				state_rx <= 7;
			end
			7: // Bit 5
			if( tick_rx ) begin
				rx_reg[5] <= rx;
				state_rx <= 8;
			end
			8: // Bit 6
			if( tick_rx ) begin
				rx_reg[6] <= rx;
				state_rx <= 9;
			end
			9: // Bit 7
			if( tick_rx ) begin
				rx_reg[7] <= rx;
				state_rx <= 10;
			end
			10: // Stoppbit
			if( tick_rx ) begin
				if( rx == 1) begin
					rx_avail_tick <= 1; // Stoppbit ist da
				end
				state_rx <= 0;
			end
		endcase
	end
end

always @(posedge clk) begin
	if( ~reset_n || rx_is_being_read || rx_avail_clear_i ) begin
		rx_avail_flag <= 1'b0;
	end else
	if(rx_avail_tick==1'b1) begin
		rx_avail_flag <= 1'b1;
	end
end

assign status[7:0] = { 6'd0, tx_active, rx_avail_flag };

endmodule