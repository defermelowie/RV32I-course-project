
addi s0, zero, 0x400	 	#basisadres inputs
addi t0, zero, 0x3FF 	#alle leds aan
add s1, s0, s0			#basisadres outputs
sw t0, 0(s1)
lw a0, 0(s0)
lw a1, 1(s0)
lw x12, 2(s0)

