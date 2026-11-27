module ADDRDecoding #(
    parameter BASE = 32'h0000_0C97
)(
    input  [31:0] ADDR,
    input         WE,
    output        CS,
    output [9:0]  iAddress,
    output        iWE
);
    wire [31:0] offset = ADDR - BASE;

    // Equivalente a (ADDR >= BASE) && (ADDR < BASE + 32'h400) sem comparadores de 32 bits
    assign CS       = ~(|offset[31:10]);
    assign iAddress = offset[9:0];
    assign iWE      = CS & WE;

endmodule