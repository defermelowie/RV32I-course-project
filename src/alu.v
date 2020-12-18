module ALU (
    in_0,
    in_1,
    operation,
    out,
    zero
);

`include "RISCV.h" // Contains XLEN definition
`include "alu_codes.h" // Contains alu operation codes

input [XLEN-1:0] in_0, in_1;
input [3:0] operation;
output reg [XLEN-1:0] out;
output reg zero;

always @(*) begin
    case (operation) // TODO add operations
        ALU_ADD: out <= in_0 + in_1;
        ALU_SUB: out <= in_0 - in_1;
        ALU_XOR: out <= in_0 ^ in_1;
        ALU_OR: out <= in_0 | in_1;
        ALU_AND: out <= in_0 & in_1;
        ALU_LSR: out <= in_0 >> in_1;
        ALU_LSL: out <= in_0 << in_1;
        ALU_PASS_1: out <= in_1;
        default: out <= {XLEN{1'b0}};
    endcase
    zero <= (out == {XLEN{1'b0}});
end
endmodule