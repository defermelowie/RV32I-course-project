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

// Device under test
alu DUT (
    .in_0(in_0),
    .in_1(in_1),
    .operation(operation),
    .out(out)
);

// Code for testing
initial begin
    $display("START TEST: add");
    operation <= ALU_ADD;
    in_0 <= 5;
    in_1 <= 7;
    #1 `assert(out, 12)
    in_0 <= -2;
    in_1 <= 7;
    #1 `assert(out, 5)
    $display("TEST DONE: add");

    $display("START TEST: sub");
    operation <= ALU_SUB;
    in_0 <= 5;
    in_1 <= 7;
    #1 `assert(out, -2)
    in_0 <= 12;
    in_1 <= 4;
    #1 `assert(out, 8)
    in_0 <= -2;
    in_1 <= -7;
    #1 `assert(out, 5)
    in_0 <= 15;
    in_1 <= 0;
    #1 `assert(out, 15)
    $display("TEST DONE: sub");

    $display("START TEST: xor");
    operation <= ALU_XOR;
    in_0 <= 5;
    in_1 <= 6;
    #1 `assert(out, 3)
    in_0 <= 10;
    in_1 <= 3;
    #1 `assert(out, 9)
    $display("TEST DONE: xor");

    $display("START TEST: or:");
    operation <= ALU_OR;
    in_0 <= 10;
    in_1 <= 3;
    #1 `assert(out, 11)
    in_0 <= 11;
    in_1 <= -11;
    #1 `assert(out, -1)
    $display("TEST DONE: or:");

    $display("START TEST: and");
    operation <= ALU_AND;
    in_0 <= 10;
    in_1 <= 3;
    #1 `assert(out, 2)
    $display("TEST DONE: and");

    $display("START TEST: lsr");
    operation <= ALU_LSR;
    in_0 <= 10;
    in_1 <= 3;
    #1 `assert(out, 1)
    in_0 <= -1;
    in_1 <= 3;
    #1 `assert(out, 'h1FFFFFFF)
    $display("TEST DONE: lsr");

    $display("START TEST: lsl");
    operation <= ALU_LSL;
    in_0 <= 5;
    in_1 <= 3;
    #1 `assert(out, 40)
    $display("TEST DONE: lsl");

    $display("START TEST: pass input 1");
    operation <= ALU_PASS_1;
    in_0 <= 8;
    in_1 <= 14;
    #1 `assert(out, 14)
    $display("TEST DONE: pass input 1");

    $display("START TEST: asr");
    operation <= ALU_ASR;
    in_0 <= 10;
    in_1 <= 3;
    #1 `assert(out, 1)
    in_0 <= -10;
    in_1 <= 3;
    #1 `assert(out, -2)
    in_0 <= -1;
    in_1 <= 37;
    #1 `assert(out, 'hFFFFFFFF)
    $display("TEST DONE: asr");

    $display("START TEST: slt");
    operation <= ALU_LT;
    in_0 <= 10;
    in_1 <= 3;
    #1 `assert(out, 0)
    in_0 <= 2;
    in_1 <= 5;
    #1 `assert(out, 1)
    in_0 <= -10;
    in_1 <= 3;
    #1 `assert(out, 1)
    in_0 <= -2;
    in_1 <= -3;
    #1 `assert(out, 0)
    $display("TEST DONE: slt");

    $display("START TEST: sltu");
    operation <= ALU_LTU;
    in_0 <= 10;
    in_1 <= 3;
    #1 `assert(out, 0)
    in_0 <= 2;
    in_1 <= 5;
    #1 `assert(out, 1)
    in_0 <= -10;
    in_1 <= 3;
    #1 `assert(out, 0)
    in_0 <= 5;  //0101
    in_1 <= -3; //1101
    #1 `assert(out, 1)
    in_0 <= -2; //1111
    in_1 <= -3; //1101
    #1 `assert(out, 0)
    $display("TEST DONE: sltu");

    $display("ALL TEST FINISHED");
    $stop();
end

endmodule