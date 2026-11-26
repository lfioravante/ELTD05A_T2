`timescale 1ns / 1ps

module Counter_TB;
    reg load, sh, clk, rst;
    wire K;

    Counter dut (
        .Load(load),
        .Sh(sh),
        .Clk(clk),
        .rst(rst),
        .K(K)
    );

    initial clk = 0;
	 always #10 clk = ~clk;

    initial begin
        load = 1'b0; sh = 1'b0; rst = 1'b1;
        
        @(negedge clk);
        @(negedge clk);
        rst = 1'b0;

        @(negedge clk);
        load = 1'b1;
        @(negedge clk);
        load = 1'b0;

        @(negedge clk);
        sh = 1'b1;
        repeat(14) @(negedge clk);
        
		  if(K!==0)
				$display("ERRO 1: K=%h", K);
		  else
				$display("OK 1: K=%h", K);
			
        @(negedge clk);
		  
		  if(K!==1)
				$display("ERRO 2: K=%h", K);
		  else
				$display("OK 2: K=%h", K);
				
		  @(negedge clk);
		  if(K!==0)
				$display("ERRO 3: K=%h", K);
		  else
				$display("OK 3: K=%h", K);
		  
		  repeat(14) @(negedge clk);
		  load = 1;
		  @(negedge clk);
		  if(K!==0)
				$display("ERRO 4: K=%h", K);
		  else
				$display("OK 4: K=%h", K);
				
		  sh = 0;
		  load = 0;
		  $stop;
		  
    end

    initial begin
        $monitor("Tempo=%0t | rst=%b | Load=%b | Sh=%b | K=%b", $time, rst, load, sh, K);
    end
endmodule
