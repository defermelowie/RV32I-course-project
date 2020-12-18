`timescale 1ns/10ps

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("TEST FAILED: %h != %h", signal, value); \
            $stop; \
        end

module alu_tb;

// Include necessary headers
`include "../src/alu_codes.h"  // Contains alu operation codes
`include "../src/riscv.h"      // Contains XLEN definition

// IO
reg [XLEN-1:0] in_0, in_1;
reg [3:0] operation;
wire [XLEN-1:0] out;
wire zero;

// Device under test
alu DUT (
    .in_0(in_0),
    .in_1(in_1),
    .operation(operation),
    .out(out),
    .zero(zero)
);

// Code for testing
initial begin
    #5 $display("START TEST: add");
    operation <= ALU_ADD;
    in_0 <= 5;
    in_1 <= 7;
    #1 `assert(out, 12)
    in_0 <= -2;
    in_1 <= 7;
    #1 `assert(out, 5)
    $display("FINISHED TEST: add");

    #5 $display("START TEST: sub");
    operation <= ALU_SUB;
    // TODO
    $display("FINISHED TEST: sub");

    #5 $display("START TEST: xor");
    operation <= ALU_XOR;
    // TODO
    $display("FINISHED TEST: xor");

    #5 $display("START TEST: or:");
    operation <= ALU_OR;
    // TODO
    $display("FINISHED TEST: or:");

    #5 $display("START TEST: and");
    operation <= ALU_AND;
    // TODO
    $display("FINISHED TEST: and");

    #5 $display("START TEST: lsr");
    operation <= ALU_LSR;
    // TODO
    $display("FINISHED TEST: lsr");

    #5 $display("START TEST: lsl");
    operation <= ALU_LSL;
    // TODO
    $display("FINISHED TEST: lsl");

    #5 $display("START TEST: pass input 1");
    operation <= ALU_PASS_1;
    // TODO
    $display("FINISHED TEST: pass input 1");

    #5 $display("START TEST: asr");
    operation <= ALU_ASR;
    // TODO
    $display("FINISHED TEST: asr");

    #5 $display("ALL TEST FINISHED");
    $stop();
end

endmodule