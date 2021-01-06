`timescale 1ns/10ps

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("TEST FAILED: signal != value"); \
            $stop; \
        end

module core_tb;
// Include necessary headers

// IO
reg clock;
reg reset;
reg [13:0] io_input_bus;    // Not used yet
wire [51:0] io_output_bus;  // Not used yet

// Device under test
core DUT(
    .clock(clock),
    .reset(reset),
    .io_input_bus(io_input_bus),
    .io_output_bus(io_output_bus)
);

// Create clock
always #5 clock = ~clock;

// Code for testing
initial begin
    // Set to known state
    reset <= 1;
    clock <= 0;
    #15 reset <= 0;

    // Stop after t/10 clock cycles
    #400 $stop();
end



endmodule