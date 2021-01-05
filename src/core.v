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
input [13:0] io_input_bus;      // |13 KEY 10|9 SW 0|
output [51:0] io_output_bus;    // |51 HEX5 45|44 HEX4 38|37 HEX3 31|30 HEX2 24|23 HEX1 17|16 HEX0 10|9 LED 0|


// Pipeline independent wires ---------------------------------
wire stale;
wire [8:0] pc_branch_address;
wire branch_enable;


// -- Instruction Fetch stage -----------------------------------------------------------------------------------------------
// Wire defs ------------------
reg [8:0] IF_pc_in;
wire [8:0] IF_pc_out;

// -- Dertermine pc in ----------------------------------------
always @(*) begin
    if (reset)
        IF_pc_in <= 0;
    else 
        IF_pc_in <= (branch_enable) ? pc_branch_address : IF_pc_out + 4;
end

// -- Instruction memory --------------------------------------
wire [XLEN-1:0] IF_instruction;
instruction_memory INSTRUCTION_MEMORY(
    .address(IF_pc_in >> 2), // pc in instead of pc out because address has an input register
	.clock(clock),  
	.data(32'b0),       // Set to zero since write is never used
	.wren(1'b0),        // Never write to instruction mem (is initialized)  
	.q(IF_instruction)       
);

// -- Program counter -----------------------------------------
// Needed since the signal after the input register of "INSTRUCTION_MEMORY" is inaccessible
register #(9) PC(
    .in(IF_pc_in),
    .write_enable(!stale),
    .out(IF_pc_out),
    .clock(clock),
    .reset(reset)
);


// -- Instruction Decode stage ----------------------------------------------------------------------------------------------
// Wire defs ------------------
wire [31:0] ID_instruction;
wire [8:0] ID_pc_out;

// -- Pipeline reg IF -> ID -----------------------------------
register #(32) IF_instruction_ID (
    .in(IF_instruction), 
    .write_enable(!stale), 
    .out(ID_instruction), 
    .clock(clock), 
    .reset(reset || branch_enable)   // Flush IF registers when taking branch
);
register #(9) IF_pc_out_ID (
    .in(IF_pc_out), 
    .write_enable(!stale), 
    .out(ID_pc_out), 
    .clock(clock), 
    .reset(reset || branch_enable)  // Flush IF registers when taking branch
);

// -- Control -------------------------------------------------
wire ID_branch_inst, ID_mem_write_enable, ID_reg_write_enable, ID_mem_to_reg, ID_alu_src, ID_ill_instr;   // Control outputs
wire [2:0] ID_branch_mode;
wire [3:0] ID_alu_op;
control CONTROL(
    .instruction(ID_instruction),  
    .stale(stale), 
    .branch_enable(ID_branch_inst),   
    .branch_mode(ID_branch_mode), 
    .mem_write_enable(ID_mem_write_enable),   
    .reg_write_enable(ID_reg_write_enable),   
    .mem_to_reg(ID_mem_to_reg),         
    .alu_op(ID_alu_op),             
    .alu_src(ID_alu_src),          
    .ill_instr(ID_ill_instr)           
);

// -- Register file -------------------------------------------
wire [XLEN-1:0] ID_read_data_0, ID_read_data_1;
wire [31:0] WB_instruction;
wire [XLEN-1:0] WB_reg_data_in;
wire WB_reg_write_enable;
register_file REGISTER_FILE(
    .read_reg_0(ID_instruction[19:15]),
    .read_reg_1(ID_instruction[24:20]),
    .write_reg(WB_instruction[11:7]),
    .write_data(WB_reg_data_in),
    .write_enable(WB_reg_write_enable),
    .read_data_0(ID_read_data_0),
    .read_data_1(ID_read_data_1),
    .clock(clock),
    .reset(reset)
);

// -- Set data based on forwarding ----------------------------
wire [FORWARDING_CODE_SIZE-1:0] forward_mode_0, forward_mode_1;
reg [XLEN-1:0] ID_data_0, ID_data_1;
wire [XLEN-1:0] EX_alu_out;
wire [XLEN-1:0] MEM_alu_out;
wire [XLEN-1:0] MEM_mem_data_out;
always @(*) begin
    case (forward_mode_0)
        ID_REG_OUT: ID_data_0 <= ID_read_data_0;
        EX_ALU_OUT: ID_data_0 <= EX_alu_out;
        MEM_MEM_OUT: ID_data_0 <= MEM_mem_data_out;
        MEM_ALU_OUT: ID_data_0 <= MEM_alu_out;
        default: ID_data_0 <= ID_read_data_0;
    endcase
    case (forward_mode_1)
        ID_REG_OUT: ID_data_1 <= ID_read_data_1;
        EX_ALU_OUT: ID_data_1 <= EX_alu_out;
        MEM_MEM_OUT: ID_data_1 <= MEM_mem_data_out;
        MEM_ALU_OUT: ID_data_1 <= MEM_alu_out;
        default: ID_data_1 <= ID_read_data_1;
    endcase
end

// -- Branch comparison unit ----------------------------------
wire ID_branch_comp; 
branch_comparison_unit BRANCH_COMPARISON_UNIT(
    .in_0(ID_data_0),
    .in_1(ID_data_1),
    .mode(ID_branch_mode),
    .branch(ID_branch_comp)
);

// -- Immediate generator -------------------------------------
wire [XLEN-1:0] ID_immediate_out;
immediate_generator IMMEDIATE_GENERATOR(
    .instruction(ID_instruction),
    .immediate_out(ID_immediate_out)
);

// -- Calculate branch address --------------------------------
assign pc_branch_address = ID_immediate_out + ID_pc_out;

// -- Set branch enable ---------------------------------------
assign branch_enable = (ID_branch_inst && ID_branch_comp);


// -- Execution stage -------------------------------------------------------------------------------------------------------
// Wire defs ------------------
wire [31:0] EX_instruction;
wire [XLEN-1:0] EX_data_0, EX_data_1, EX_immediate_out;
wire EX_mem_write_enable, EX_reg_write_enable, EX_mem_to_reg, EX_alu_src;
wire [3:0] EX_alu_op;

// -- Pipeline reg ID -> EX -----------------------------------
register #(32) ID_instruction_EX (.in(ID_instruction), .write_enable('b1), .out(EX_instruction), .clock(clock), .reset(reset));
register #(XLEN) ID_data_0_EX (.in(ID_data_0), .write_enable('b1), .out(EX_data_0), .clock(clock), .reset(reset));
register #(XLEN) ID_data_1_EX (.in(ID_data_1), .write_enable('b1), .out(EX_data_1), .clock(clock), .reset(reset));
register #(XLEN) ID_immediate_out_EX (.in(ID_immediate_out), .write_enable('b1), .out(EX_immediate_out), .clock(clock), .reset(reset));
register #(1) ID_mem_write_enable_EX (.in(ID_mem_write_enable), .write_enable('b1), .out(EX_mem_write_enable), .clock(clock), .reset(reset));
register #(1) ID_reg_write_enable_EX (.in(ID_reg_write_enable), .write_enable('b1), .out(EX_reg_write_enable), .clock(clock), .reset(reset));
register #(1) ID_mem_to_reg_EX (.in(ID_mem_to_reg), .write_enable('b1), .out(EX_mem_to_reg), .clock(clock), .reset(reset));
register #(1) ID_alu_src_EX (.in(ID_alu_src), .write_enable('b1), .out(EX_alu_src), .clock(clock), .reset(reset));
register #(4) ID_alu_op_EX (.in(ID_alu_op), .write_enable('b1), .out(EX_alu_op), .clock(clock), .reset(reset));

// -- Arithmetic logic unit -----------------------------------
alu ALU(
    .in_0(EX_data_0),
    .in_1((EX_alu_src) ? EX_immediate_out : EX_data_1),
    .operation(EX_alu_op),
    .out(EX_alu_out)
);


// -- Memory access stage ---------------------------------------------------------------------------------------------------
// Wire defs ------------------
wire [31:0] MEM_instruction;
wire MEM_mem_write_enable, MEM_reg_write_enable, MEM_mem_to_reg;
wire [XLEN-1:0] MEM_mem_data_in;

// -- Pipeline reg EX -> MEM ----------------------------------
register #(32) EX_instruction_MEM (.in(EX_instruction), .write_enable('b1), .out(MEM_instruction), .clock(clock), .reset(reset));
register #(XLEN) EX_alu_out_MEM (.in(EX_alu_out), .write_enable('b1), .out(MEM_alu_out), .clock(clock), .reset(reset));
register #(XLEN) EX_mem_data_in_MEM (.in(EX_data_1), .write_enable('b1), .out(MEM_mem_data_in), .clock(clock), .reset(reset));   // Alu in 1 -> mem data!
register #(1) EX_mem_write_enable_MEM (.in(EX_mem_write_enable), .write_enable('b1), .out(MEM_mem_write_enable), .clock(clock), .reset(reset));
register #(1) EX_reg_write_enable_MEM (.in(EX_reg_write_enable), .write_enable('b1), .out(MEM_reg_write_enable), .clock(clock), .reset(reset));
register #(1) EX_mem_to_reg_MEM (.in(EX_mem_to_reg), .write_enable('b1), .out(MEM_mem_to_reg), .clock(clock), .reset(reset));


// -- Data memory ---------------------------------------------
data_memory DATA_MEMORY(
	.address(EX_alu_out[9:0]),   // EX instead of MEM since memory has input registers
    .byteena(4'b0),              // TODO set byte enable based on instruction (lw, lb, lh)
	.clock(clock),  
	.data(EX_data_1),            // EX instead of MEM since memory has input registers
    .wren(EX_mem_write_enable),  // EX instead of MEM since memory has input registers
	.q(MEM_mem_data_out),
    .io_input_bus(io_input_bus),
    .io_output_bus(io_output_bus)
);


// -- Write back stage ------------------------------------------------------------------------------------------------------
// Wire defs ------------------
wire WB_mem_to_reg;
wire [XLEN-1:0] WB_mem_data_out, WB_alu_out;

// -- Pipeline reg MEM -> WB ----------------------------------
register #(32) MEM_instruction_WB (.in(MEM_instruction), .write_enable('b1), .out(WB_instruction), .clock(clock), .reset(reset));
register #(XLEN) MEM_mem_data_out_WB (.in(MEM_mem_data_out), .write_enable('b1), .out(WB_mem_data_out), .clock(clock), .reset(reset));
register #(XLEN) MEM_alu_out_WB (.in(MEM_alu_out), .write_enable('b1), .out(WB_alu_out), .clock(clock), .reset(reset));
register #(1) MEM_reg_write_enable_WB (.in(MEM_reg_write_enable), .write_enable('b1), .out(WB_reg_write_enable), .clock(clock), .reset(reset));
register #(1) MEM_mem_to_reg_WB (.in(MEM_mem_to_reg), .write_enable('b1), .out(WB_mem_to_reg), .clock(clock), .reset(reset));

// Determine registerfile data source ----------------------------------
assign WB_reg_data_in = (WB_mem_to_reg) ? WB_mem_data_out : WB_alu_out;


// -- Forwarding and hazard detection ---------------------------------------------------------------------------------------

// -- Forwarding unit -----------------------------------------
forwarding_unit FORWARDING_UNIT (
    .ID_instruction(ID_instruction),             // input -> instruction in the instruction decode stage
    .EX_reg_write_enable(EX_reg_write_enable),   // input -> "reg_write_enable" from execution stage
    .EX_instruction(EX_instruction),             // input -> instruction in the execution stage
    .MEM_reg_write_enable(MEM_reg_write_enable), // input -> "reg_write_enable" from memory access stage
    .MEM_instruction(MEM_instruction),           // input -> instruction in the memory access stage
    .MEM_mem_to_reg(MEM_mem_to_reg),             // input -> "mem_to_reg" from the memory access stage
    .forward_mode_0(forward_mode_0),             // output -> forwarding mode for data 0 
    .forward_mode_1(forward_mode_1)              // output -> forwarding mode for data 1 
);

// -- Hazard detection unit -----------------------------------
hazard_detection_unit HAZARD_DETECTION_UNIT (
    .EX_mem_to_reg(EX_mem_to_reg),
    .EX_destination_register(EX_instruction[11:7]),
    .ID_read_register_0(ID_instruction[19:15]),
    .ID_read_register_1(ID_instruction[24:20]),
    .stale(stale)
);

endmodule