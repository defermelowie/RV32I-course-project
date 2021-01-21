li s0, 0x2000   # output io base address
li t0, 0x0302B100
sw t0, 0(zero)
# MEMORY:
# addr data
# 0x0   00
# 0x1   B1
# 0x2   02
# 0x3   03

lw t1, 0(zero) # Should return 0x0302B100
jal time_consuming_loop

lh t1, 0(zero) # Should return 0xFFFFB100
jal time_consuming_loop
lh t1, 1(zero) # Should return 0x000002B1
jal time_consuming_loop
lh t1, 2(zero) # Should return 0x00000302
jal time_consuming_loop

lb t1, 0(zero) # Should return 0x00000000
jal time_consuming_loop
lb t1, 1(zero) # Should return 0xFFFFFFB1
jal time_consuming_loop
lb t1, 2(zero) # Should return 0x00000002
jal time_consuming_loop
lb t1, 3(zero) # Should return 0x00000003
jal time_consuming_loop

lhu t1, 0(zero) # Should return 0x0000B100
jal time_consuming_loop
lhu t1, 1(zero) # Should return 0x000002B1
jal time_consuming_loop
lhu t1, 2(zero) # Should return 0x00000302
jal time_consuming_loop

lbu t1, 0(zero) # Should return 0x00000000
jal time_consuming_loop
lbu t1, 1(zero) # Should return 0x000000B1
jal time_consuming_loop
lbu t1, 2(zero) # Should return 0x00000002
jal time_consuming_loop
lbu t1, 3(zero) # Should return 0x00000003
jal time_consuming_loop

li t0, 0xCCEEFF11
sb t0, 0(zero) # Should store 0x0302B111
jal time_consuming_loop
sb t0, 1(zero) # Should store 0x0302FF11
jal time_consuming_loop
sb t0, 2(zero) # Should store 0x03EEFF11
jal time_consuming_loop
sb t0, 3(zero) # Should store 0xCCEEFF11
jal time_consuming_loop

time_consuming_loop:
    sw t1, 0(s0)
    sw t1, 4(s0)
    li t3, 0x3000000
    L1:
    addi t3, t3, -1
    bne t3, zero, L1
    ret