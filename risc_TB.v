`timescale 1ns/1ps

module risc_TB;

    parameter WIDTH = 32;

    // Parametros de controle da simulacao
    parameter integer MAX_REF_CYCLES    = 10000;
    parameter integer STABLE_REF_CYCLES = 100;

    reg  [WIDTH-1:0] Data_BUS_READ;
    reg  [WIDTH-1:0] Prog_BUS_READ;
    reg              CLK;
    reg              RST;

    wire [WIDTH-1:0] ADDR_Prog;
    wire             CS_P;
    wire [WIDTH-1:0] ADDR;
    wire [WIDTH-1:0] Data_BUS_WRITE;
    wire             WE;
    wire             CS;

    // Variaveis de controle do log
    integer fd;
    integer ciclo_pc;
    integer total_sw;

    // Variaveis para deteccao do termino do programa
    integer ref_cycles;
    integer stable_count;

    reg [WIDTH-1:0] prev_addr_prog;
    reg             prev_we;

    reg pc_change_seen;
    reg finish_detected;
    reg timeout_reached;


    // =========================================================
    // INSTANCIACAO DO PROCESSADOR (DUT)
    // =========================================================

    risc dut (
        .Data_BUS_READ  (Data_BUS_READ),
        .Prog_BUS_READ  (Prog_BUS_READ),
        .CLK            (CLK),
        .RST            (RST),
        .ADDR_Prog      (ADDR_Prog),
        .CS_P           (CS_P),
        .ADDR           (ADDR),
        .Data_BUS_WRITE (Data_BUS_WRITE),
        .WE             (WE),
        .CS             (CS)
    );


    // =========================================================
    // CLOCK DE REFERENCIA: 50 MHz
    // Periodo = 20 ns
    // =========================================================

    initial CLK = 1'b0;

    always #10 CLK = ~CLK;


    // =========================================================
    // INICIALIZACAO DA SIMULACAO
    // =========================================================

    initial begin

        // Inicializacao dos barramentos
        Data_BUS_READ  = 32'h0000_0000;
        Prog_BUS_READ  = 32'h0000_0000;

        CLK = 1'b0;
        RST = 1'b1;

        // Inicializacao dos contadores
        ciclo_pc       = 0;
        total_sw       = 0;

        ref_cycles     = 0;
        stable_count   = 0;

        // Inicializacao dos sinais de monitoramento
        prev_addr_prog = 32'hFFFF_FFFF;
        prev_we        = 1'b0;

        pc_change_seen = 1'b0;
        finish_detected = 1'b0;
        timeout_reached = 1'b0;


        // Formatacao do tempo em nanossegundos
        $timeformat(-9, 2, " ns", 12);


        // Criacao do arquivo de log
        fd = $fopen("risc_TB_output.txt", "w");

        if (fd == 0) begin
            $display("[ERRO] Nao foi possivel criar risc_TB_output.txt");
            $stop;
        end


        // Cabecalho do arquivo
        $fdisplay(fd, "==============================================================================================");
        $fdisplay(fd, " LOG DE SIMULACAO - PROCESSADOR RISC 5 ESTAGIOS (GRUPO 11)");
        $fdisplay(fd, " CteMemProg = 0x00000000 (BASE_PROG = 0x00000000) | CteMemDados = 0x0125 (BASE_DADOS = 0x0C97)");
        $fdisplay(fd, "==============================================================================================");

        $fdisplay(fd, "   Tempo(ns) | Ciclo |  ADDR_Prog | CS_P |       ADDR | Data_BUS_WRITE | WE | CS | Evento");

        $fdisplay(fd, "----------------------------------------------------------------------------------------------");


        $display("");
        $display("==========================================================");
        $display("[INFO] Simulacao do processador RISC iniciada.");
        $display("[INFO] Clock de referencia: 50 MHz.");
        $display("[INFO] Periodo do clock: 20 ns.");
        $display("[INFO] Aplicando Reset...");
        $display("==========================================================");


        // Reset durante 5 ciclos completos de clock
        repeat (5) @(negedge CLK);

        RST = 1'b0;

        $display("[INFO] Reset liberado em %0t.", $time);
        $display("[INFO] Aguardando execucao do programa...");
        $display("");


        // =====================================================
        // ESPERA CONDICIONADA
        // A simulacao termina quando:
        // 1. O PC permanece estavel pelo tempo configurado;
        // 2. Pelo menos uma escrita SW foi detectada.
        //
        // Caso contrario, o watchdog encerra a simulacao.
        // =====================================================

        wait (finish_detected || timeout_reached);


        // =====================================================
        // FINALIZACAO
        // =====================================================

        $fdisplay(fd, "----------------------------------------------------------------------------------------------");

        if (finish_detected) begin

            $fdisplay(fd, " STATUS: PROGRAMA FINALIZADO (PC ESTAVEL).");

            $display("");
            $display("==========================================================");
            $display("[FIM] Programa finalizado com sucesso!");
            $display("[INFO] Condicao de termino: PC permaneceu estavel.");
            $display("==========================================================");

        end
        else begin

            $fdisplay(fd, " STATUS: TIMEOUT - TERMINO DO PROGRAMA NAO DETECTADO.");

            $display("");
            $display("==========================================================");
            $display("[AVISO] Tempo maximo de simulacao atingido.");
            $display("[AVISO] Nao foi detectada a condicao de termino.");
            $display("[INFO] Verifique o PC e a execucao do programa.");
            $display("==========================================================");

        end


        $fdisplay(fd, " Tempo final: %0t", $time);

        $fdisplay(fd, " Ciclos de PC registrados: %0d", ciclo_pc);

        $fdisplay(fd, " Total de escritas SW: %0d", total_sw);

        $fdisplay(fd, " Ultimo ADDR_Prog: 0x%08h", ADDR_Prog);

        $fdisplay(fd, "==============================================================================================");


        $fclose(fd);


        $display("");
        $display("[RESULTADO] Tempo final: %0t", $time);
        $display("[RESULTADO] Ciclos de PC: %0d", ciclo_pc);
        $display("[RESULTADO] Escritas SW: %0d", total_sw);
        $display("[RESULTADO] PC final: 0x%08h", ADDR_Prog);
        $display("");
        $display("[INFO] Log salvo em risc_TB_output.txt");
        $display("==========================================================");


        $stop;

    end


    // =========================================================
    // WATCHDOG
    // Limite maximo de 10000 ciclos de referencia.
    //
    // 10000 ciclos x 20 ns = 200 us
    // =========================================================

    always @(posedge CLK) begin

        if (RST) begin

            ref_cycles = 0;

        end
        else if (!finish_detected && !timeout_reached) begin

            ref_cycles = ref_cycles + 1;

            if (ref_cycles >= MAX_REF_CYCLES) begin

                $display("[WATCHDOG] Limite maximo de simulacao atingido.");

                timeout_reached = 1'b1;

            end

        end

    end


    // =========================================================
    // MONITORAMENTO DOS SINAIS DO PROCESSADOR
    //
    // Amostragem 5 ns apos a borda de subida do clock.
    // =========================================================

    always @(posedge CLK) begin

        #5;

        if (!RST && !finish_detected && !timeout_reached) begin


            // =================================================
            // DETECCAO DE ESCRITA SW
            // =================================================

            if ((WE === 1'b1) && (prev_we === 1'b0)) begin

                total_sw = total_sw + 1;

            end


            // =================================================
            // MONITORAMENTO DO PC
            // Ignora valores desconhecidos (X/Z).
            // =================================================

            if ((^ADDR_Prog) !== 1'bx) begin


                // Verifica se o endereco do programa mudou
                if (ADDR_Prog !== prev_addr_prog) begin

                    ciclo_pc = ciclo_pc + 1;


                    // Registro de SW associado a mudanca de PC
                    if ((WE === 1'b1) && (prev_we === 1'b0)) begin

                        $fdisplay(fd, "%12t | %5d | 0x%08h |   %b  | 0x%08h |     0x%08h |  %b |  %b | [SW] Dado=%0d",
                                  $time, ciclo_pc, ADDR_Prog, CS_P,
                                  ADDR, Data_BUS_WRITE, WE, CS,
                                  Data_BUS_WRITE);

                        $display("[SW] t=%0t | PC=0x%08h | ADDR=0x%08h | Dado=0x%08h (%0d) | CS=%b",
                                 $time, ADDR_Prog, ADDR,
                                 Data_BUS_WRITE, Data_BUS_WRITE, CS);

                    end

                    else begin

                        $fdisplay(fd, "%12t | %5d | 0x%08h |   %b  | 0x%08h |     0x%08h |  %b |  %b |",
                                  $time, ciclo_pc, ADDR_Prog, CS_P,
                                  ADDR, Data_BUS_WRITE, WE, CS);

                    end


                    // Atualiza o endereco anterior
                    prev_addr_prog = ADDR_Prog;

                    // Confirma que o PC ja apresentou atividade
                    pc_change_seen = 1'b1;

                    // Reinicia a contagem de estabilidade
                    stable_count = 0;

                end


                // =============================================
                // PC PERMANECEU NO MESMO ENDERECO
                // =============================================

                else begin


                    // Registro de SW sem mudanca de PC
                    if ((WE === 1'b1) && (prev_we === 1'b0)) begin

                        $fdisplay(fd, "%12t | %5d | 0x%08h |   %b  | 0x%08h |     0x%08h |  %b |  %b | [SW] Dado=%0d",
                                  $time, ciclo_pc, ADDR_Prog, CS_P,
                                  ADDR, Data_BUS_WRITE, WE, CS,
                                  Data_BUS_WRITE);

                        $display("[SW] t=%0t | PC=0x%08h | ADDR=0x%08h | Dado=0x%08h (%0d) | CS=%b",
                                 $time, ADDR_Prog, ADDR,
                                 Data_BUS_WRITE, Data_BUS_WRITE, CS);

                    end


                    // =========================================
                    // CONDICAO DE TERMINO DO PROGRAMA
                    // =========================================

                    if (pc_change_seen && (total_sw > 0)) begin

                        if (stable_count < STABLE_REF_CYCLES) begin

                            stable_count = stable_count + 1;

                        end


                        if (stable_count >= STABLE_REF_CYCLES) begin

                            $display("");
                            $display("[INFO] PC permaneceu estavel por %0d ciclos de referencia.",
                                     STABLE_REF_CYCLES);

                            $display("[INFO] Total de escritas SW: %0d", total_sw);

                            $display("[INFO] Endereco final do programa: 0x%08h",
                                     ADDR_Prog);


                            // Sinaliza termino da simulacao
                            finish_detected = 1'b1;

                        end

                    end

                end

            end


            // Atualizacao do estado anterior de WE
            if (WE === 1'b1) begin

                prev_we = 1'b1;

            end
            else if (WE === 1'b0) begin

                prev_we = 1'b0;

            end

        end

    end


endmodule