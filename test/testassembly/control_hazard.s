# Normal operation: branch not taken
li t0, 7
li t1, 8
nop
nop
nop
beq t0, t1, branch_1
li t3, 1
branch_1:
nop

# Normal operation: branch taken
li t0, 9
li t1, 9
nop
nop
nop
beq t0, t1, branch_2
li t3, 2
branch_2:
nop

# Control hazard: EX stage
li t0, 5
nop
li t1, 5    # Data in EX stage
beq t0, t1, branch_3
li t3, 3
branch_3:
nop

# Control hazard: MEM stage
li t0, 7
li t1, 7    # Data in MEM stage
nop
beq t0, t1, branch_4
li t3, 3
branch_4:
nop