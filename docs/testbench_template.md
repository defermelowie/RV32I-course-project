# Testbench template

```verilog
`timescale 1ns/10ps

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("TEST FAILED: signal != value"); \
            $stop; \
        end

module {DUT module name}_tb;
// Include necessary headers

// IO
reg {DUT inputs};
wire {DUT outputs};

// Device under test
{DUT module name} DUT (

);

// Create clock if needed
// always #5 clock = ~clock;

// Code for testing
initial begin
    // Example assertion
    //`assert(a, 5)
end

endmodule
```