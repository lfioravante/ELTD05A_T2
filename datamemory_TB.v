`timescale 1ns/1ps
module datamemory_TB;
	reg	[9:0]  address;
	reg	  clock;
	reg	[31:0]  data;
	reg	  wren;
	wire	[31:0]  q;

	datamemory  DUT (.address(address), .clock(clock), .data(data), .wren(wren), .q(q));
	
	initial clock = 0;
	always #10 clock = ~clock;
	
	initial begin
		address = 0;
		data = 0;
		wren = 0;
		#15
		if(q !== 32'h00000001)
			$display("ERRO 1: address=%h || saida:%h", address, q);
		else
			$display("OK 1: address=%h || saida:%h", address, q);
			
		address = 1;	
		#20
		if(q !== 32'h00000003)
			$display("ERRO 2: address=%h || saida:%h", address, q);
		else
			$display("OK 2: address=%h || saida:%h", address, q);
			
		address = 31;
		#20
		
		if(q !== 32'h00000009)
			$display("ERRO 3: address=%h || saida:%h", address, q);
		else
			$display("OK 3: address=%h || saida:%h", address, q);
		
		address = 1023;
		data = 32'hDEADBEEF;
		wren = 1;
		
		#20
			
		wren = 0;
		
		#20
		
		if(q !== 32'hDEADBEEF)
			$display("ERRO 4: address=%h || saida:%h", address, q);
		else
			$display("OK 4: address=%h || saida:%h", address, q);
		
		address = 0;
		data = 32'hFFFFFFFF;
		wren = 0;
		
		#20
		
		if(q !== 32'h00000001)
			$display("ERRO 5: address=%h || saida:%h", address, q);
		else
			$display("OK 5: address=%h || saida:%h", address, q);
		
		wren = 1;
		data = 32'h12345678;
		address = 5;
		#20
		
		wren = 0;
		
		#20
		
		if(q !== 32'h12345678)
			$display("ERRO 6: address=%h || saida:%h", address, q);
		else
			$display("OK 6: address=%h || saida:%h", address, q);
		
		
		$stop;
	end
endmodule