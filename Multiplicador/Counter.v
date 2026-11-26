module Counter #(parameter N = 16) (
    input Load, Sh, Clk, rst,
    output K
);
    // Registrador interno dimensionado para contar as iterações
    reg [$clog2(N)-1:0] count;

    assign K = (count == N-1);

    // Bloco sequencial de incremento e reinicialização
    always @(posedge Clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else if (Load) begin
            count <= 0;
        end else if (Sh) begin
            count <= count + 1'b1;
        end
    end

endmodule