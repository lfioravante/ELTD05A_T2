`timescale 1ns/1ps
module register_TB;
	reg clk ;                
	reg rst ;                
	reg  [31:0] data_in ;    
	wire [31:0] data_out ;         

	register #(32) DUT ( .clk(clk), .rst(rst), .data_in(data_in), .data_out(data_out) );

	initial clk = 0;
	always #10 clk = ~clk;

	initial begin
		rst = 1;
		data_in = 0;

		#20 rst = 0;                                  

		data_in = 32'h12345678;                       
		#5;                                           
			$display("antes da borda: out=%h (ainda o valor antigo)", data_out);
		#15;                                          
		if (data_out !== data_in) 
			$display("ERRO 3a: out=%h", data_out);
		else                       
			$display("OK 3a");

		data_in = 32'hFF;
		#5;
		$display("antes da borda: out=%h (ainda o valor antigo)", data_out);
		#15;
		if (data_out !== data_in) $display("ERRO 3b: out=%h", data_out);
		else                       
			$display("OK 3b");

		data_in = 32'hAA00;
		#5;
		$display("antes da borda: out=%h (ainda o valor antigo)", data_out);
		#15;
		if (data_out !== data_in) $display("ERRO 3c: out=%h", data_out);
		else                       
			$display("OK 3c");

		rst = 1;
		#5;                                        
		if (data_out !== 0) 
			$display("ERRO 4: out=%h", data_out);
		else                       
			$display("OK 4 (reset assincrono)");
		#15;                                        
		rst = 0;

		// 5) fim
		$stop;
	end
endmodule