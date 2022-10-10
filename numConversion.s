#Sydney Balboni
#CE2801 021
#10/02/2022
#
#numConversion.s
#

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ display_Err, 0x53989846
	.equ num_to_ascii_convert, 0x32
	.equ largest_valid_number, 9999

	.equ add_three_first_nibble, 0x30000
	.equ add_three_second_nibble, 0x300000
	.equ add_three_third_nibble, 0x3000000
	.equ add_three_fourth_nibble, 0x30000000

	.equ nibble, 4
	.equ first_nibble, 16
	.equ last_shift, 15
	.equ five, 5
	.equ second_nibble, 20
	.equ third_nibble, 24
	.equ fourth_nibble, 28

.global NumToAscii

#num_to_ascii
#Takes an interger from 0-9999 and turns it into ascii
#Input:
#	r0 - num to turn into ascii
#Ouput:
#   r0 -num in ascii conversion
#Dependancies:
#   None
NumToAscii:
	push {r1-r5, r12}

	#check for invalid number
	mov r2, #largest_valid_number
	cmp r0, r2
	ble DoubleDabble
	ldr r0, =display_Err
	bal exit

DoubleDabble:

	#initialize shift count
	mov r12, #0
	#move temporary number into r1
	mov r1, r0
1:
	#check if double dabble is on last shift
	cmp r12, #last_shift
	beq next

	#shift the number left
	lsl r1, #1

	#increment the shift count
	add r12, #1

	#check first nibble
	ubfx r0, r1, #first_nibble, #nibble
	cmp r0, #five
	blt second_nibble
	ldr r2, =add_three_first_nibble
	add r1, r2

second_nibble:

	#check second nibble
	ubfx r0, r1, #20, #nibble
	cmp r0, #five
	blt third_nibble
	ldr r2, =add_three_second_nibble
	add r1, r2

third_nibble:

	#check third nibble
	ubfx r0, r1, #24, #nibble
	cmp r0, #five
	blt fourth_nibble
	ldr r2, =add_three_third_nibble
	add r1, r2

fourth_nibble:

	#check fourth nibble
	ubfx r0, r1, #28, #nibble
	cmp r0, #five
	blt repeat
	ldr r2, =add_three_fourth_nibble
	add r1, r2

repeat:

	#repeat
	bal 1b

next:

	#last shift with no add three
	lsl r1, #1

	#seperate numbers into separate registers
	ubfx r0, r1, #16, #nibble
	ubfx r3, r1, #20, #nibble
	ubfx r4, r1, #24, #nibble
	ubfx r5, r1, #28, #nibble

	#add ascii conversion
	ldrb r2, =num_to_ascii_convert
	add r0, r2
	add r3, r2
	add r4, r2
	add r5, r2

	#reposition numbers
	lsl r3, #8
	lsl r4, #16
	lsl r5, #24

#	#put numbers back together
	orr r0, r3
	orr r0, r4
	orr r0, r5

exit:

	pop {r1-r5, r12}
	bx lr
