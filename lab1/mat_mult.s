# Saige Sloan
# Cal Poly SLO
# Description: The following program implements a simple
#              algorithm for finding the matrix product of two
#              square N x N matricies.

.data
  SIZE:    .word  16
  MAT_A:   .word    0,   3,   2,   0,   3,   1,   0,   3,   2,   3,   2,   0,   3,   3,   1,   2,   3,   0,   0,   1, 
    1,   1,   2,   3,   1,   2,   3,   1,   1,   3,   2,   2,   0,   1,   3,   2,   2,   2,   0,   0, 
    1,   0,   1,   3,   3,   0,   3,   3,   3,   3,   0,   3,   2,   1,   2,   2,   0,   0,   3,   0, 
    1,   1,   0,   3,   3,   1,   2,   3,   3,   0,   1,   2,   1,   0,   1,   2,   2,   1,   0,   3, 
    1,   0,   2,   2,   1,   1,   1,   1,   1,   1,   2,   0,   3,   1,   1,   2,   2,   3,   3,   1, 
    3,   2,   0,   0,   0,   3,   3,   3,   2,   1,   2,   3,   1,   0,   0,   0,   0,   1,   2,   2, 
    1,   1,   3,   3,   3,   1,   1,   2,   3,   1,   3,   3,   2,   3,   2,   1,   2,   3,   0,   2, 
    2,   1,   1,   0,   0,   0,   0,   0,   1,   3,   3,   1,   1,   1,   2,   2,   3,   2,   1,   1, 
    1,   1,   3,   0,   2,   2,   1,   3,   2,   1,   2,   2,   1,   3,   1,   3,   1,   3,   2,   3, 
    1,   2,   1,   3,   2,   2,   0,   1,   0,   0,   1,   2,   3,   3,   1,   0,   0,   0,   3,   1, 
    2,   3,   2,   3,   2,   0,   0,   0,   0,   0,   3,   1,   3,   0,   0,   0,   3,   1,   1,   1, 
    1,   2,   1,   2,   3,   2,   0,   0,   2,   2,   3,   0,   3,   0,   0,   3,   0,   3,   1,   3, 
    3,   1,   1,   1,   2,   2,   1,   3,   0,   3,   3,   1,   0,   0,   3,   2

  MAT_B:   .word    1,   1,   0,   3,   1,   2,   0,   0,   0,   0,   0,   2,   1,   2,   3,   0,   0,   3,   3,   2, 
    2,   1,   2,   3,   3,   0,   2,   2,   1,   1,   2,   2,   0,   2,   2,   1,   2,   3,   2,   2, 
    3,   3,   2,   2,   1,   1,   1,   1,   2,   1,   2,   2,   3,   3,   3,   0,   0,   3,   2,   3, 
    2,   3,   1,   2,   1,   1,   2,   2,   0,   1,   0,   3,   2,   1,   1,   1,   2,   0,   1,   2, 
    2,   0,   2,   1,   3,   3,   2,   3,   2,   0,   3,   1,   3,   3,   2,   0,   1,   0,   1,   1, 
    2,   2,   1,   1,   2,   2,   1,   2,   3,   3,   1,   3,   2,   2,   2,   3,   3,   1,   0,   2, 
    1,   0,   0,   0,   1,   1,   2,   0,   3,   2,   3,   3,   0,   2,   3,   1,   0,   0,   2,   1, 
    2,   0,   2,   1,   1,   2,   3,   1,   3,   2,   1,   0,   0,   0,   0,   0,   2,   2,   0,   2, 
    1,   2,   0,   3,   2,   2,   0,   0,   3,   2,   1,   1,   3,   0,   2,   0,   0,   1,   0,   2, 
    3,   3,   1,   3,   3,   0,   0,   2,   2,   0,   0,   0,   1,   0,   0,   1,   3,   0,   2,   1, 
    3,   2,   2,   1,   3,   2,   0,   1,   2,   2,   3,   2,   1,   1,   1,   1,   3,   0,   1,   3, 
    2,   2,   3,   1,   1,   2,   0,   2,   1,   1,   2,   3,   1,   0,   1,   0,   1,   1,   0,   0, 
    2,   0,   3,   0,   3,   0,   3,   2,   2,   3,   3,   2,   1,   0,   2,   2

  MAT_OUT: .word  0

# Notes:
#
# --- Dont forget that each location is 4 bytes
#     - Meaning offset by 4 for each increment
#
# In Memory we have for mat_a:
# [  ↑  ]
# [ ... ] ; Other stuff above
# -------- Start of Matrix
# [  1  ] # <- Row 1, Col 1 | 0
# [  2  ] # Col 2           | 1
# [  5  ] # Col 3           | 2
# [  8  ] # Col 4           | 3
# [  7  ] # Col 5           | 4
# ---------------
# [  8  ] # <- Row 2, Col 1 | 5
# [  2  ] # Col 2           | 6
# [  6  ] # Col 3           | 7
# [  2  ] # Col 4           | 8
# [  9  ] # Col 5           | 9
# --------------- ; More rows below
# [ ... ]
# -------- End of Matrix
# [ ... ] ; Other stuff below
# [  ↓  ] 
#
# To find an arbitrary position in the matrix
# we need to know its size, which we are given.
# We know that it is square.
# First to find the row:
# (Assuming loop as in the example C code)
# lets just say matrix size = N
# row = i*N
# for example, say we are at row 2 in a 5x5 matrix
# (**0 based indexing**)
# we will have i = 1, N = 5
# So we will offset by 5 elements, landing us
# exactly at the start of Row 2, as seen above. Perfect.
# Now to find the column offset, based on the example,
# k acts as the column index (for accessing A),
# *j acts as the column index for saving the result*
# So, simply, col = k
# So, putting it together, if we want Row 2, Col 4
# again, 0 based index
# We will have i*N + k, or, 1*5 + 3.
# ---
# Now, this isn't quite enough, since these values in memory
# are words, not bytes, we will need to multiply the entire thing
# by 4, so, the final index for A is:
# (i*N + k)*4
# ..... Yay...!
# A very similar approach is done for mat b, but with
# k as the row index, and j as the column index.
# Phew, thats a lot. Should be good now though

.text
main:
init: 
  li sp, 0xFFFC # Init SP

  la a0, MAT_A 
  la a1, MAT_B
  la a2, SIZE
  lw a2, 0(a2) # get mat size 
  la a3, MAT_OUT

  li s6, 0x11080000 # LED Port

  call mat_mult

  li t0, 0xFF
  sw t0, 0(s6) # Write FF to LEDs

  prog_end:
    j prog_end 


# Matrix multiplication of an n x n matrix
# a0 = addr[A]
# a1 = addr[B]
# a2 = size
# a3 = output matrix after multiplication
mat_mult:
  addi sp, sp, -36
  sw   ra, 32(sp)
  sw   s0, 28(sp)             # Used for i
  sw   s1, 24(sp)             # Used for j
  sw   s2, 20(sp)             # Used for k
  sw   s3, 16(sp)             # Used to sum row/col mults
  sw   s4, 12(sp)             # addr[A]
  sw   s5, 8(sp)              # addr[B]
  sw   s6, 4(sp)              # addr[outMat]
  sw   s7, 0(sp)              # size

  mv   s4, a0                 # Copy addr[A]
  mv   s5, a1                 # Copy addr[B]
  mv   s6, a3                 # Copy addr[outMat]
  mv   s7, a2                 # Copy size
  
  mv   s0, zero               # i counter
  loop_i:

    bge s0, s7, end_i         # If i >= SIZE (end of row)

    mv  s1, zero              # j counter
    loop_j:

      bge s1, s7, end_j       # If j >= SIZE (end of col)
      mv  s3, zero            # clear accumulator for each matrix cell
      mv  s2, zero            # k counter
      loop_k:
        bge s2, s7, end_k    # If k >= SIZE
        # Get mat_A[i][k]
        
        # Note: s0 = i, s7 = size
        mv   a0, s0 
        mv   a1, s7
        call multiply       # yields i*size
        add  a0, a0, s2     # i*size + k

        slli a0, a0, 2      # Multiply by 4
                            # WORD offset

        # Add base address of A
        add  a0, a0, s4     # yields addr[A[i][k]]
        lw   t0, 0(a0)      # Get value from memory

        # Get mat_B[i][k]
        # Similar as for A

        # Note: s2 = k, s7 = size
        mv   a0, s2 
        mv   a1, s7
        call multiply       # yields k*size
        add  a0, a0, s1     # k*size + j
        slli a0, a0, 2      # Multiply by 4

        # Add base address of B now
        add  a0, a0, s5     # yields addr[B[k][j]] now
        lw   t2, 0(a0)      # Load val from mem

        # Multiply the two values above (t0 * t2)
        mv   a0, t0
        mv   a1, t2         # Copy values to args
        call multiply

        add  s3, s3, a0     # Add output to accumulator
        addi s2, s2, 1

        j    loop_k
      end_k:
      k_admin:

      # Calculate output matrix location/address
      mv   a0, s0
      mv   a1, s7
      call multiply         # i*size
      add  a0, a0, s1       # i*size + j
      slli a0, a0, 2        # mult by 4
      
      # Get out mat address
      add  a0, a0, s6       # yields addr[outMat[i][j]]
      sw   s3, 0(a0)        # store accumulated value in out matrix

      addi s1, s1, 1
      j    loop_j
    end_j:
    
    addi s0, s0, 1
    j    loop_i
  end_i:



  # Restore context
  lw   s7, 0(sp)
  lw   s6, 4(sp)
  lw   s5, 8(sp)
  lw   s4, 12(sp)
  lw   s3, 16(sp)
  lw   s2, 20(sp)
  lw   s1, 24(sp)
  lw   s0, 28(sp)
  lw   ra, 32(sp)
  
  addi sp, sp, 36
  ret


# Muliply two numbers
# Numbers held in a0 and a1
# Return set in a0
multiply:
  addi sp, sp, -4
  sw   ra, 0(sp)

  mv   t6, a0           # Make copy
  mv   a0, zero         # Init return accum

  mult_loop: 
    beqz a1, end_mult
    
    add  a0, a0, t6
    addi a1, a1, -1
    
    j    mult_loop

  end_mult:

  lw     ra, 0(sp)
  addi   sp, sp, 4
  ret
