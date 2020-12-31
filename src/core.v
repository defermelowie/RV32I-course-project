module core (
    clock,
    reset,
    io_input_bus,
    io_output_bus
);


// -- Include definitions -------------------------------------
`include "riscv.h"              // Contains XLEN definition
`include "forwarding_codes.h"   // Contains forwarding codes


// -- Module IO -----------------------------------------------
input clock, reset;
input [10:0] io_input_bus;  // TODO
output [10:0] io_output_bus; // TODO


// Pipeline independent wires ---------------------------------
wire stale;


// -- Instruction Fetch stage ---------------------------------
// Wire defs ------------------
wire [8:0] IF_pc_in;
// TODO dertermine pc in

// -- Instruction memory ------
reg [XLEN-1:0] IF_instruction;
instruction_memory INSTRUCTION_MEMORY(
    .address(IF_pc_in), // pc in instead of pc out because address has an input register
	.clock(clock),  
	.data(32'b0),       // Set to zero since write is never used
	.wren(0),           // Never write to instruction mem (is initialized)  
	.q(IF_instruction)       
);

// -- Program counter ---------
// Needed since the signal after the input register of "INSTRUCTION_MEMORY" is inaccessible
reg [8:0] IF_pc_out;
register PC(
    .in(IF_pc_in),
    .write_enable(!stale),
    .out(IF_pc_out),
    .clock(clock),
    .reset(reset)
);


// -- Instruction Decode stage --------------------------------
// Wire defs ------------------
wire [31:0] ID_instruction;
wire [8:0] ID_pc_out;

// -- Pipeline reg IF -> ID ---
register #(31) IF_instruction_ID (.in(IF_instruction), .write_enable(!stale), .out(ID_instruction), .clock(clock), .reset(reset)); // TODO add flush IF to reset
register #(9) IF_pc_out_ID (.in(IF_pc_out), .write_enable(!stale), .out(ID_pc_out), .clock(clock), .reset(reset)); // TODO add flush IF to reset

// -- Control -----------------
reg ID_branch_enable, ID_mem_write_enable, ID_reg_write_enable, ID_mem_to_reg, ID_alu_src, ID_alu_inv_zero, ID_ill_instr;   // Control outputs
reg [3:0] ID_alu_op;
wire ID_control = {ID_branch_enable, ID_mem_write_enable, ID_reg_write_enable, ID_mem_to_reg, ID_alu_src, ID_alu_inv_zero, ID_ill_instr};
control CONTROL(
    .instruction(ID_instruction),  
    .stale(stale), 
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
    .read_reg_0(ID_instruction[19:15]),
    .read_reg_1(ID_instruction[24:20]),
    .write_reg(ID_instruction[11:7]),
    .write_data(0), // TODO get from WB
    .write_enable(0), // TODO (WB_reg_write_enable)
    .read_data_0(ID_read_data_0), 
    .read_data_1(ID_read_data_1), 
    .clock(clock),   
    .reset(reset) 
);


// -- Immediate generator -----
reg [XLEN-1:0] ID_immediate_out;
immediate_generator IMMEDIATE_GENERATOR(
    .instruction(ID_instruction),
    .immediate_out(ID_immediate_out)
);


// -- Execution stage -----------------------------------------
// Wire defs ------------------
wire [XLEN-1:0] EX_read_data_0, EX_read_data_1;
wire EX_branch_enable, EX_mem_write_enable, EX_reg_write_enable, EX_mem_to_reg, EX_alu_src, EX_alu_inv_zero, EX_ill_instr;
wire EX_alu_op;
wire EX_control = {EX_branch_enable, EX_mem_write_enable, EX_reg_write_enable, EX_mem_to_reg, EX_alu_src, EX_alu_inv_zero, EX_ill_instr};

// -- Pipeline reg ID -> EX ---
register #(XLEN) ID_read_data_0_EX (.in(ID_read_data_0), .write_enable('1), .out(EX_read_data_0), .clock(clock), .reset(reset));
register #(XLEN) ID_read_data_1_EX (.in(ID_read_data_1), .write_enable('1), .out(EX_read_data_1), .clock(clock), .reset(reset));
register #(7) ID_control_EX (.in(ID_control), .write_enable('1), .out(EX_control), .clock(clock), .reset(reset));
register #(4) ID_alu_op_EX (.in(ID_alu_op), .write_enable('1), .out(EX_alu_op), .clock(clock), .reset(reset));

// -- Arithmetic logic unit ---
reg [XLEN-1:0] EX_alu_out;
reg EX_alu_zero;
alu ALU(
    .in_0(0), // TODO
    .in_1(0), // TODO
    .operation(EX_alu_op),
    .inv_zero(EX_alu_inv_zero),
    .out(EX_alu_out),
    .zero(EX_alu_zero)
);


// -- Memory access stage -------------------------------------

// -- Data memory -------------
reg MEM_data_mem_out;
data_memory DATA_MEMORY(
	.address(0), // TODO
	.clock(clock),  
	.data(0), // TODO
    .wren(0), // TODO
	.q(MEM_data_mem_out)
);


// -- Write back stage ----------------------------------------
// TODO


// -- Forwarding and hazard detection -------------------------

// -- Forwarding unit ---------
reg [FORWARDING_CODE_SIZE-1:0] EX_forward_0, EX_forward_1;
forwarding_unit FORWARDING_UNIT (
    .MEM_reg_write_enable(0), // TODO
    .WB_reg_write_enable(0), // TODO
    .MEM_destination_register(0), // TODO
    .WB_destination_register(0), // TODO
    .EX_read_register_0(0), // TODO
    .EX_read_register_1(0), // TODO
    .forward_0(EX_forward_0),
    .forward_1(EX_forward_1)
);

// -- Hazard detection unit ---
hazard_detection_unit HAZARD_DETECTION_UNIT (
    .EX_mem_to_reg(0), // TODO
    .EX_destination_register(0), // TODO
    .ID_read_register_0(0), // TODO
    .ID_read_register_1(0), // TODO
    .stale(stale)
);

endmodule