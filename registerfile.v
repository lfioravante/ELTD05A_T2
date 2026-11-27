module registerfile #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
) (
    input                       clk,
    input                       reset,
    input                       wr,
    input      [DATA_WIDTH-1:0] dataIn,
    input      [ADDR_WIDTH-1:0] wrAddress,
    input      [ADDR_WIDTH-1:0] rdAddress1,
    input      [ADDR_WIDTH-1:0] rdAddress2,
    output reg [DATA_WIDTH-1:0] dataOut1,
    output reg [DATA_WIDTH-1:0] dataOut2
);
    localparam NUM_REGISTERS = 2**ADDR_WIDTH;
    integer i;

    reg [DATA_WIDTH-1:0] registers [1:NUM_REGISTERS-1];

    // Escrita sincrona com reset assincrono (r0 fixo em zero)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 1; i < NUM_REGISTERS; i = i + 1)
                registers[i] <= {DATA_WIDTH{1'b0}};
        end else if (wr && (wrAddress != {ADDR_WIDTH{1'b0}})) begin
            registers[wrAddress] <= dataIn;
        end
    end

    // Leitura combinacional 1 com bypass Write-First (WB -> ID no mesmo ciclo)
    always @(*) begin
        if (rdAddress1 == {ADDR_WIDTH{1'b0}})
            dataOut1 = {DATA_WIDTH{1'b0}};
        else if (wr && (wrAddress == rdAddress1))
            dataOut1 = dataIn;
        else
            dataOut1 = registers[rdAddress1];
    end

    // Leitura combinacional 2 com bypass Write-First (WB -> ID no mesmo ciclo)
    always @(*) begin
        if (rdAddress2 == {ADDR_WIDTH{1'b0}})
            dataOut2 = {DATA_WIDTH{1'b0}};
        else if (wr && (wrAddress == rdAddress2))
            dataOut2 = dataIn;
        else
            dataOut2 = registers[rdAddress2];
    end
endmodule