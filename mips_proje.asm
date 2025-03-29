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
		li $v0, 0 # Return 
		li $v1, 1 # Return the number that indicates which rule i violated
		li $s0, 1 
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
		li $v0, 0 # Return false
		li $v1, 2 # Return the number that indicates which rule i violated
		li $s0, 1
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
		li $v0, 0 # Return false
		li $v1, 3 # Return the number that indicates which rule i violated
		li $s0, 1
		jr $ra
		
star_check:
	addi $sp, $sp, -4 # Store the a0 in stack as we will modify it in this procedure
	sw $a0, 0($sp)
	li $t3, 0
	li $t4, 0
	count_star:
		lb $t0, 0($a0)
		li $t1, 42
		li $t2, 43
		add $t5, $t3, $zero
		add $t6, $t4, $zero
		seq $t3, $t0, $t1
		seq $t4, $t0, $t2
		or $t3, $t3, $t5
		or $t4, $t4, $t6
		and $s0, $t3, $t4
		beq $s0, 1, end_star
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
		li $v0, 0 # Return false
		li $v1, 4 # Return the number that indicates which rule i violated
		li $s0, 1
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
		li $v0, 0
		lw $a1, ($sp)
		addi $sp, $sp, 4
		lw $a0, ($sp)
		addi $sp, $sp, 4
		jr $ra
	end_same:
		li $v0, 1
		lw $a1, ($sp)
		addi $sp, $sp, 4
		lw $a0, ($sp)
		addi $sp, $sp, 4
		jr $ra
	
		
		 
		
		
	
		
	
	
	
	
