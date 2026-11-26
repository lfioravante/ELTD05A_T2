module mux #(parameter WIDTH = 32)(
	input [WIDTH-1:0] data_in_1,
	input [WIDTH-1:0] data_in_2,
	input sel,
	output [WIDTH-1:0] data_out
);
	
	assign data_out = sel ? data_in_2 : data_in_1;
	
endmodule	
	