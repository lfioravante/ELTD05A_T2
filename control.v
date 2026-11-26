`timescale 1ns/1ps

module control #(
	parameter integer GRUPO = 11
)(
	input  wire [31:0] inst,             
	output reg [25:0]jmpAddress,   
	output reg jmpFlag,      
	output reg branchFlag,    
	output reg [1:0] alu_op,        
	output reg alu_src_b,     
	output reg sel_mul,   
	output reg reg_write,     
	output reg mem_read,   
	output reg mem_write,     
	output reg mem_to_reg,
	output reg reg_dst
);

	wire [5:0] opcode = inst[31:26];
	wire [5:0] funct = inst[5:0];
	wire [25:0] j_addr = inst[25:0];

	localparam [1:0]
	OP_ADD = 2'b00,
	OP_SUB = 2'b01,
	OP_AND = 2'b10,
	OP_OR  = 2'b11;

	localparam [5:0]
	OPC_R_TYPE = GRUPO + 6'd10, // 21
	OPC_JMP = 6'd2,          // 2
	OPC_LW = GRUPO + 6'd32, // 43
	OPC_SW = GRUPO + 6'd33, // 44
	OPC_BNE = GRUPO + 6'd34, // 45
	OPC_ADDI = GRUPO + 6'd35, // 46
	OPC_ORI = GRUPO + 6'd36; // 47

	localparam [5:0]
	FNC_ADD = 6'd32,
	FNC_SUB = 6'd34,
	FNC_MUL = 6'd50,
	FNC_AND = 6'd36,
	FNC_OR  = 6'd37;

	always @(*) begin
		jmpAddress = j_addr;
		jmpFlag = 1'b0;
		branchFlag = 1'b0;
		alu_op = OP_ADD;
		alu_src_b = 1'b0;
		sel_mul = 1'b0;
		reg_write = 1'b0;
		mem_read = 1'b0;
		mem_write = 1'b0;
		mem_to_reg = 1'b0;
		reg_dst = 1'b0;

		case (opcode)
			OPC_R_TYPE: begin
			reg_dst = 1'b1;
			reg_write = 1'b1;
			alu_src_b = 1'b0;
			mem_to_reg = 1'b0;

				case (funct)
					FNC_ADD: alu_op = OP_ADD;
					FNC_SUB: alu_op = OP_SUB;
					FNC_MUL: begin
						alu_op = OP_ADD;
						sel_mul = 1'b1;
					end
					FNC_AND: alu_op = OP_AND;
					FNC_OR:  alu_op = OP_OR;
					default: begin
						alu_op = OP_ADD;
						reg_write = 1'b0;
					end
				endcase
			end

			OPC_LW: begin
				alu_op = OP_ADD;
				alu_src_b = 1'b1;
				mem_read = 1'b1;
				reg_write = 1'b1;
				mem_to_reg = 1'b1;
			end

			OPC_SW: begin
				alu_op = OP_ADD; 
				alu_src_b = 1'b1;
				mem_write = 1'b1;
				reg_write = 1'b0;
			end

			OPC_ADDI: begin
				alu_op = OP_ADD;
				alu_src_b = 1'b1;
				reg_write = 1'b1;
				mem_to_reg = 1'b0;
			end

			OPC_ORI: begin
				alu_op = OP_OR;  
				alu_src_b = 1'b1;
				reg_write = 1'b1;
				mem_to_reg = 1'b0;
			end

			OPC_BNE: begin
				reg_write = 1'b0;
				mem_write = 1'b0;
				mem_read = 1'b0;
				alu_op = OP_SUB;
				branchFlag = 1'b1;
				
			end

			OPC_JMP: begin
				jmpFlag = 1'b1;
				jmpAddress = j_addr;
				reg_write = 1'b0;
				mem_write = 1'b0;
				mem_read = 1'b0;
			end

			default: begin
			end
		endcase
	end

endmodule