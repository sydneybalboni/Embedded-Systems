#Sydney Balboni
#CE2801 021
#10/02/2022
#
#numConversion.s
#Functionality for converting decimal numbers into ascii codes

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ DISPLAY_ERROR, 0x4572722E
	.equ NUM_TO_ASCII_CONVERT, 0x30
	.equ LARGEST_VALID_NUMBER, 9999

	.equ ADD_THREE_FIRST_NIBBLE, 0x30000
	.equ ADD_THREE_SECOND_NIBBLE, 0x300000
	.equ ADD_THREE_THIRD_NIBBLE, 0x3000000
	.equ ADD_THREE_FOURTH_NIBBLE, 0x30000000

	.equ NIBBLE, 4
	.equ FIRST_NIBBLE, 16
	.equ LAST_SHIFT, 15
	.equ SECOND_NIBBLE, 20
	.equ THIRD_NIBBLE, 24
	.equ FOURTH_NIBBLE, 28

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

	push {r1-r6}

	#check for invalid number
	mov r2, #LARGEST_VALID_NUMBER
	cmp r0, r2
	ble DoubleDabble
	ldr r0, =DISPLAY_ERROR
	bal Exit

DoubleDabble:

	#Initialize shift count
	mov r6, #0
	#Move temporary number into r1
	mov r1, r0
1:
	#Check if double dabble is on last shift
	cmp r6, #LAST_SHIFT
	beq Next

	#Shift the number left
	lsl r1, #1

	#Increment the shift count
	add r6, #1

	#Check first nibble
	ubfx r0, r1, #FIRST_NIBBLE, #NIBBLE
	cmp r0, #5
	blt SecondNibble
	ldr r2, =ADD_THREE_FIRST_NIBBLE
	add r1, r2

SecondNibble:

	#Check second nibble
	ubfx r0, r1, #20, #NIBBLE
	cmp r0, #5
	blt ThirdNibble
	ldr r2, =ADD_THREE_SECOND_NIBBLE
	add r1, r2

ThirdNibble:

	#Check third nibble
	ubfx r0, r1, #24, #NIBBLE
	cmp r0, #5
	blt FourthNibble
	ldr r2, =ADD_THREE_THIRD_NIBBLE
	add r1, r2

FourthNibble:

	#Check fourth nibble
	ubfx r0, r1, #28, #NIBBLE
	cmp r0, #5
	blt Repeat
	ldr r2, =ADD_THREE_FOURTH_NIBBLE
	add r1, r2

Repeat:

	#Repeat
	bal 1b

Next:

	#Last shift with no add three
	lsl r1, #1

	#Seperate numbers into separate registers
	ubfx r0, r1, #16, #NIBBLE
	ubfx r3, r1, #20, #NIBBLE
	ubfx r4, r1, #24, #NIBBLE
	ubfx r5, r1, #28, #NIBBLE

	#Add ascii conversion
	ldrb r2, =NUM_TO_ASCII_CONVERT
	add r0, r2
	add r3, r2
	add r4, r2
	add r5, r2

	#Reposition numbers
	lsl r3, #8
	lsl r4, #16
	lsl r5, #24

	#Put numbers back together
	orr r0, r3
	orr r0, r4
	orr r0, r5

Exit:

	pop {r1-r6}
	bx lr
