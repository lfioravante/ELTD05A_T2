module Adder #(parameter WIDTH = 16)(
	input [WIDTH-1:0] OperandoA,
	input [WIDTH-1:0] OperandoB,
	output [WIDTH:0] Soma
);

	assign Soma = OperandoA + OperandoB;
	
endmodule