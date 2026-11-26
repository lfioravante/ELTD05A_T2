module alu #(parameter WIDTH = 32) (
	input [WIDTH-1:0] data_in_1,
	input [WIDTH-1:0] data_in_2,
	input [1:0] bits_sel,
	output reg [WIDTH-1:0] data_out,
	output zero

);

	always @(*) begin
		case ( bits_sel )
			2'b00 : data_out = data_in_1 + data_in_2;   
			2'b01 : data_out = data_in_1 - data_in_2;   
			2'b10 : data_out = data_in_1 & data_in_2;   
			2'b11 : data_out = data_in_1 | data_in_2;   
			default: data_out = 0;
		endcase
	end
	assign zero = ( data_out == 0 );
endmodule