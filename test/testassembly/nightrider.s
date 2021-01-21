li s0, 0x800			# IO base address for leds and hex
li s3, 0x400			# IO base address for switches and keys
addi s1, zero, 1		# boundary right side leds
li s2, 0x200			# boundary left side leds
li s4, 0x2000000		# limit for counting
addi t0, zero, 1		# value for the leds
addi t1, zero, 0		# orientation of the knight rider (0 <-- ; 1 -->)

loop:
    sw t0, 0(s0)
    jal time_consuming_loop
	beq t0, s1, goLeft
	beq t0, s2, goRight
	bne t1, s1, shiftLeft
	srli t0, t0, 1
	addi t2, s0, 1
	beq zero, zero, loop

time_consuming_loop:
    addi t3, zero, 0
	
    L1:
	lw t4, 0(s3)
    add t3, t3, t4
    ble t3, s4, L1
    ret

goRight:
	addi t1, zero, 1
	srli t0, t0, 1
	jal loop

goLeft:
	addi t1, zero, 0
	jal shiftLeft


shiftLeft:
	slli t0, t0, 1
	jal loop
	