# Lukasz Wojcicki
# used registers:
# a0 turtle x pos
# a1 turtle y pos
# a2 current pen color - 00RRGGBB
# a3 current direction - 0 - up, 1-left, 2-down, 3-right
# a4 pen on(0)/off(1)


.eqv BMP_FILE_SIZE 90122
.eqv BYTES_PER_ROW 1800
.eqv BIN_FILE_SIZE 200

	.data
#space for the 600x50px 24-bits bmp image
.align 4
res:	.space 2

bin:	.space BIN_FILE_SIZE

image:	.space BMP_FILE_SIZE

binname: .asciz "turtle_wersja5a.bin"

fname:	.asciz "source.bmp"
	.text
main:
	jal	read_bmp
	jal	read_bin
	li s0, 0 	#set direction function
	li s1, 0x4000 	#set position function 0100 0000 0000 0000b
	li s2, 0x8000 	#set pen function 1000 0000 0000 0000b
	li s3, 0xC000 	#move function 1100 0000 0000 0000b
	la t0, bin
	j load_word

load_word:		#reding form binary file (16 bits)
	li t3, 0x1001003F
	bge t0, t3, exit
	lbu t1, (t0)
	slli t1, t1, 8
	addi t0, t0, 1
	lbu t2, (t0)
	add t1, t1, t2
	li t3, 0xC000 	#1100 0000 0000 0000b - checking first two bits
	and t2, t3, t1
	beq t2, s0, set_dir
	beq t2, s1, set_pos
	beq t2, s2, set_pen
	beq t2, s3, move
set_dir:	
	li t3,0x0003 # only 2 last bits matters
	and  a3, t1, t3	# a3 - set direction 0 - up, 1-left, 2-down, 3-right
	addi t0, t0, 1
	jal	load_word

set_pos:
	addi t0, t0, 1	# reding second 16 bit - word
	lbu t1, (t0)
	slli t1, t1, 8
	addi t0, t0, 1
	lbu t2, (t0)
	add t1, t1, t2
	li t3, 0xFC00 # 1111 1100 0000 0000b - separte y value
	and t4, t3, t1
	srli a1, t4, 10 # a1 - y position
	li t3, 0x03FF
	and a0, t3, t1 # a0 - x position
	
	addi t0, t0, 1
	jal	load_word
move:	
	li t3, 0x03FF # 0000 0011 1111 1111b - separte move value
	and t4,t3,t1 # t4 - distance to move
	beqz a3, up
	li t3, 1
	beq a3, t3, left
	li t3,2
	beq a3, t3, down
	li t3,3
	beq a3, t3, right
	
end_move:
	addi t0, t0, 1
	jal	load_word
# moving up
up:
	# t4 - distance
	beqz t4, end_move
	addi a1,a1,1
	addi t4,t4,-1
	jal check_up
check_up: # y cant be higher than 50
	li t3, 49
	ble a1,t3, up2
	li a1,49
	j up2
up2:
	li t3,1
	beq t3,a4,up # if pen is up skip put_pixel
	jal put_pixel
	j up
#moving left
left:
	# t4 - distance
	beqz t4, end_move
	addi a0,a0,-1
	addi t4,t4,-1
	jal check_left
check_left: # x cant be lower than 0
	li t3, 0
	bge a0,t3, left2
	li a0,0
	j left2
left2:
	li t3,1
	beq t3,a4,left # if pen is up skip put_pixel
	jal put_pixel
	j left
#moving down
down:
	# t4 - distance
	beqz t4, end_move
	addi a1,a1,-1
	addi t4,t4,-1
	jal check_down
check_down: # y cant be lower than 0
	li t3, 0
	bge a1,t3, down2
	li a1,0
	j down2
down2:
	li t3,1
	beq t3,a4,down # if pen is up skip put_pixel
	jal put_pixel
	j down
#moving right
right:
	# t4 - distance
	beqz t4, end_move
	addi a0,a0,1
	addi t4,t4,-1
	jal check_right
check_right: # x cant be higher than 600
	li t3, 599
	ble a1,t3, right2
	li a0,599
	j right2
right2:
	li t3,1
	beq t3,a4,right # if pen is up skip put_pixel
	jal put_pixel
	j right

set_pen:
	li t3, 0x1000 # 0001 0000 0000 0000b - separete bit meaning pen status
	and t2, t3, t1
	srli a4, t2, 12 # a4 - pen status, 0- down, 1-up
	# set red color value
	li t3, 0x000F	#
	and a2, t1, t3
	slli a2, a2, 8
	# set green color value
	li t3, 0x00F0
	and t2, t1,t3
	srli t2,t2,4
	add a2,a2,t2
	slli a2,a2,8
	#set blue color value
	li t3, 0x0F00
	and t2, t1,t3
	srli t2,t2,8
	add a2,a2,t2
	slli a2,a2,4
	
	addi t0, t0, 1
	jal load_word
exit:
	jal save_bmp
	li 	a7,10		#Terminate the program
	ecall
# ============================================================================
	
read_bin:
#description: 
#	reads the contents of a bin file into memory
#arguments:
#	none
#return value: none
	addi sp, sp, -4		#push $s1
	sw s1, 0(sp)
#open file
	li a7, 1024
        la a0, binname		#file name 
        li a1, 0		#flags: 0-read file
        ecall
	mv s1, a0      # save the file descriptor
	
#check for errors - if the file was opened
#...

#read file
	li a7, 63
	mv a0, s1
	la a1, bin
	li a2, BIN_FILE_SIZE
	ecall

#close file
	li a7, 57
	mv a0, s1
        ecall
	
	lw s1, 0(sp)		#restore (pop) s1
	addi sp, sp, 4
	jr ra


# ============================================================================
read_bmp:
#description: 
#	reads the contents of a bmp file into memory
#arguments:
#	none
#return value: none
	addi sp, sp, -4		#push $s1
	sw s1, 0(sp)
#open file
	li a7, 1024
        la a0, fname		#file name 
        li a1, 0		#flags: 0-read file
        ecall
	mv s1, a0      # save the file descriptor
	
#check for errors - if the file was opened
#...

#read file
	li a7, 63
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

#close file
	li a7, 57
	mv a0, s1
        ecall
	
	lw s1, 0(sp)		#restore (pop) s1
	addi sp, sp, 4
	jr ra

# ============================================================================
save_bmp:
#description: 
#	saves bmp file stored in memory to a file
#arguments:
#	none
#return value: none
	addi sp, sp, -4		#push s1
	sw s1, (sp)
#open file
	li a7, 1024
        la a0, fname		#file name 
        li a1, 1		#flags: 1-write file
        ecall
	mv s1, a0      # save the file descriptor
	
#check for errors - if the file was opened
#...

#save file
	li a7, 64
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

#close file
	li a7, 57
	mv a0, s1
        ecall
	
	lw s1, (sp)		#restore (pop) $s1
	addi sp, sp, 4
	jr ra


# ============================================================================
put_pixel:
#description: 
#	sets the color of specified pixel
#arguments:
#	a0 - x coordinate
#	a1 - y coordinate - (0,0) - bottom left corner
#	a2 - 0RGB - pixel color
#return value: none
	mv s11, a0
	mv s10, a1
	mv s9, a2
	mv s8, t4

	la t1, image	#adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2	#adress of pixel array in $t2
	
	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 #t1= y*BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0	#$t3= 3*x
	add t1, t1, t3	#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1	#pixel address 
	
	#set new color
	sb a2,(t2)		#store B
	srli a2,a2,8
	sb a2,1(t2)		#store G
	srli a2,a2,8
	sb a2,2(t2)		#store R
	
	mv a0, s11
	mv a1, s10
	mv a2, s9
	mv t4,s8

	jr ra
# ============================================================================

