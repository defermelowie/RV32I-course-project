module data_memory (
	address,        // input -> address to read/write
    byteena,        // input -> byte enable [3:0]
	clock,          // input -> clock
	data,           // input -> input data
	wren,           // input -> high enables write
	q,              // output -> output data
    io_input_bus,    // input -> input io
    io_output_bus   // output -> output io
);

// -- Module IO -----------------------------------------------
input [9:0] address;        // 2^10 words
input [3:0] byteena;
input clock;
input [31:0] data;
input wren;
output [31:0] q;
input [13:0] io_input_bus;
output [51:0] io_output_bus;

// -- Internal signals ----------------------------------------
wire [31:0] mem_out;
wire [31:0] io_out;
wire io_address;

// -- Chose between io out or mem out -------------------------
assign q = (io_address) ? io_out : mem_out;

// -- Memory block --------------------------------------------
data_memory_ip_block DATA_MEMORY_IP_BLOCK(
	.address(address),              // has input register !
    .byteena(byteena),              // has input register !
	.clock(clock),                  // has input register !
	.data(data),                    // has input register !
    .wren(wren && !io_address),     // has input register !
	.q(mem_out)
);

// -- Determine if address is IO address ----------------------
// TODO
assign io_address = 0;  // temporarily for testing

// -- Write io registers --------------------------------------
// Must have input registers!
// TODO

// -- Read io registers ---------------------------------------
// Must have input register for address signal!
// TODO

endmodule