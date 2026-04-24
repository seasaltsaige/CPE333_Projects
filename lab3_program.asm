addi x7, zero, 7
addi x8, zero, 0x100
addi x10,zero,10
or  x11,x7,x10
sw  x11,0(x8)
addi x12, x7, 10
lw x13, 0(x8)
add x12, x12, x13
