module CONTROL (
    input      Clk, K, St, M, rst,
    output reg Idle, Done, Load, Sh, Ad
);
    // Codificacao One-Hot dos estados para menor atraso no dominio CLK_MUL
    localparam [3:0]
        S0_IDLE  = 4'b0001,
        S1_CHECK = 4'b0010,
        S2_SHIFT = 4'b0100,
        S3_DONE  = 4'b1000;

    reg [3:0] current_state, next_state;

    always @(posedge Clk or posedge rst) begin
        if (rst)
            current_state <= S0_IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        Load       = 1'b0;
        Sh         = 1'b0;
        Ad         = 1'b0;
        Idle       = 1'b0;
        Done       = 1'b0;
        next_state = current_state;

        case (current_state)
            S0_IDLE: begin
                Idle = 1'b1;
                if (St) begin
                    Load       = 1'b1;
                    next_state = S1_CHECK;
                end
            end

            S1_CHECK: begin
                if (M)
                    Ad = 1'b1;
                next_state = S2_SHIFT;
            end

            S2_SHIFT: begin
                Sh = 1'b1;
                if (K)
                    next_state = S3_DONE;
                else
                    next_state = S1_CHECK;
            end

            S3_DONE: begin
                Done = 1'b1;
                if (!St)
                    next_state = S0_IDLE;
            end

            default: next_state = S0_IDLE;
        endcase
    end

endmodule