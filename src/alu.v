module alu (
    in_0,           // input -> first data input of alu
    in_1,           // input -> second data input of alu
    operation,      // input -> specify operation
    out            // output -> data output
);

// -- Include definitions -------------------------------------
`include "riscv.h"      // Contains XLEN definition
`include "alu_codes.h"  // Contains alu operation codes

// -- Module IO -----------------------------------------------
input [XLEN-1:0] in_0, in_1;
input [3:0] operation;
output reg [XLEN-1:0] out;

// -- Internal signals ----------------------------------------
wire [2*XLEN-1:0] in_0_extended = {{XLEN{in_0[XLEN-1]}},in_0};

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
            if (in_1 > XLEN)
                out <= {XLEN{in_0[XLEN-1]}};
            else
                out <= in_0_extended >> in_1;
        end
        ALU_PASS_1: out <= in_1;
        ALU_LT: begin
            if (in_0[XLEN-1] && in_1[XLEN-1])           // Both are negative
                out <= (in_0 < in_1);
            else if (!in_0[XLEN-1] && in_1[XLEN-1])     // in_0 is positive and in_1 is negative
                out <= 0;
            else if (in_0[XLEN-1] && !in_1[XLEN-1])     // in_0 is negative and in_1 is positive
                out <= 1;
            else                                        // Both are positive
                out <= (in_0 < in_1);
        end
        ALU_LTU: out <= (in_0 < in_1) ? 1 : 0;
        default: out <= {XLEN{1'b0}};   // Return zero in case of unknown operation code
    endcase
end

endmodule