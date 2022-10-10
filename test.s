#Sydney Balboni
#CE2801 021
#10/02/2022
#
#test.s
#Tests the subroutines made in lab 3

.syntax unified
.cpu cortex-m4
.thumb
.section .text



.global main

#Define registers

main:

	bl LcdInit

	mov r0, #0x33


//end:
	//bal end

