`timescale 1ns/1ps
module pc_TB;
	reg clk ;                
	reg rst ;                
	reg  [31:0] data_in ;    
	wire [31:0] data_out ; 
	localparam RESET_ADDR = 32'h00001000;
	
	pc #(.WIDTH(32), .RESET_ADDR(RESET_ADDR)) DUT ( .clk(clk), .rst(rst), .data_in(data_in), .data_out(data_out) );

	initial clk = 0;
	always #10 clk = ~clk;
	initial begin
		rst = 1;
		data_in = 0;
                   
		#5;
		if (data_out !== RESET_ADDR) 
			$display("ERRO 1: out=%h", data_out);
		else                       
			$display("OK 1");		
			
		
		#15;  
		
		rst = 0;
		data_in = data_out + 4;
		#5
		if (data_out !== RESET_ADDR) 
			$display("ERRO 2: out=%h", data_out);
		else                       
			$display("OK 2");
		#15;
		if (data_out !== RESET_ADDR + 4) $display("ERRO 3: out=%h", data_out);
		else                       
			$display("OK 3");

			
		data_in = data_out + 4;
		#5;
		$display("antes da borda: out=%h (ainda o valor antigo)", data_out);
		#15;
		if (data_out !== RESET_ADDR + 8) $display("ERRO 4: out=%h", data_out);
		else                       
			$display("OK 4");
			
		data_in = data_out + 4;
		#5;
		$display("antes da borda: out=%h (ainda o valor antigo)", data_out);
		#15;
		if (data_out !== RESET_ADDR + 12) $display("ERRO 5: out=%h", data_out);
		else                       
			$display("OK 5");
		
		rst = 1;
		#1;
		if (data_out !== RESET_ADDR) 
			$display("ERRO 6: out=%h", data_out); 
		else 
			$display("OK 6");	
			
		#19;
		rst = 0;
		
		$stop;
	end
endmodule