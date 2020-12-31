module forwarding_unit (
    MEM_reg_write_enable,       // input -> "reg_write_enable" from memory access stage
    WB_reg_write_enable,        // input -> "reg_write_enable" from write back stage
    MEM_destination_register,   // input -> destination register from memory access stage
    WB_destination_register,    // input -> destination register from write back stage
    EX_read_register_0,         // input -> read register 0 from execution stage
    EX_read_register_1,          // input -> read register 1 from execution stage
    forward_0,                  // output -> forwarding code for alu operand 0 
    forward_1                   // output -> forwarding code for alu operand 1 
);

// -- Include definitions -------------------------------------
`include "riscv.h"              // Contains XLEN definition
`include "forwarding_codes.h"   // Contains forwarding code definitions   

// -- Module IO -----------------------------------------------
input MEM_reg_write_enable, WB_reg_write_enable;
input [4:0] MEM_destination_register, WB_destination_register, EX_read_register_0, EX_read_register_1;
output reg [FORWARDING_CODE_SIZE-1:0] forward_0, forward_1;

// -- Determine hazard ----------------------------------------
wire ex_hazard_0 = (
    MEM_reg_write_enable && 
    (MEM_destination_register != 0) &&
    (MEM_destination_register == EX_read_register_0)
);
wire ex_hazard_1 = (
    MEM_reg_write_enable && 
    (MEM_destination_register != 0) &&
    (MEM_destination_register == EX_read_register_1)
);
wire mem_hazard_0 = (
    WB_reg_write_enable &&
    (WB_destination_register != 0) &&
    !ex_hazard_0 &&
    (WB_destination_register == EX_read_register_0)
);
wire mem_hazard_1 = (
    WB_reg_write_enable &&
    (WB_destination_register != 0) &&
    !ex_hazard_1 &&
    (WB_destination_register == EX_read_register_1)
);

// -- Set forwarding signals ----------------------------------
always @(*) begin
    case ('b1)
        ex_hazard_0: forward_0 <= ALU_RESULT;
        mem_hazard_0: forward_0 <= MEMORY;
        default: forward_0 <= REG_FILE;
    endcase
    case ('b1)
        ex_hazard_1: forward_1 <= ALU_RESULT;
        mem_hazard_1: forward_1 <= MEMORY;
        default: forward_1 <= REG_FILE;
    endcase    
end

endmodule