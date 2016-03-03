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
		
		output overflow
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

assign overflow = enable && ( timer == cmp );


wire [15:0] ctrl = { 8'd0, { 2'b00, clk_div[4:0], enable } };


always @(posedge clk) begin
	ack <= 1'b0;
	if( ~reset_n ) begin
		//cpol <= 0;
		//cpha <= 1;
		clk_div <= 0;
		cmp <= 0;
		enable <= 0;
	end else
	if( rw ) begin // read from timer module -->
		// 0..3: timer register
		if( addr[7:1] == 7'd0 ) begin
			if( uds ) begin // 0: Timer MSB
				data_read[15:8] <= timer[31:24];
			end
			if( lds ) begin // 1: Timer byte 3
				data_read[7:0] <= timer[23:16];
			end
		end else
		if( addr[7:1] == 7'd1 ) begin
			if( uds ) begin // 2: Timer byte 2
				data_read[15:8] <= timer[15:8];
			end
			if( lds ) begin // 3: Timer LSB
				data_read[7:0] <= timer[7:0];
			end
		end else
		// 4..7: cmp register
		if( addr[7:1] == 7'd2 ) begin
			if( uds ) begin // 0: cmp MSB
				data_read[15:8] <= cmp[31:24];
			end
			if( lds ) begin // 1: cmp byte 3
				data_read[7:0] <= cmp[23:16];
			end
		end else
		if( addr[7:1] == 7'd3 ) begin
			if( uds ) begin // 2: cmp byte 2
				data_read[15:8] <= cmp[15:8];
			end
			if( lds ) begin // 3: cmp LSB
				data_read[7:0] <= cmp[7:0];
			end
		end else		
		// 8: ctrl
		if( addr[7:1] == 7'd4 ) begin
			if( uds ) begin // 0: ctrl
				data_read[15:8] <= ctrl[15:8];
			end
			if( lds ) begin // 1: ctrl
				data_read[7:0] <= ctrl[7:0];
			end
		end
		if( uds || lds ) ack <= 1'b1;
	end else begin // write to timer module -->
		// 0..3: timer register
		if( addr[7:1] == 7'd0 ) begin
			if( uds ) begin // 0: timer MSB
			end
			if( lds ) begin // 1: timer byte 3
			end
		end else
		if( addr[7:1] == 7'd1 ) begin
			if( uds ) begin // 2: timer byte 2
			end
			if( lds ) begin // 3: timer LSB
			end
		end else
		// 4..7: cmp register
		if( addr[7:1] == 7'd2 ) begin
			if( uds ) begin // 0: cmp MSB
				cmp[31:24] <= data_write[15:8];
			end
			if( lds ) begin // 1: cmp byte 3
				cmp[23:16] <= data_write[7:0];
			end
			ack <= 1;
		end else
		if( addr[7:1] == 7'd3 ) begin
			if( uds ) begin // 2: cmp byte 2
				cmp[15:8] <= data_write[15:8];
			end
			if( lds ) begin // 3: cmp LSB
				cmp[7:0] <= data_write[7:0];
			end
		end else
		if( addr[7:1] == 7'd4 ) begin
			if( uds ) begin // 0: ctrl
			end
			if( lds ) begin // 1: ctrl
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
				if( uds ) timer[7:0] <= data_write[15:8];
				if( lds ) timer[15:8] <= data_write[7:0];
			end else
			if( addr[7:1] == 7'd1 ) begin
				if( uds ) timer[23:16] <= data_write[15:8];
				if( lds ) timer[31:24] <= data_write[7:0];
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
