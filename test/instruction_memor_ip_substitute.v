// This module is for simulating only, for synthesizing a RAM Quartus IP block is used.
module instruction_memory (
	address,        // input -> address to read/write
    	addressstall_a, // input -> high stalls address input register
	clock,          // input -> clock
	data,           // input -> input data
	wren,           // input -> high enables write
	q               // output -> output data
);

// -- Module IO -----------------------------------------------
// Io matches that of RAM IP block and thus should not be altered!
input [8:0] address;
input addressstall_a;
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
    data_reg <= data;
    if (!addressstall_a)
        address_reg <= address;
end

// -- Read from memory ----------------------------------------
assign q = mem[address_reg];

// -- Initialize memory ---------------------------------------
initial begin
        $readmemh ("../Repo/test/testmem/instruction_memory.mem", mem);
    end

endmodule