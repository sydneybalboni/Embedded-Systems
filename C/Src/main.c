/**
 ******************************************************************************
 * @file    main.c
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Driver for console reading and writing to memory
 *
 * @paragraph I had a good experience with this lab. This lab was another great
 * opportunity for me to explore how pointers are used in embedded systems.
 * The hardest part of this lab was getting used to formatting strings. I used
 * this lab as an opportunity to look in depth at how strings are handled by
 * different commonly used functions.
 ******************************************************************************
 */

#include <stdio.h>
#include "uart_driver.h"
#include "delay.h"
#include "lcd.h"
#include "console.h"

#define F_CPU 16000000UL

int main() 
{
	init_usart2(57600,F_CPU);

	char* strings[3];

	strings[0] = "bird";
	strings[1] = "cat";
	strings[2] = "shark";

	for (int i = 0; i < 3; ++i)
	{
		printf("Index %d: %s\n", i, strings[i]);
	}

	return 0;
}

/**
 * Displays a 10 seconds countdown
 * on the lcd display
 */
// int main(void)
// {
// 	init_usart2(57600,F_CPU);

// 	delayS(2);

// 	initialPrompt();

// 	for (;;)
// 	{
// 		char str[50];

// 		fgets(str, 99, stdin);
// 		acceptInput(str);

// 		printf("\n\n");
// 	}
// }
