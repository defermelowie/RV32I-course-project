li t0, 0x0
li t1, 0x200
li t2, 0x800    # IO base address
loop:
    sw t0, 0(t0)
    sw t0, 0(t2)
    sw t0, 1(t2)
    addi t0, t0, 1
    bne t0, t1, loop
exit:
beq zero, zero, exit
    
