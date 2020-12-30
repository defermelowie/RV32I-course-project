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
// TODO

// -- Instruction Decode stage --------------------------------

// -- Control -----------------
reg ID_branch_enable, ID_mem_write_enable, ID_reg_write_enable, ID_mem_to_reg, ID_alu_src, ID_alu_inv_zero, ID_ill_instr;   // Control outputs
control CONTROL(
    .instruction(), // TODO      
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
    .clock(), // TODO     
    .reset() // TODO    
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