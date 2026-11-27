module register #(
    parameter WIDTH     = 32,
    parameter USE_RESET = 1
)(
    input                  clk,
    input                  rst,
    input      [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);
    generate
        if (USE_RESET) begin : g_rst
            always @(posedge clk or posedge rst) begin
                if (rst)
                    data_out <= {WIDTH{1'b0}};
                else
                    data_out <= data_in;
            end
        end else begin : g_no_rst
            always @(posedge clk) begin
                data_out <= data_in;
            end
        end
    endgenerate

endmodule