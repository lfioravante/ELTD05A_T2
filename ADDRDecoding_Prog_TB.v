`timescale 1ns/1ps
module ADDRDecoding_Prog_TB;
	reg  [31:0] ADDR;
   wire        CS;
   wire [9:0]  iAddress;
	
	ADDRDecoding_Prog #(.BASE(32'h0)) DUT (.ADDR(ADDR), .CS(CS), .iAddress(iAddress));
	
	initial begin
		ADDR = 32'h000;
		#10
		if(iAddress !== 10'h00 || CS !== 1'b1 )
			$display("ERRO 1: ADDR=%h | CS=%b (esp 1) | iAddress=%0d (esp 0)", ADDR, CS, iAddress);
		else
			$display("OK 1:   ADDR=%h | CS=%b | iAddress=%0d", ADDR, CS, iAddress);
			
		ADDR = 32'h004;
		#10
		if(iAddress !== 10'h001 || CS !== 1'b1)
			$display("ERRO 2: ADDR=%h | CS=%b (esp 1) | iAddress=%0d (esp 1)", ADDR, CS, iAddress);
		else
			$display("OK 2:   ADDR=%h | CS=%b | iAddress=%0d", ADDR, CS, iAddress);
			
		ADDR = 32'hFFC;
		#10
		if(iAddress !== ('hFFC/4) || CS !== 1'b1)
			$display("ERRO 3: ADDR=%h | CS=%b (esp 1) | iAddress=%0d (esp 1023)", ADDR, CS, iAddress);
		else
			$display("OK 4:   ADDR=%h | CS=%b | iAddress=%0d", ADDR, CS, iAddress);
			
		ADDR = 32'h1000;
		#10
		if(CS !== 1'b0)
			$display("ERRO 4: ADDR=%h | CS=%b (esp 1) | iAddress=%0d (esp 1023)", ADDR, CS, iAddress);
		else
			$display("OK 4:   ADDR=%h | CS=%b | iAddress=%0d", ADDR, CS, iAddress);

			
		$stop;
	end
endmodule