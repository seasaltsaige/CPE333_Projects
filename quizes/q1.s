# 1
 
lw  t3, 40(x10) # Load from memory at 'a' with offset 4 * 10
sw  t3, 40(x11) # Store for 'b' with offset 4 * 10


# 2

mv t6, zero # Sum
li t5, 9 # Counter

loop:
  beqz t5, end # Exit loop
  

end: