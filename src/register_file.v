module register_file (
    read_reg_0,     // input -> address of reg to read
    read_reg_1,     // input -> address of reg to read
    write_reg,      // input -> address of reg to write
    write_data,     // input -> data to write
    write_enable,   // input -> high enables write
    read_data_0,    // output -> data at address "read_reg_0"
    read_data_1,    // output -> data at address "read_reg_1"
    clock,          // input -> clock
    reset           // input -> resets all registers
);

// -- Include definitions -------------------------------------
`include "riscv.h"      // Contains XLEN definition

// -- Module IO -----------------------------------------------
input [4:0] read_reg_0, read_reg_1, write_reg;
input [XLEN-1:0] write_data;
input write_enable, clock, reset;
output reg [XLEN-1:0] read_data_0, read_data_1;

// Reg_file is 32 words deep for RV32I
reg [XLEN-1:0] reg_file [31:0];

// -- Process for reading -------------------------------------
always @ (*) begin
        if (read_reg_0 == 0)	// x0 is always zero
            read_data_0 <= 0;
        else
            read_data_0 <= reg_file [read_reg_0];
            
        if (read_reg_1 == 0) // x0 is always zero
            read_data_1 <= 0;
        else
            read_data_1 <= reg_file [read_reg_1];
end

// -- Process for writing -------------------------------------
integer i;
always @ (posedge clock) begin
    if (reset)                      // Set all registers to zero
        for (i=0; i < 32; i=i+1)
            reg_file [i] <= 32'b0;
    else if (write_enable == 1) begin
        if (write_reg != 0) begin   // Register x0 can't be written
            reg_file [write_reg] <= write_data;
        end
    end
end

endmodule