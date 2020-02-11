
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "../data/1dgrid.txt"
dictionary_file_name:   .asciiz  "../data/dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 2				# Align the next field, for integers
dictionary_idx:		.space 4000	# Maximum number of starting indices * 4
					# (size of int)
					
					
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!



	j GET_DICT_IDX			# jump to create dict_idx

# helper function contain()
# $s0, $s1, s2, $s3, $s4, s7

contain:
	lb $s5, 0($a0)			# get *string
	lb $s6, 0($a1)			# get *word
	beq $s5, $s6, CONT_LOOP 	# branch if *string == *word
	li $t0, 10			# $t0 = '\n'
	beq $s6, $t0, WORD_END 		# branch if *word == '\n'
	li $v0, 0			# store return value
	#jr $ra				# returns
	j contain_returns
	
WORD_END:
	li $v0, 1			# store return value
	#jr $ra				# returns
	j contain_returns
	
CONT_LOOP:
	addi $a0, $a0, 1		# string++
	addi $a1, $a1, 1		# word++
	jal contain			# go back to contain	
	
# end of contain()


# helper function print_word(char *word)
# parameter: word is a pointer

# s0-4, s7

print_word:
	li $t0, 10			# $t0 = '\n'

PRINT_LOOP:
	lb $t2, 0($a0) 			# $t2 = *word
	beq $t2, $t0, PRINT_END		# branch if *word == '\n'
	beq $t2, $0, PRINT_END		# branch if *word == '\0'
	move $s5, $a0			# $s0 = word
	move $a0, $t2			# $a0 = *word
	li $v0, 11			# syscall for print char
	syscall				# print char
	move $a0, $s5			# $a0 = word
	addi $a0, $a0, 1		# word++
	j PRINT_LOOP
	
PRINT_END:
	#jr $ra				# go back to caller
	j print_word_returns
	
# end of print_word
	
	
	


# create an array for all start indices in dictionary

GET_DICT_IDX:		
	li $s0,	0			# idx = 0
	li $s1, 0			# dict_idx = 0
	li $s2, 0			# start_idx = 0
	la $s3, dictionary		# $s3 = &dictionary[0]

DICT_LOOP:
	add $t2, $s0, $s3		# $t2 = &dictionary[idx]
	lb $t0, 0($t2)			# c_input = dictionary[idx]
	beq $t0, $0,  END_DICT		# branch if (c_input == '\0')
	li $t1, 10			# $t1 = '\n'
	beq $t0, $t1, WORD_BOUND	# branch if (c_input == '\n')
	addi $s0, $s0, 1		# idx += 1
	j DICT_LOOP
	
WORD_BOUND:
	li $t3, 4			# $t3 = 4
	mul $t4, $t3, $s1		# $t4 = 4 * dict_idx
	sw $s2, dictionary_idx($t4)	# dictionary_idx[dict_idx] = start_idx
	addi $s1, $s1, 1		# dict_idx++
	addi $s2, $s0, 1		# start_idx = idx + 1
	addi $s0, $s0, 1		# idx++
	j DICT_LOOP
	
END_DICT:
	move $s7, $s1			# dict_num_words = dict_idx (always in $s7!)


	
#end of creating dict_idx


# implement strfind() and calling it

	li $s0, 0			# int idx = 0
	li $s1, 0			# int grid_idx = 0
	la $s2, ($0)			# char *word;
	li $s3, 0			# int contains = 0

LOOP_GRID:
	lb $s4, grid($s1)		# $s4 = grid[grid_idx]
	beq $s4, $0, GRID_END		# branch if (grid[grid_idx] == '\0')
	move $t1, $s7			# $t1 = dict_num_words

ALL_WORDS:
# seems like this condition doesn't work
# put break point at contain	
	bge $s0, $t1, DIC_END		# for idx: idx < dict_num_words
	li $t0, 4			# int_size = 4
	mul $t3, $s0, $t0		# $t3 = idx * int_size
	lw $t2, dictionary_idx($t3)	# $t2 = dictionary_idx[idx]	
	la $s2, dictionary($t2)		# word = dictionary + dictionary_idx[idx]
	move $a1, $s2			# $a1 = word
	la $a0, grid($s1)		# $t4 = grid + grid_idx
	jal contain			# contain()

contain_returns:
	
	move $t4, $v0			# $t4 = contain(grid + grid_idx, word)
	beqz $t4, NOT_CONTAIN		# if (contain)
	li $s3, 1			# contains = 1
	li $v0, 1			# syscall for print integer
	move $a0, $s1			# $a0 = grid_idx
	syscall				# print integer
	li $v0, 11			# syscall for print char
	li $a0, 32			# $a0 = '\s'
	syscall				# print space
	move $a0, $s2			# $a0 = word
	jal print_word 			# print_word(word)
	
print_word_returns:	
	
	addi $s0, $s0, 1 		# idx++
	li $v0, 11			# syscall for print char
	li $a0, 10			# $a0 = '\n'
	syscall				# print new line
	j ALL_WORDS			

NOT_CONTAIN:
	addi $s0, $s0, 1 		# idx++
	j ALL_WORDS	
	
DIC_END:
	addi $s1, $s1, 1		# grid_idx++
	li $s0, 0			# reset int idx = 0
	j LOOP_GRID
	
GRID_END:
	beq $s3, $0, NO_MATCH		# if (!contains)
	j main_end
	
NO_MATCH:
	li $v0 , 1			# syscall for print int
	li $a0, -1			# $a0 = -1
	syscall				# print int
	li $v0, 11			# syscall for print char
	li $a0, 10			# $t0 = '\n'
	syscall				# print char
	j main_end
	
	

 
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
