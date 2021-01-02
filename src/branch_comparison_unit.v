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
wire signed in_0_signed, in_1_signed;
assign in_0_signed = in_0;
assign in_1_signed = in_1;

// -- process to decide to branch -----------------------------
always @(*) begin
    branch <= 0;    // Preset branch to zero, then set in neccesary
    case (mode)
        EQ: if (in_0 == in_1) branch => 1;
        NE: if (in_0 != in_1) branch => 1;
        LT: if (in_0_signed < in_1_signed) branch => 1;
        GE: if (in_0_signed >= in_1_signed) branch => 1;
        LTU: if (in_0 < in_1) branch => 1;
        GEU: if (in_0 >= in_1) branch => 1;
        default: branch <= 0; // In case of unknown mode, do not branch
    endcase 
end
    
endmodule