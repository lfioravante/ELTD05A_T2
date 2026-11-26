`timescale 1ns / 1ps

module Multiplicador_TB;
	 localparam N = 16;
    // Sinais de Entrada
    reg [N-1:0] multiplicando;
    reg [N-1:0] multiplicador;
    reg st;
    reg clk;
    reg rst;

    // Sinais de Saída
    wire [2*N-1:0] produto;
    wire idle;
    wire done;
	 
	 integer t_st, t_done;


    // Descritor para gravação de arquivo
    integer file_out;

    // Instanciação do módulo sob teste (DUT)
    Multiplicador dut (
        .Multiplicando(multiplicando),
        .Multiplicador(multiplicador),
        .St(st),
        .Clk(clk),
        .rst(rst),
        .Produto(produto),
        .Idle(idle),
        .Done(done)
    );

    // Geração de Clock (Período de 10 unidades de tempo)
    initial clk = 0;
	 always #10 clk = ~clk;
        

    initial begin
        multiplicando = 4'd0;
        multiplicador = 4'd0;
        st = 1'b0;
        rst = 1'b1;

		  #15 //15
        rst = 1'b0;
		  #5 //20
		  
        multiplicando = 13;
        multiplicador = 11;
		  
        st = 1'b1;
		  t_st = $time;
		  
		  #20 //40
		  st = 1'b0;
        wait (done == 1'b1);
		  t_done = $time;
		  #1 //41
		  
		  if(produto!==32'd143)
				$display("ERRO 1: produto=%h", produto);
		  else
				$display("OK 1: produto=%h", produto);

		  $display("   St em %0d ns, Done em %0d ns -> %0d subidas de clock",
                 t_st, t_done, (t_done - t_st + 10) / 20);
        
        #4 //45
		  wait(idle ==1'b1);
		  @(negedge clk);
		  
		  st = 1;
		  multiplicando = 0;
        multiplicador = 16'hFFFF;
		  #20 //60
		  st = 1'b0;
        wait (done == 1'b1);
		  #1 //61
		  
		  if(produto!==0)
				$display("ERRO 2: produto=%h", produto);
		  else
				$display("OK 2: produto=%h", produto);
		  
        #4 //65
		  wait(idle ==1'b1);
		  @(negedge clk);
		  
		  st = 1;
		  multiplicando = 1;
        multiplicador = 16'hFFFF;
		  #20
		  st = 1'b0;
		  wait (done == 1'b1);

		  #1
		  if(produto!==32'h0000FFFF)
				$display("ERRO 3: produto=%h", produto);
		  else
				$display("OK 3: produto=%h", produto);
		  #4
        wait(idle ==1'b1);
		  @(negedge clk);
		  
		  st = 1;
		  multiplicando = 16'hFFFF;
        multiplicador = 16'hFFFF;
		  #20
		  st = 1'b0;
		  wait (done == 1'b1);
		  
		  #1
		  if(produto!==32'hFFFE0001)
				$display("ERRO 4: produto=%h", produto);
		  else
				$display("OK 4: produto=%h", produto);
				
        #4
		  wait(idle ==1'b1);
		  @(negedge clk);
		  
		  st = 1;
		  multiplicando = 145;
        multiplicador = 255;
		  #20
		  st = 1'b0;
		  wait (done == 1'b1);
		  #1
		  if(produto!==36975)
				$display("ERRO 5: produto=%h", produto);
		  else
				$display("OK 5: produto=%h", produto);
        
        $stop;
    end

    // Tarefa de monitoramento dinâmico via console e arquivo
    initial begin
        
        // Monitoramento no console
        $monitor("Tempo: %0t | rst=%b | st=%b | Multiplicando=%d | Multiplicador=%d | Produto=%d | Idle=%b | Done=%b",
                 $time, rst, st, multiplicando, multiplicador, produto, idle, done);
                 
        
    end

endmodule