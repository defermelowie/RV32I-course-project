module branch_comparison_unit (
    in_0,    // input -> first register file output
    in_1,    // input -> second register file output
    mode,   // input -> comparison mode
    branch  // output -> high if comparison is true
);

// -- Include definitions -------------------------------------
`include "riscv.h"              // Contains XLEN definition
`include "comparison_codes.h"   // Contains comparison codes

// -- Module IO -----------------------------------------------
input wire [XLEN-1:0] in_0, in_1;
input wire [2:0] mode;
output reg branch;

// -- Internal signals ----------------------------------------

// -- process to decide to branch -----------------------------
always @(*) begin
    branch <= 0;    // Preset branch to zero, then set if neccesary
    case (mode)
        EQ: if (in_0 == in_1) branch <= 1;
        NE: if (in_0 != in_1) branch <= 1;
        LT: begin
                if (!in_0[XLEN-1] && in_1[XLEN-1])          // in_0 is positive and in_1 is negative
                    branch <= 0;
                else if (in_0[XLEN-1] && !in_1[XLEN-1])     // in_0 is negative and in_1 is positive
                    branch <= 1;
                else                                        // in_0 and in_1 have equal sign
                    branch <= (in_0 < in_1);
            end
        GE: begin
                if (!in_0[XLEN-1] && in_1[XLEN-1])          // in_0 is positive and in_1 is negative
                    branch <= 1;
                else if (in_0[XLEN-1] && !in_1[XLEN-1])     // in_0 is negative and in_1 is positive
                    branch <= 0;
                else                                        // in_0 and in_1 have equal sign
                    branch <= (in_0 >= in_1);
            end
        LTU: if (in_0 < in_1) branch <= 1;
        GEU: if (in_0 >= in_1) branch <= 1;
        default: branch <= 0; // In case of unknown mode, do not branch
    endcase 
end
    
endmodule