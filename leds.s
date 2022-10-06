#Sydney Balboni
#CE2801 021
#10/02/2022
#
#led.s
#Functionality for manipulating leds on CE2801 Embedded Systems boards

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800
	.equ RCC_AHB1ENR, 0x30
	.equ GPIOBEN, (1<<1)

	.equ GPIOB_BASE, 0x40020400
	.equ GPIO_MODER, 0x00
	.equ GPIO_ODR, 0x14

	.equ clear_mask, 0x00000000
	.equ set_mask, 0x7ff
	.equ five_bits, 5

.global led_init
.global num_to_led



#led_init
#Initializes the LED pins to be outputs
#Input:
#	None
#Output:
#	None
#Dependancies:
#	None
led_init:

    push {r1-r4}

    #turn on clock
    ldr r1, =RCC_BASE
    ldr r2, [r1, #RCC_AHB1ENR]
    orr r2, r2, #GPIOBEN
    str r2, [r1, #RCC_AHB1ENR]

    #set the clear mask
    ldr r3, =0xFF3FFC00
    ldr r4, =0x55155400

    #set all led pins to outputs
    ldr r1, =GPIOB_BASE
    ldr r2, [r1, #GPIO_MODER]

    #clear bits
    bic r2, r2, r3

    #mask to clear bit for output: (PB5-PB10,PB12-PB15)
    orr r2, r4

    str r2, [r1, #GPIO_MODER]

	#exit
    pop {r1-r4}
    bx lr


#num_to_led
#Displays the 10 least-significant-bits of a number to the leds
#Input:
#	r0 - number to display
#Output:
#	None
#Dependancies:
#	None
num_to_led:

	push {r1-r5}

    #shift number over to match pins
    lsl r0, r0, #five_bits

    #isolate upper bits and shift over
    ubfx r4, r0, #11, #five_bits
    lsl r4, r4, #12

    #mask and add new register
    mov r5, #set_mask
    and r0, r5
    add r0, r0, r4

    #turn on the lights
    ldr r1, =GPIOB_BASE
    ldr r2, [r1, #GPIO_ODR]
    and r2, #clear_mask
    orr r2, r2, r0
    strh r2, [r1, #GPIO_ODR]

	#exit
    pop {r1-r5}
    bx lr
