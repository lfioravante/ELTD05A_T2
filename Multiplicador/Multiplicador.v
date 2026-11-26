module Multiplicador #(parameter N=16)(
    input [N-1:0] Multiplicando, 
    input [N-1:0] Multiplicador,
    input St, Clk, rst,
    output [2*N-1:0] Produto,
    output Idle, Done
);

// Fios de controle
wire Load, Sh, Ad, K, M;

// Fios de dados (Datapath)
wire [N:0] soma_out;
wire [2*N:0] acc_saidas;

// A flag M extrai o bit menos significativo (LSB) do acumulador
assign M = acc_saidas[0];

// O produto final corresponde aos 8 bits inferiores do acumulador
assign Produto = acc_saidas[2*N-1:0];

Adder #(.WIDTH(N)) adder (
    .OperandoA(Multiplicando), 
    .OperandoB(acc_saidas[2*N-1:N]),
    .Soma(soma_out)
);

ACC #(.N(N)) acc(
    .Load(Load), 
    .rst(rst),
    .Sh(Sh), 
    .Ad(Ad), 
    .Clk(Clk), 
    .Entradas({soma_out, Multiplicador}),
    .Saidas(acc_saidas)
);

CONTROL control(
    .Clk(Clk), 
    .rst(rst),
    .K(K), 
    .St(St), 
    .M(M),
    .Idle(Idle), 
    .Done(Done), 
    .Load(Load), 
    .Sh(Sh),
    .Ad(Ad)
);

Counter #(.N(N)) counter(
    .Load(Load),
    .Sh(Sh),
    .rst(rst),
    .Clk(Clk),
    .K(K)
);

endmodule