`timescale 1ns/1ps
module alu_TB;
	reg [31:0] data_in_1;    
	reg [31:0] data_in_2;
	reg [1:0] bits_sel;
	wire [31:0] data_out; 
	wire zero;
	
	
	alu #(.WIDTH(32)) DUT ( .data_in_1(data_in_1), .data_in_2(data_in_2), .bits_sel(bits_sel), .data_out(data_out), .zero(zero) );

	initial begin
		bits_sel = 2'b00;
		data_in_1 = 32'h5;
		data_in_2 = 32'h3;
		
		#10
		if(data_out === 32'h8 && zero === 1'b0)
			$display("OK 1: out=%h", data_out);
		else
			$display("ERRO 1: out=%h", data_out);
			
		data_in_1 = 32'hFFFFFFFF;
		data_in_2 = 32'h1;
		#20
		if(data_out === 32'h0 && zero === 1'b1)
			$display("OK 2: out=%h e zero=%h", data_out, zero);
		else
			$display("ERRO 2: out=%h", data_out);
			
		bits_sel = 2'b01;
		data_in_1 = 32'h5;
		data_in_2 = 32'h3;
		
		#20
		if(data_out === 32'h2 && zero === 1'b0)
			$display("OK 3: out=%h", data_out);
		else
			$display("ERRO 3: out=%h", data_out);
		
		data_in_1 = 32'h3;
		data_in_2 = 32'h5;
		#20
		if(data_out === 32'hFFFFFFFE && zero === 1'b0)
			$display("OK 4: out=%h", data_out);
		else
			$display("ERRO 4: out=%h", data_out);
			
		data_in_1 = 32'h5;
		data_in_2 = 32'h5;
		#20
		if(data_out === 32'h0 && zero === 1'b1)
			$display("OK 5: out=%h e zero=%h", data_out, zero);
		else
			$display("ERRO 5: out=%h", data_out);
		
		bits_sel = 2'b10;
		data_in_1 = 32'hFFFF0000;
		data_in_2 = 32'h0F0F0F0F;
		#20
		if(data_out === 32'h0F0F0000 && zero === 1'b0)
			$display("OK 6: out=%h", data_out);
		else
			$display("ERRO 6: out=%h", data_out);
		
		
		bits_sel = 2'b11;
		#20
		if(data_out === 32'hFFFF0F0F && zero === 1'b0)
			$display("OK 7: out=%h ", data_out);
		else
			$display("ERRO 7: out=%h", data_out);
		$stop;
	end
	
endmodule