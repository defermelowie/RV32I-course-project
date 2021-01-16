.text
    # Set registers
    addi t0, zero, 0x00000003
    addi t1, zero, 0x00000005
    li t5, 0x00000c00 # use as io base address
    addi t6, zero, 0x00000015 # use as data segment address
    addi s0, zero, 0x00000000 # skip delay loops if set to 0

    ### Show t0 ###############################################
    # t3 = 0xff * 2^17 = 0x1FE0000
    beq s0, zero, exita0    # skip if s0 == zero
    addi t4, zero, 0x00000011
    addi t3, zero, 0x000000ff
    add0:
        add t3, t3, t3
        addi t4, t4, -1
        beq t4, zero, exita0
        beq zero, zero, add0
    exita0:

    # Show t0
    sw t0, 0(t5)    # write t2 to leds

    # Wait for t3 (0x1FE0000) clockcycli
    beq s0, zero, exit0
    loop0:
        addi t3, t3, -1
        beq t3, zero, exit0
        beq zero, zero, loop0
    exit0:

    ### Show t1 ###############################################
    # t3 = 0xff * 2^17 = 0x1FE0000
    beq s0, zero, exita1    # skip if s0 == zero
    addi t4, zero, 0x00000011
    addi t3, zero, 0x000000ff
    add1:
        add t3, t3, t3
        addi t4, t4, -1
        beq t4, zero, exita1
        beq zero, zero, add1
    exita1:

    # Show t1
    sw t1, 0(t5)    # write t2 to leds

    # Wait for t3 (0x1FE0000) clockcycli
    beq s0, zero, exit1 # skip if s0 == zero
    loop1:
        addi t3, t3, -1
        beq t3, zero, exit1
        beq zero, zero, loop1
    exit1:

    ### Test add instruction ##################################
    # t3 = 0xff * 2^17 = 0x1FE0000
    beq s0, zero, exita2    # skip if s0 == zero
    addi t4, zero, 0x00000011
    addi t3, zero, 0x000000ff
    add2:
        add t3, t3, t3
        addi t4, t4, -1
        beq t4, zero, exita2
        beq zero, zero, add2
    exita2:

    # Show add(t0, t1)
    add t2, t1, t0
    sw t2, 0(t5)    # write t2 to leds

    # Wait for t3 (0x1FE0000) clockcycli
    beq s0, zero, exit2 # skip if s0 == zero
    loop2:
        addi t3, t3, -1
        beq t3, zero, exit2
        beq zero, zero, loop2
    exit2:

    ### Test sub instruction ##################################
    # t3 = 0xff * 2^17 = 0x1FE0000
    beq s0, zero, exita3    # skip if s0 == zero
    addi t4, zero, 0x00000011
    addi t3, zero, 0x000000ff
    add3:
        add t3, t3, t3
        addi t4, t4, -1
        beq t4, zero, exita3
        beq zero, zero, add3
    exita3:

    # Show sub(t0, t1)
    sub t2, t0, t1
    sw t2, 0(t5)    # write t2 to leds

    # Wait for t3 (0x1FE0000) clockcycli
    beq s0, zero, exit3 # skip if s0 == zero
    loop3:
        addi t3, t3, -1
        beq t3, zero, exit3
        beq zero, zero, loop3
    exit3:

    ### Test and instruction ##################################
    # t3 = 0xff * 2^17 = 0x1FE0000
    beq s0, zero, exita4    # skip if s0 == zero
    addi t4, zero, 0x00000011
    addi t3, zero, 0x000000ff
    add4:
        add t3, t3, t3
        addi t4, t4, -1
        beq t4, zero, exita4
        beq zero, zero, add4
    exita4:

    # Show and(t0, t1)
    and t2, t0, t1
    sw t2, 0(t5)    # write t2 to leds

    # Wait for t3 (0x1FE0000) clockcycli
    beq s0, zero, exit4 # skip if s0 == zero
    loop4:
        addi t3, t3, -1
        beq t3, zero, exit4
        beq zero, zero, loop4
    exit4:

    ### Test or instruction ###################################
    # t3 = 0xff * 2^17 = 0x1FE0000
    beq s0, zero, exita5    # skip if s0 == zero
    addi t4, zero, 0x00000011
    addi t3, zero, 0x000000ff
    add5:
        add t3, t3, t3
        addi t4, t4, -1
        beq t4, zero, exita5
        beq zero, zero, add5
    exita5:

    # Show or(t0, t1)
    or t2, t0, t1
    sw t2, 0(t5)    # write t2 to leds

    # Wait for t3 (0x1FE0000) clockcycli
    beq s0, zero, exit5 # skip if s0 == zero
    loop5:
        addi t3, t3, -1
        beq t3, zero, exit5
        beq zero, zero, loop5
    exit5:

    ### Test lw instruction and memory mapping of keys ########
    # t3 = 0xff * 2^17 = 0x1FE0000
    beq s0, zero, exita6    # skip if s0 == zero
    addi t4, zero, 0x00000011
    addi t3, zero, 0x000000ff
    add6:
        add t3, t3, t3
        addi t4, t4, -1
        beq t4, zero, exita6
        beq zero, zero, add6
    exita6:

    # Show key's at io_base_address + 8
    lw t2, 8(t5)
    sw t2, 0(t5)    # write t2 to leds

    # Wait for t3 (0x1FE0000) clockcycli
    beq s0, zero, exit6 # skip if s0 == zero
    loop6:
        addi t3, t3, -1
        beq t3, zero, exit6
        beq zero, zero, loop6
    exit6:

    ### Test memory mapping of switches and hex displays ######
    # t3 = 0xff * 2^17 = 0x1FE0000
    beq s0, zero, exita7    # skip if s0 == zero
    addi t4, zero, 0x00000011
    addi t3, zero, 0x000000ff
    add7:
        add t3, t3, t3
        addi t4, t4, -1
        beq t4, zero, exita7
        beq zero, zero, add7
    exita7:

    # Show switches at io_base_address + 7
    lw t2, 7(t5)
    sw t2, 1(t5)    # write t2 to hex0 at io_base_address + 1
    sw t2, 2(t5)    # write t2 to hex1 at io_base_address + 2
    sw t2, 3(t5)    # write t2 to hex2 at io_base_address + 3
    sw t2, 4(t5)    # write t2 to hex3 at io_base_address + 4
    sw t2, 5(t5)    # write t2 to hex4 at io_base_address + 5
    sw t2, 6(t5)    # write t2 to hex5 at io_base_address + 6

    # Wait for t3 (0x1FE0000) clockcycli
    beq s0, zero, exit7 # skip if s0 == zero
    loop7:
        addi t3, t3, -1
        beq t3, zero, exit7
        beq zero, zero, loop7
    exit7:

    ### Loop forever ##########################################
    beq zero, zero, 0