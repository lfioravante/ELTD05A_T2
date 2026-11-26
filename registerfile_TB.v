`timescale 1ns/1ps
module registerfile_TB;
	reg clk, reset, wr;
	reg  [31:0] dataIn;
	reg  [4:0]  wrAddress, rdAddress1, rdAddress2;
	wire [31:0] dataOut1, dataOut2;

	registerfile #(.DATA_WIDTH(32), .ADDR_WIDTH(5)) dut (
		.clk(clk), .reset(reset), .wr(wr), .dataIn(dataIn),
		.wrAddress(wrAddress), .rdAddress1(rdAddress1),
		.rdAddress2(rdAddress2), .dataOut1(dataOut1), .dataOut2(dataOut2)
	);

	always #10 clk = ~clk;

	initial begin
		clk = 0; 
		reset = 1; 
		wr = 0; 
		dataIn = 0;
		wrAddress = 0; 
		rdAddress1 = 0; 
		rdAddress2 = 0;
		#25  //25
		reset = 0;          
		
		dataIn = 32'hFF;
		wr = 1;
		wrAddress = 5;
		#10	//35
		wr = 0;
		rdAddress1 = 5;
		rdAddress2 = 5;
		#5	//40
		if(dataOut1 !== dataIn || dataOut2  !== dataIn)
			$display("ERRO 1");
		else
			$display("OK 1");
			
			
		wr = 1;
		wrAddress = 0;
		dataIn = 32'hAA;
		#15	//55
		
		wr = 0;
		rdAddress1 = 0;
		rdAddress2 = 0;
		
		#5	//60
		
		if(dataOut1 !== 32'h0 || dataOut2 !== 32'h0)
			$display("ERRO 2");
		else
			$display("OK 2");
		
		
		wr = 0;
		wrAddress = 5;
		dataIn = 32'hAA;
		#15 //75
		
		wr = 0;
		rdAddress1 = 5;
		rdAddress2 = 5;
		
		#5	//80
		
		if(dataOut1 !== 32'hFF || dataOut2 !== 32'hFF)
			$display("ERRO 3");
		else
			$display("OK 3");
			
		wr = 1;
		wrAddress = 7;
		dataIn = 32'h88;
		#15 //95
		
		wr = 0;
		rdAddress1 = 5;
		rdAddress2 = 7;
		#5 //100
		
		if(dataOut1 !== 32'hFF || dataOut2 !== 32'h88)
			$display("ERRO 4");
		else
			$display("OK 4");
			
		reset = 1;
		#5  //105
		if(dataOut1 !== 32'h0 || dataOut2 !== 32'h0)
			$display("ERRO 5");
		else
			$display("OK 5");
		#15 //120
		reset = 0;
		#5	//125
		if(dataOut1 !== 32'h0 || dataOut2 !== 32'h0)
			$display("ERRO 5.b");
		else
			$display("OK 5.b");
		
		
	
		
		wr = 1;
		wrAddress = 9;
		dataIn = 32'h99;
		rdAddress1 = 9;
		rdAddress2 = 9;
		#2 //127
		if(dataOut1 !== 32'h0 || dataOut2 !== 32'h0)
			$display("ERRO 6");
		else
			$display("OK 6");
			
		#8 //135
		if(dataOut1 !== 32'h99 || dataOut2 !== 32'h99)
			$display("ERRO 6.b");
		else
			$display("OK 6.b");
		
		
		$stop;
	end
endmodule