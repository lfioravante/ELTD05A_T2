module ACC #(parameter N = 16)(
    input Load, Sh, Ad, Clk, rst,
    input [2*N:0] Entradas,
    output [2*N:0] Saidas
);
    // Registrador interno do acumulador
    reg [2*N:0] acc_reg;

    // A saída reflete continuamente o estado do registrador
    assign Saidas = acc_reg;

    // Bloco sequencial síncrono
    always @(posedge Clk or posedge rst) begin
        if (rst) begin
            acc_reg <= 0;
        end else begin
            if (Load) begin
                // Carrega os bits 3 a 0 com o multiplicador e zera os bits 8 a 4
                acc_reg[2*N:N] <= 0;
                acc_reg[N-1:0] <= Entradas[N-1:0];
            end else if (Ad) begin
                // Carrega a saída do somador (bits 8 a 4 de Entradas) na porção superior
                acc_reg[2*N:N] <= Entradas[2*N:N];
            end else if (Sh) begin
                // Desloca todos os bits registrados 1 posição para a direita
                acc_reg <= {1'b0, acc_reg[2*N:1]};
            end
        end
    end

endmodule