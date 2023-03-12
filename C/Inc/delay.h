/**
 ******************************************************************************
 * @file    delay.h
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Provides prototypes and defintions for the delay.c file 
 ******************************************************************************
 */

#ifndef DELAY_H
#define DELAY_H

//CPU Frequency
//#define F_CPU 16000000UL

// SysTivk registers
#define SYSTICK_BASE 0xE000E010
#define STK_CTRL_OFFSET 0x00
#define STK_LOAD_OFFSET 0x04
#define STK_VAL_OFFSET 0x08

// SysTick bits
#define STK_EN (1 << 0)
#define STK_TICKINT (1 << 1)
#define STK_CLK (1 << 2)
#define STK_COUNTFLAG (1 << 16)

// Function prototypes
void delayS(int s);
void delayMS(int delay);
void delayUS(int delay);

#endif
