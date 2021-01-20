li s0, 0x400    # IO input base address
li s1, 0x800    # IO output base address

loop:
    lw t1, 0(s0)    # Load switches
    sw t1, 0(s1)    # Store to leds
    sw t1, 1(s1)    # Store to hex displays
    j loop
    