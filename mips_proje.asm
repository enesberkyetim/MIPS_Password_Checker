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
	beq $t0, 1, count_error # If below 7 jump to count_error and exit
	
	
	li $v0, 4
	la $a0, output
	syscall
	
	li $v0, 4
	la $a0, strong
	syscall
	
	li $v0, 10 # All things are done in main function, so... quit
	syscall
count_error:
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
		beq $t0, $zero, end_count
		addi $t1, $t1, 1 # Increment counter +1
		addi $a0, $a0, 1 # Increment a0 so that we can read the next character's address
		j count_letters
	end_count :
		lw $a0, 0($sp) # Loading back the a0 from stack
		addi $sp, $sp, 4
		add $v0, $t1, $zero # Copying t1 to v0 for returning the total count
		jr $ra
	
	
	