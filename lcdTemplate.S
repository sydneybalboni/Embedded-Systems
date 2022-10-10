#Sydney Balboni
#CE2801 021
#10/08/2022
#
#lcdTemplate.s
#Functionality for manipulating LCD on Emedded Systems board

.syntax unified
.cpu cortex-m4
.thumb
.section .text

	.equ RCC_BASE, 0x40023800
    .equ RCC_AHB1ENR, 0x30
    .equ RCC_GPIOAEN, 1
    .equ RCC_GPIOCEN, 1<<2

	//DB Pins
    .equ GPIOA_BASE, 0x40020000

    //RS, RW, E pins
    .equ GPIOC_BASE, 0x40020800

    .equ GPIO_MODER, 0x00
    .equ GPIO_ODR, 0x14
    .equ GPIO_BSRR, 0x18

	.equ RS, 8
	.equ RW, 9
	.equ E, 10

	.equ RS_SET, 1<<RS
	.equ RS_CLR, 1<<(RS+16)
	.equ RW_SET, 1<<RW
	.equ RW_CLR, 1<<(RW+16)
	.equ E_SET, 1<<E
	.equ E_CLR, 1<<(E+16)
	.equ DB_CLR, 0xFF<<16
	.equ BSRR_CLR, 0x00000000

	//DB0-DB7
	.equ DB_PINS, 0xFF<<4
	.equ DB_PINS_OUTPUT_MODE, 0x555500
	.equ RS_RW_EN_PINS, 0b111<<8
	.equ RS_RW_E_OUTPUT_MODE, 0x150000

	.equ DB_CLEAR, 1

.global LcdInit
.global LcdPrintNum
.global LcdPrintString
.global LcdClear
.global LcdHome
.global LcdSetPosition

#
#
#Input:
#	None
#Output:
#	None
#Dependancies:
#	None
PortSetup:

    push {r1-r3, lr}

    #Turn on Ports in RCC
	ldr r1, =RCC_BASE
    ldr r2, [r1, #RCC_AHB1ENR]
    orr r2, r2, #RCC_GPIOAEN
    orr r2, r2, #RCC_GPIOCEN
    str r2, [r1, #RCC_AHB1ENR]

    #Set DB Pins to Outputs
    ldr r3, =DB_PINS_OUTPUT_MODE
	ldr r1, =GPIOA_BASE
	ldr r2, [r1, #GPIO_MODER]
	orr r2, r3
	str r2, [r1, #GPIO_MODER] //Breaks


    #Set RS, RW, and E Pins to Outputs
    ldr r3, =RS_RW_E_OUTPUT_MODE
	ldr r1, =GPIOC_BASE
	ldr r2, [r1, #GPIO_MODER]
	orr r2, r3
	str r2, [r1, #GPIO_MODER]

	pop {r1-r3, lr}

#WriteInstruction
#Writes an instruction to the LCD
#Input:
#	R1: Databus to write
#Output:
#	None
#Dependancies:
#	None
WriteInstruction:
#RS=0 RW=0  R1-Arg
	#r1: DB
	#r2: GPIO
	#r3: BSRR
	#r4: clr/set masks
	push {r2-r4, lr}

	#Clear RS, RW, and E bits
	ldr r2, =GPIOC_BASE
	ldr r3, [r2, #GPIO_BSRR]
	#Ensure bits are clear
	mov r3, #BSRR_CLR
	#Setup reset mask
	ldr r4, =RS_CLR
	orr r4, r4, #RW_CLR
	orr r4, r4, #E_CLR
	#Apply reset mask
	orr r3, r3, r4
	#Set RS=0,RW=0,E=0
	str r3, [r2, #GPIO_BSRR]

	#Set E=1
	ldr r3, [r2, #GPIO_BSRR]
	ldr r4, =E_SET
	orr r3, r3, r4
	str r3, [r2, #GPIO_BSRR]

	#Set R1 -> DataBus 
	ldr r2, =GPIOA_BASE
	ldr r3, [r2, #GPIO_BSRR]
	ldr r3, =BSRR_CLR
	mov r3, r1
	str r3, [r2, #GPIO_BSRR]
	
	#Set E=0
	ldr r3, [r2, #GPIO_BSRR]
	ldr r4, =E_CLR
	orr r3, r3, r4
	str r3, [r2, #GPIO_BSRR]

	#Wait for appropriate delay
	bl LcdDelay

	pop {r2-r4, lr}


#WriteData
#Writes data to the LCD
#Input:
#	R1: Databus to write
#Output:
#	None
#Dependancies:
#	None
WriteData:
#RS=0 RW=0  R1-Arg
	push {r1, lr}

	#Set RS=1,RW=0,E=0

	#Set E=1

	#Set R1 -> DataBus 
	
	#Set E=0

	#Wait for appropriate delay

	pop {r1, pc}

#LcdInit
#Initializes the LCD
#Input:
#	None
#Output:
#	None
#Dependancies:
#	None
LcdInit:

	#r1: DB
	push {r1}

    #Set up Ports
    b PortSetup

    #Wait 40ms
	bl LcdDelay

    #Write Function Set (0x38)
	mov r1, #0x38
	bl WriteInstruction

    #Write Function Set (0x38)
    mov r1, #0x38
	bl WriteInstruction

    #Write Display On/Off(0x0F)
    mov r1, #0x0F
	bl WriteInstruction

    #Write Display Clear (0x01)
    mov r1, #0x01
	bl WriteInstruction

    #Write Entry Mode Set (0x06)
    mov r1, #0x06
	bl WriteInstruction

	pop {r1}
	bx lr

#Write other global functions

#LcdClear
#Clears the LCD
#Input:
#	None
#Output:
#	None
#Dependancies:
#	None
LcdClear:
	#Include the necessary delay
	push {r1 }

	ldr r1, =GPIOA_BASE
	ldr r2, [r1, #GPIO_BSRR]



	ldr r3, =DB_CLEAR



	pop {r1 }
	bx lr

#LcdHome
#Moves cursor to the home position
#Input:
#	None
#Output:
#	None
#Dependancies:
#	None
LcdHome:
	#Include the necessary delay
	push {r1 }

	pop {r1 }
	bx lr

#LcdSetPosition
#Moves cursor to the position indicated
#Input:
#	R0: Row
#	R1: Column
#Output:
#	None
#Dependancies:
#	None
LcdSetPosition:
#Include necessary delay
	push { r1}

	pop {r1 }
	bx lr

#LcdPrintString
#Prints a string to the LCD
#Input:
#	R0: Address of null-terminated string
#Output:
#	R0: Number of characters written to the display
#Dependancies:
#	None
LcdPrintString:
#remember necessary delay

	push {r1 }

	pop {r1 }
	bx lr

#LcdPrintNum
#Prints a number to the LCD
#Input:
#	R0: Number to be printed within 0-9999
#Output:
#	None
#Dependancies:
#	None
LcdPrintNum:
#Include necessary delay
	push {r1 }

	pop {r1 }
	bx lr

	#LcdDelay
#Delays LCD instructions
#Input:
#	None
#Output:
#	None
#Dependancies:
#	None
LcdDelay:
#Helper function you probably want to move somewhere else...
# about r1 microseonds
	# stack
	push {r1,lr}

	mov r1, #400
	lsl r1, r1, #3

1:
	subs r1, r1, #1
	bne 1b

	# return
	pop {r1, lr}
