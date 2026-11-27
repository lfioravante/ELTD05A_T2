module pc #(
    parameter WIDTH      = 32,
    parameter RESET_ADDR = 32'h0000_0000
)(
    input                  clk,
    input                  rst,
    input      [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= RESET_ADDR;
        else
            data_out <= data_in;
    end
endmodule