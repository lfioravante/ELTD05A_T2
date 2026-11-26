`timescale 1ns/1ps
module mux_TB;
	reg  [31:0] data_in_1, data_in_2;   
	reg         sel;        
	wire [31:0] data_out;         

	mux #(32) DUT ( .data_in_1(data_in_1), .data_in_2(data_in_2), .sel(sel), .data_out(data_out) );

	initial begin
		data_in_1 = 32'hFF; 
		data_in_2 = 32'hA5; 
		sel = 0;
		#10;
		if (data_out !== data_in_1) 
			$display("ERRO 1: y=%h", data_out); 
		else 
			$display("OK 1");

		sel = 1;
		#10;
		if (data_out !== data_in_2) 
			$display("ERRO 2: y=%h", data_out); 
		else 
			$display("OK 2");

		sel = 1;
		data_in_2 = 32'h12345678; 
	
		#10
		if (data_out !== data_in_2) 
			$display("ERRO 3: y=%h", data_out); 
		else 
			$display("OK 3");
			
		sel = 0;
		data_in_1 = 32'h345621;	
	
		#10
		if (data_out !== data_in_1) 
			$display("ERRO 4: y=%h", data_out); 
		else 
			$display("OK 4");
			
		sel = 0;
		data_in_1 = 32'hFFFFFFFF;
	
		#10
		if (data_out !== data_in_1) 
			$display("ERRO 5.0: y=%h", data_out); 
		else 
			$display("OK 5.0");
			
		sel = 1;
		data_in_2 = 32'hAAAA5555;	
	
		#10
		if (data_out !== data_in_2) 
			$display("ERRO 5.1: y=%h", data_out); 
		else 
			$display("OK 5.1");
		$stop;
	end
endmodule