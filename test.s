/**
#**********************************#
* Sydney Balboni
* CE2801-021
* 9-19-2022
*
* test.s
* Tests the subroutines made in lab3
#**********************************#
*/

.syntax unified
.cpu cortex-m4
.thumb
.section .text

#***********Psuedocode*************#

#0. Initialize Lights as outputs

#1. Setup registers for program

#2. Scan LEDs left

#3. Check if conditional functionality is needed

#4. Scan LEDs right

#5. Check if conditional functionality is needed

#6. Repeat steps 2 - 5

#**********************************#



#Lights are PB5-PB10, PB12-PB15

	.equ test_number, 1234


.global main

main:
	ldrh r4, =test_number //double check ldrh










































