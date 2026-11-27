module alu #(parameter WIDTH = 32)(
    input      [WIDTH-1:0] data_in_1,
    input      [WIDTH-1:0] data_in_2,
    input      [1:0]       bits_sel,
    output reg [WIDTH-1:0] data_out,
    output                 zero
);
    wire [WIDTH-1:0] op_b        = bits_sel[0] ? ~data_in_2 : data_in_2;
    wire [WIDTH-1:0] add_sub_out = data_in_1 + op_b + {{(WIDTH-1){1'b0}}, bits_sel[0]};
    wire [WIDTH-1:0] logic_out   = bits_sel[0] ? (data_in_1 | data_in_2) : (data_in_1 & data_in_2);

    always @(*) begin
        data_out = bits_sel[1] ? logic_out : add_sub_out;
    end

    assign zero = ~(|data_out);

endmodule