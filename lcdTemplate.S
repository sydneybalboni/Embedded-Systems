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

    .equ GPIOA_BASE, 0x40020000
    .equ GPIOC_BASE, 0x40020800
    .equ GPIO_MODER, 0x00
    .equ GPIO_ODR, 0x14
    .equ GPIO_IDR, 0x10
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
	.equ RS_RW_E_OUTPUT_MODE, 0x150000
	.equ RS_RW_EN_PINS, 0b111<<8
	.equ LCD_CLEAR, 1
	.equ LCD_HOME, 2

	.equ FUNCTION_SET, 0x38
	.equ TURN_DISPLAY_ON, 0x0F
	.equ DISPLAY_CLEAR, 0x01
	.equ ENTRY_MODE_SET, 0x06


.global LcdInit
.global LcdPrintNum
.global LcdPrintString
.global LcdClear
.global LcdHome
.global LcdSetPosition


#PortSetup
#Initializes the pins needed in the usage of the LCD
#Input:
#	None
#Output:
#	None
#Dependencies:
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


#LcdWrite
#Initializes the pins needed in the usage of the LCD
#Input:
#	None
#Output:
#	None
#Dependencies:
#	None
LcdWrite:

	#r1: DB
	#r2: Delay time
	#r3: GPIO
	#r4: BSRR
	#r5: CLR/SET masks

	push {r2-r5, lr}

	#Write DB
	ldr r3, =GPIOA_BASE
	ldr r4, [r3, #GPIO_ODR]
	#clear output
	bic r4, r4, (0xFF<<4)
	lsl r1, r1, #4
	orr r4, r4, r1
	str r4, [r3, #GPIO_ODR]

	#Set and reset control bits
	ldr r3, =GPIOC_BASE
	#RW=0, E=1
	mov r4, #RW_CLR
	orr r4, r5, #E_SET
	str r4, [r3, #GPIO_BSRR]

	#Delay for toggling E
	mov r2, #50
	bl LcdDelay

	#E=0
	mov r4, #E_CLR
	str r4, [r3, #GPIO_BSRR]

	#Delay for toggling E
	mov r1, #37
	bl LcdDelay

	pop {r2-r5, pc}


#WriteInstruction
#Writes an instruction to the LCD
#Input:
#	R1: Databus to write
#Output:
#	None
#Dependencies:
#	None
WriteInstruction:

	#r1: DB
	#r2: GPIO
	#r3: Clear mask

	push {r2-r3, lr}

	//Clear RS
	ldr r2, =GPIOC_BASE
	mov r3, #RS_CLR
	str r3, [r2, #GPIO_BSRR]

	//Call the write subroutine
	bl LcdWrite

	pop {r2-r3, pc}
	bx lr


#WriteData
#Writes data to the LCD
#Input:
#	R1: Databus to write
#Output:
#	None
#Dependencies:
#	None
WriteData:

	#r1: DB
	#r2: GPIO
	#r3: Set mask

	push {r2-r3, lr}

	//Set RS
	ldr r2, =GPIOC_BASE
	mov r3, #RS_SET
	str r3, [r2, #GPIO_BSRR]

	//Call the write subroutine
	bl LcdWrite

	pop {r2-r3, lr}
	bx lr


#LcdInit
#Initializes the LCD
#Input:
#	None
#Output:
#	None
#Dependencies:
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

    #Write Function Set
	mov r1, #FUNCTION_SET
	bl WriteInstruction
	bl DelayMS

    #Write Function Set
    mov r1, #FUNCTION_SET
	bl WriteInstruction
	bl DelayMS

    #Write Display On/Off
    mov r1, #TURN_DISPLAY_ON
	bl WriteInstruction
	bl DelayMS

    #Write Display Clear
    mov r1, #DISPLAY_CLEAR
    mov r2, #1520
	bl WriteInstruction
	bl DelayMS

    #Write Entry Mode Set
    mov r1, #ENTRY_MODE_SET
    mov r2, #37
	bl WriteInstruction

	pop {r1-r2, pc}


#LcdClear
#Clears the LCD
#Input:
#	None
#Output:
#	None
#Dependencies:
#	None
LcdClear:
	#Include the necessary delay
	push {r1, lr}

	ldr r1, =LCD_CLEAR
	bl WriteInstruction

	mov r2, #152
	bl LcdDelay

	pop {r1, pc}
	bx lr


#LcdHome
#Moves cursor to the home position
#Input:
#	None
#Output:
#	None
#Dependencies:
#	None
LcdHome:
	#Include the necessary delay
	push {r1, lr }

	ldr r1, =LCD_HOME
	bl WriteInstruction

	mov r2, #152
	bl LcdDelay

	pop {r1, pc}
	bx lr


#LcdSetPosition
#Moves cursor to the position indicated
#Input:
#	R0: Row
#	R1: Column
#Output:
#	None
#Dependencies:
#	None
LcdSetPosition:
#Include necessary delay
	push {r2, lr}
	#Shift row to bit 6
	lsl r0, r0, #6
	#Add row
	orr r1, r1, r0
	#Set instruction bit
	orr r1, r1, #(1<<7)
	#Send instruction
	bl WriteInstruction
	pop {r2, pc}


#LcdPrintString
#Prints a string to the LCD
#Input:
#	R0: Address of null-terminated string
#Output:
#	R0: Number of characters written to the display
#Dependencies:
#	None
LcdPrintString:

	#r0: String address/number of characters
	#r1: DB
	#r2: Delay
	#r3: Address shifter TODO

	push {r1-r3, lr}

	#Address shifter
	mov r3, #0

	#Load the value at the string memory address into r1,
	#shifted by the address shifter
1:	ldrb r1, [r0, r3]
	#Check for null terminator
	cmp r1, #0
	beq end
	#Display
	bl WriteData
	#Shift the address over a byte
	add r3, #1
	b 1b

end:
	#Return character count
	add r0, r3, #1
	pop {r1-r3, pc}


#LcdPrintNum
#Prints a number to the LCD
#Input:
#	R0: Number to be printed within 0-9999
#Output:
#	None
#Dependencies:
#	None
LcdPrintNum:

	#r0: Number to display
	#r1: DB
	#r2: Delay
	#r3: First number
	#r4: Second number
	#r5: Third number
	#r6: Fourth number

	push {r2-r6, lr}

	#Convert number to ascii
	bl NumToAscii

	#Break up individual numbers
	ubfx r3, r0, #0, #8
	ubfx r4, r0, #8, #8
	ubfx r5, r0, #16, #8
	ubfx r6, r0, #24, #8

	#Setup delay
	mov r2, #40
	bl DelayMS
	#First number
	mov r1, r6
	bl WriteData
	bl DelayMS
	#Second number
	mov r1, r5
	bl WriteData
	bl DelayMS
	#Third number
	mov r1, r4
	bl WriteData
	bl DelayMS
	#Fourth number
	mov r1, r3
	bl WriteData
	bl DelayMS

	pop {r2-r6, pc}

#CheckBusyFlag
#Repeatedly checks the busy flag until it is down
#Input:
#	None
#Output:
#	None
#Dependencies:
#	None
CheckBusyFlag:

	#r1: GPIO/busy flag
	#r2: Mask/Input

	push {r1-r3, lr}

	#RS=0, RW=1
	ldr r1, =GPIOC_BASE
	ldr r2, =RW_SET
	orr r2, r2, #RS_CLR
	str r2, [r1, #GPIO_BSRR]
1:
	#Check the busy flag
	ldr r1, =GPIOA_BASE
	ldr r2, [r1, #GPIO_IDR]
	#Isolate busy flag
	ubfx r1, r2, #11, #1
	#Check if busy flag is down
	cmp r1, #0
	#Check again if busy flag is high
	bne 1b

	pop {r1-r3, pc}


