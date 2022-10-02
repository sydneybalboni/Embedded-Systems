#Sydney Balboni
#CE2801 021
#10/02/2022
#
#led.s
#

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ GPIOB_BASE, 0x40020400
	.equ GPIO_MODER, 0x00
	.equ GPIO_BSRR, 0x18

.global led_init
.global num_to_led



#led_init
#Initializes the GPIO pins to be outputs
#Input:
#	None
#Output:
#	None?
#Dependancies:
#	None?
led_init:
	push {r1-r3}

	#Set all led pins to outputs
	#Set mask
	movw r3, #0x5400
	movt r3, #0x5515
	ldr r1, =GPIOB_BASE
	ldr r2, [r1, #GPIO_MODER]
	orr r2, r3
	str r2, [r1,#GPIO_MODER]

	pop {r1-r3}
	bx lr


#num_to_led
#Displays the 10 least-significant-bits
#of a number to the leds
#Input:
#	r0 - number to display
#Output:
#	??????
#Dependancies:
#	None
num_to_led:

	push {r1-r2}

	#load memory address into r1
	ldr r1, =GPIOB_BASE

	#clear leds
	mov r2, #0
	movt r2, #0xFFFF
	str r2, [r1, #GPIO_BSRR]

	#grab the 10 least-significant-bits of number
	movw r2, #0x03FF
	movt r2, #0x0000
	and r0, r2

	#store number into leds
	strh r0, [r1, #GPIO_BSRR]

	pop {r1-r2}
	bx lr
