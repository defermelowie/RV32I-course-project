li s1, 0x2000   # output io base address
addi s0, s1, 4
li t0, 0x0302B18C

addi t1, zero, 1
sb t0, 0(s0) # Should store 0x0000008C
sw t1, 0(s1) 
jal time_consuming_loop
sb t0, 1(s0) # Should store 0x00008C8C
addi t1, t1, 1
sw t1, 0(s1)
jal time_consuming_loop
li t0, 0x2321
sb t0, 2(s0) # Should store 0x00218C8C
addi t1, t1, 1
sw t1, 0(s1)
jal time_consuming_loop
sh t0, 1(s0) # Should store 0x2123218C
addi t1, t1, 1
sw t1, 0(s1)
jal time_consuming_loop


time_consuming_loop:
    li t3, 0x3000000
    L1:
    addi t3, t3, -1
    bne t3, zero, L1
    ret