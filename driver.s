#Sydney Balboni
#CE2801 021
#10/22/2022
#
#driver.s
#Allows you to play notes using the piezo buzzer 

.syntax unified
.cpu cortex-m4
.thumb

.section .rodata
Play:
	.asciz "Play a note!"
PromptTop:
	.asciz "1: 1/8  2: 1/4"
PromptBottom:
	.asciz "3: 1/2  4: whole"
Notes:
	.ascii "?CDEFGAB"

.section .text

	.equ POUND_KEY, 8

	.equ NUM_OF_NOTES, 7

.global main


main:

	#Initialize timer, LEDs, LCD, buzzer, and keypad
	bl TimerInit
	bl LedInit
	bl LcdInit
	bl KeyInit
	bl BuzzerInit



	#Main screen
1:
	bl LcdClear
	mov r0, #0
	mov r1, #2
	bl LcdSetPosition
	ldr r0, =Play
	bl LcdPrintString


	#Detect a key press
	bl KeyGetKey

	#If '#' then prompt for settings
	cmp r0, #POUND_KEY
	bne 2f
	bl Settings
	b 1b

2:
	#If a note key was pressed then play a note
	cmp r0, #NUM_OF_NOTES
	bgt 1b
	bl PlayNote

	b 1b




Settings:

	push {r1, lr}

	#Display options
	bl LcdClear
	bl LcdHome
	ldr r0, =PromptTop
	bl LcdPrintString
	mov r0, #1
	mov r1, #0
	bl LcdSetPosition
	ldr r0, =PromptBottom
	bl LcdPrintString

1:
	#Check pressed key
	bl KeyGetKey

	#If a valid key is pressed then set the note length
	cmp r0, #13
	blt 1b
	sub r0, r0, #13

	bl SetNoteLength

	pop {r1, pc}


PlayNote:

	#r0: note number

	push {r1, lr}

	#Multiply by four to get word array index (4 bytes)
	mov r1, #4
	sub r0, r0, #1
	mul r0, r0, r1

	bl Buzz

	pop {r1, pc}



