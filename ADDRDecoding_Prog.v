module ADDRDecoding_Prog #(
	parameter BASE = 32'h0
) (
	input  [31:0] ADDR,
	output        CS,
	output [9:0]  iAddress
);
	wire [31:0] offset = ADDR - BASE;
	assign CS = (ADDR >= BASE) && (ADDR < BASE + 32'h1000);   
	assign iAddress = offset[11:2];                               
endmodule