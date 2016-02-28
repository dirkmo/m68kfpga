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

parameter SYS_CLK = 'd25_000_000;
parameter BAUDRATE = 'd115200;

reg tx_start;

//----------------------------------------------------------
// Baudratengenerator
// 50 MHz
// 115200 Baud
// 50.000.000 / 115.200 = 434,03 -> 9 Bit
//`define TICK 434

// 1,5625 MHz
// 9600Baud
// 1562500 / 9600 = 163 = 8 Bit
//`define TICK 163

// 25 MHz
// 115200 Baud
// 25.000.000 / 115200 = 217
//`define TICK 9'd217

// 20 MHz
// 115200 Baud
// 20.000.000 / 115200 = 174
//`define TICK 9'd174

// 12,5 MHz
// 115200 Baud
// 12.500.000 / 115200 = 
//`define TICK 9'd109


`define TICK (SYS_CLK/BAUDRATE)

reg [8:0] baud;

wire tick = (baud[8:0] == `TICK);

always @(posedge clk) begin
	if(tx_start || tick) begin
		baud <= 0;
	end else begin
		baud <= baud + 'd1;
	end
end


//----------------------------------------------------------
// Interface zum Systembus

reg [7:0] tx_reg;
reg rx_is_being_read; // high when rx_reg is being read, for resetting rx_avail_flag in status[]
reg status_is_being_read; // for resetting overflow flag in status[]

wire [7:0] fifo_out;
reg fifo_pop;

wire [7:0] status;

reg rx_avail_flag;
assign rx_avail = rx_avail_flag;

always @(posedge clk) begin
	data_read[15:0] = 16'h0;
	ack = 1'b0;
	tx_start = 0;
	rx_is_being_read = 1'b0;
	status_is_being_read = 1'b0;
	fifo_pop = 1'b0;
	if( ~reset_n ) begin
	end else
	if( rw ) begin // read from uart
		if( addr[7:1] == 7'd0 ) begin
			if( uds ) begin // 0: UART RXTX
				data_read[15:8] = fifo_out[7:0];
				rx_is_being_read = 1'b1;
				fifo_pop = 1;
				ack = 1'b1;
			end
			if( lds ) begin // 1: UART STATUS
				data_read[7:0] = status[7:0];
				status_is_being_read = 1'b1;
				ack = 1'b1;
			end
		end
	end else begin // write to uart
		if( addr[7:1] == 7'd0 ) begin
			if( uds ) begin // 0: UART RXTX
				if( tx_active == 0 ) begin
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
// UART TX


reg [3:0] state_tx;

assign tx_active = (state_tx != 0) || tx_start;

always @(posedge clk) begin
	state_tx <= state_tx;
	tx <= tx;
	if( ~reset_n ) begin
		tx_reg <= 0;
		state_tx <= 0;
	end else begin
		case (state_tx)
			0: begin
				tx <= 1;
				state_tx <= 0;
				if( tx_start ) begin // start bit
					tx_reg[7:0] <= data_write[15:8];
					tx <= 0;
					state_tx <= 1;
				end
			end
			1: begin
					tx <= 0;
					if( tick ) begin
						tx <= tx_reg[0];
						state_tx <= 2;
					end
				end
			2: begin
					tx <= tx_reg[0];
					if( tick ) begin
						tx <= tx_reg[1];
						state_tx <= 3;
					end
				end
			3: begin
					tx <= tx_reg[1];
					if( tick ) begin
						tx <= tx_reg[2];
						state_tx <= 4;
					end
				end
			4: begin
					tx <= tx_reg[2];
					if( tick ) begin
						tx <= tx_reg[3];
						state_tx <= 5;
					end
				end
			5: begin
					tx <= tx_reg[3];
					if( tick ) begin
						tx <= tx_reg[4];
						state_tx <= 6;
					end
				end
			6: begin
					tx <= tx_reg[4];
					if( tick ) begin
						tx <= tx_reg[5];
						state_tx <= 7;
					end
				end
			7: begin
					tx <= tx_reg[5];
					if( tick ) begin
						tx <= tx_reg[6];
						state_tx <= 8;
					end
				end
			8: begin
					tx <= tx_reg[6];
					if( tick ) begin
						tx <= tx_reg[7];
						state_tx <= 9;
					end
				end
			9: begin
					tx <= tx_reg[7];
					if( tick ) begin
						tx <= 1;
						state_tx <= 10;
					end
				end
			10: begin
					tx <= 1;
					if( tick ) begin
						tx <= 1;
						state_tx <= 11;
					end
				end
			11: begin
				tx <= 1;
				if( tick ) begin
					state_tx <= 0;
				end
			end
			default: begin
					state_tx <= 0;
					tx <= 1;
				end
		endcase
	end
end

//----------------------------------------------------------
// UART RX

reg [8:0] baud_rx;
reg baud_start;
reg rx_overflow_flag;

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
reg [7:0] rx_reg;

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
			default: state_rx <= 0;
		endcase
	end
end

wire fifo_empty;
wire fifo_full;

always @(posedge clk) begin
	if( ~reset_n || rx_is_being_read || rx_avail_clear_i ) begin
		rx_avail_flag <= 1'b0;
	end else
	if(rx_avail_tick==1'b1) begin
		rx_avail_flag <= 1'b1;
	end
end

always @(posedge clk) begin
	if( ~reset_n || status_is_being_read ) begin
		rx_overflow_flag <= 0;
	end else
	if( rx_avail_tick && fifo_full ) begin
		rx_overflow_flag <= 1;
	end
end

fifo fifo_rx (
    .clk(clk), 
    .reset_n(reset_n), 
    .data_in(rx_reg), 
    .data_out(fifo_out), 
    .push(rx_avail_tick), 
    .pop(fifo_pop), 
    .empty(fifo_empty), 
    .full(fifo_full)
);


assign status[7:0] = { 5'd0, rx_overflow_flag, tx_active, ~fifo_empty };

endmodule
