module ADDRDecoding #(
    parameter BASE = 32'hC97      
) (
    input  [31:0] ADDR,
    input         WE,
    output        CS,
    output [9:0]  iAddress,
    output        iWE
);
    wire [31:0] offset = ADDR - BASE;
    assign CS       = (ADDR >= BASE) && (ADDR < BASE + 32'h400);   
    assign iAddress = offset[9:0];                            
    assign iWE      = CS & WE;                              
endmodule