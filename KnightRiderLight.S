/**
******************************************************************************
* Sydney Balboni
* CE2801-021
* 9-19-2022
*
* KnightRiderLights.S
* Recreates knight rider lights on
* the Embedded Systems board's LEDs
******************************************************************************
*/

.syntax unified
.cpu cortex-m4
.thumb
.section .text

#*****************************************************************************

#0. Initialize Lights as outputs

#1. Turn on the first light

#2. Delay

#3. Shift binary value

#4. Turn on the next light

#5. Hit last light and reverse directions

#6. Go back to 1

#**********************************#

#Lights are PB5-PB10, PB12-PB15

	.equ RCC_BASE, 0x40023800
	.equ RCC_AHB1ENR, 0x30
	.equ GPIOBEN, (1<<1)


	.equ GPIOB_BASE, 0x40020400
	.equ GPIO_MODER, 0x00
	.equ GPIO_ODR, 0x14
	.equ GPIO_BSRR, 0x18

	.equ all_lights, 0xF7E0
	.equ first_light, 0x20

#**********************************#

.global main

main:

#R1 - Address
#R2 - LED output
#R3 - shift count

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

#1. Turn on the first light
	ldr r1, =GPIOB_BASE
	ldrh r2, [r1,#GPIO_BSRR]
	orr r2, #0
	mov r3, #0



shift_left:
	movw r2, #0x0020
	movt r2, #0x0010

1:	str r2, [r1,#GPIO_BSRR]
	bl delay
	cmp r3, #10
	beq shift_right
	lsl r2, #1
	add r3, #1
	cmp r3, #6
	bne 1b


	movw r2, #0x1000
	movt r2, #0x0400
	str r2, [r1,#GPIO_BSRR]
	bl delay
	movw r2, #0x2000
	movt r2, #0x1000
	add r3, #2
	bal 1b


shift_right:
	movw r2, #0x4000
	movt r2, #0x8000
	sub r3, #1

1:	str r2, [r1,#GPIO_BSRR]
	cmp r3, #0
	beq shift_left
	bl delay
	lsr r2, #1
	sub r3, #1
	cmp r3, #6
	bne 1b

	movw r2, #0x0400
	movt r2, #0x1000
	str r2, [r1,#GPIO_BSRR]
	bl delay
	movw r2, #0x0200
	movt r2, #0x0400
	sub r3, #2
	bal 1b

#4. Turn on the next light

#5. Hit last light and reverse directions

#6. Go back to 1



#************Subroutines************#

delay:
	movw r0, #0x0000
	movt r0, #0x0008
1:
	subs r0,r0,#1
	bne 1b
	bx lr

#***********************************#








































