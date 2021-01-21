li t0, 0x0302B100
sw t0, 0(zero)
# MEMORY:
# addr data
# 0x0   00
# 0x1   B1
# 0x2   02
# 0x3   03

lw t1, 0(zero) # Should return 0x0302B100

lh t1, 0(zero) # Should return 0xFFFFB100
lh t1, 1(zero) # Should return 0x000002B1
lh t1, 2(zero) # Should return 0x00000302

lb t1, 0(zero) # Should return 0x00000000
lb t1, 1(zero) # Should return 0xFFFFFFB1
lb t1, 2(zero) # Should return 0x00000002
lb t1, 3(zero) # Should return 0x00000003

lhu t1, 0(zero) # Should return 0x0000B100
lhu t1, 1(zero) # Should return 0x000002B1
lhu t1, 2(zero) # Should return 0x00000302

lbu t1, 0(zero) # Should return 0x00000000
lbu t1, 1(zero) # Should return 0x000000B1
lbu t1, 2(zero) # Should return 0x00000002
lbu t1, 3(zero) # Should return 0x00000003

li t0, 0xCCEEFF11
sb t0, 0(zero) # Should store 0x0302B111
sb t0, 1(zero) # Should store 0x0302FF11
sb t0, 2(zero) # Should store 0x03EEFF11
sb t0, 3(zero) # Should store 0xCCEEFF11