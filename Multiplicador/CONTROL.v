module CONTROL (
    input Clk, K, St, M, rst,
    output reg Idle, Done, Load, Sh, Ad
);
    // Parametrização para estado
    localparam [1:0] 
        S0_IDLE  = 2'b00,
        S1_CHECK = 2'b01,
        S2_SHIFT = 2'b10,
        S3_DONE  = 2'b11;

    reg [1:0] current_state, next_state;

    // Bloco de sincronismo
    always @(posedge Clk or posedge rst) begin
        if (rst) begin
            current_state <= S0_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Bloco de decodificação lógica (Prevenção de latches indesejados)
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
                if (M) begin
                    Ad = 1'b1;
                end
                next_state = S2_SHIFT;
            end

            S2_SHIFT: begin
                Sh = 1'b1;
                if (K) begin
                    next_state = S3_DONE;
                end else begin
                    next_state = S1_CHECK;
                end
            end

            S3_DONE: begin
                Done = 1'b1;
                if (!St) begin
                    next_state = S0_IDLE;
                end
            end

            default: next_state = S0_IDLE;
        endcase
    end
endmodule