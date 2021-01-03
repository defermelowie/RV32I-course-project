module forwarding_unit (
    ID_instruction,             // input -> instruction in the instruction decode stage
    EX_reg_write_enable,        // input -> "reg_write_enable" from execution stage
    EX_instruction,             // input -> instruction in the execution stage
    MEM_reg_write_enable,       // input -> "reg_write_enable" from memory access stage
    MEM_instruction,            // input -> instruction in the memory access stage
    MEM_mem_to_reg,             // input -> "mem_to_reg" form the memory access stage
    forward_mode_0,             // output -> forwarding mode for data 0 
    forward_mode_1              // output -> forwarding mode for data 1 
);

// -- Include definitions -------------------------------------
`include "riscv.h"              // Contains XLEN definition
`include "forwarding_codes.h"   // Contains forwarding code definitions   

// -- Module IO -----------------------------------------------
input EX_reg_write_enable, MEM_reg_write_enable, MEM_mem_to_reg;
input [31:0] ID_instruction, EX_instruction, MEM_instruction;
output reg [FORWARDING_CODE_SIZE-1:0] forward_mode_0, forward_mode_1;

// -- Internal signals ----------------------------------------
wire [4:0] ID_destination_register = ID_instruction[11:7];
wire [4:0] ID_read_register_0 = ID_instruction[19:15];
wire [4:0] ID_read_register_1 = ID_instruction[24:20];
wire [4:0] EX_destination_register = EX_instruction[11:7];
wire [4:0] MEM_destination_register = MEM_instruction[11:7];

// -- Determine hazard ----------------------------------------
wire ex_alu_0 = (
    EX_reg_write_enable && 
    (EX_destination_register != 0) &&
    (EX_destination_register == ID_read_register_0)
);

wire ex_alu_1 = (
    EX_reg_write_enable && 
    (EX_destination_register != 0) &&
    (EX_destination_register == ID_read_register_1)
);

wire mem_mem_0 = (
    MEM_reg_write_enable && 
    (MEM_destination_register != 0) &&
    MEM_mem_to_reg &&
    (MEM_destination_register == ID_read_register_0)
);

wire mem_mem_1 = (
    MEM_reg_write_enable && 
    (MEM_destination_register != 0) &&
    MEM_mem_to_reg &&
    (MEM_destination_register == ID_read_register_1)
);

wire mem_alu_0 = (
    MEM_reg_write_enable && 
    (MEM_destination_register != 0) &&
    !MEM_mem_to_reg &&
    (MEM_destination_register == ID_read_register_0)
);

wire mem_alu_1 = (
    MEM_reg_write_enable && 
    (MEM_destination_register != 0) &&
    !MEM_mem_to_reg &&
    (MEM_destination_register == ID_read_register_1)
);

// -- Set forwarding signals ----------------------------------
always @(*) begin
    case ('b1)
        ex_alu_0: forward_mode_0 <= EX_ALU_OUT;
        mem_mem_0: forward_mode_0 <= MEM_MEM_OUT;
        mem_alu_0: forward_mode_0 <= MEM_ALU_OUT;
        default: forward_mode_0 <= ID_REG_OUT;
    endcase

    case ('b1)
        ex_alu_1: forward_mode_1 <= EX_ALU_OUT;
        mem_mem_1: forward_mode_1 <= MEM_MEM_OUT;
        mem_alu_1: forward_mode_1 <= MEM_ALU_OUT;
        default: forward_mode_1 <= ID_REG_OUT;
    endcase    
end

endmodule