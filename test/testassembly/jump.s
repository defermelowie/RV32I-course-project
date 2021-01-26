li t0, 5
li t1, 7
li s1, 0x2000
nop
nop
nop
nop
jal test  # jump to test and save position to ra
nop
nop
nop
nop
auipc t0, 0x1
sw t0, 4(s1)
nop
nop
nop
nop
beq zero, zero, exit


test:
    add t2, t1, t0
    ret

exit:
    j exit