# Saige Sloan
# Cal Poly SLO
# Assume each section (#1, #2, and #3) are their own 
# contexts, and that labels do not conflict.
# ===================================================================
# 1
# Load from b[10]
lw   t2, 40(x11)  # b[10] (4 * 10 for words); 4 bytes in a word
addi t2, t2, 10   # + 10
sw   t2, 40(x10)  # a[10] = b[10] + 10
# ===================================================================


# ===================================================================
# 2
.data
  # 20 Element list of random numbers
  a: .word 3, 9, 3, 1, 6, 3, 7, 2, 1, 8, 0, 0, 2, 3, 5, 7, 1, 2, 7, 3

.text

main:
  la s0, a # Load base address of array
  mv t6, zero # Sum
  li s1, 40 # 10 * 4 for word offset (element 0 to 9)
  li t5, 0 # Counter/a offset

  loop:
    bge t5, s1, end # If t5 >= s1, branch to end

    add t2, s0, t5 # Add offset to base
    lw t3, 0(t2) # Load value from array
    add t6, t6, t3 # Add value to sum
    addi t5, t5, 4 # Move to next value in array
    j loop # Loop back
  end:
# ===================================================================

# ===================================================================
# 3
.data
  # 20 Element list of random numbers
  a: .word 3, 9, 3, 1, 6, 3, 7, 2, 1, 8, 0, 0, 2, 3, 5, 7, 1, 2, 7, 3

.text
main:
  # Example usage
  li   a0, 15
  la   a1, a
  call func
  # a0 now contains sum
  mv   t6, a0   # Do stuff with the result

  quit: 
    j  quit


# 'func' takes n and &a as parameters in
# a0 and a1
# returning 'sum' in a0
func:
  # a0 = n
  # a1 = &a
  slli t0, a0, 2      # n * 4 for word size
  mv   a0, zero       # Clear return/sum
  mv   t2, zero       # Counter/offset
  loop:
    bge  t2, t0, end  # if t2 >= t0, branch to end
    add  t3, a1, t2   # &a + offset
    lw   t3, 0(t3)    # Get value from array
    add  a0, a0, t3   # Accumulate
    addi t2, t2, 4    # Next value in array
    j    loop
  end:
  ret

# ===================================================================