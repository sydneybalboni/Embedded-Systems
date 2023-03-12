/**
 ******************************************************************************
 * @file    main.c
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Driver for console reading and writing to memory
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
