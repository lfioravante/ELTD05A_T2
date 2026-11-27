module pc #(
    parameter WIDTH      = 32,
    parameter RESET_ADDR = 32'h0000_0000
)(
    input                  clk,
    input                  rst,
    input      [WIDTH-1:0] data_in,      // Retorno do somador PC + 4
    input                  jmpFlag,      // Controle de salto incondicional (ID)
    input      [25:0]      jmpAddress,   // Endereco de salto (ID)
    input                  branchFlag,   // Controle de desvio condicional BNE (ID/EX)
    input                  zeroFlag,     // Saida zero da ALU (EX)
    input      [WIDTH-1:0] branchOffset, // Imediato estendido de IMM (ID/EX)
    output reg [WIDTH-1:0] data_out,     // Endereco atual do PC
    output                 flush_ctrl,   // Limpeza sincrona de CTRL em ID/EX
    output                 flush_if      // Mascara de instrucao na sombra da InstMem
);
    wire branch_taken = branchFlag & ~zeroFlag;
    wire jmp_taken    = jmpFlag & ~branch_taken;

    // No ciclo de EX da instrucao BNE, data_out equivale a PC_BNE + 8;
    // subtrair 4 alinha o calculo a PC_BNE + 4 conforme os offsets de Code.hex
    wire [WIDTH-1:0] branch_target = (data_out - 32'd4) + branchOffset;
    wire [WIDTH-1:0] jmp_target    = {data_out[WIDTH-1:26], jmpAddress};

    assign flush_ctrl = branch_taken;
    assign flush_if   = branch_taken | jmp_taken;

    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= RESET_ADDR;
        else if (branch_taken)
            data_out <= branch_target;
        else if (jmp_taken)
            data_out <= jmp_target;
        else
            data_out <= data_in;
    end

endmodule