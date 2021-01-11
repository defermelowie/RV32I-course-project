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
input [11:0] address;        // 2^10 words + gpio addresses
input [3:0] byteena;
input clock;
input [31:0] data;
input wren;
output [31:0] q;
input [13:0] io_input_bus;
output reg [51:0] io_output_bus;

// -- Internal signals ----------------------------------------
wire [31:0] mem_out;
reg [31:0] io_out;

// -- registers for address and data
wire [11:0] address_register;
register #(12) address_register_data_memory (.in(address), .write_enable(1'b1), .out(address_register), .clock(clock), .reset(1'b0));
wire [31:0] data_register;
register #(32) data_register_data_memory (.in(data), .write_enable(1'b1), .out(data_register), .clock(clock), .reset(1'b0));
wire wren_register;
register #(1) wren_register_data_memory (.in(wren), .write_enable(1'b1), .out(wren_register), .clock(clock), .reset(1'b0));

// -- Chose between io out or mem out -------------------------
assign q = (address_register[10]) ? io_out : mem_out;

// -- Memory block --------------------------------------------
data_memory_ip_block DATA_MEMORY_IP_BLOCK(
	.address(address),              // has input register !
    .byteena(byteena),              // has input register !
	.clock(clock),                  // has input register !
	.data(data),                    // has input register !
    .wren(wren && !address[11]),     // has input register !
	.q(mem_out)
);


// -- Write io registers --------------------------------------
// Must have input registers!
always @(posedge clock)
begin
	if (address_register[11] && wren_register)
	begin
		case (address_register[2:0] )
		3'b000: io_output_bus[9:0] <= data_register[9:0];
		3'b001: io_output_bus[16:10] <= data_register[6:0];
		3'b010: io_output_bus[23:17] <= data_register[6:0];
		3'b011: io_output_bus[30:24] <= data_register[6:0];
		3'b100: io_output_bus[37:31] <= data_register[6:0];
		3'b101: io_output_bus[44:38] <= data_register[6:0];
		3'b110: io_output_bus[51:45] <= data_register[6:0];
		default: io_out <= {32{1'b0}};
		endcase
	end
end

// -- Read io registers ---------------------------------------
// Must have input register for address signal!
always @(*)
begin
	if (address_register[10])
	begin
		case (address_register[2:0])
		3'b000: io_out <= {{22{1'b0}}, io_input_bus[9:0]};
		3'b001: io_out <= {{31{1'b0}}, io_input_bus[10]};
		3'b010: io_out <= {{31{1'b0}}, io_input_bus[11]};
		3'b011: io_out <= {{31{1'b0}}, io_input_bus[12]};
		3'b100: io_out <= {{31{1'b0}}, io_input_bus[13]};
		default: io_out <= {32{1'b0}};
		endcase
	end
end

endmodule