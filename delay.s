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

.global DelayMS
.global LcdDelay



#delay_ms
#Busy delay loop for ~N millisec
#Input:
#	r2 - Number of milliseconds (Arg >0)
#Output:
#   None
#Dependancies:
#   None
DelayMS:
	push {r1-r2}

	mov r1, #5333
	mul r2, r2, r1
1:
	subs r2,r2,#1
	bne 1b


	pop {r1-r2}
	bx lr


	#LcdDelay
#Delays LCD instructions
#Input:
#	r2: number of microseconds
#Output:
#	None
#Dependancies:
#	None
LcdDelay:
# about r2 microseconds
	# stack
	push {r2,lr}

	lsl r2, r2, #3

1:
	subs r2, r2, #1
	bne 1b

	# return
	pop {r2, pc}
