parameter FORWARDING_CODE_SIZE = 2;
// -- Forwarding encoding -------------------------------------
parameter REG_FILE = 'b00;      // Alu operand must come from register file
parameter ALU_RESULT = 'b01;    // Alu operand must come from prior alu result
parameter MEMORY = 'b10;        // Alu operand must come from memory or from prior alu result (based on control:mem_to_reg) 