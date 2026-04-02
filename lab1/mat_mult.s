.data

  SIZE:  .word 5
  MAT_A: .word 1, 2, 5, 8, 7,
               8, 2, 6, 2, 9,
               1, 2, 3, 9, 0, 
               1, 1, 7, 7, 3,
               8, 9, 4, 2, 8

  MAT_B: .word 9, 2, 3, 1, 9,
               2, 3, 1, 8, 4, 
               1, 9, 4, 2, 9,
               2, 9, 3, 7, 6,
               1, 8, 3, 4, 1

  MAT_OUT: .word 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0

.text
main:
init: 
  li sp, 0xFFFC # Init SP

  la a0, MAT_A 
  la a1, MAT_B
  li a2, 5
  la a3, MAT_OUT

  call mat_mult

  prog_end:
    j prog_end 


# Matrix multiplication of an n x n matrix
# a0 = addr[A]
# a1 = addr[B]
# a2 = size
# a3 = output matrix after multiplication
mat_mult:
  addi sp, sp, -4
  sw ra, 0(sp)

  mat_init:

  mv s0, zero # i counter
  mv s1, zero # j counter
  mv s2, zero # k counter

  mv t2, a0
  mv t3, a1
  mv t4, a2
  mv t5, a3

  li s0, 0 # i = 0
  loop_i:
    
    li s1, 0 # j = 0
    loop_j:


      loop_k:
        

        call mult
        add a2, a2, 

      j loop_k
      end_k:

    end_j:

  end_i:




  lw ra, 0(sp)
  addi sp, sp 4
  ret


# Muliply two numbers
# Numbers held in a0 and a1
# Return set in a2
multiply:
  addi sp, sp, -4
  sw ra, 0(sp)
  mv t6, a1 # Make copy of counter for additio
  mv a2, zero # Init return accum

  mult_loop: 
    beqz a1, end_mult
    
    add a2, a2, t6 # Add mult
    
    addi a1, a1, -1 # Subtract one from multiplier
    j mult_loop

  end_mult:

  lw ra, 0(sp)
  addi sp, sp, 4
  ret