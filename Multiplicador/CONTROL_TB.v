`timescale 1ns / 1ps

module CONTROL_TB;
    reg clk, k, st, m, rst;
    wire idle, done, load, sh, ad;

    CONTROL dut (
        .Clk(clk),
        .K(k),
        .St(st),
        .M(m),
        .rst(rst),
        .Idle(idle),
        .Done(done),
        .Load(load),
        .Sh(sh),
        .Ad(ad)
    );

    initial clk = 0;
	 always #10 clk = ~clk;     

    initial begin
        k = 1'b0; st = 1'b0; m = 1'b0; rst = 1'b1;
        
        
		  #15	
        rst = 1'b0;
		  if(idle!==1)
				$display("ERRO 1: idle=%h", idle);
		  else
				$display("OK 1: idle=%h", idle);
		
        st = 1'b1;
		  #2
		  if(load!==1)
				$display("ERRO 2: load=%h", load);
		  else
				$display("OK 2: load=%h", load);
		  #18 //35
        st = 1'b0;
			
        m = 1'b1;
        #2
		  if(ad!==1)
				$display("ERRO 3: ad=%h", ad);
		  else
				$display("OK 3: ad=%h", ad);
		  
        k = 1'b0;
		  #18 //55
		  if(sh!==1)
				$display("ERRO 4: sh=%h", sh);
		  else
				$display("OK 4: sh=%h", sh);
		  
		  #2
        m = 1'b0;
		  if(ad!==0)
				$display("ERRO 5: ad=%h", ad);
		  else
				$display("OK 5: ad=%h", ad);
		  
        k = 1'b1;
		  #18 //75
		  if(done!==1)
				$display("ERRO 6: done=%h", done);
		  else
				$display("OK 6: done=%h", done);

		  #20 //95
		  if(idle!==1)
				$display("ERRO 7: idle=%h", idle);
		  else
				$display("OK 7: idle=%h", idle);

		  
        k = 1'b0;
        
        @(negedge clk);
        $stop;
    end

    initial begin
        $monitor("Tempo=%0t | rst=%b | St=%b | M=%b | K=%b || Idle=%b | Load=%b | Ad=%b | Sh=%b | Done=%b", 
                 $time, rst, st, m, k, idle, load, ad, sh, done);
    end
endmodule