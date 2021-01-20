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
