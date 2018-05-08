.text
.align 2
.globl main
main:
	addi $sp, $sp, -4   # make room for ra on stack
	sw $ra, 0($sp)      # save ra on stack
	
	la $a0, input_prompt #load string address into a0
	li $v0, 4 #prepare to print string
	syscall #print string
	
	li $v0, 5 #prepare to read int
	syscall #read int into v0
	
	move $a0, $v0 #save input into a0 to prepare for function call
	
	jal func
	
	#answer now in v0
	
	move $a0, $v0 #load int v0 into a0
	li $v0, 1 #prepare to print int
	syscall #display answer
	
	#li $v0, 10 #prepare to exit
	#syscall #exit
	
	lw $ra, 0($sp)   # reload ra from stack
	addi $sp, $sp, 4 # readjust stack
	jr $ra           # exit

func: #function that calculates f(a0)
	li $v0, 2 #prepare to exit if a0 == 0
	beq $a0, $0, func_exit
	
	li $t0, 1
	li $v0, 3 #prepare to exit if a0 == 1
	beq $a0, $t0, func_exit

	addi $sp, $sp, -16 #make room on stack for four variables
	sw $a0, 0($sp) #store a0
	sw $s0, 4($sp) #store s0
	sw $s1, 8($sp) #store s1
	sw $ra, 12($sp) #store ra
	
	addi $a0, $a0, -1 #prepare to call f(a0-1)
	jal func #call f(a0-1), result in $v0
	move $s0, $v0 #s0 is result of call f(a0-1)
	
	addi $a0, $a0, -1 #prepare to call f(a0-2)
	jal func
	move $s1, $v0 #s1 is result of call f(a0-2)
	
	li $t0, 3 #prepare to multiply s1 by 3
	mul $s1, $s1, $t0 #multiply s1 by 3
	
	li $v0, 1
	add $v0, $v0, $s0
	add $v0, $v0, $s1 #set v0 = 1 + s0 + s1
	
	lw $a0, 0($sp) #load a0
	lw $s0, 4($sp) #load s0
	lw $s1, 8($sp) #load s1
	lw $ra, 12($sp) #load ra
	addi $sp, $sp, 16 #readjust stack, remove three variables
	
func_exit:
	jr $ra
	
.data
input_prompt:
	.asciiz "Input integer:"
new_line:
	.asciiz "\n"