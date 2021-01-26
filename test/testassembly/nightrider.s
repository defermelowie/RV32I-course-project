li s0, 0x2000			# IO base address for leds and hex
li s3, 0x1000			# IO base address for switches and keys
addi s1, zero, 1		# boundary right side leds
li s2, 0x200			# boundary left side leds
li s4, 0x2000000		# limit for counting
addi t0, zero, 1		# value for the leds
addi t1, zero, 0		# orientation of the knight rider (0 <-- ; 1 -->)
addi s5, zero, 10		# comparision value for decimal counting

addi s6, zero, -1
addi s7, zero, 0
addi s8, zero, 0
addi s9, zero, 0
addi s10, zero, 0
addi s11, zero, 0

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
	jal counter
	slli t5, s11, 4
	add t5, t5, s10
	slli t5, t5, 4
	add t5, t5, s9
	slli t5, t5, 4
	add t5, t5, s8
	slli t5, t5, 4
	add t5, t5, s7
	slli t5, t5, 4
	add t5, t5, s6
	sw t5, 4(s0)
	jal shiftLeft


shiftLeft:
	slli t0, t0, 1
	jal loop

counter:
	e:
		addi s6, s6, 1
		beq s5, s6, t
		ret
	t: 
		addi s6, zero, 0
		addi s7, s7, 1
		beq s5, s7, h
		ret
	h:
		addi s7, zero, 0
		addi s8, s8, 1
		beq s5, s8, d
		ret
	d:
		addi s8, zero, 0
		addi s9, s9, 1
		beq s5, s9, td
		ret
	td:
		addi s9, zero, 0
		addi s10, s10, 1
		beq s5, s10, hd
		ret
	hd:
		addi s10, zero, 0
		addi s11, s11, 1
		beq s5, s11, exit
		ret
	exit:
		addi s11, zero, 0
		beq zero, zero, e
	
	
	