# Sydney Balboni
# CE2801-021
# 9-19-2022
#
# KnightRiderLights.S
# Recreates knight rider lights on the Embedded Systems board's LEDs


.syntax unified
.cpu cortex-m4
.thumb
.section .text

#************Psuedocode************#

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

	.equ all_lights, 0xF7E0
	.equ first_light, 0x20

#**********************************#

.global main

main:

#R1 - Address
#R2 - Scratch register
#R3 - Mask register Clear
#R4 - Mask register Set
#R5 - Amount to turn on the first light
#R7 - Current LED

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
	mov r5, #first_light
	ldr r1, =GPIOB_BASE

	#loading half-word
	ldrh r2, [r1,#GPIO_ODR]

#2. Delay


#3. Shift binary value
shift_left:
	add r7, #1
	cmp r5, #0x800
	beq skip_eleven
	bic r2, r2
	orr r2, r2, r5
	strh r2, [r1,#GPIO_ODR]
	bl delay
	lsl r5, #1
	cmp r7, #11
	bne shift_left

shift_right:
	sub r7, #1
	cmp r5, #0x800
	beq skip_eleven
	bic r2, r2
	orr r2, r2, r5
	strh r2, [r1,#GPIO_ODR]
	bl delay
1:	lsr r5, #1
	cmp r7, #0
	bne shift_right
	bal shift_left

#4. Turn on the next light

	bl delay

#5. Hit last light and reverse directions

#6. Go back to 1



#************Subroutines************#

delay:
	movw r3, #0x0000
	movt r3, #0x0020
1:
	subs r3,r3,#1
	bne 1b
	mov pc, lr

skip_eleven:
	add r7, #1
	mov pc, lr

#**********************************#








































