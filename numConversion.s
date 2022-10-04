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

	.equ display_Err, 0x539898
	.equ num_to_ascii_convert, 0x20202020
	.equ add_three, 0x30000

.global num_to_ascii



#num_to_ascii
#Takes an interger from 0-9999 and turns it into ascii
#Input:
#	r0 - num
#Ouput:
#   r0 -num in ascii conversion
#Dependancies:
#   None
num_to_ascii:

	push {r1-r7, r12}

	#check for invalid number
	mov r2, #0x270f
	cmp r0, r2
	ble double_dabble
	ldr r0, =display_Err
	bl exit

double_dabble:

	ldr r2, =add_three
	#initialize shift count
	mov r12, #0
	#move temporary number into r1
	mov r1, r0
1:
	cmp r12, #14
	beq next
	#shift the number left
	lsl r1, #1
	#increment the shift count
	add r12, #1

	#start switch statement for which nibble to check
	cmp r12, #13
	blt case2
	#13-16 shifts
	ubfx r3, r1, #28, #4
	cmp r3, #5
	blt 1b
	add r1, r2
	bal 1b
case2:
	cmp r12, #9
	blt case3
	#9-12 shifts
	ubfx r3, r1, #24, #4
	cmp r3, #5
	blt 1b
	add r1, r2
	bal 1b
case3:
	cmp r12, #5
	blt case4
	#5-8 shifts
	ubfx r3, r1, #20, #4
	cmp r3, #5
	blt 1b
	add r1, r2
	bal 1b
case4:
	#1-4 shifts
	ubfx r3, r1, #16, #4
	cmp r3, #5
	blt 1b
	add r1, r2
	bal 1b

next:
	#seperate numbers into separate registers
	ubfx r0, r1, #16, #4
	ubfx r5, r1, #20, #4
	ubfx r6, r1, #24, #4
	ubfx r7, r1, #28, #4
	add r7, r7, #1
	add r6, r6, #1
	#reposition numbers
	lsl r5, #8
	lsl r6, #16
	lsl r7, #24
	#put numbers back together
	orr r0, r5
	orr r0, r6
	orr r0, r7
	#convert into ascii values
	orr r0, #num_to_ascii_convert

exit:
	pop {r1-r7, r12}
	bx lr
