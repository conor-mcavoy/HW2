.text
.align 2
.globl main
main: 
	la $a0, input_prompt # load input prompt address into a0
	li $v0, 4            # prepare to print string
	syscall              # print input prompt
	
	li $v0, 5     # prepare to read int
	syscall       # read int into v0
	move $t0, $v0 # save input into t0
	
	li $t1, 0 # prepare to enter loop
	          # loop t0 times
			  # increment t1 by 3 each time, then print
	
loop1_start:
	blez $t0, loop1_end # if t0 <= 0, end loop
	addi $t0, $t0, -1   # decrement t0
	
	addi $t1, $t1, 3 # increment t1 by 3
	
	move $a0, $t1 # load int t1 into a0
	li $v0, 1     # prepare to print int
	syscall       # print t1
	
	la $a0, new_line # load new line address into a0
	li $v0, 4        # prepare to print string
	syscall          # print newline
	
	j loop1_start # go back to start of loop
	
loop1_end:

	#li $v0, 10 # prepare to exit
	#syscall    # exit
	
	jr $ra # exit
	
.data
input_prompt:
	.asciiz "Input integer:"
new_line:
	.asciiz "\n"