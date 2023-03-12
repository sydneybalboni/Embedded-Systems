/**
 ******************************************************************************
 * @file    main.c
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Driver for console reading and writing to memory
 *
 * @paragraph I had a good experience with this lab. This lab was a great 
 * opportunity for me to learn how to utilize interupts.The hardest part of 
 * this lab was debugging to figure out why my printf statements weren't
 * functioning correctly.
 ******************************************************************************
 */

#include <stdio.h>
#include "regs.h"
#include "uart_driver.h"
#include "delay.h"
#include "buzzer.h"
#include "lcd.h"
#include "console.h"
#include "frequency.h"

#define F_CPU 16000000UL

int main(void)
{
 	init_usart2(57600,F_CPU);

	buzzerInit();
	
	initialPrompt();

	for (;;)
	{
		char str[50];

		fgets(str, 99, stdin);

		acceptInput(str);

		printf("\n\n");
	}
}
