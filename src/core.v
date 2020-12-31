module core (
    clock,
    reset,
    io_input_bus,
    io_output_bus
);


// -- Include definitions -------------------------------------
`include "riscv.h" // Contains XLEN definition


// -- Module IO -----------------------------------------------
input clock, reset;


// -- Instruction Fetch stage ---------------------------------
reg IF_pc_in;
// TODO dertermine pc in

// -- Instruction memory ------
reg IF_instruction;
instruction_memory INSTRUCTION_MEMORY(
    .address(IF_pc_in), // pc in instead of pc out because address has an input register
	.clock(clock),  
	.data(32'b0),       // Set to zero since write is never used
	.wren(0),           // Never write to instruction mem (is initialized)  
	.q(IF_instruction)       
);

// -- Program counter ---------
// Needed since the signal after the input register of "INSTRUCTION_MEMORY" is inaccessible
reg IF_pc_out;
register PC(
    .in(IF_pc_in),
    .write_enable(), // TODO don't write pc when stalling
    .out(IF_pc_out),
    .clock(clock),
    .reset(reset)
);


// -- Instruction Decode stage --------------------------------

// -- Control -----------------
reg ID_branch_enable, ID_mem_write_enable, ID_reg_write_enable, ID_mem_to_reg, ID_alu_src, ID_alu_inv_zero, ID_ill_instr;   // Control outputs
control CONTROL(
    .instruction(), // TODO   
    .stale(), // TODO  
    .branch_enable(ID_branch_enable),      
    .mem_write_enable(ID_mem_write_enable),   
    .reg_write_enable(ID_reg_write_enable),   
    .mem_to_reg(ID_mem_to_reg),         
    .alu_op(ID_alu_op),             
    .alu_src(ID_alu_src),            
    .alu_inv_zero(ID_alu_inv_zero),           
    .ill_instr(ID_ill_instr)           
);

// -- Register file -----------
reg [XLEN-1:0] ID_read_data_0, ID_read_data_1;
register_file REGISTER_FILE(
    .read_reg_0(), // TODO  
    .read_reg_1(), // TODO  
    .write_reg(), // TODO   
    .write_data(), // TODO  
    .write_enable(), // TODO
    .read_data_0(ID_read_data_0), 
    .read_data_1(ID_read_data_1), 
    .clock(clock),   
    .reset(reset) 
);


// -- Immediate generator -----
reg [XLEN-1:0] ID_immediate_out;
immediate_generator IMMEDIATE_GENERATOR(
    .instruction(), // TODO
    .immediate_out(ID_immediate_out)
);


// -- Execution stage -----------------------------------------

// -- Arithmetic logic unit ---
reg [XLEN-1:0] EX_alu_out;
reg EX_alu_zero;
alu ALU(
    .in_0(), // TODO     
    .in_1(), // TODO     
    .operation(), // TODO
    .inv_zero(), // TODO 
    .out(EX_alu_out),      
    .zero(EX_alu_zero)      
);


// -- Memory access stage -------------------------------------
// TODO


// -- Write back stage ----------------------------------------
// TODO

endmodule