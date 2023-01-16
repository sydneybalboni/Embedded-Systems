#Sydney Balboni
#CE2801 021
#10/08/2022
#
#lcd.s
#Functionality for manipulating LCD on Emedded Systems board

.syntax unified
.cpu cortex-m4
.thumb

.section .rodata
ascii:
	.asciz "?123A456B789C*0#D"

.section .text

	.equ RCC_BASE, 0x40023800
    .equ RCC_AHB1ENR, 0x30
    .equ RCC_GPIOCEN, 1<<2

    .equ GPIOC_BASE, 0x40020800
    .equ GPIO_MODER, 0x00
    .equ GPIO_ODR, 0x14
    .equ GPIO_IDR, 0x10
    .equ GPIO_PUPDR, 0x0C
    .equ SET_PIN_PULL_UP, 0x5555

	.equ SET_COL_OUTPUT_ROW_INPUT, 0x55
	.equ SET_COL_INPUT_ROW_OUTPUT, 0x5500


.global KeyInit
.global KeyGetKet
.global KeyGetChar


#KeyInit
#Turns on the keypad port and sets keys to correct modes
#Input:
#	None
#Output:
#	None
#Dependencies:
#	None
KeyInit:

	#r1: RCC_BASE
	#r2: GPIO Register

    push {r1-r3, lr}

    #Turn on port in RCC
	ldr r1, =RCC_BASE
    ldr r2, [r1, #RCC_AHB1ENR]
    orr r2, r2, #RCC_GPIOCEN
    str r2, [r1, #RCC_AHB1ENR]

	#Set keys to pull-up
	ldr r1, =GPIOC_BASE
	mov r2, #0
	mov r3, #SET_PIN_PULL_UP
	orr r2, r2, r3
	str r2, [r1, #GPIO_PUPDR]

	pop {r1-r3, pc}


#KeyGetKeyNoBlock
#Returns the key number of a pressed key, 0 if no key is pressed
#Input:
#	None
#Output:
#	r0: key number, returns 0 if no key is pressed
#Dependencies:
#	None
KeyGetKeyNoBlock:

	#Scan keys once
	bl ScanKeys

	bx lr


#KeyGetKey
#Returns the key number of a pressed key, 0 if no key is pressed
#Waits until a key is pressed
#Input:
#	None
#Output:
#	None
#Dependencies:
#	None
KeyGetKey:

	#Scan keys and wait for a key to be pressed
	bl ScanKeysWithBlock

	bx lr


#KeyGetChar
#Returns the corresponding ascii code for the pressed key
#Waits until a key is pressed
#Input:
#	None
#Output:
#	None
#Dependencies:
#	None
KeyGetChar:

	#r0: corresponding ascii code for key
	#r1: key number
	#r2: ascii string address

	push {r1-r2, lr}

	bl ScanKeysWithBlock

	mov r1, r0

	ldr r2, =ascii

	ldrb r0, [r2, r1]

	pop {r1-r2, pc}

#ScanKeys
#Scans the keys once and returns the key number pressed
#Input:
#	None
#Output:
#	r0: the key # pressed, 0 if no key is pressed
#Dependencies:
#	None
ScanKeys:

	#r0: the key # pressed, 0 if no key is pressed
	#r1: GPIO_BASE
	#r2: I/O
	#r3: row input


	push {r1-r3, lr}

	ldr r1, =GPIOC_BASE

	bl SetRowToInputColToOutput

	#Check row by 0000 -> ODR
1:	mov r2, #0
	strb r2, [r1, #GPIO_ODR]
	#Check the value of col
	ldrb r2, [r1, #GPIO_IDR]
	#If 1111, then repeat check col
	bic r2, 0b1111
	cmp r2, 0xF0
	beq 1b
	mov r3, r2
	lsr r3, #4

	#Get col by row -> ODR
	strb r2, [r1, #GPIO_ODR]
	#Switch row to output and col to input
	bl SetColToInputRowToOutput
	#Get the value of col
	ldrb r2, [r1, #GPIO_IDR]
	and r2, 0b1111
	mov r1, r3

	bl ReadKey

	#Wait until key is released
	ldr r1, =GPIOC_BASE
	mov r2, #0
2:	strb r2, [r1, #GPIO_ODR]
	#Check the value of row
	ldrb r2, [r1, #GPIO_IDR]
	#If not 1111, then check again
	bic r2, (0xF<<4)
	cmp r2, 0xF
	bne 2b

return:
	pop {r1-r3, pc}


#ScanKeysWithBlock
#Scans the keys repeatedly and returns the key number pressed
#Input:
#	None
#Output:
#	r0: the key # pressed
#Dependencies:
#	None
ScanKeysWithBlock:

	#r0: the key # pressed

	push {lr}

	mov r0, #0

	#Scan the keys
1:	bl ScanKeys
	#Check if key press is detected
	cmp r0, #0
	#If not detected, repeat scan
	beq 1b
	#Else return

	pop {pc}


#ReadKey
#Identifies the pressed key on the key pad
#Input:
#	r1: row input
#	r2: col input
#Output:
#	r0: numeric code representing the pressed key
#Dependencies:
#	None
ReadKey:

	#r0: Key number
	#r1: row
	#r2: col

	push {r1, lr}

	#Convert row # to decimal
	mov r0, r1
	bl FindZero
	mov r1, r0

	#Convert col # to decimal
	mov r0, r2
	bl FindZero

	#Convert row and col #s to the key number
	#r0: col, r1: row
	bl ComputeKeyNumber

	pop {r1, pc}


#FindZero
#Finds the location of the zero bit
#Input:
#	r0: binary number n containing a zero bit
#Output:
#	r0: location of the zero bit
#Dependencies:
#	None
FindZero:

	#r0: Location of the zero bit
	#r1: Negation of n
	#r2: n + 1

	push {r1-r2, lr}

	mov r1, r0
	mov r2, r0

	#Negate bits of n in r1
	eor r1, 0b1111
	and r1, 0b1111

	#Add 1 to n in r2
	add r2, r2, #1

	#And r1 and r2 into r0
	and r0, r1, r2

	#Convert binary location value to decimal
	bl ConvertLocationToDecimal

	pop {r1-r2, pc}


#ConvertLocationToDecimal
#Converts the binary representation to decimal value 1-4
#Input:
#	r0: binary representation of zero bit location
#Output:
#	r0: location of the zero bit in decimal 1-4
#Dependencies:
#	None
ConvertLocationToDecimal:

	#r0: Binary representation of bit location
	#r1: Decimal value of location

	push {r1, lr}

	#Initialize location value to 1
	mov r1, #1

1:	#If set bit is in the first bit location
	cmp r0, #1
	#Then branch forward
	beq 2f
	#Else shift and repeat
	lsr r0, #1
	add r1, r1, #1
	b 1b

2:	#Return decimal representation of zero bit location
	mov r0, r1

	pop {r1, pc}


#ComputeKeyNumber
#Converts the col # and row # to the specific key #
#Input:
#	r0: col #
# 	r1: row #
#	r2: decimal value 3
#Output:
#	r0: key number
#Dependencies:
#	None
ComputeKeyNumber:

	#r0: col #
	#r1: row #

	push {r1, lr}


	cmp r1, #1
	bne 1f
	mov r1, #0
	b 4f

1:	cmp r1, #2
	bne 2f
	mov r1, #4
	b 4f


2:	cmp r1, #3
	bne 3f
	mov r1, #8
	b 4f


3:	cmp r1, #4
	mov r1, #12

	#Add row # to col #
4:	add r0, r1, r0

	pop {r1, pc}


#
#
#Input:
#	r0:
#Output:
#	None
#Dependencies:
#	None
SetRowToInputColToOutput:

	push {r2, lr}

    ldr r2, [r1, #GPIO_MODER]
    #Clear col and row bits
    bic r2, #0xFF
    bic r2, (0xFF<<8)
    #Set column bits to output mode and row bits to input mode
    orr r2, #SET_COL_OUTPUT_ROW_INPUT
    str r2, [r1, #GPIO_MODER]
    bl KeypadDelay

    pop {r2, pc}


#
#
#Input:
#	r0:
#Output:
#	None
#Dependencies:
#	None
SetColToInputRowToOutput:

	push {r2, lr}

    ldr r2, [r1, #GPIO_MODER]
    #Clear col and row bits
    bic r2, #0xFF
    bic r2, (0xFF<<8)
    #Set column bits to input mode and row bits to output mode
    orr r2, #SET_COL_INPUT_ROW_OUTPUT
    str r2, [r1, #GPIO_MODER]
    bl KeypadDelay

    pop {r2, pc}



