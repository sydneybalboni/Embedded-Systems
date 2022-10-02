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
	.equ num_to_ascii, 0x20202020
	.equ add_three, 0x30000
	.equ nibble, 0x4
	.equ bits_29_to_32, 0x20
	.equ bits_25_to_28, 0x1c
	.equ bits_21_to_24, 0x20
	.equ bits_17_to_20, 0x1c



.global DelayMS



#DelayMS
#Busy delay loop for ~N millisec
#Input:
#	r0 -
#Ouput:
#   r0 -
#Dependancies:
#   None
num_to_ascii:

	push {r1-r3, r12}

	#check for invalid number
	mov r2, #0x270f
	cmp r0, r2
	ble double_dabble
	ldr r0, =display_Err
	bl exit

double_dabble: // double dabble
	ldr r2, =add_three
	#initialize shift count
	mov r12, #0
	#move temporary number into r1
	mov r1, r0

1:
	lsl r1, #1
	add r12, #1

	cmp r12, #13
	blt case2
	ldr
	ubfx r3, r1, =bits_29_to_32, =nibble
	cmp r3, #5
	blt 1b
	add r1, r2
case2:

	cmp r12, #9
	blt case3
case3:

	cmp r12, #5
	blt case4
case4:



exit:
	pop {r1-r3, r12}
	bx lr
