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
	
	jal number_counter # Calling number_counter function
	
	slti $t0, $v0, 7 # Checking whether the number count is below 7 or not
	beq $t0, 1, print_error # If below 7 jump to count_error and exit
	
	jal uppercase_check
	
	beq $v0, 0, print_error
	
	jal lowercase_check
	
	beq $v0, 0, print_error
	
	li $v0, 4
	la $a0, output
	syscall
	
	li $v0, 4
	la $a0, strong
	syscall
	
	li $v0, 10 # All things are done in main function, so... quit
	syscall
print_error:
	# Notify user by printing strings then exit
	li $v0, 4
	la $a0, output
	syscall
	
	li $v0, 4
	la $a0, not_strong
	syscall
	
	li $v0, 10
	syscall
	
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
		lw $a0, 0($sp) # Loading back the a0 from stack
		addi $sp, $sp, 4
		add $v0, $t1, $zero # Copying t1 to v0 for returning the total count
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
		li $v0, 0 # Return false
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
		jr $ra
		
	
	
	
	
