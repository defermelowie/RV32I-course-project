// This module is for simulating only, for synthesizing a RAM Quartus IP block is used.
module data_memory_ip_block (
    aclr,       // input -> async clear
	address,    // input -> address to read/write
    byteena,    // input -> byte enable [3:0]
	clock,      // input -> clock
	data,       // input -> input data
	wren,       // input -> high enables write
	q           // output -> output data
);

// -- Module IO -----------------------------------------------
// Io matches that of 1-port RAM IP block and thus should not be altered!
input aclr;
input [9:0] address;        // 2^10 words
input [3:0] byteena;
input clock;
input [31:0] data;
input wren;
output [31:0] q;

// -- Internal signals ----------------------------------------
reg wren_reg;
reg [9:0] address_reg;
reg [31:0] data_reg;
reg [31:0] mem [1023:0];

// -- Process to control input registers ----------------------
always @(posedge clock) begin
    if (aclr) begin
        wren_reg <= 0;
        address_reg <= 0;
        data_reg <= 0;
    end else begin
        wren_reg <= wren;
        address_reg <= address;
        data_reg <= data;
    end
end

// -- Read from memory ----------------------------------------
assign q = mem[address_reg];

// -- Write to memory -----------------------------------------
always @(posedge clock) begin
    if (wren_reg)
        mem[address_reg] <= data_reg;
end

endmodule