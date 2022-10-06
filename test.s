#Sydney Balboni
#CE2801 021
#10/02/2022
#
#test.s
#Tests the subroutines made in lab 3

.syntax unified
.cpu cortex-m4
.thumb
.section .text


	.equ test_number, 10000

	.equ half_second_delay, 500
	.equ one_second_delay, 1000

	.equ byte_length, 8
	.equ large_num, 0x00200000
	.equ clear_mask, 0x00000000

	.equ lsb_first_num, 24
	.equ lsb_second_num, 16
	.equ lsb_third_num, 8
	.equ lsb_fourth_num, 0


.global main

#r0 - number to display
#r1 - delay amount
#r2 - test number

main:
	#setup test
	bl led_init
	ldrh r2, =test_number
	mov r0, r2
	bl num_to_ascii
	mov r2, r0

display_num:

	#load half second delay time into parameter register
	ldrh r1, =half_second_delay

	#display the first number to the LEDs
	ubfx r0, r2, #lsb_first_num, #byte_length
	bl num_to_led
	bl delay_ms

	#display the second number to the LEDs
	ubfx r0, r2, #lsb_second_num, #byte_length
	bl num_to_led
	bl delay_ms

	#display the third number to the LEDs
	ubfx r0, r2, #lsb_third_num, #byte_length
	bl num_to_led
	bl delay_ms

	#display the fourth number to the LEDs
	ubfx r0, r2, #lsb_fourth_num, #byte_length
	bl num_to_led
	bl delay_ms
	bl delay_ms

	#clear the LEDs
	and r0, #clear_mask
	bl num_to_led

	#long delay
	ldrh r1, =one_second_delay
	bl delay_ms

	#repeat
	bal display_num

