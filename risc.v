module risc #(parameter WIDTH = 32)(

	input [WIDTH-1:0] Data_BUS_READ,
	input [WIDTH-1:0] Prog_BUS_READ,
	input CLK,
	input RST,
	
	output [WIDTH-1:0] ADDR_Prog,
	output CS_P,
	output [WIDTH-1:0] ADDR,
	output [WIDTH-1:0] Data_BUS_WRITE,
	output WE,
	output CS
);

	(* keep = 1 *) wire CLK_SYS, CLK_MUL;
	wire locked;
	wire [31:0] PC, PC_next;
	wire [31:0] instmem_q;
	wire [31:0] INST;
	
	wire rst_sys = RST | ~locked;

	PLL u_PLL (.areset(RST), .inclk0(CLK), .c0(CLK_SYS), .c1(CLK_MUL), .locked(locked));
	
	pc # (.WIDTH(32), .RESET_ADDR(0)) u_pc(.clk(CLK_SYS), .rst(rst_sys), .data_in(PC_next), .data_out(PC));
	
	assign PC_next   = PC + 32'd4;
	assign ADDR_Prog = PC;
	
	ADDRDecoding_Prog # (.BASE(0)) u_ADDRDecoding_Prog (.ADDR(PC), .CS(CS_P), .iAddress());
	
	InstMem u_InstMem (.address(PC[11:2]), .clock(CLK_SYS), .q(instmem_q));	
	
	mux # (.WIDTH(32)) u_mux (.data_in_1(Data_BUS_READ), .data_in_2(instmem_q), .sel(CS_P), .data_out(INST));
	
	
	wire dataOut1, dataOut2;
	registerfile # (.DATA_WIDTH(32), .ADDR_WIDTH(5)) u_registerfile(
		.clk(CLK_SYS, 
		.rst(rst_sys), 
		.wr(1'b0), 
		.dataIn(32'd0), 
		.wrAddress(5'd0), 
		.rdAddress1(INST[25:21]), 
		.rdAddress2(INST[20:16]),
		.dataOut1(dataOut1),
		.dataOOut2(dataOut2)
	);
	
	wire [1:0] alu_op;
	wire alu_src_b, sel_mul, reg_write, mem_write, mem_to_reg, reg_dst;
	control # (.GRUPO(11)) u_control (
		.inst(INST), 
		.jmpAddress(), 
		.branchFlag(), 
		.alu_op(alu_op), 
		.alu_src_b(alu_src_b), 
		.sel_mul(sel_mul),
		.reg_write(reg_write),
		.mem_read(),
		.mem_write(mem_write),
		.mem_to_reg(mem_to_reg),
		.reg_dst(reg_dst)
	);
	
	wire [31:0] imm16, out;
	extend #(.WIDTH_IN(16), .WIDTH_OUT(32)) u-control(.in(imm16), .out(out));
	
	wire [4:0] dest = reg_dst ? rd : rt;
	
	wire [11:0] ctrl_in = {reg_write, mem_to_reg, mem_write, sel_mul, alu_src_b, alu_op, dest};
	
	(* keep = 1 *) wire [WIDTH-1:0] A, B, IMM, CTRL
	//A
	register #(.WIDTH(32)) u_register(.clk(clk_sys), .rst(rst_sys), .data_in(dataOut1), .data_out(A));
	
	//B
	register #(.WIDTH(32)) u_register(.clk(clk_sys), .rst(rst_sys), .data_in(dataOut2), .data_out(B));

	//IMM
	register #(.WIDTH(32)) u_register(.clk(clk_sys), .rst(rst_sys), .data_in(out), .data_out(IMM));

	//CTRL
	register #(.WIDTH(32)) u_register(.clk(clk_sys), .rst(rst_sys), .data_in(ctrl_in), .data_out(CTRL));


endmodule