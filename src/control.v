module control (
    instruction,        // input -> full instruction
    stall,              // input -> high if processor must stall
    branch_enable,      // output -> high for branch instructions
    branch_mode,        // output -> branch comparison mode (definitions in comparison_codes.h))
    mem_write_enable,   // output -> high enables write to data memory
    mem_unsigned,       // output -> high when unsigned load
    mem_mode,           // output -> specifies memory mode i.e. byte/halfword/word
    reg_write_enable,   // output -> high enables write to registerfile
    mem_to_reg,         // output -> high routes data memory output to register input
    alu_op,             // output -> ALU operating mode (definitions in alu_codes.h)
    alu_src,            // output -> high: alu input = immediate, low: alu input = register file
    pc_to_reg,          // output -> high: writes pc + 4 to destination reg
    jump_enable,        // output -> high for jump instructions
    jump_reg,           // output -> high: set pc to reg content
    ill_instr           // output -> high if instruction is not recognized
);

// -- Include definitions ---------------------------------
`include "alu_codes.h"          // Contains risc-v opcodes
`include "comparison_codes.h"   // Contains comparison codes
`include "opcodes.h"            // Contains alu operation codes
`include "mem_modes.h"          // Contains memory mode definitions

// -- Module IO -------------------------------------------
input [31:0] instruction;
input stall;
output reg branch_enable, jump_enable, mem_write_enable, mem_unsigned, reg_write_enable, mem_to_reg, alu_src, pc_to_reg, jump_reg, ill_instr;
output reg [1:0] mem_mode;
output reg [2:0] branch_mode;
output reg [3:0] alu_op;

// -- Extract opcode --------------------------------------
wire [6:0] opcode;
assign opcode = instruction[6:0];
// -- Extract funct3 ---------------------------------------
wire [2:0] funct3;
assign funct3 = instruction[14:12];
// -- Extract funct7 ---------------------------------------
wire [6:0] funct7;
assign funct7 = instruction[31:25];

// -- Determine instruction -------------------------------
// Lui
wire lui_inst = (opcode == lui_gr);
// Auipc
wire auipc_inst = (opcode == aui_gr);
// Jal
wire jal_inst = (opcode == jal_gr);
// Jalr
wire jalr_inst = (opcode == jlr_gr) && (funct3 == 3'b000);
// Branch group
wire beq_inst = (opcode == bra_gr) && (funct3 == 3'b000);
wire bne_inst = (opcode == bra_gr) && (funct3 == 3'b001);
wire blt_inst = (opcode == bra_gr) && (funct3 == 3'b100);
wire bge_inst = (opcode == bra_gr) && (funct3 == 3'b101);
wire bltu_inst = (opcode == bra_gr) && (funct3 == 3'b110);
wire bgeu_inst = (opcode == bra_gr) && (funct3 == 3'b111);
// Load group
wire lb_inst = (opcode == loa_gr) && (funct3 == 3'b000);
wire lh_inst = (opcode == loa_gr) && (funct3 == 3'b001);
wire lw_inst = (opcode == loa_gr) && (funct3 == 3'b010);
wire ld_inst = (opcode == loa_gr) && (funct3 == 3'b011);
wire lbu_inst = (opcode == loa_gr) && (funct3 == 3'b100);
wire lhu_inst = (opcode == loa_gr) && (funct3 == 3'b101);
wire lwu_inst = (opcode == loa_gr) && (funct3 == 3'b110);
// Store group
wire sb_inst = (opcode == sto_gr) && (funct3 == 3'b000);
wire sh_inst = (opcode == sto_gr) && (funct3 == 3'b001);
wire sw_inst = (opcode == sto_gr) && (funct3 == 3'b010);
wire sd_inst = (opcode == sto_gr) && (funct3 == 3'b011);
// Arithmetic & logic immediate group
wire addi_inst = (opcode == rim_gr) && (funct3 == 3'b000);
wire slli_inst = (opcode == rim_gr) && (funct3 == 3'b001);
wire slti_inst = (opcode == rim_gr) && (funct3 == 3'b010);
wire sltiu_inst = (opcode == rim_gr) && (funct3 == 3'b011);
wire xori_inst = (opcode == rim_gr) && (funct3 == 3'b100);
wire srli_inst = (opcode == rim_gr) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
wire srai_inst = (opcode == rim_gr) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
wire ori_inst = (opcode == rim_gr) && (funct3 == 3'b110);
wire andi_inst = (opcode == rim_gr) && (funct3 == 3'b111);
// Arithmetic & logic R-type instructions
wire add_inst = (opcode == reg_gr) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
wire sub_inst = (opcode == reg_gr) && (funct3 == 3'b000) && (funct7 == 7'b0100000);
wire sll_inst = (opcode == reg_gr) && (funct3 == 3'b001) && (funct7 == 7'b0000000);
wire slt_inst = (opcode == reg_gr) && (funct3 == 3'b010) && (funct7 == 7'b0000000);
wire sltu_inst = (opcode == reg_gr) && (funct3 == 3'b011) && (funct7 == 7'b0000000);
wire xor_inst = (opcode == reg_gr) && (funct3 == 3'b100) && (funct7 == 7'b0000000);
wire srl_inst = (opcode == reg_gr) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
wire sra_inst = (opcode == reg_gr) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
wire or_inst = (opcode == reg_gr) && (funct3 == 3'b110) && (funct7 == 7'b0000000);
wire and_inst = (opcode == reg_gr) && (funct3 == 3'b111) && (funct7 == 7'b0000000);
// Fence instructions group -> NOT IMPLEMENTED
// Csr instructions group -> NOT IMPLEMENTED

// -- Set control signals ---------------------------------
always @(*) begin
    // Reset all signals
    branch_enable <= 0;
    branch_mode <= 0;
    mem_write_enable <= 0;
    reg_write_enable <= 0;
    mem_to_reg <= 0;
    mem_unsigned <= 0;
    mem_mode <= MEM_WORD;
    alu_src <= 0;
	alu_op <= 'b0;
    pc_to_reg <= 0;
    jump_enable <= 0;
    jump_reg <= 0;
    ill_instr <= 0;
    if (!stall) begin // If stall: set all signals to 0
        // Set signal if needed for instruction
        case (1'b1)
            lui_inst: begin alu_op <= ALU_PASS_1; alu_src <= 1; reg_write_enable <= 1; end
            //auipc_inst: TODO
            jal_inst: begin alu_op <= ALU_PASS_1; reg_write_enable <= 1; pc_to_reg <= 1; jump_enable <= 1; end
            jalr_inst: begin alu_op <= ALU_PASS_1; reg_write_enable <= 1; pc_to_reg <= 1; jump_enable <= 1; jump_reg <= 1; end
            // Branch group
            beq_inst: begin branch_enable <= 1; branch_mode <= EQ; end
            bne_inst: begin branch_enable <= 1; branch_mode <= NE; end
            blt_inst: begin branch_enable <= 1; branch_mode <= LT; end
            bge_inst: begin branch_enable <= 1; branch_mode <= GE; end
            bltu_inst: begin branch_enable <= 1; branch_mode <= LTU; end
            bgeu_inst: begin branch_enable <= 1; branch_mode <= GEU; end
            // Load group
            lb_inst: begin alu_op <= ALU_ADD; alu_src <= 1; reg_write_enable <= 1; mem_to_reg <= 1; mem_mode <= MEM_BYTE; end
            lh_inst: begin alu_op <= ALU_ADD; alu_src <= 1; reg_write_enable <= 1; mem_to_reg <= 1; mem_mode <= MEM_HALF; end
            lw_inst: begin alu_op <= ALU_ADD; alu_src <= 1; reg_write_enable <= 1; mem_to_reg <= 1; mem_mode <= MEM_WORD; end
            lbu_inst: begin alu_op <= ALU_ADD; alu_src <= 1; reg_write_enable <= 1; mem_to_reg <= 1; mem_mode <= MEM_BYTE; mem_unsigned <= 1; end
            lhu_inst: begin alu_op <= ALU_ADD; alu_src <= 1; reg_write_enable <= 1; mem_to_reg <= 1; mem_mode <= MEM_HALF; mem_unsigned <= 1; end
            lwu_inst: begin alu_op <= ALU_ADD; alu_src <= 1; reg_write_enable <= 1; mem_to_reg <= 1; mem_mode <= MEM_WORD; mem_unsigned <= 1; end
            // Store group
            sb_inst: begin alu_op <= ALU_ADD; alu_src <= 1; mem_write_enable <= 1; mem_mode <= MEM_BYTE; end
            sh_inst: begin alu_op <= ALU_ADD; alu_src <= 1; mem_write_enable <= 1; mem_mode <= MEM_HALF; end
            sw_inst: begin alu_op <= ALU_ADD; alu_src <= 1; mem_write_enable <= 1; mem_mode <= MEM_WORD; end
            // Arithmetic & logic immediate group
            addi_inst: begin alu_op <= ALU_ADD; alu_src <= 1; reg_write_enable <= 1; end
            slli_inst: begin alu_op <= ALU_LSL; alu_src <= 1; reg_write_enable <= 1; end
            slti_inst: begin alu_op <= ALU_LT; alu_src <= 1; reg_write_enable <= 1; end
            sltiu_inst: begin alu_op <= ALU_LTU; alu_src <= 1; reg_write_enable <= 1; end
            xori_inst: begin alu_op <= ALU_XOR; alu_src <= 1; reg_write_enable <= 1; end
            srli_inst: begin alu_op <= ALU_LSR; alu_src <= 1; reg_write_enable <= 1; end
            srai_inst: begin alu_op <= ALU_ASR; alu_src <= 1; reg_write_enable <= 1; end
            ori_inst: begin alu_op <= ALU_OR; alu_src <= 1; reg_write_enable <= 1; end
            andi_inst: begin alu_op <= ALU_AND; alu_src <= 1; reg_write_enable <= 1; end
            // Arithmetic & logic R-type instructions
            add_inst: begin alu_op <= ALU_ADD; reg_write_enable <= 1; end
            sub_inst: begin alu_op <= ALU_SUB; reg_write_enable <= 1; end
            sll_inst: begin alu_op <= ALU_LSL; reg_write_enable <= 1; end
            slt_inst: begin alu_op <= ALU_LT; reg_write_enable <= 1; end
            sltu_inst: begin alu_op <= ALU_LTU; reg_write_enable <= 1; end
            xor_inst: begin alu_op <= ALU_XOR; reg_write_enable <= 1; end
            srl_inst: begin alu_op <= ALU_LSR; reg_write_enable <= 1; end
            sra_inst: begin alu_op <= ALU_ASR; reg_write_enable <= 1; end
            or_inst: begin alu_op <= ALU_OR; reg_write_enable <= 1; end
            and_inst: begin alu_op <= ALU_AND; reg_write_enable <= 1; end
            default: ill_instr <= 1;
        endcase
    end
end
    
endmodule