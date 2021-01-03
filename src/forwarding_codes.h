parameter FORWARDING_CODE_SIZE = 2;
// -- Forwarding encoding -------------------------------------
parameter ID_REG_OUT = 'b00;    // Data must come from register file
parameter EX_ALU_OUT = 'b01;    // Data must come from alu result in EX stage
parameter MEM_MEM_OUT = 'b10;   // Data must come from memory out in MEM stage
parameter MEM_ALU_OUT = 'b11;   // Data must come from alu result in MEM stage