addi t0, x0, 5  # Mem hazard
addi t1, x0, 5  # Ex hazard
add t3, t1, t0

nop
nop
nop

sw t0, 0(sp)
nop
nop
nop
lw t3, 0(sp)    # Load hazard -> must stall
add t3, t1, t3
