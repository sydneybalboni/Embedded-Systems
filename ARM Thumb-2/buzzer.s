#Sydney Balboni
#CE2801 021
#10/28/2022
#
#buzzer.s
#Functionality for manipulating the piezzo buzzer on the Embedded Systems board

.syntax unified
.cpu cortex-m4
.thumb

.section .data

noteLengths:
	.word 1562500, 3125000, 6250000, 7500000

noteLengthSelected:
	.byte 4

count:
	.word 1562500

noteCounts:
	.word 30578, 27242, 24270, 22908, 20408, 18182, 16198

.section .text

	.equ RCC_BASE, 0x40023800

	.equ RCC_AHB1ENR, 0x30
	.equ GPIOBEN, 1<<1
	.equ ODR, 0x14

	.equ RCC_APB1ENR, 0x40
	.equ TIM3EN, 1<<1

	.equ GPIOB_BASE, 0x40020400
	.equ GPIOx_MODER, 0x00
	.equ ALTFUN, 0b10
	.equ GPIOx_AFRL, 0x20
	.equ AF2, 0b0010

	.equ TIM3_BASE, 0x40000400
	.equ TIMx_CNT, 0x24
	.equ TIMx_ARR, 0x2C
	.equ TIMx_CCR1, 0x34

	.equ TIMx_CCMR1, 0x18
	.equ OCM1, 4
	.equ TOGGLE, 0b011

	.equ TIMx_CCER, 0x20
	.equ CC1E, 1<<0

	.equ TIMx_CR1, 0x00
	.equ CEN, 1<<0

	.equ SYSTICK_BASE, 0xE000E010
	.equ SYSTICK_CTRL, 0x0
	.equ SYSTICK_LOAD, 0x4
	.equ SYSTICK_VAL, 0x8
	.equ ENABLE, 1<<0
	.equ TICKINT, 1<<1
	.equ CLOCKSRC, 1<<2

.global BuzzerInit
.global Buzz
.global SetNoteLength

#BuzzerInit
#Initializes the buzzer
#Input:
#	None
#Output:
#	None
#Dependencies:
#	None
BuzzerInit:

    push {r1-r4, lr}

	#Turn on GPIOB
    ldr r0, =RCC_BASE
	ldrb r1, [r0, #RCC_AHB1ENR]
	orr r1, #GPIOBEN
	strb r1, [r0, #RCC_AHB1ENR]

	#TIM3
	ldrb r1, [r0,#RCC_APB1ENR]
	orr r1, #TIM3EN
	strb r1, [r0,#RCC_APB1ENR]

	ldr r0, =GPIOB_BASE

	mov r2, #ALTFUN
	ldr r1, [r0, GPIOx_MODER]
	bfi r1, r2, #(4*2), #2
	str r1, [r0, GPIOx_MODER]

	mov r2, #AF2
	ldr r1, [r0, GPIOx_AFRL]
	bfi r1, r2, #(4*4), #4
	str r1, [r0, GPIOx_AFRL]

	ldr r0, =TIM3_BASE
	ldr r2, =625000
	str r2, [r0, #TIMx_ARR]
	str r2, [r0, #TIMx_CCR1]

	#3 Set output mode to "Toggle" in CCMR1
	mov r2, #TOGGLE
	ldr r1, [r0, #TIMx_CCMR1]
	bfi r1, r2, #OCM1, #3
	str r1, [r0, #TIMx_CCMR1]

	#Enable output in CCER
	ldr r1, [r0, #TIMx_CCER]
	orr r1, #CC1E
	str r1, [r0, #TIMx_CCER]

	ldr r0, =SYSTICK_BASE
	#Set up Systick to interupt
	ldr r1, =(6250000-1)
	str r1, [r0, #SYSTICK_LOAD]

    pop {r1-r4, pc}


#Buzz
#Plays a note on the buzzer
#Input:
#	r0 - note tick count
#	r1 - note
#Output:
#	None
#Dependencies:
#	None
Buzz:

	#r0: note number
	#r1: note

	push {r0-r3, lr}

	#Load correct count for note
	ldr r2, =noteCounts
	ldrh r1, [r2, r0]

	#Send note to timer
	ldr r2, =TIM3_BASE
	mov r3, r1
	str r3, [r2, #TIMx_ARR]
	str r3, [r2, #TIMx_CCR1]

    #Play note
	ldr r3, [r2, #TIMx_CR1]
	orr r3, #CEN
	str r3, [r2, #TIMx_CR1]

	#Send note duration to SysTick
	ldr r1, =SYSTICK_BASE
	ldr r2, =noteLengths
	ldr r4, =noteLengthSelected
	ldrb r3, [r4]
	ldr r4, [r2, r3]
	str r4, [r1, #SYSTICK_LOAD]
	str r4, [r1, #SYSTICK_VAL]

	#Turn on SysTick
	mov r2, #(ENABLE|TICKINT|CLOCKSRC)
	strb r2, [r1, #SYSTICK_CTRL]

	#exit
    pop {r0-r3, pc}


#SetNoteLength
#Sets the note length
#Input:
#	r0 - note length index
#Output:
#	None
#Dependencies:
#	None
SetNoteLength:

	#r0: note length index
	#r1: address of note length selected
	#r2: word multiplier for memory accessing

	push {r1-r2, lr}

	#Multiply by four to get word array index (4 bytes)
	mov r2, #4
	mul r2, r2, r0

	#Store selected value into memory
	ldr r1, =noteLengthSelected
	strb r2, [r1]

	pop {r1-r2, pc}


.global SysTick_Handler
.thumb_func
SysTick_Handler:



	#Stop buzzer
	ldr r0, =TIM3_BASE
	ldr r1, [r0, #TIMx_CR1]
	bic r1, #CEN
	str r1, [r0, #TIMx_CR1]

	#Clear flag
	ldr r0, =SYSTICK_BASE
	str r0, [r0, #SYSTICK_VAL]

	bx lr
