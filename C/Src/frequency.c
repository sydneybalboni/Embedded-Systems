/**
 ******************************************************************************
 * @file    frequency.c
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Provides functionality for reading a frequency
*******************************************************************************
 */

#include <stdio.h>
#include "uart_driver.h"
#include "frequency.h"
#include <string.h>
#include <stdint.h>
#include "console.h"

static volatile RCCr* const RCC = (RCCr*)0x40023800;
static volatile TIMx* const TIM2 = (TIMx*)0x40000000;
static volatile uint32_t* const NVIC_ISER = (uint32_t*)0xE000E100;
static volatile GPIO* const GPIOA = (GPIO*)0x40020000;


static FREQUENCY freqy; 
static uint32_t samples[11];  
static volatile int32_t periods[10]; 
static int numSamples; 

static void TIM2Init(void);

void getFreqy()
{
    numSamples = 0;

    freqy.value = 0;
    freqy.min = ~(0x00000000);
    freqy.max = 0;
    unsigned int freqySum = 0;
    
    // Setup TIM2
    TIM2Init();

    // Wait for samples to be collected by ISR
    while (numSamples < 11) {asm("nop");}

    int i = 0;

    while (i < 10)
    {
        periods[i] = (16000000/(samples[i + 1] - samples[i]));
        if (periods[i] < freqy.min)
        {
            freqy.min = periods[i];
        }
        if (periods[i] > freqy.max)
        {
            freqy.max = periods[i];
        }
        freqySum += periods[i];
        ++i;
    }

    freqy.value = (freqySum/10);

    char* string = "Frequency values: ";
    
    printf("\n%s\n", string);

    for (int i = 0; i < 10; i++)
    {
        printf("    %d\n", (int) periods[i]);
    }

    printf("\nAvg: %d\n", (int) freqy.value);
    printf("Min:  %d\n", (int) freqy.min);
    printf("Max:  %d\n", (int) freqy.max);

    return;
} 

void TIM2Init()
{
    // Enable clock to timer
    RCC->APB1ENR |= (1<<0);
    RCC->AHB1ENR |= (1<<0);

    // Select active input
    TIM2->CCMR1 &= ~(0b11);
    TIM2->CCMR1 = CC1S;

    // Set PA15 to ALTFUN
    GPIOA->MODER &= ~(0b11 << 30);
    GPIOA->MODER |= (0b10 << 30);
    GPIOA->AFRH &= ~(0b1111 << 28);
    GPIOA->AFRH |= (0b0001 << 28); 

    // Set to maximum value
    TIM2->ARR = MAX_VALUE;

    // Select edge of active transition
    TIM2->CCER &= ~(0b101 << 1);
    TIM2->CCER |= CC1EN;

    // Enable interrupt
    NVIC_ISER[0] = 1<<28;

    TIM2->DIER |= CC1IE;
    
    // Turn on timer
    TIM2->CR1 |= CEN;
}

void TIM2_IRQHandler(void)
{
    TIM2->SR =0;
    if (numSamples < 12)
    {
        samples[numSamples] = TIM2->CCR1;

        ++numSamples;

        return;
    }
}