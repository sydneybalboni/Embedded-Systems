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

	.equ RS_SET, 1<<8
	.equ RS_CLR, 1<<24
	.equ RW_SET, 1<<9
	.equ RW_CLR, 1<<25
	.equ E_SET, 1<<10
	.equ E_CLR, 1<<26
	.equ DB_CLR, 0x0FF00000
	.equ BSRR_RESET, 0xFFFF0000

	.equ DB_PINS, 0x00000FF0
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

	#r1: RCC_BASE/GPIO
	#r2: GPIOXEN/MODER
	#r3: Output set masks

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
	str r2, [r1, #GPIO_MODER]


    #Set RS, RW, and E Pins to Outputs
    ldr r3, =RS_RW_E_OUTPUT_MODE
	ldr r1, =GPIOC_BASE
	ldr r2, [r1, #GPIO_MODER]
	orr r2, r3
	str r2, [r1, #GPIO_MODER]

	pop {r1-r3, pc}

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
	#r2: Delay time
	#r3: GPIO
	#r4: BSRR
	#r5: clr/set masks
	push {r2-r5, lr}

	#Clear RS, RW, and E bits
	ldr r3, =GPIOC_BASE
	ldr r4, [r3, #GPIO_BSRR]
	#Ensure bits are clear
	add r4, r4, 0x00000000
	#Setup reset mask
	ldr r5, =RS_CLR
	orr r5, r5, #RW_CLR
	orr r5, r5, #E_CLR
	#Apply reset mask
	orr r4, r4, r5
	#Set RS=0,RW=0,E=0
	str r4, [r3, #GPIO_BSRR]

	#Set E=1
	ldr r4, [r3, #GPIO_BSRR]
	ldr r5, =E_SET
	orr r4, r4, r5
	str r4, [r3, #GPIO_BSRR]

	#Set R1 -> DataBus
	#reset bits
	ldr r3, =GPIOA_BASE
	ldr r4, [r3, #GPIO_BSRR]
	ldr r4, =BSRR_RESET
	str r4, [r3, #GPIO_BSRR]
	#set DB
	ldr r3, =GPIOA_BASE
	ldr r4, [r3, #GPIO_BSRR]
	mov r4, r1
	str r4, [r3, #GPIO_BSRR]

	#Set E=0
	ldr r4, [r3, #GPIO_BSRR]
	ldr r5, =E_CLR
	orr r4, r4, r5
	str r4, [r3, #GPIO_BSRR]

	#Wait for appropriate delay
	bl LcdDelay

	pop {r2-r5, pc}


#WriteData
#Writes data to the LCD
#Input:
#	R1: Databus to write
#Output:
#	None
#Dependancies:
#	None
WriteData:
	#r1: DB
	#r2: Delay time
	#r3: GPIO
	#r4: BSRR
	#r5: clr/set masks
	push {r1, lr}

	#Set RS=1,RW=0,E=0
	ldr r3, =GPIOC_BASE
	ldr r4, [r3, #GPIO_BSRR]
	#Ensure bits are clear
	add r4, r4, 0x00000000
	#Setup mask
	ldr r5, =RS_SET
	orr r5, r5, #RW_CLR
	orr r5, r5, #E_CLR
	#Apply mask
	orr r4, r4, r5
	#Set RS=1,RW=0,E=0
	str r4, [r3, #GPIO_BSRR]

	#Set E=1
	ldr r4, [r3, #GPIO_BSRR]
	ldr r5, =E_SET
	orr r4, r4, r5
	str r4, [r3, #GPIO_BSRR]

	#Set R1 -> DataBus 
	#reset bits
	ldr r3, =GPIOA_BASE
	ldr r4, [r3, #GPIO_BSRR]
	ldr r4, =BSRR_RESET
	str r4, [r3, #GPIO_BSRR]
	#set DB
	ldr r3, =GPIOA_BASE
	ldr r4, [r3, #GPIO_BSRR]
	mov r4, r1
	str r4, [r3, #GPIO_BSRR]
	
	#Set E=0
	ldr r4, [r3, #GPIO_BSRR]
	ldr r5, =E_CLR
	orr r4, r4, r5
	str r4, [r3, #GPIO_BSRR]

	#Wait for appropriate delay
	#TODO
	bl LcdDelay

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
	#r2: delay time
	push {r1-r2, lr}

    #Set up Ports
    bl PortSetup

    #Wait 40ms
    mov r2, #40
	bl DelayMS

    #Write Function Set (0x38)
	mov r1, #0x380
	mov r2, #37
	bl WriteInstruction

    #Write Function Set (0x38)
    mov r1, #0x380
	bl WriteInstruction

    #Write Display On/Off(0x0F)
    mov r1, #0x0F0
	bl WriteInstruction

    #Write Display Clear (0x01)
    mov r1, #0x010
    mov r2, #1520
	bl WriteInstruction

    #Write Entry Mode Set (0x06)
    mov r1, #0x060
    mov r2, #37
	bl WriteInstruction

	#cursor


	pop {r1-r2, pc}

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
	#R0: number to display
	#R2: delay
	push {r2, lr}

	#Convert number to ascii
	bl NumToAscii





	pop {r2, pc}
