// This module is for simulating only, for synthesizing a RAM Quartus IP block is used.
module data_memory (
	address,    // input -> address to read/write
	clock,      // input -> clock
	data,       // input -> input data
	wren,       // input -> high enables write
	q           // output -> output data
);

// -- Module IO -----------------------------------------------
// Io matches that of RAM IP block and thus should not be altered!
input [8:0] address;
input clock;
input [31:0] data;
input wren;
output [31:0] q;

// -- Internal signals ----------------------------------------
reg wren_reg;
reg [8:0] address_reg;
reg [31:0] data_reg;
reg [31:0] mem [511:0];

// -- Process to control input registers ----------------------
always @(posedge clock) begin
    wren_reg <= wren;
    address_reg <= address;
    data_reg <= data;
end

// -- Read from memory ----------------------------------------
assign q = mem[address_reg];

// -- Write to memory -----------------------------------------
always @(posedge clock) begin
    if (wren)
        mem[address_reg] <= data_reg;
end

endmodule