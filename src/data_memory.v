module data_memory (
	address,        // input -> address to read/write
    mem_mode,		// input -> specifies memory mode i.e. byte/halfword/word
	mem_unsigned,	// input -> high indicates unsigned load
	clock,          // input -> clock
	data,           // input -> input data
	wren,           // input -> high enables write
	q,              // output -> output data
    io_input_bus,   // input -> input io
    io_output_bus,  // output -> output io
	reset			// input -> resets input registers
);

// -- Include definitions ---------------------------------
`include "mem_modes.h"          // Contains memory mode definitions

// -- Module IO -----------------------------------------------
input [31:0] address;        // 32 bit word (alu output)
input [1:0] mem_mode;
input clock, mem_unsigned, wren, reset;
input [31:0] data;
output reg [31:0] q;
input [13:0] io_input_bus;
output reg [51:0] io_output_bus;

// -- Internal signals ----------------------------------------
wire [31:0] mem_out;
reg [3:0] byte_enable;
reg [31:0] io_out;
reg [31:0] io_in;

// -- registers for address and data
wire [31:0] address_register;
register #(32) address_register_data_memory (.in(address), .write_enable(1'b1), .out(address_register), .clock(clock), .reset(reset));
wire [31:0] data_register;
register #(32) data_register_data_memory (.in(data), .write_enable(1'b1), .out(data_register), .clock(clock), .reset(reset));
wire wren_register;
register #(1) wren_register_data_memory (.in(wren), .write_enable(1'b1), .out(wren_register), .clock(clock), .reset(reset));
wire [3:0] byte_enable_reg;
register #(4) byte_enable_reg_data_memory (.in(byte_enable), .write_enable(1'b1), .out(byte_enable_reg), .clock(clock), .reset(reset));
wire [1:0] mem_mode_reg;
register #(2) mem_mode_reg_data_memory (.in(mem_mode), .write_enable(1'b1), .out(mem_mode_reg), .clock(clock), .reset(reset));

// -- Set byte enable according to mode & address -------------
always @(*) begin
	if (wren)
		case (mem_mode)
			MEM_BYTE: byte_enable <= ('b0001 << address[1:0]);
			MEM_HALF: byte_enable <= ('b0011 << address[1:0]);	// TODO "Problem" if address[1:0] == 3
			MEM_WORD: byte_enable <= 'b1111;
			default: byte_enable <= 'b1111; // Write full words as default
		endcase
	else byte_enable <= 'b0000;
end

// -- Select memory block (for writing) -----------------------
reg ram_sel, io_in_sel;	// Block select signals
always @(*) begin
	ram_sel <= 0;
	io_in_sel <= 0;
	if (address[13:12] == 'b00) begin
		ram_sel <= 1;
	end
	if (address_register[13:12] == 'b10) begin
		io_in_sel <= 1;
	end
end

// -- Select output source ------------------------------------
reg [31:0] unmasked_q;
always @(*) begin
	case (address_register[13:12])
		'b00: begin	// Select ram block
			unmasked_q <= mem_out >> (address_register[1:0]*8); // TODO "Problem" if address[1:0] == 3 and mode == MEM_HALF
		end
		'b01: begin	// Select block for reading from io
			unmasked_q <= io_out >> (address_register[1:0]*8); // TODO "Problem" if address[1:0] == 3 and mode == MEM_HALF
		end
		'b10: begin	// Select block for writing to io
			unmasked_q <= io_in >> (address_register[1:0]*8); // TODO "Problem" if address[1:0] == 3 and mode == MEM_HALF
		end
		default: unmasked_q <= 0;
	endcase
	case (mem_mode_reg)	// Shift and mask result based on mode
		MEM_BYTE: q <= {(mem_unsigned)? {24{1'b0}} : {24{unmasked_q[7]}}, unmasked_q[7:0]};
		MEM_HALF: q <= {(mem_unsigned)? {24{1'b0}} : {16{unmasked_q[15]}}, unmasked_q[15:0]};
		MEM_WORD: q <= unmasked_q;
		default: q <= unmasked_q;
	endcase
end

// -- Memory block --------------------------------------------
data_memory_ip_block DATA_MEMORY_IP_BLOCK(
	.aclr(reset),
	.address(address[11:2]),        // has input register !
    .byteena(byte_enable),          // has input register !
	.clock(clock),                  // has input register !
	.data(data),                    // has input register !
    .wren(wren && ram_sel),     	// has input register !
	.q(mem_out)
);


// -- Io input block ------------------------------------------
// Registers to store data of input to io
reg [31:0] io_registers [1:0];
// Process for writing to io registers
always @(posedge clock)
begin
	if (io_in_sel && wren_register)
	begin
		case (address_register[3:2]) // Must have input registers!
			3'b00: io_registers[0] <= data_register;
			3'b01: io_registers[1] <= data_register;
		endcase
	end
end
// Process for reading from io registers
always @(posedge clock)
begin
	case (address_register[3:2])
		'b00: io_in <= io_registers[0];
		'b01: io_in <= io_registers[1];
		default: io_in <= {32{1'b0}};
	endcase
end

wire [6:0] digit_0, digit_1, digit_2, digit_3, digit_4, digit_5;
bin2seg convert_digit_0 (io_registers[1][3:0], digit_0);
bin2seg convert_digit_1 (io_registers[1][7:4], digit_1);
bin2seg convert_digit_2 (io_registers[1][11:8], digit_2);
bin2seg convert_digit_3 (io_registers[1][15:12], digit_3);
bin2seg convert_digit_4 (io_registers[1][19:16], digit_4);
bin2seg convert_digit_5 (io_registers[1][23:20], digit_5);
// Map signals to IO's
always @(*) begin
	io_output_bus[9:0] <= io_registers[0][9:0];	// First io register
	io_output_bus[16:10] <= digit_0; 			// 1st digit from second io register
	io_output_bus[23:17] <= digit_1; 			// 2nd digit from second io register
	io_output_bus[30:24] <= digit_2; 			// 3th digit from second io register
	io_output_bus[37:31] <= digit_3; 			// 4th digit from second io register
	io_output_bus[44:38] <= digit_4; 			// 5th digit from second io register
	io_output_bus[51:45] <= digit_5; 			// 6th digit from second io register
end

// -- Io output block -----------------------------------------
// Map signals from IO's to io_out based on address
always @(posedge clock)
begin
	case (address_register[4:2]) // Must have input register for address signal!
		3'b000: io_out <= {{22{1'b0}}, io_input_bus[9:0]};
		3'b001: io_out <= {{31{1'b0}}, io_input_bus[10]};
		3'b010: io_out <= {{31{1'b0}}, io_input_bus[11]};
		3'b011: io_out <= {{31{1'b0}}, io_input_bus[12]};
		3'b100: io_out <= {{31{1'b0}}, io_input_bus[13]};
		default: io_out <= {32{1'b0}};
	endcase
end

endmodule