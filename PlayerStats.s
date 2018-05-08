.text
.align 2
.globl main
main:
	addi $sp, $sp, -4   # make room for ra on stack
	sw $ra, 0($sp)      # save ra on stack
	
	li $s1, 0           # initialize head pointer to 0
	
input_loop:

	# create linked list nodes
	# each node has a name char buffer of size 40,
	# a float DOC, and a pointer next
	# 40 + 4 + 4 = 48
	li $a0, 48    # prepare to allocate 48 bytes
	li $v0, 9     # prepare for memory allocation
	syscall       # allocate memory
	move $s0, $v0 # store location of beginning new memory in s0
	
	la $a0, name_prompt # load address of name prompt into a0
	li $v0, 4           # prepare to print string
	syscall             # print name prompt
	
	move $a0, $s0 # keep location of new memory in a0
	li $a1, 40    # prepare to store up to 40 bytes in the buffer
	li $v0, 8     # prepare to read string
	syscall       # read name
	# now name is from location s0 up to s0 + 40
	# a0 still points to the same place as s0 but that will change due to strcomp
	
	la $a1, done # load address of done into a1
	jal strcomp  # compare name string with done
	
	beq $v0, $0, input_end # if name is equal to done then end input
	
	la $a0, points_prompt # load address of points prompt into a0
	li $v0, 4             # prepare to print string
	syscall               # print points prompt
	
	li $v0, 6      # prepare to read float
	syscall        # read float
	mov.s $f2, $f0 # save points into f2
	
	la $a0, assists_prompt # load address of assists prompt into a0
	li $v0, 4              # prepare to print string
	syscall                # print assists prompt
	
	li $v0, 6      # prepare to read float
	syscall        # read float
	mov.s $f4, $f0 # save assists into f4
	
	la $a0, minutes_prompt # load address of minutes prompt into a0
	li $v0, 4              # prepare to print string
	syscall                # print minutes prompt
	
	li $v0, 6     # prepare to read float
	syscall       # read float
	
	# at this point we have
	# s0 is the start of the memory location we need
	# name is already in place from s0 to somewhere before s0 + 40
	# f2 is points
	# f4 is assists
	# f0 is minutes
	# s1 points to the head (or 0 on first input)
	
	# now to calculate DOC = (points + assists) / minutes
	li.s $f6, 0.0  # set f6 to 0 for comparison
	
	c.eq.s $f0, $f6   # check if minutes == 0
	bc1t zero_minutes # if so, skip calculation
	
	add.s $f2, $f2, $f4 # calculate points + assists
	div.s $f0, $f2, $f0 # divide by minutes, answer in f0
	
	j DOC_done
	
zero_minutes:
	li.s $f0, 0.0

DOC_done:
	# now we put the DOC in s0 + 40 position
	mfc1 $t0, $f0   # move f0 so we can save it
	sw $t0, 40($s0) # put DOC in s0 + 40
	move $s4, $t0   # it will be useful to save DOC in s4
	
	# now to place the player node in the correct position in the linked list
	# for now we will simply place them in order for testing purposes
	
	beq $s1, $0, no_head # no head exists yet, so create the head
	j head_exists
	
no_head:
	move $s1, $s0 # if we need to create the head, we already have it ready in s0
	j input_loop  # continue reading input

head_exists:
	move $s2, $s1 # use s2 as the "current" node, start at the head
	li $s3, 0     # use s3 as the "previous" node, start as NULL
	
	# while (current player pointer) && (current DOC > new DOC)
	# move forward in list
move_forward_DOC:
	beq $s2, $0, stop_forward_DOC # if current player pointer is null we need to
	                              # stop moving forward

	lw $t0, 40($s2)            # temporarily store current DOC
	sub $t0, $t0, $s4          # set t0 = current DOC - new DOC
	blez $t0, stop_forward_DOC # if current DOC <= new DOC then stop
	
	move $s3, $s2   # prev player = current player
	lw $t0, 44($s2) # get current player next pointer
	move $s2, $t0   # set current player equal to next player
	
	j move_forward_DOC # keep looping
	
stop_forward_DOC:

move_forward_alpha:
	beq $s2, $0, stop_forward_alpha # if current player pointer is null then stop
	
	lw $t0, 40($s2)                  # temp save current DOC
	bne $t0, $s4, stop_forward_alpha # if DOCs aren't equal then don't sort
	
	move $a0, $s2 # prepare to strcomp
	move $a1, $s0 # prepare to strcomp
	jal strcomp   # if v0 < 0 then move forward
	
	bgez $v0, stop_forward_alpha # quit if new player comes first in alphabet
	
	move $s3, $s2   # prev player = current player
	lw $t0, 44($s2) # get current player next pointer
	move $s2, $t0   # set current player equal to next player
	
	j move_forward_alpha # keep looping
	
stop_forward_alpha:
	
	# at this point we have reached the correct location within the list
	# now we need to actually insert the new player
	
	beq $s2, $0, no_next_player
	j next_player_exists
	
no_next_player:
	sw $s0, 44($s3) # prev player next pointer is new player
	j input_loop    # done
	
next_player_exists:
	beq $s3, $0, no_prev_player
	j prev_player_exists
	
no_prev_player:
	sw $s1, 44($s0) # set new player next to head
	# but now the head pointer isn't right
	move $s1, $s0 # fix head pointer
	j input_loop  # done

prev_player_exists:
	lw $t0, 44($s3) # load prev player next
	sw $t0, 44($s0) # save in new player's next
	
	sw $s0, 44($s3) # set prev player next to new player
	j input_loop    # done
	
input_end:
	# print each name in order
	# s1 is head
	
print_start:
	move $a0, $s1      # get ready to print name
	jal trim_last_char # get rid of trailing new line
	
	li $v0, 4     # prepare to print string
	syscall       # print name
	
	la $a0, space # get ready to print space
	li $v0, 4     # prepare to print string
	syscall       # print space
	
	lw $t0, 40($s1) # load DOC
	mtc1 $t0, $f12  # store DOC in f12
	li $v0, 2       # prepare to print float
	syscall         # print float
	
	la $a0, new_line   # get ready to print new line
	li $v0, 4          # prepare to print string
	syscall            # print space
	
	lw $t0, 44($s1)        # load next pointer
	beq $t0, $0, print_end # if next pointer is null then stop printing
	move $s1, $t0          # otherwise move the head pointer down the list
	j print_start          # and continue printing
	
print_end:
	lw $ra, 0($sp)   # reload ra from stack
	addi $sp, $sp, 4 # readjust stack
	jr $ra           # exit
	
strcomp:
	lb $t0, 0($a0) # load first char of a0 into t0
	lb $t1, 0($a1) # load first char of a1 into t1
	
	beq $t0, $0, zero_case1
	beq $t1, $0, zero_case2
	j no_zero
	
zero_case1: # t0 is 0 and t1 is unknown
	beq $t1, $0, zero_case3 # if both are 0 go to case 3
	li $v0, -1              # else return negative number
	jr $ra                  # return

zero_case2: # t0 is not 0 and t1 is 0
	li $v0, 1 # return positive number
	jr $ra    # return
	
zero_case3: # both t0 and t1 are 0
	li $v0, 0 # return 0 for equality
	jr $ra
	
no_zero: # go here if no 0 character
	sub $v0, $t0, $t1        # set v0 = t0 - t1
	bne $v0, $0, strcomp_end # exit if v0 != 0
	
	addi $a0, 1 # increment pointer
	addi $a1, 1 # increment pointer
	j strcomp   # continue looping
	
strcomp_end:
	jr $ra # return
	
trim_last_char:
	move $a1, $a0 # temporarily save a0
	
begin_loop:
	lb $t0, 0($a1)        # load char
	beq $t0, $0, end_loop # if char is 0 quit loop
	addi $a1, 1           # increment pointer
	j begin_loop          # continue looping
	
end_loop:
	addi $a1, -1  # decrement pointer
	sb $0, 0($a1) # delete character
	
	jr $ra # return
	
.data
name_prompt:
	.asciiz "Type player name with no spaces (or DONE to finish):"
points_prompt:
	.asciiz "Input points:"
assists_prompt:
	.asciiz "Input assists:"
minutes_prompt:
	.asciiz "Input minutes:"
done:
	.asciiz "DONE\n"
space:
	.asciiz " "
new_line:
	.asciiz "\n"