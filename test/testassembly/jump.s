li t0, 5
li t1, 7
nop
nop
nop
nop
jal test  # jump to test and save position to ra
nop
nop
nop
nop
test:
    add t2, t1, t0
    ret