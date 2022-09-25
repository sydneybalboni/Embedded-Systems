/**
#**********************************#
* Sydney Balboni
* CE2801-021
* 9-19-2022
*
* KnightRiderLights.S
* Recreates knight rider lights on
* the Embedded Systems board
#**********************************#
*/

.syntax unified
.cpu cortex-m4
.thumb
.section .text

#***********Psuedocode*************#
#0. Initialize Lights as outputs

#1. Setup registers for program

#2. Scan LEDs left

#3. Check if conditional functionality is needed

#4. Scan LEDs right

#5. Check if conditional functionality is needed

#6. Repeat steps 2 - 5

#**********************************#



#Lights are PB5-PB10, PB12-PB15

	.equ RCC_BASE, 0x40023800
	.equ RCC_AHB1ENR, 0x30
	.equ GPIOBEN, (1<<1)


	.equ GPIOB_BASE, 0x40020400
	.equ GPIO_MODER, 0x00
	.equ GPIO_BSRR, 0x18


.global main

main:

#r1 - Address
#r2 - LED output
#r3 - Shift count

#0. Initialize Lights as outputs
	#Turn on clock

	#(1)Address
	ldr r1, =RCC_BASE
	#(2)Read
	ldr r2, [r1,#RCC_AHB1ENR]
	#(3)Modify
	orr r2, #GPIOBEN
	#(4)Write
	str r2, [r1,#RCC_AHB1ENR]

	#Set all led pins to outputs
	#Clear control
	movw r3, #0xFC00
	movt r3, #0xFF3F
	#Set mask
	movw r4, #0x5400
	movt r4, #0x5515
	ldr r1, =GPIOB_BASE
	ldr r2, [r1, #GPIO_MODER]
	bic r2, r2, r3
	orr r2, r4
	str r2, [r1,#GPIO_MODER]


start:

#1. Setup registers for program

	# Read and reset BSRR register
	ldrh r2, [r1,#GPIO_BSRR]
	orr r2, #0

	# Initialize shift count to 0
	mov r3, #0

shift_left:

#2. Scan LEDs left

	# Move first LED output going left into r2
	movw r2, #0x0020
	movt r2, #0x0010

	# Store LED output into BSRR
1:	str r2, [r1,#GPIO_BSRR]
	bl delay

#3. Check if conditional functionality is needed

	# If the last LED is on ...
	cmp r3, #10
	# ... then switch directions
	beq shift_right

	# Shift output value left
	lsl r2, #1
	# Increment the shift count
	add r3, #1

	# If PB11 is next...
	cmp r3, #6
	# Else branch back to storing the output value
	bne 1b
	# ... Then maneuver around PB11
	movw r2, #0x1000
	movt r2, #0x0400
	str r2, [r1,#GPIO_BSRR]
	bl delay
	movw r2, #0x2000
	movt r2, #0x1000
	# Increment the shift count twice for each shift
	add r3, #2
	# Branch back to storing the output value
	bal 1b

shift_right:

#4. Scan LEDs right

	# Move first LED output going right into r2
	movw r2, #0x4000
	movt r2, #0x8000
	# Decrement shift count
	sub r3, #1

	# Store LED output into BSRR
1:	str r2, [r1,#GPIO_BSRR]

#5. Check if conditional functionality is needed

	# If the first LED is on ...
	cmp r3, #0
	# ... then switch directions
	beq shift_left

	# Shift output value right
	lsr r2, #1
	bl delay
	# Decrement shift count
	sub r3, #1

	# If PB11 is next ...
	cmp r3, #6
	# Else branch back to storing the output value
	bne 1b
	# ... Then maneuver around PB11
	movw r2, #0x0400
	movt r2, #0x1000
	str r2, [r1,#GPIO_BSRR]
	bl delay
	movw r2, #0x0200
	movt r2, #0x0400
	# Decrement shift count twice for each shift
	sub r3, #2
	# Branch back to storing the output value
	bal 1b

#6. Repeat steps 2 - 5

#***********Subroutines************#

/*
* Delays the program to make the speed
* of the LEDs visible
*/
delay:
	# Move a high number into r0
	movw r0, #0x0000
	movt r0, #0x0008
1:
	# Repeatedly decrement the number
	subs r0,r0,#1
	bne 1b
	bx lr

#**********************************#









































