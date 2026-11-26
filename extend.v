module extend #(parameter WIDTH_IN = 16,parameter WIDTH_OUT = 32)(
	input [WIDTH_IN-1:0] in,
	output [WIDTH_OUT-1:0] out
);
	assign out = { {WIDTH_OUT - WIDTH_IN{in[WIDTH_IN-1]}}, in};

endmodule
	
	