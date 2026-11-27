module ACC #(parameter N = 16)(
    input          Load, Sh, Ad, Clk, rst,
    input  [2*N:0] Entradas,
    output [2*N:0] Saidas
);
    reg [2*N:0] acc_reg;

    assign Saidas = acc_reg;

    always @(posedge Clk or posedge rst) begin
        if (rst) begin
            acc_reg <= {(2*N+1){1'b0}};
        end else begin
            case ({Load, Ad, Sh})
                3'b100: begin
                    // Carrega o multiplicador nos N bits inferiores e zera a porcao superior
                    acc_reg[2*N:N] <= {(N+1){1'b0}};
                    acc_reg[N-1:0] <= Entradas[N-1:0];
                end
                3'b010: begin
                    // Carrega a soma parcial com carry-out na porcao superior
                    acc_reg[2*N:N] <= Entradas[2*N:N];
                end
                3'b001: begin
                    // Deslocamento logico de 1 bit para a direita
                    acc_reg <= {1'b0, acc_reg[2*N:1]};
                end
                default: begin
                    acc_reg <= acc_reg;
                end
            endcase
        end
    end

endmodule