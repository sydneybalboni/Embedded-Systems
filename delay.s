#Sydney Balboni
#CE2801 021
#10/02/2022
#
#delay.s
#Busy delay loop for ~N millisec

.syntax unified
.cpu cortex-m4
.thumb
.section .text

.global delay_ms
.global LcdDelay



#delay_ms
#Busy delay loop for ~N millisec
#Input:
#	r1 - Number of milliseconds (Arg >0)
#Output:
#   None
#Dependancies:
#   None
delay_ms:

	push {r1-r2}

	mov r2, #5333
	mul r1, r1, r2
1:
	subs r1,r1,#1
	bne 1b


	pop {r1-r2}
	bx lr



