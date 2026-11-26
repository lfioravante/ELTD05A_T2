`timescale 1ns/1ps
module risc_TB;
	localparam WIDTH = 32;
	reg [WIDTH-1:0] Data_BUS_READ;
	reg [WIDTH-1:0] Prog_BUS_READ;
	reg CLK;
	reg RST;
	
	wire [WIDTH-1:0] ADDR_Prog;
	wire CS_P;
	wire [WIDTH-1:0] ADDR;
	wire [WIDTH-1:0] Data_BUS_WRITE;
	wire WE;
	wire CS;
	
	risc #(32) DUT (.Data_BUS_READ(Data_BUS_READ), 
	.Prog_BUS_READ(Prog_BUS_READ), 
	.CLK(CLK), 
	.RST(RST), 
	.ADDR_Prog(ADDR_Prog), 
	.CS_P(CS_P), 
	.ADDR(ADDR), 
	.Data_BUS_WRITE(Data_BUS_WRITE),
	.WE(WE),
	.CS(CS));
	
	
	initial CLK = 0;
	always #10 CLK = ~CLK;
	
	initial begin
		Prog_BUS_READ = 0; 
		Data_BUS_READ = 0;
	
		RST = 1;
		#100
		RST = 0;
		#5000
	$stop;
	end
endmodule