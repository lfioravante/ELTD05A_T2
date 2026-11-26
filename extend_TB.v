`timescale 1ns/1ps
module extend_TB;
	reg [15:0] in;
	wire [31:0] out;
	
	extend #(16, 32) DUT ( .in(in), .out(out));
	
	initial begin
		in = 16'h0005;
		#10;
		if (out !== 32'h00000005) 
			$display("ERRO 1: y=%h", out); 
		else 
			$display("OK 1");
		
		in = 16'h7FFF;
		#10;
		if (out !== 32'h00007FFF) 
			$display("ERRO 2: y=%h", out); 
		else 
			$display("OK 2");
		
		in = 16'h8000;
		#10;
		if (out !== 32'hFFFF8000) 
			$display("ERRO 3: y=%h", out); 
		else 
			$display("OK 3");
		
		in = 16'hFFFF;
		#10;
		if (out !== 32'hFFFFFFFF) 
			$display("ERRO 4: y=%h", out); 
		else 
			$display("OK 4");
		
		in = 16'h0000;
		#10;
		if (out !== 32'h00000000) 
			$display("ERRO 5: y=%h", out); 
		else 
			$display("OK 5");
	$stop;
	end
	
endmodule