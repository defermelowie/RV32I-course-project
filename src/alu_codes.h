// -- ALU operations encoding ---------------------------------
parameter ALU_ADD = 4'b0000;    // add
parameter ALU_SUB = 4'b0001;    // subtract
parameter ALU_XOR = 4'b0010;    // xor
parameter ALU_OR  = 4'b0101;    // or
parameter ALU_AND = 4'b0110;    // and
parameter ALU_LSR = 4'b0111;    // logical shift right
parameter ALU_LSL = 4'b1000;    // logical shift left
parameter ALU_PASS_1 = 4'b1001; // pass input 1 to output
parameter ALU_ASR = 4'b1010;    // arithmetic shift right
