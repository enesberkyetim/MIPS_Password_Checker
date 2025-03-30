	.data
enter_password:		.asciiz "Please enter a password: "
output:			.asciiz "Output: "
please_consider:	.asciiz "Consider using : "
not_strong:		.asciiz "Your password is not strong enough. "
strong:			.asciiz "Your password is strong. "

	.text
main :
	li $v0, 4 # Calling print_string to direct user to enter password
	la $a0, enter_password # Loading the address of the string
	syscall
	
	li $v0, 9 # Allocating memory from heap to store the user input string
	li $a0, 50
	syscall
	
	add $a0, $v0, $zero # v0 is copied to a0 which contains the address of user input string
	addi $a1, $zero, 50 # a1 is 50 which is the limit of the string
	li $v0, 8
	syscall # Reading user input string (password)
	
	add $t0, $a0, $zero
	
	li $v0, 9 # Allocating memory from heap to store the copy of the user input string
	li $a0, 50
	syscall
	
	add $a1, $v0, $zero # a1 will have the user input string copy that we will manipulate
	add $a0, $t0, $zero # a0 will have the user input string that we check
	
	jal copy_input
	
	jal number_counter # Calling number_counter function
	
	jal uppercase_check
	
	jal lowercase_check
	
	jal digit_check
	
	jal star_check
	
	jal plus_check
	
	jal same_check
	
	
	beq $s0, 1, print_error
	
	li $v0, 4
	la $a0, output
	syscall
	
	li $v0, 4
	la $a0, strong
	syscall
	
	j main
print_error:
	
	# Notify user by printing strings then exit
	li $v0, 4
	la $a0, output
	syscall
	
	li $v0, 4
	la $a0, not_strong
	syscall
	
	li $v0, 4
	la $a0, please_consider
	syscall
	
	li $v0, 4
	add $a0, $a1, $zero
	syscall
	
	j main
	
copy_input:
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	copy_loop:
		lb $t0, ($a0)
		beq $t0, 10, end_copy
		sb $t0, ($a1)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j copy_loop
	end_copy:
		sb $t0, ($a1)
		lw $a1, ($sp)
		addi $sp, $sp, 4
		lw $a0, ($sp)
		addi $sp, $sp, 4
		jr $ra
	
number_counter:
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	li $t1, 0 # Will be the counter in number_counter
	count_letters:	
		lb $t0, 0($a0)
		beq $t0, 10, end_count # Check if the current character is '\n' (break)
		addi $t1, $t1, 1 # Increment counter +1
		addi $a0, $a0, 1 # Increment a0 so that we can read the next character's address
		j count_letters
	end_count :
		add $v0, $t1, $zero # Copying t1 to v0 for returning the total count
		slti $t0, $v0, 7 # Checking whether the number count is below 7 or not
		beq $t0, 1, go_correct_number # If below 7 jump to count_error and exit
		resume_end_count:
			lw $a0, 0($sp) # Loading back the a0 from stack
			addi $sp, $sp, 4 
			jr $ra
	go_correct_number:
		addi $t4, $ra, 0
		jal correct_number
		addi $ra, $t4, 0
		j resume_end_count
		
correct_number:
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	li $s0, 1
	addi $t0, $v0, -7 # How many more characters needed ?
	not $t0, $t0
	addi $t0, $t0, 1 # Converted the negative difference result to positive
	add $t1, $a1, $v0 # t1 holds the character after the last character
	addi $t2, $t1, -1
	li $t3, 97
	correct_number_loop:
		lb $s1, ($t2)
		beq $s1, $t3, increment_char
		beq $t0, 0, finish_correct_number
		sb $t3, ($t1)
		addi $t3, $t3, 1
		addi $t1, $t1, 1
		addi $t2, $t2, 1
		addi $t0, $t0, -1
		j correct_number_loop
	increment_char:
		addi $t3, $t3, 1
		j correct_number_loop
	finish_correct_number:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $t3, 10
		sb $t3, ($t1)
		jr $ra
		
	
	
		
uppercase_check:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	count_upper:
		lb $t0, 0($a0) # Load the next character
		li $t3, 64
		slt $t1, $t3, $t0 # Is it over or equal 65 == 'A'
		slti $t2, $t0, 91 # Is it below or equal 90 == 'Z'
		and $t4, $t1, $t2 # Both should be satisfied
		beq $t4, 1, end_upper # We found an uppercase letter so our job is done
		beq $t0, 10, false_upper # If we come to '\n' that means there is no uppercase so, false
		addi $a0, $a0, 1 # Will get the next character by incrementing a0 by 1
		j count_upper
	end_upper:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $v0, 1 # Return true in v0
		jr $ra 
	false_upper:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $s0, 1
		add $t3, $ra, $zero
		jal correct_uppercase
		add $ra, $t3, $zero
		jr $ra
		
correct_uppercase:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	li $t0, 0
	add $t0, $a1, $t0
	find_end:
		lb $t1, ($t0)
		beq $t1, 10, resume_end
		addi $t0, $t0, 1
		j find_end
	resume_end:
		li $t1, 90
		sb $t1, ($t0)
		addi $t0, $t0, 1
		li $t1, 10
		sb $t1, ($t0)
		lw $a0, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
lowercase_check:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	count_lower:
		lb $t0, 0($a0) # Load the next character
		li $t3, 64
		slt $t1, $t3, $t0 # Is it over or equal 65 == 'A'
		slti $t2, $t0, 91 # Is it below or equal 90 == 'Z'
		and $t4, $t1, $t2 # Both should be satisfied
		beq $t4, 1, end_lower # We found an lowercase letter so our job is done
		beq $t0, 10, false_lower # If we come to '\n' that means there is no lowercase so, false
		addi $a0, $a0, 1 # Will get the next character by incrementing a0 by 1
		j count_lower
	end_lower:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $v0, 1 # Return true in v0
		jr $ra 
	false_lower:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $s0, 1
		add $t3, $ra, $zero
		jal correct_lowercase
		add $ra, $t3, $zero
		jr $ra
		
correct_lowercase:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	li $t0, 0
	add $t0, $a1, $t0
	find_end2:
		lb $t1, ($t0)
		beq $t1, 10, resume_end2
		addi $t0, $t0, 1
		j find_end2
	resume_end2:
		li $t1, 122
		sb $t1, ($t0)
		addi $t0, $t0, 1
		li $t1, 10
		sb $t1, ($t0)
		jr $ra
		
digit_check:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	count_digit:
		lb $t0, 0($a0)
		li $t1, 47
		slt $t3, $t1, $t0
		slti $t4, $t0, 58
		and $t5, $t3, $t4
		beq $t5, 1, end_digit
		beq $t0, 10, false_digit
		addi $a0, $a0, 1
		j count_digit
	end_digit:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $v0, 1 # Return true in v0
		jr $ra 
	false_digit:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $s0, 1
		add $t3, $ra, $zero
		jal correct_digit
		add $ra, $t3, $zero
		jr $ra
		
correct_digit:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	li $t0, 0
	add $t0, $a1, $t0
	find_end3:
		lb $t1, ($t0)
		beq $t1, 10, resume_end3
		addi $t0, $t0, 1
		j find_end3
	resume_end3:
		li $t1, 57
		sb $t1, ($t0)
		addi $t0, $t0, 1
		li $t1, 10
		sb $t1, ($t0)
		jr $ra
		
star_check:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	li $t3, 0
	li $t4, 0
	count_star:
		lb $t0, 0($a0)
		li $t1, 42
		seq $t3, $t0, $t1
		beq $t3, 1, end_star
		beq $t0, 10, false_star
		addi $a0, $a0, 1
		j count_star
	end_star:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $v0, 1 # Return true in v0
		jr $ra 
	false_star:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $s0, 1
		add $t3, $ra, $zero
		jal correct_star
		add $ra, $t3, $zero
		jr $ra

correct_star:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	li $t0, 0
	add $t0, $a1, $t0
	find_end4:
		lb $t1, ($t0)
		beq $t1, 10, resume_end4
		addi $t0, $t0, 1
		j find_end4
	resume_end4:
		li $t1, 42
		sb $t1, ($t0)
		addi $t0, $t0, 1
		li $t1, 10
		sb $t1, ($t0)
		jr $ra
		
plus_check:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	li $t3, 0
	li $t4, 0
	count_plus:
		lb $t0, 0($a0)
		li $t1, 43
		seq $t3, $t0, $t1
		beq $t3, 1, end_plus
		beq $t0, 10, false_plus
		addi $a0, $a0, 1
		j count_plus
	end_plus:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $v0, 1 # Return true in v0
		jr $ra 
	false_plus:
		lw $a0, 0($sp) # Restore a0 which holds the address of the start of the input string
		addi $sp, $sp, 4
		li $s0, 1
		add $t3, $ra, $zero
		jal correct_plus
		add $ra, $t3, $zero
		jr $ra

correct_plus:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	li $t0, 0
	add $t0, $a1, $t0
	find_end5:
		lb $t1, ($t0)
		beq $t1, 10, resume_end5
		addi $t0, $t0, 1
		j find_end5
	resume_end5:
		li $t1, 43
		sb $t1, ($t0)
		addi $t0, $t0, 1
		li $t1, 10
		sb $t1, ($t0)
		jr $ra
		
same_check:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	addi $sp, $sp, -4 # Store the a1 in stack as we will modify it in this procedure
	sw $a1, 0($sp)
	add $a1, $a0, $zero
	addi $a3, $a0, 1
	same_loop:
		lb $t1, ($a1)
		lb $t2, ($a3)
		beq $t1, $t2, false_same
		beq $t2, 10, end_same
		addi $a1, $a1, 1
		addi $a3, $a3, 1
		j same_loop
	false_same:
		lw $a1, ($sp)
		addi $sp, $sp, 4
		lw $a0, ($sp)
		addi $sp, $sp, 4
		li $s0, 1
		add $t3, $ra, $zero
		jal correct_same
		add $ra, $t3, $zero
		jr $ra
	end_same:
		li $v0, 1
		lw $a1, ($sp)
		addi $sp, $sp, 4
		lw $a0, ($sp)
		addi $sp, $sp, 4
		jr $ra
	
		
correct_same:		 
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	addi $sp, $sp, -4 # Store the a1 in stack as we will modify it in this procedure
	sw $a1, 0($sp)
	addi $t0, $a1, 0
	addi $t1, $a1, 1
	addi $t2, $a1, 2
	li $s2, 75	
	iter_string:
		lb $t4, ($t0)
		lb $t5, ($t1)
		lb $t6, ($t2)
		beq $t5, 10, end_correct_same
		seq $s3, $t4, $t5
		beq $s3, 1, change_char
		seq $s3, $t5, $t6
		beq $s3, 1, change_char
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		addi $t2, $t2, 1
		j iter_string
	change_char:
		sb $s2, ($t1)
		addi $s2, $s2, 1
		j iter_string
	end_correct_same:
		lw $a1, ($sp)
		addi $sp, $sp, 4
		lw $a0, ($sp)
		addi $sp, $sp, 4
		li $s0, 1
		jr $ra
		
	
		
	
	
	
	
