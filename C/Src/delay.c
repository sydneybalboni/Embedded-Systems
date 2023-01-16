/**
 ******************************************************************************
 * @file    delay.c
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Delay functionality for the Embedded Systems board utilizing the
 *          SysTic timer
 ******************************************************************************
 */

#include <stdio.h>
#include <inttypes.h>
#include "delay.h"


/**
 * Initializes the SysTick timer
*/
static void delayInit(int ticks)
{
    volatile uint32_t *const STK_LOAD = (uint32_t *)(SYSTICK_BASE + STK_LOAD_OFFSET);
    *STK_LOAD = ticks;

    volatile uint32_t *const STK_VAL = (uint32_t *)(SYSTICK_BASE + STK_VAL_OFFSET);
    *STK_VAL = 0;

    volatile uint32_t *const STK_CTRL = (uint32_t *)(SYSTICK_BASE + STK_CTRL_OFFSET);
    *STK_CTRL = (STK_CLK | STK_EN);

    *STK_CTRL &= ~STK_TICKINT;
    return;
}

/**
 * Delays for n seconds
 * 
 * @param s number of n seconds
*/
void delayS(int s)
{
    delayInit((F_CPU / 1) * s);

    volatile uint32_t *const STK_CTRL = (uint32_t *)(SYSTICK_BASE + STK_CTRL_OFFSET);

    while ((*STK_CTRL & STK_COUNTFLAG) == 0)
    {
        __asm("nop");
    }

    *STK_CTRL &= ~STK_EN;

    return;
}

/**
 * Delays for n milliseconds
 * 
 * @param ms number of n milliseconds
*/
void delayMS(int ms)
{
    delayInit((F_CPU / 1000) * ms);

    volatile uint32_t *const STK_CTRL = (uint32_t *)(SYSTICK_BASE + STK_CTRL_OFFSET);

    while ((*STK_CTRL & STK_COUNTFLAG) == 0)
    {
        __asm("nop");
    }

    *STK_CTRL &= ~STK_EN;

    return;
}

/**
 * Delays for n microseconds
 * 
 * @param us number of n microseconds
*/
void delayUS(int us)
{
    delayInit((F_CPU / 1000000) * us);

    volatile uint32_t *const STK_CTRL = (uint32_t *)(SYSTICK_BASE + STK_CTRL_OFFSET);

    while ((*STK_CTRL & STK_COUNTFLAG) == 0)
    {
        __asm("nop");
    }

    *STK_CTRL &= ~STK_EN;

    return;
}
