li t0, 0x0
li t1, 0x200
li s2, 0x2000    # IO base address
loop:
    sb t0, 0(t0)
    sw t0, 0(s2)
    sw t0, 1(s2)
    jal time_consuming_loop
    addi t0, t0, 1
    bne t0, t1, loop
exit:
beq zero, zero, exit

time_consuming_loop:
    li t3, 0x1000000
    L1:
    addi t3, t3, -1
    bne t3, zero, L1
    ret
    
