`timescale 1ns / 1ps


module fifo(
    input clk,
	 input reset_n,
    input [7:0] data_in,
    output [7:0] data_out,
    input push,
    input pop,
	 output empty,
	 output full
);


	reg [7:0] buffer[3:0];
	reg [1:0] rd_idx;
	reg [1:0] wr_idx;
	reg empty_n;
	
	assign empty = ~empty_n;
	assign full = ( wr_idx == rd_idx ) && ~empty;
	assign data_out[7:0] = buffer[rd_idx][7:0];

	wire [1:0] rd_idx_next = rd_idx + 2'd1;
	wire [1:0] wr_idx_next = wr_idx + 2'd1;

	reg push_r, pop_r;
	always @(posedge clk) begin
		push_r <= push;
		pop_r <= pop;
	end
	
	wire push_pe = ~push_r && push;
	wire pop_pe = ~pop_r && pop;

	always @(posedge clk) begin
		if( ~reset_n ) begin
			rd_idx <= 2'd0;
			wr_idx <= 2'd0;
			empty_n <= 1'b0;
		end else if( push_pe && ~full ) begin
			wr_idx <= wr_idx_next;
			buffer[wr_idx] <= data_in[7:0];
			empty_n <= 1'b1;
		end else if( pop_pe && ~empty ) begin
			rd_idx <= rd_idx_next;
			empty_n <= (wr_idx != rd_idx_next);
		end
	end

endmodule
