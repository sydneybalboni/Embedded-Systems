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


	.equ test_number, 1234
	.equ half_second_delay, 500
	.equ one_and_a_half_second_delay, 1500
	.equ byte_length, 8
	.equ large_num, 0x00200000
	.equ clear_mask, 0x00000000


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
	ldrh r1, =half_second_delay
	ubfx r0, r2, #24, #byte_length
	bl num_to_led
	bl delay_ms
	bl num_to_led
	bl delay_ms
	ubfx r0, r2, #16, #byte_length
	bl num_to_led
	bl delay_ms
	bl num_to_led
	bl delay_ms
	ubfx r0, r2, #8, #byte_length
	bl num_to_led
	bl delay_ms
	bl num_to_led
	bl delay_ms
	ubfx r0, r2, #0, #byte_length
	bl num_to_led
	bl delay_ms
	bl delay_ms
	and r0, #clear_mask
	bl num_to_led

	#long delay
	ldrh r1, =one_and_a_half_second_delay
	bl delay_ms
	bal display_num

