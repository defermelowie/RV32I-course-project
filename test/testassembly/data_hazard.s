addi t0, x0, 5  # Mem hazard
addi t1, x0, 5  # Ex hazard
add t3, t1, t0

nop
nop
nop

sw t0, 12(sp)
addi t0, x0, 5
addi t1, x0, 0
nop
nop
nop
lw t1, 12(sp)    # Load hazard -> must stall
add t3, t1, t0
