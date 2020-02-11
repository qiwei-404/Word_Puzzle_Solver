
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
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

grid_file_name:         .asciiz  "../data/2dgrid.txt"
dictionary_file_name:   .asciiz  "../data/dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!

.align 2				# Align the next field, for integers
dictionary_idx:		.space 4000	# Maximum number of starting indices * 4
					# (size of int)
.align 2				# align the next field for int
row_col_nums: 		.space 8	# store [row, col]

col_word: 		.space 33	# col_word

dg_word: 		.space 33 	# dg_word

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

contain_hor:
	lb $s5, 0($a0)			# get *string
	lb $s6, 0($a1)			# get *word
	beq $s5, $s6, CONT_LOOP_HOR 	# branch if *string == *word
	li $t0, 10			# $t0 = '\n'
	beq $s6, $t0, WORD_END_HOR 		# branch if *word == '\n'
	li $v0, 0			# store return value
	j contain_returns_hor		# returns
	
	
WORD_END_HOR:
	li $v0, 1			# store return value
	j contain_returns_hor		# returns
	
CONT_LOOP_HOR:
	addi $a0, $a0, 1		# string++
	addi $a1, $a1, 1		# word++
	jal contain_hor			# go back to contain	
	
contain_ver:
	lb $s5, 0($a0)			# get *string
	lb $s6, 0($a1)			# get *word
	beq $s5, $s6, CONT_LOOP_VER 	# branch if *string == *word
	li $t0, 10			# $t0 = '\n'
	beq $s6, $t0, WORD_END_VER 	# branch if *word == '\n'
	li $v0, 0			# store return value
	j contain_returns_ver		# returns
	
	
WORD_END_VER:
	li $v0, 1			# store return value
	j contain_returns_ver		# returns
	
CONT_LOOP_VER:
	addi $a0, $a0, 1		# string++
	addi $a1, $a1, 1		# word++
	jal contain_ver			# go back to contain
	
	
contain_dg:
	lb $s5, 0($a0)			# get *string
	lb $t6, 0($a1)			# get *word
	beq $s5, $t6, CONT_LOOP_DG 	# branch if *string == *word
	li $t7, 10			# $t0 = '\n'
	beq $t6, $t7, WORD_END_DG 	# branch if *word == '\n'
	li $v0, 0			# store return value
	j contain_returns_dg		# returns
		
WORD_END_DG:
	li $v0, 1			# store return value
	j contain_returns_dg		# returns
	
CONT_LOOP_DG:
	addi $a0, $a0, 1		# string++
	addi $a1, $a1, 1		# word++
	jal contain_dg			# go back to contain
	
# end of contain()


# helper function print_word(char *word)
# parameter: word is a pointer

# s0-4, s7

print_word_hor:
	li $t0, 10			# $t0 = '\n'

PRINT_LOOP_HOR:
	lb $t4, 0($a0) 			# $t4 = *word
	beq $t4, $t0, PRINT_END_HOR	# branch if *word == '\n'
	beq $t4, $0, PRINT_END_HOR	# branch if *word == '\0'
	move $s5, $a0			# $s0 = word
	move $a0, $t4			# $a0 = *word
	li $v0, 11			# syscall for print char
	syscall				# print char
	move $a0, $s5			# $a0 = word
	addi $a0, $a0, 1		# word++
	j PRINT_LOOP_HOR
	
PRINT_END_HOR:
	j print_returns_hor		# go back to caller
	
	
print_word_ver:
	li $t0, 10			# $t0 = '\n'

PRINT_LOOP_VER:
	lb $t4, 0($a0) 			# $t4 = *word
	beq $t4, $t0, PRINT_END_VER	# branch if *word == '\n'
	beq $t4, $0, PRINT_END_VER	# branch if *word == '\0'
	move $s5, $a0			# $s0 = word
	move $a0, $t4			# $a0 = *word
	li $v0, 11			# syscall for print char
	syscall				# print char
	move $a0, $s5			# $a0 = word
	addi $a0, $a0, 1		# word++
	j PRINT_LOOP_VER
	
PRINT_END_VER:
	j print_returns_ver		# go back to caller
	
print_word_dg:
	li $t7, 10			# $t7 = '\n'

PRINT_LOOP_DG:
	lb $t8, 0($a0) 			# $t8 = *word
	beq $t8, $t7, PRINT_END_DG	# branch if *word == '\n'
	beq $t8, $0, PRINT_END_DG	# branch if *word == '\0'
	move $t9, $a0			# $t9 = word
	move $a0, $t8			# $a0 = *word
	li $v0, 11			# syscall for print char
	syscall				# print char
	move $a0, $t9			# $a0 = word
	addi $a0, $a0, 1		# word++
	j PRINT_LOOP_DG
	
PRINT_END_DG:
	j print_returns_dg		# go back to caller
	
	
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

# store rows and cols

STORE_ROW_COL:
	li $s0, 0			# row_num = 0
	li $s1, 0			# col_num = 0
	li $s2, 0			# idx = 0
	
WHILE_GRID:
	lb $t0, grid($s2)		# $t0 = grid[idx]
	beq $t0, $0, GRID_END		# while (grid[idx] != '\0')
	li $t1, 10			# $t2 = '\n'
	beq $t0, $t1, ROW_END		# if (grid[idx] != '\n')
	addi $s1, $s1, 1		# col_num++
	addi $s2, $s2, 1		# idx++
	j WHILE_GRID

ROW_END:
	li $t2, 4			# row_col_idx = 1 (size 4)
	sw $s1, row_col_nums($t2)	# row_col_nums[1] = col_num
	addi $s2, $s2, 1		# idx++
	li $s1, 0			# col_num = 0
	addi $s0, $s0, 1		# row_num++
	j WHILE_GRID
	
GRID_END:
	sw $s0, row_col_nums($0)	# row_col_nums[0] = row_num
	
# end of store rows and cols	



# implement strfind()

	li $s2, 0			# contains = 0
	li $s3, 0			# x_coord = 0
	
LOOP_ROW_HOR:
	li $s4, 0			# y_coord = 0
	li $t0, 4			# int_offset = 4
	lb $t1, row_col_nums($0)	# $t1 = total_rows
	lb $t2, row_col_nums($t0)	# $t2 = total_cols
	bge $s3, $t1, HOR_END		# while (x_coord < total_rows)
	
LOOP_COL_HOR:
	bge $s4, $t2, NEXT_ROW_HOR	# while (y_coord < total_cols)
	li $t3, 0			# idx = 0
	
LOOP_DIC_HOR:
	bge $t3, $s7, NEXT_COL_HOR	# for (idx < dict_num_words)
	li $t0, 4			# int offset = 4
	mul $t4, $t0, $t3		# $t4 = idx * offset
	lw $t5, dictionary_idx($t4)	# $t5 = dictionary_idx[idx]
	la $t6, dictionary($t5)		# char *word = dictionary + dictionary_idx[idx]
	mul $t7, $s3, $t2		# $t7 = x_coord * total_cols
	add $t7, $t7, $s4		# grid_idx = y_coord + x_coord * total_cols
	la $t8, grid($t7)		# t8 = &grid[grid_idx]
	move $a0, $t8			# $a0 = &grid[grid_idx]
	move $a1, $t6			# $a1 = word
	jal contain_hor			# contain(&grid, word)
	
contain_returns_hor:
	move $t0, $v0			# $t0 = contain(&grid, word)
	beqz $t0, NEXT_WORD_HOR		# if (contain(&grid, word)
	li $s2, 1			# contains = 1
	li $v0, 1			# syscall for print int
	move $a0, $s3			# $a0 = x_coord
	syscall				# print x_coord
	li $v0, 11			# syscall for print char
	li $a0, 44			# $a0 = ','
	syscall				# print ','
	li $v0, 1			# syscall for print int
	sub $a0, $s4, $s3		# $a0 = y_coord excluding \n
	syscall				# print y_coord
	li $v0, 11			# syscall for print char
	li $a0, 32			# $a0 = '\s'
	syscall				# print '\s'
	li $v0, 11			# syscall for print char
	li $a0, 72			# $a0 = 'H'
	syscall				# print 'H'
	li $v0, 11			# syscall for print char
	li $a0, 32			# $a0 = '\s'
	syscall				# print '\s'
	move $a0, $t6			# $a0 = word
	jal print_word_hor		# print word

print_returns_hor:	
	li $v0, 11			# syscall for print char
	li $a0, 10			# $a0 = '\n'
	syscall				# print '\n'
	
NEXT_WORD_HOR:
	addi $t3, $t3, 1		# idx++
	j LOOP_DIC_HOR
	
NEXT_COL_HOR:
	addi $s4, $s4, 1		# y_coord++
	j LOOP_COL_HOR
	
NEXT_ROW_HOR:
	addi $s3, $s3, 1		# x_coord++
	j LOOP_ROW_HOR
	
HOR_END:
#$t1, t2, s2, s3, s4 are taken
	
	li $s4, 0			# y_coord = 0
	
LOOP_COL_VER:
	li $s3, 0			# x_coord = 0
	bge $s4, $t2, COL_END		# while (y_coord < total_cols)

LOOP_ROW_VER:
	bge $s3, $t1, NEXT_COL_VER	# while (x_coord < total_rows)
	addi $t4, $t2, 1		# $t4 = total_cols + 1 (including \n)
	mul $t0, $s3, $t4		# $t0 = x_coord * total_cols
	add $t0, $t0, $s4		# grid_idx = y_coord + x_coord * (total_cols + 1)
	lb $t3, grid($t0)		# $t3 = grid[grid_idx]
	sb $t3, col_word($s3)		# col_word[x_coord] = grid[grid_idx]
	addi $s3, $s3, 1		# x_coord++
	j LOOP_ROW_VER

NEXT_COL_VER:	
	li $s1, 0			# start_idx = 0
	
COL_WORD_VER:
	bge $s1, $t1, COL_WORD_END	# while (start_idx < total_rows)
	li $t3, 0			# idx = 0
	
LOOP_DIC_VER:	
	bge $t3, $s7, DIC_END_VER	# for (idx < dict_num_words)
	li $t4, 4			# int offset = 4
	mul $t4, $t4, $t3		# $t4 = idx * offset
	lw $t5, dictionary_idx($t4)	# $t5 = dictionary_idx[idx]
	la $t6, dictionary($t5)		# char *word = dictionary + dictionary_idx[idx]
	la $s0, col_word($s1)		# $s0 = &col_word[start_idx]
	move $a0, $s0			# $a0 = &col_word[start_idx]
	move $a1, $t6			# $a1 = word
	jal contain_ver
	
contain_returns_ver:	
	move $t4, $v0			# $t4 = contain(&col_word[start_idx], word)
	beqz $t4, NEXT_WORD_VER		# if (contain())
	li $s2, 1			# contains = 1
	li $v0, 1			# syscall for print int
	move $a0, $s1			# $a0 = start_idx
	syscall				# print start_idx
	li $v0, 11			# syscall for print char
	li $a0, 44			# $a0 = ','
	syscall				# print ','
	li $v0, 1			# syscall for print int
	move $a0, $s4			# $a0 = y_coord 
	syscall				# print y_coord
	li $v0, 11			# syscall for print char
	li $a0, 32			# $a0 = '\s'
	syscall				# print '\s'
	li $v0, 11			# syscall for print char
	li $a0, 86			# $a0 = 'V'
	syscall				# print 'V'
	li $v0, 11			# syscall for print char
	li $a0, 32			# $a0 = '\s'
	syscall				# print '\s'
	move $a0, $t6			# $a0 = word
	jal print_word_ver		# print word
	
print_returns_ver:
	li $v0, 11			# syscall for print char
	li $a0, 10			# $a0 = '\n'
	syscall				# print '\n'
		
NEXT_WORD_VER:
	addi $t3, $t3, 1		# idx++
	j LOOP_DIC_VER
	
DIC_END_VER:
	addi $s1, $s1, 1		# start_idx++
	j COL_WORD_VER
	
COL_WORD_END:
	addi $s4, $s4, 1		# y_coord++
	j LOOP_COL_VER
	
COL_END:
# s2, s3, s4, t1, t2 taken
	
	ble $t1, $t2, MIN_LEN_ROW	# if (total_rows > total_cols)
	move $s0, $t2			# dg_length = total_cols
	j strfind_dg
	
MIN_LEN_ROW:
	move $s0, $t1			# else: dg_length = total_rows 
	
strfind_dg:
	li $t3, 0			# row_start_idx = 0
	
LOOP_ROW_DG:
	li $t4, 0			# col_start_idx = 0	
	bge $t3, $t1, ROW_END_DG	# while row_start_idx < total_rows

LOOP_COL_DG:	
	bge $t4, $t2, COL_END_DG	# while col_start_idx < total_cols
	li $t0, 0			# int dg_idx = 0
	move $s3, $t3			# x_coord = row_start_idx
	move $s4, $t4			# y_coord = col_start_idx
	
SW_DG:
	bge $s3, $t1, WORD_CREATED	# while x_coord < total_rows
	bge $s4, $t2, WORD_CREATED	# while y_coord < total_cols
	addi $t5, $t2, 1		# $t5 = total_cols + 1 (including \n)
	mul $t6, $s3, $t5		# $t6 = x_coord * total_cols
	add $t6, $t6, $s4		# grid_idx = y_coord + x_coord * (total_cols + 1)
	lb $t7, grid($t6)		# $t7 = grid[grid_idx]
	sb $t7, dg_word($t0)		# dg_word[dg_idx] = grid[grid_idx]
	addi $t0, $t0, 1		# dg_idx++
	addi $s3, $s3, 1		# x_coord++
	addi $s4, $s4, 1		# y_coord++
	j SW_DG
	
WORD_CREATED:
	li $t5, 0			# idx = 0
	
LOOP_DIC_DG:
	bge $t5, $s7, DIC_END_DG	# for idx < dict_num_words
	li $t6, 4			# int_size = 4
	mul $t6, $t6, $t5		# $t6 = idx * size
	lw $t7, dictionary_idx($t6)	# $t7 = dictionary_idx[idx]
	la $t8, dictionary($t7)		# char *word = dictionary + dictionary_idx[idx]
	la $t9, dg_word			# $t9 = &dg_word[0]
	move $a0, $t9			# $a0 = &dg_word[0]
	move $a1, $t8			# $t8 = word
	jal contain_dg			# contain()

contain_returns_dg:	
	beqz $v0, NEXT_WORD_DG		# if (contain(&dg_word[0], word))
	li $s2, 1			# contains = 1
	li $v0, 1			# syscall for print int
	move $a0, $t3			# $a0 = row_start_idx
	syscall				# print row_start_idx
	li $v0, 11			# syscall for print char
	li $a0, 44			# $a0 = ','
	syscall				# print ','
	li $v0, 1			# syscall for print int
	move $a0, $t4			# $a0 = col_start_idx 
	syscall				# print col_start_idx
	li $v0, 11			# syscall for print char
	li $a0, 32			# $a0 = '\s'
	syscall				# print '\s'
	li $v0, 11			# syscall for print char
	li $a0, 68			# $a0 = 'D'
	syscall				# print 'D'
	li $v0, 11			# syscall for print char
	li $a0, 32			# $a0 = '\s'
	syscall				# print '\s'
	move $a0, $t8			# $a0 = word
	jal print_word_dg		# print word
	
print_returns_dg:
	li $v0, 11			# syscall for print char
	li $a0, 10			# $a0 = '\n'
	syscall				# print '\n'
	
NEXT_WORD_DG:
	addi $t5, $t5, 1		# idx++
	j LOOP_DIC_DG
	
DIC_END_DG:
	addi $t4, $t4, 1		# col_start_idx++
	j LOOP_COL_DG
	
COL_END_DG:
	addi $t3, $t3, 1		# row_start_idx++
	j LOOP_ROW_DG
	
ROW_END_DG:
	bnez $s2, main_end		# if (!contains)
	li $v0 , 1			# syscall for print int
	li $a0, -1			# $a0 = -1
	syscall				# print int
	li $v0, 11			# syscall for print char
	li $a0, 10			# $t0 = '\n'
	syscall				# print char
	

 
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
