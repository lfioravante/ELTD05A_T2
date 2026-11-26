module pc #(parameter WIDTH = 32, parameter RESET_ADDR = 32'h00001000) (
    input  clk,                 // clock
    input  rst,                 // reset
    input  [WIDTH-1:0] data_in,     // entrada
    output reg [WIDTH-1:0] data_out  // saída
);
    always @(posedge clk or posedge rst ) begin
        if ( rst )
            data_out <= RESET_ADDR;
        else
            data_out <= data_in;
    end
endmodule