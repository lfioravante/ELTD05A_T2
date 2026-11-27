module ADDRDecoding_Prog #(
    parameter BASE = 32'h0000_0000
)(
    input  [31:0] ADDR,
    output        CS,
    output [9:0]  iAddress
);
    wire [31:0] offset = ADDR - BASE;

    // Equivalente a (ADDR >= BASE) && (ADDR < BASE + 32'h1000)
    assign CS       = ~(|offset[31:12]);
    assign iAddress = offset[11:2];

endmodule