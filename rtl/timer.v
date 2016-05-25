`timescale 1ns / 1ps

module timer(
		input clk,
		input reset_n,
		
		input [15:0] data_write,
		output reg [15:0] data_read,
		input [7:0] addr,
		input uds,
		input lds,
		input rw,
		output reg ack,
		
		output interrupt
);

reg [31:0] cnt;
reg [4:0] clk_div;
wire timer_clk = cnt[clk_div];

reg timer_clk_r;
always @(posedge clk) timer_clk_r <= timer_clk;
wire timer_tick = { timer_clk_r, timer_clk } == 2'b01;


reg [31:0] cmp;
reg [31:0] timer;

reg enable;

wire overflow = enable && ( timer == cmp );
reg overflow_r;
always @(posedge clk) overflow_r <= overflow;

assign interrupt = { overflow_r, overflow } == 2'b01;

wire [15:0] ctrl = { 8'd0, { 2'b00, clk_div[4:0], enable } };

wire [6:0] addr7 = addr[7:1];

always @(posedge clk) begin
	ack <= 1'b0;
	if( ~reset_n ) begin
		clk_div <= 0;
		cmp <= 0;
		enable <= 0;
	end else
	if( rw ) begin // read from timer module -->
		// 0..3: timer register
		if( addr[7:1] == 7'd0 ) begin
			if( uds ) begin // 0: Timer byte 3 (MSB)
				data_read[15:8] <= timer[31:24];
			end
			if( lds ) begin // 1: Timer byte 2
				data_read[7:0] <= timer[23:16];
			end
		end else
		if( addr[7:1] == 7'd1 ) begin
			if( uds ) begin // 2: Timer byte 1
				data_read[15:8] <= timer[15:8];
			end
			if( lds ) begin // 3: Timer byte 0 (LSB)
				data_read[7:0] <= timer[7:0];
			end
		end else
		// 4..7: cmp register
		if( addr[7:1] == 7'd2 ) begin
			if( uds ) begin // 4: cmp byte 3 (MSB)
				data_read[15:8] <= cmp[31:24];
			end
			if( lds ) begin // 5: cmp byte 2
				data_read[7:0] <= cmp[23:16];
			end
		end else
		if( addr[7:1] == 7'd3 ) begin
			if( uds ) begin // 6: cmp byte 1
				data_read[15:8] <= cmp[15:8];
			end
			if( lds ) begin // 7: cmp byte 0 (LSB)
				data_read[7:0] <= cmp[7:0];
			end
		end else		
		// 8: ctrl 8..11
		if( addr[7:1] == 7'd4 ) begin
			if( uds ) begin // 8: ctrl byte 3 (MSB)
				data_read[15:8] <= 8'd1;
			end
			if( lds ) begin // 9: ctrl byte 2
				data_read[7:0] <= 8'd2;
			end
		end else
		if( addr[7:1] == 7'd5 ) begin
			if( uds ) begin // 10: ctrl byte 1
				data_read[15:8] <= 8'd3;//ctrl[15:8];
			end
			if( lds ) begin // 11: ctrl byte 0 (LSB)
				data_read[7:0] <= 8'd4;//ctrl[7:0];
			end
		end
		if( uds || lds ) ack <= 1'b1;
		
	end else begin // write to timer module -->

		// 0..3: timer register
		if( addr[7:1] == 7'd0 ) begin
			// wird timer register block behandelt
		end else
		if( addr[7:1] == 7'd1 ) begin
			// wird timer register block behandelt
		end else
		// 4..7: cmp register
		if( addr[7:1] == 7'd2 ) begin
			if( uds ) begin // 4: cmp byte 3 (MSB)
				cmp[31:24] <= data_write[15:8];
			end
			if( lds ) begin // 5: cmp byte 2
				cmp[23:16] <= data_write[7:0];
			end
		end else
		if( addr[7:1] == 7'd3 ) begin
			if( uds ) begin // 6: cmp byte 1
				cmp[15:8] <= data_write[15:8];
			end
			if( lds ) begin // 7: cmp byte 0 (LSB)
				cmp[7:0] <= data_write[7:0];
			end
		end else
		// 8..11: ctrl register
		if( addr[7:1] == 7'd4 ) begin
			if( uds ) begin // 8: ctrl byte 3 (MSB)
			end
			if( lds ) begin // 9: ctrl byte 2
			end
		end else
		if( addr[7:1] == 7'd5 ) begin
			if( uds ) begin // 10: ctrl byte 1
			end
			if( lds ) begin // 11: ctrl byte 0 (LSB)
				{ clk_div[4:0], enable } <= data_write[5:0];
			end
		end
		if( uds || lds ) ack <= 1;
	end
end

// timer register
always @(posedge clk) begin
	if( ~reset_n ) begin
		timer <= 0;
	end else begin
		if( ~rw ) begin
			if( addr[7:1] == 7'd0 ) begin
				if( uds ) timer[31:24] <= data_write[15:8];
				if( lds ) timer[23:16] <= data_write[7:0];
			end else
			if( addr[7:1] == 7'd1 ) begin
				if( uds ) timer[15:8] <= data_write[15:8];
				if( lds ) timer[7:0] <= data_write[7:0];
			end
		end
		if( overflow && timer_tick ) begin
			timer <= 'd0;
		end else
		if( enable && timer_tick ) begin
			timer <= timer + 1'b1;
		end
	end
end

always @(posedge clk) begin
	if( ~reset_n ) begin
		cnt <= 0;
	end else
	if(enable) begin
		cnt <= cnt + 'd1;
	end
end

endmodule
