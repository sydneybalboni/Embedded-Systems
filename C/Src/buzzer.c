/**
 ******************************************************************************
 * @file    buzzer.c
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Provides functionality for the Embedded Systems board buzzer
*******************************************************************************
 */

#include <stdio.h>
#include "buzzer.h"
#include <string.h>
#include <inttypes.h>

void notesInit(void);
void playNote(void)

volatile TIMx* const TIM3 = (TIMx*) 0x40000400;
volatile GPIOx* const GPIOB = (GPIOx*) 0x40020400

/**
 * Initializes the buzzer
*/
void buzzerInit()
{
    volatile uint32_t* const RCC_AHB1ENR = (uint32_t*) (RCC_BASE + AHB1ENR_OFFSET);

    // Turn on port and TIM3
    *RCC_AHB1ENR |= ((1<<0)|(1<<1))

    // Configure PB4 for alternate function
    GPIOB.MODER &= ~(0b11<<8)
    GPIOB.MODER |= (ALTFUN<<8);

    // Configure alternate function
    GPIOB.AFRL &= ~(0b1111<<16);
    GPIOB.AFRL |= (AF2<<16);
     
    // Set half-period count
    TIM3.ARR = HALF_PERIOD;
    TIM3.CCR1 = HALF_PERIOD;

    // Set output mode to "toggle on matched"
    TIM3.CCMR1 &= ~(0b111<<4);
    TIM3.CCMR1 |= (TOGGLE<<4);

    // Enable output 
    TIM3.CCER &= ;
    TIM3.CCER |= ;

    // Enable counter
}

/**
 * @todo
*/
void playSong()
{

}

/**
 * Initialize notes
*/
void notesInit()
{

}