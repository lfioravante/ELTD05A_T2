`timescale 1ns / 100ps

module ACC_TB;
    reg load, sh, ad, clk, rst;
    reg  [32:0] entradas;
    wire [32:0] saidas;
    
    // Descritor de ficheiro
    integer file_out;

    ACC dut (
        .Load(load),
        .Sh(sh),
        .Ad(ad),
        .Clk(clk),
        .rst(rst),
        .Entradas(entradas),
        .Saidas(saidas)
    );

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    initial begin
        load = 0; sh = 0; ad = 0;
        entradas = 0; rst = 1;
        
        @(negedge clk);
        @(negedge clk);
		  
		  
        rst = 0;
        @(negedge clk);
		  if(saidas !== {17'h00000, 16'h0000})
				$display("ERRO 1: saidas=%h", saidas);
		  else
				$display("OK 1: saidas=%h", saidas);
		  
		  
        entradas = {17'h1FFFF, 16'hABCD};
		  load = 1;
        @(negedge clk);
		  if(saidas !== {17'h0000, 16'hABCD})
				$display("ERRO 2: saidas=%h", saidas);
		  else
				$display("OK 2: saidas=%h", saidas);
        
		  load = 0;
        ad = 1;
		  entradas = {17'h12345, 16'hFFFF};
        @(negedge clk);
		  if(saidas !== {17'h12345, 16'hABCD})
				$display("ERRO 3: saidas=%h", saidas);
		  else
				$display("OK 3: saidas=%h", saidas);
				
				
		  ad = 0;
		  sh = 1;
        @(negedge clk);
        if(saidas !== {17'h91A2, 16'hD5E6})
				$display("ERRO 4: saidas=%h", saidas);
		  else
				$display("OK 4: saidas=%h", saidas);
		  
        repeat(2) @(negedge clk);
        sh = 0;
		  

        @(negedge clk);
        $fclose(file_out);
        $stop;
    end

    initial begin
        // Abertura do ficheiro para escrita
        file_out = $fopen("resultados_acc.txt", "w");
        
        // Monitoramento no terminal
        $monitor("Tempo=%0t | Load=%b | Ad=%b | Sh=%b | Entradas=%b | Saidas=%b", 
                 $time, load, ad, sh, entradas, saidas);
                 
        // Monitoramento direccionado ao ficheiro
        $fmonitor(file_out, "Tempo=%0t | Load=%b | Ad=%b | Sh=%b | Entradas=%b | Saidas=%b", 
                  $time, load, ad, sh, entradas, saidas);
    end
endmodule