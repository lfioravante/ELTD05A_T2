`timescale 1ns/1ps

module control_TB;

    localparam integer GRUPO = 11;

    reg  [31:0] inst;

    wire [25:0] jmpAddress;
    wire        jmpFlag;
    wire        branchFlag;
    wire [1:0]  alu_op;
    wire        alu_src_b;
    wire        sel_mul;
    wire        reg_write;
    wire        mem_read;
    wire        mem_write;
    wire        mem_to_reg;
	 wire			 reg_dst;

    localparam [1:0]
        OP_ADD = 2'b00,
        OP_SUB = 2'b01,
        
        OP_AND = 2'b10,
        OP_OR  = 2'b11;

    localparam [5:0]
        OPC_R_TYPE = GRUPO + 6'd10, // 21
        OPC_JMP    = 6'd2,          // 2
        OPC_LW     = GRUPO + 6'd32, // 43
        OPC_SW     = GRUPO + 6'd33, // 44
        OPC_BNE    = GRUPO + 6'd34, // 45
        OPC_ADDI   = GRUPO + 6'd35, // 46
        OPC_ORI    = GRUPO + 6'd36; // 47

    localparam [5:0]
        FNC_ADD = 6'd32,
        FNC_SUB = 6'd34,
        FNC_MUL = 6'd50,
        FNC_AND = 6'd36,
        FNC_OR  = 6'd37;

    control #(
        .GRUPO(GRUPO)
    ) dut (
        .inst(inst),
        .jmpAddress(jmpAddress),
        .jmpFlag(jmpFlag),
        .branchFlag(branchFlag),
        .alu_op(alu_op),
        .alu_src_b(alu_src_b),
        .sel_mul(sel_mul),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
		  .reg_dst(reg_dst)
    );

    integer erros;

    task check_outputs;
        input [8*20-1:0] nome_teste;
        input [25:0]     exp_jmpAddress;
        input            exp_jmpFlag;
        input            exp_branchFlag;
        input [1:0]      exp_alu_op;
        input            exp_alu_src_b;
        input            exp_sel_mul;
        input            exp_reg_write;
        input            exp_mem_read;
        input            exp_mem_write;
        input            exp_mem_to_reg;
		  input				 exp_reg_dst;
        begin
            #1;
            if (jmpAddress !== exp_jmpAddress ||
                jmpFlag    !== exp_jmpFlag    ||
                branchFlag !== exp_branchFlag ||
                alu_op     !== exp_alu_op     ||
                alu_src_b  !== exp_alu_src_b  ||
                sel_mul 	!== exp_sel_mul		 ||
                reg_write  !== exp_reg_write  ||
                mem_read   !== exp_mem_read   ||
                mem_write  !== exp_mem_write  ||
                mem_to_reg !== exp_mem_to_reg ||
					 reg_dst    !== exp_reg_dst)    begin
                $display("[ERRO] %0s em t=%0t | inst=%h", nome_teste, $time, inst);
                $display("       jmpFlag=%b (exp %b) jmpAddress=%h (exp %h) branchFlag=%b (exp %b)",
                         jmpFlag, exp_jmpFlag, jmpAddress, exp_jmpAddress, branchFlag, exp_branchFlag);
                $display("       alu_op=%0d (exp %0d) alu_src_b=%b (exp %b) sel_mul=%b (exp %b)",
                         alu_op, exp_alu_op, alu_src_b, exp_alu_src_b, sel_mul, exp_sel_mul);
                $display("       reg_write=%b (exp %b) mem_read=%b (exp %b) mem_write=%b (exp %b) mem_to_reg=%b (exp %b) reg_dst=%b (exp=%b)",
                         reg_write, exp_reg_write, mem_read, exp_mem_read, mem_write, exp_mem_write, mem_to_reg, exp_mem_to_reg, reg_dst, exp_reg_dst);
                erros = erros + 1;
            end else begin
                $display("[OK]   %0s", nome_teste);
            end
        end
    endtask

    initial begin
        erros = 0;
        inst = 32'd0;
		  
        #10;

        // ADD
        inst = {OPC_R_TYPE, 5'd1, 5'd2, 5'd3, 5'd0, FNC_ADD};
        check_outputs("ADD", inst[25:0], 1'b0, 1'b0, OP_ADD, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1);

        // SUB
        inst = {OPC_R_TYPE, 5'd4, 5'd5, 5'd6, 5'd0, FNC_SUB};
        check_outputs("SUB", inst[25:0], 1'b0, 1'b0, OP_SUB, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1);

        // MUL
        inst = {OPC_R_TYPE, 5'd7, 5'd8, 5'd9, 5'd0, FNC_MUL};
        check_outputs("MUL", inst[25:0], 1'b0, 1'b0, OP_ADD, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1);

        // AND
        inst = {OPC_R_TYPE, 5'd2, 5'd3, 5'd4, 5'd0, FNC_AND};
        check_outputs("AND", inst[25:0], 1'b0, 1'b0, OP_AND, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1);

        // OR
        inst = {OPC_R_TYPE, 5'd5, 5'd6, 5'd7, 5'd0, FNC_OR};
        check_outputs("OR", inst[25:0], 1'b0, 1'b0, OP_OR, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1);

        // LW
        inst = {OPC_LW, 5'd1, 5'd2, 16'h0010};
        check_outputs("LW", inst[25:0], 1'b0, 1'b0, OP_ADD, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b0);

        // SW
        inst = {OPC_SW, 5'd1, 5'd2, 16'h0020};
        check_outputs("SW", inst[25:0], 1'b0, 1'b0, OP_ADD, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0);

        // ADDI
        inst = {OPC_ADDI, 5'd2, 5'd3, 16'h0005};
        check_outputs("ADDI", inst[25:0], 1'b0, 1'b0, OP_ADD, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

        // ORI
        inst = {OPC_ORI, 5'd3, 5'd4, 16'h00FF};
        check_outputs("ORI", inst[25:0], 1'b0, 1'b0, OP_OR, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

        //BNE
        inst = {OPC_BNE, 5'd1, 5'd2, 16'h0004};
		  check_outputs("BNE", inst[25:0], 1'b0, 1'b1, OP_SUB, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);        // BNE (sem desvio)
        
        // JMP
        inst = {OPC_JMP, 26'h0001234};
        check_outputs("JMP", 26'h0001234, 1'b1, 1'b0, OP_ADD, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
		  
		  // NOP
		  inst = 32'd0;
		  check_outputs("NOP", 26'd0, 1'b0, 1'b0, OP_ADD, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);

        #10;
        if (erros == 0)
            $display("=== TODOS OS TESTES DO CONTROL_TB PASSARAM COM SUCESSO ===");
        else
            $display("=== FINALIZADO COM %0d ERRO(S) ===", erros);

        $finish;
    end

endmodule