module alu (
    in_0,
    in_1,
    operation,
    out,
    zero
);

// -- Include definitions -------------------------------------
`include "riscv.h"      // Contains XLEN definition
`include "alu_codes.h"  // Contains alu operation codes

// -- Module IO -----------------------------------------------
input [XLEN-1:0] in_0, in_1;
input [3:0] operation;
output reg [XLEN-1:0] out;
output reg zero;

// -- Internal signals ----------------------------------------
wire signed [XLEN-1:0] in_0_signed, in_1_signed;    // Must be signed in order for right shift arithmetic (>>>) and set less than to work
reg signed [XLEN-1:0] out_signed;                  // Must be signed in order for right shift arithmetic (>>>) and set less than to work
assign in_0_signed = in_0;
assign in_1_signed = in_1;

// -- Calculate output based on operation code ----------------
always @(*) begin
    case (operation)
        ALU_ADD: out <= in_0 + in_1;
        ALU_SUB: out <= in_0 - in_1;
        ALU_XOR: out <= in_0 ^ in_1;
        ALU_OR: out <= in_0 | in_1;
        ALU_AND: out <= in_0 & in_1;
        ALU_LSR: out <= in_0 >> in_1;
        ALU_LSL: out <= in_0 << in_1;
        ALU_ASR: begin
            out_signed <= in_0_signed >>> in_1_signed;
            out <= out_signed;
        end 
        ALU_PASS_1: out <= in_1;
        ALU_LT: begin
            out_signed <= (in_0_signed < in_1_signed)? 1 : 0;
            out <= out_signed;
        end
        ALU_LTU: out <= (in_0 < in_1)? 1 : 0;
        default: out <= {XLEN{1'b0}};   // Return zero in case of unknown operation code
    endcase
    zero <= (out == {XLEN{1'b0}});
end

endmodule