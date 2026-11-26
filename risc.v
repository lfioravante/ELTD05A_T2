/*
 * ============================================================================
 * UNIVERSIDADE FEDERAL DE ITAJUBA - UNIFEI
 * ELTD15 - LABORATORIO DE SISTEMAS DIGITAIS
 * TRABALHO II - PROCESSADOR RISC PIPELINED DE 5 ESTAGIOS (GRUPO 11)
 *
 * Preencher as respostas as alineas a) a g) com os valores extraidos do
 * TimeQuest Timing Analyzer apos a compilacao na FPGA Cyclone IV GX.
 * ============================================================================
 */

module risc #(
    parameter WIDTH      = 32,
    parameter GRUPO      = 11,
    parameter BASE_PROG  = 32'h0000_0000,
    parameter BASE_DADOS = 32'h0000_0C97
)(
    input  [WIDTH-1:0] Data_BUS_READ,
    input  [WIDTH-1:0] Prog_BUS_READ,
    input              CLK,
    input              RST,

    output [WIDTH-1:0] ADDR_Prog,
    output             CS_P,
    output [WIDTH-1:0] ADDR,
    output [WIDTH-1:0] Data_BUS_WRITE,
    output             WE,
    output             CS
);

    // =========================================================================
    // 1. Geracao de Relogios (PLL) e Reset Sincronizado
    // =========================================================================
    (* keep = 1 *) wire CLK_SYS, CLK_MUL;
    wire locked;
    wire rst_sys = RST | ~locked;

    PLL u_PLL (
        .areset (RST),
        .inclk0 (CLK),
        .c0     (CLK_SYS),
        .c1     (CLK_MUL),
        .locked (locked)
    );

    // =========================================================================
    // 2. Estagio IF (Instruction Fetch) - BRAM absorve IF/ID
    // =========================================================================
    (* keep = 1 *) wire [WIDTH-1:0] PC;
    wire [WIDTH-1:0] PC_plus4 = PC + 32'd4;
    wire [WIDTH-1:0] PC_next;

    wire [WIDTH-1:0] instmem_q;
    wire [9:0]       prog_iAddress;

    // Alinhamento de CS_P, Prog_BUS_READ e flush com a latencia de 1 ciclo da BRAM
    reg              id_CS_P;
    reg  [WIDTH-1:0] id_prog_bus_read;
    reg              flush_if;

    // Sinais de salto/desvio provenientes de ID e EX
    wire             jmpFlag;
    wire [25:0]      jmpAddress;
    wire             branch_taken;
    wire [WIDTH-1:0] branch_target;

    // Endereco de JMP codificado em bytes conforme Code.hex
    wire [WIDTH-1:0] jmp_target = {PC[31:26], jmpAddress};
    wire             jmp_taken  = jmpFlag & ~branch_taken;

    // Prioridade: BNE em EX > JMP em ID > PC + 4
    assign PC_next   = branch_taken ? branch_target :
                       jmp_taken    ? jmp_target    :
                                      PC_plus4;
    assign ADDR_Prog = PC;

    pc #(
        .WIDTH      (WIDTH),
        .RESET_ADDR (BASE_PROG)
    ) u_pc (
        .clk      (CLK_SYS),
        .rst      (rst_sys),
        .data_in  (PC_next),
        .data_out (PC)
    );

    // ADDRDecoding_Prog.v: CS = 1 -> Memoria Interna; CS = 0 -> Memoria Externa
    ADDRDecoding_Prog #(
        .BASE (BASE_PROG)
    ) u_ADDRDecoding_Prog (
        .ADDR     (PC),
        .CS       (CS_P),
        .iAddress (prog_iAddress)
    );

    InstMem u_InstMem (
        .address (prog_iAddress),
        .clock   (CLK_SYS),
        .q       (instmem_q)
    );

    always @(posedge CLK_SYS or posedge rst_sys) begin
        if (rst_sys) begin
            id_CS_P          <= 1'b1;
            id_prog_bus_read <= {WIDTH{1'b0}};
            flush_if         <= 1'b1;
        end else begin
            id_CS_P          <= CS_P;
            id_prog_bus_read <= Prog_BUS_READ;
            flush_if         <= branch_taken | jmp_taken;
        end
    end

    wire [WIDTH-1:0] inst_mux_out;

    // mux.v: sel = 0 -> data_in_1 (Mem. Externa); sel = 1 -> data_in_2 (Mem. Interna)
    mux #(.WIDTH(WIDTH)) u_mux_inst (
        .data_in_1 (id_prog_bus_read),
        .data_in_2 (instmem_q),
        .sel       (id_CS_P),
        .data_out  (inst_mux_out)
    );

    (* keep = 1 *) wire [WIDTH-1:0] INST = flush_if ? 32'd0 : inst_mux_out;

    // =========================================================================
    // 3. Estagio ID (Instruction Decode)
    // =========================================================================
    wire [4:0]  rs    = INST[25:21];
    wire [4:0]  rt    = INST[20:16];
    wire [4:0]  rd    = INST[15:11];
    wire [15:0] imm16 = INST[15:0];

    wire [WIDTH-1:0] dataOut1, dataOut2;
    wire [WIDTH-1:0] imm_ext;

    wire             branchFlag;
    wire [1:0]       alu_op;
    wire             alu_src_b, sel_mul, reg_write, mem_read, mem_write, mem_to_reg, reg_dst;

    // Sinais de realimentacao vindos de WB
    (* keep = 1 *) wire [WIDTH-1:0] writeBack_data;
    wire                            wb_reg_write;
    wire [4:0]                      wb_dest;

    registerfile #(
        .DATA_WIDTH (WIDTH),
        .ADDR_WIDTH (5)
    ) u_registerfile (
        .clk        (CLK_SYS),
        .reset      (rst_sys),
        .wr         (wb_reg_write),
        .dataIn     (writeBack_data),
        .wrAddress  (wb_dest),
        .rdAddress1 (rs),
        .rdAddress2 (rt),
        .dataOut1   (dataOut1),
        .dataOut2   (dataOut2)
    );

    control #(.GRUPO(GRUPO)) u_control (
        .inst       (INST),
        .jmpAddress (jmpAddress),
        .jmpFlag    (jmpFlag),
        .branchFlag (branchFlag),
        .alu_op     (alu_op),
        .alu_src_b  (alu_src_b),
        .sel_mul    (sel_mul),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .reg_dst    (reg_dst)
    );

    extend #(
        .WIDTH_IN  (16),
        .WIDTH_OUT (WIDTH)
    ) u_extend (
        .in  (imm16),
        .out (imm_ext)
    );

    wire [4:0]  dest        = reg_dst ? rd : rt;
    wire [12:0] id_ctrl_raw = {reg_write, mem_to_reg, mem_write, branchFlag, sel_mul, alu_src_b, alu_op, dest};
    wire [12:0] id_ctrl_in  = branch_taken ? 13'd0 : id_ctrl_raw;

    // =========================================================================
    // Registrador de Pipeline: ID/EX
    // =========================================================================
    (* keep = 1 *) wire [WIDTH-1:0] ex_A, ex_B, ex_IMM, ex_PC_plus4;
    (* keep = 1 *) wire [12:0]      ex_CTRL;

    register #(.WIDTH(WIDTH)) u_reg_IDEX_A    (.clk(CLK_SYS), .rst(rst_sys), .data_in(dataOut1),   .data_out(ex_A));
    register #(.WIDTH(WIDTH)) u_reg_IDEX_B    (.clk(CLK_SYS), .rst(rst_sys), .data_in(dataOut2),   .data_out(ex_B));
    register #(.WIDTH(WIDTH)) u_reg_IDEX_IMM  (.clk(CLK_SYS), .rst(rst_sys), .data_in(imm_ext),    .data_out(ex_IMM));
    register #(.WIDTH(WIDTH)) u_reg_IDEX_PC4  (.clk(CLK_SYS), .rst(rst_sys), .data_in(PC),         .data_out(ex_PC_plus4));
    register #(.WIDTH(13))    u_reg_IDEX_CTRL (.clk(CLK_SYS), .rst(rst_sys), .data_in(id_ctrl_in), .data_out(ex_CTRL));

    // =========================================================================
    // 4. Estagio EX (Execute)
    // =========================================================================
    wire       ex_reg_write   = ex_CTRL[12];
    wire       ex_mem_to_reg  = ex_CTRL[11];
    wire       ex_mem_write   = ex_CTRL[10];
    wire       ex_branch_flag = ex_CTRL[9];
    wire       ex_sel_mul     = ex_CTRL[8];
    wire       ex_alu_src_b   = ex_CTRL[7];
    wire [1:0] ex_alu_op      = ex_CTRL[6:5];
    wire [4:0] ex_dest        = ex_CTRL[4:0];

    wire [WIDTH-1:0] alu_in_b;
    wire [WIDTH-1:0] alu_out;
    wire             alu_zero;
    wire [WIDTH-1:0] mul_out;
    wire             mul_idle, mul_done;
    (* keep = 1 *) wire [WIDTH-1:0] ex_result;

    // mux.v: sel = 0 -> ex_B; sel = 1 -> ex_IMM
    mux #(.WIDTH(WIDTH)) u_mux_alu_b (
        .data_in_1 (ex_B),
        .data_in_2 (ex_IMM),
        .sel       (ex_alu_src_b),
        .data_out  (alu_in_b)
    );

    alu #(.WIDTH(WIDTH)) u_alu (
        .data_in_1 (ex_A),
        .data_in_2 (alu_in_b),
        .bits_sel  (ex_alu_op),
        .data_out  (alu_out),
        .zero      (alu_zero)
    );

    // Desvio condicional BNE com offset ja codificado em bytes conforme Code.hex
    assign branch_taken  = ex_branch_flag & ~alu_zero;
    assign branch_target = ex_PC_plus4 + ex_IMM;

    // Pulso St de 1 ciclo de CLK_MUL por ciclo de CLK_SYS com MUL ativo
    reg sys_toggle;
    reg sys_toggle_d;

    always @(posedge CLK_SYS or posedge rst_sys) begin
        if (rst_sys) sys_toggle <= 1'b0;
        else         sys_toggle <= ~sys_toggle;
    end

    always @(posedge CLK_MUL or posedge rst_sys) begin
        if (rst_sys) sys_toggle_d <= 1'b0;
        else         sys_toggle_d <= sys_toggle;
    end

    wire mul_start = ex_sel_mul & (sys_toggle ^ sys_toggle_d);

    Multiplicador #(.N(16)) u_Multiplicador (
        .Multiplicando (ex_A[15:0]),
        .Multiplicador (ex_B[15:0]),
        .St            (mul_start),
        .Clk           (CLK_MUL),
        .rst           (rst_sys),
        .Produto       (mul_out),
        .Idle          (mul_idle),
        .Done          (mul_done)
    );

    // mux.v: sel = 0 -> alu_out; sel = 1 -> mul_out
    mux #(.WIDTH(WIDTH)) u_mux_ex_res (
        .data_in_1 (alu_out),
        .data_in_2 (mul_out),
        .sel       (ex_sel_mul),
        .data_out  (ex_result)
    );

    wire [7:0] ex_ctrl_out = {ex_reg_write, ex_mem_to_reg, ex_mem_write, ex_dest};

    // =========================================================================
    // Registrador de Pipeline: EX/MEM
    // =========================================================================
    (* keep = 1 *) wire [WIDTH-1:0] mem_D, mem_B;
    (* keep = 1 *) wire [7:0]       mem_CTRL;

    register #(.WIDTH(WIDTH)) u_reg_EXMEM_D    (.clk(CLK_SYS), .rst(rst_sys), .data_in(ex_result),   .data_out(mem_D));
    register #(.WIDTH(WIDTH)) u_reg_EXMEM_B    (.clk(CLK_SYS), .rst(rst_sys), .data_in(ex_B),        .data_out(mem_B));
    register #(.WIDTH(8))     u_reg_EXMEM_CTRL (.clk(CLK_SYS), .rst(rst_sys), .data_in(ex_ctrl_out), .data_out(mem_CTRL));

    // =========================================================================
    // 5. Estagio MEM (Memory Access) - BRAM absorve registrador de saida M
    // =========================================================================
    wire       mem_reg_write  = mem_CTRL[7];
    wire       mem_mem_to_reg = mem_CTRL[6];
    wire       mem_mem_write  = mem_CTRL[5];
    wire [4:0] mem_dest       = mem_CTRL[4:0];

    wire [9:0]       data_iAddress;
    wire             data_iWE;
    wire [WIDTH-1:0] datamem_q;

    assign ADDR           = mem_D;
    assign Data_BUS_WRITE = mem_B;
    assign WE             = mem_mem_write;

    // ADDRDecoding.v: CS = 1 -> Memoria Interna; iWE = CS & WE
    ADDRDecoding #(
        .BASE (BASE_DADOS)
    ) u_ADDRDecoding_Data (
        .ADDR     (mem_D),
        .WE       (mem_mem_write),
        .CS       (CS),
        .iAddress (data_iAddress),
        .iWE      (data_iWE)
    );

    datamemory u_datamemory (
        .address (data_iAddress),
        .clock   (CLK_SYS),
        .data    (mem_B),
        .wren    (data_iWE),
        .q       (datamem_q)
    );

    wire [6:0] mem_ctrl_out = {mem_reg_write, mem_mem_to_reg, mem_dest};

    // =========================================================================
    // Registrador de Pipeline: MEM/WB (D, CTRL e alinhamento de CS/Data_BUS_READ)
    // =========================================================================
    (* keep = 1 *) wire [WIDTH-1:0] wb_D;
    (* keep = 1 *) wire [WIDTH-1:0] wb_M;
    (* keep = 1 *) wire [6:0]       wb_CTRL;
    wire [WIDTH-1:0]                wb_ext_data;
    wire                            wb_CS;

    register #(.WIDTH(WIDTH)) u_reg_MEMWB_D    (.clk(CLK_SYS), .rst(rst_sys), .data_in(mem_D),         .data_out(wb_D));
    register #(.WIDTH(WIDTH)) u_reg_MEMWB_EXT  (.clk(CLK_SYS), .rst(rst_sys), .data_in(Data_BUS_READ), .data_out(wb_ext_data));
    register #(.WIDTH(1))     u_reg_MEMWB_CS   (.clk(CLK_SYS), .rst(rst_sys), .data_in(CS),            .data_out(wb_CS));
    register #(.WIDTH(7))     u_reg_MEMWB_CTRL (.clk(CLK_SYS), .rst(rst_sys), .data_in(mem_ctrl_out),  .data_out(wb_CTRL));

    // =========================================================================
    // 6. Estagio WB (Write Back)
    // =========================================================================
    assign wb_reg_write  = wb_CTRL[6];
    wire   wb_mem_to_reg = wb_CTRL[5];
    assign wb_dest       = wb_CTRL[4:0];

    // mux.v: sel = 0 -> wb_ext_data (Mem. Externa); sel = 1 -> datamem_q (Mem. Interna)
    mux #(.WIDTH(WIDTH)) u_mux_mem (
        .data_in_1 (wb_ext_data),
        .data_in_2 (datamem_q),
        .sel       (wb_CS),
        .data_out  (wb_M)
    );

    // mux.v: sel = 0 -> wb_D (ALU/MUL); sel = 1 -> wb_M (Memoria)
    mux #(.WIDTH(WIDTH)) u_mux_wb (
        .data_in_1 (wb_D),
        .data_in_2 (wb_M),
        .sel       (wb_mem_to_reg),
        .data_out  (writeBack_data)
    );

endmodule