/**
 ******************************************************************************
 * @file    wave.c
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Provides functionality for digitizing a wave
 *******************************************************************************
 */

#include "wave.h"
#include "regs.h"
#include <inttypes.h>

static volatile RCCr *const RCC = (RCCr *)0x40023800;
static volatile TIMx *const TIM4 = (TIMx *)0x40000800;
static volatile GPIO *const GPIOB = (GPIO *)0x40020400;
static volatile ADCx *const ADC1 = (ADCx *)0x40012000;
static volatile uint32_t *const NVIC_ISER = (uint32_t *)0xE000E100;

static uint16_t *samples;

static int sampleCount;
static int count;

static int samplesAreCollected;
static int memoryIsFreed;

static float calculateVolts(int);
static void waveInit(int);

/**
 * TIM4 is used to pace the ADC interrupts
 * ADC channel 9 is connected to PB4
 * PB1 needs to be in analog mode
 */

int collectSamples(int numSamples, int rate)
{
    if (memoryIsFreed != 0)
    {
        return 0;
    }

    // Reset collection flag
    samplesAreCollected = 0;

    // Use malloc() to allocate dynamic memory
    samples = (uint32_t *)malloc(numSamples);
    if (samples == 0)
    {
        return 0;
    }

    sampleCount = numSamples;
    count = numSamples;

    // Configure ADC
    waveInit(rate);

    // Enable timer
    TIM4->CR1 = 1<<0; 

    return 1;
}

void retrieveSamples()
{
    if (samplesAreCollected == 0)
    {
        return;
    }
    
    memoryIsFreed = 0;

    printf("Wave samples:\n");

    for (int i = 0; i < count; i++)
    {
        printf("    %lu V\n", calculateVolts(samples[i]));
    }

    free(samples);
    return;
}

void waveInit(int rate)
{
    // Enable clock to peripherals
    RCC->AHB1ENR |= 1 << 1;
    RCC->APB2ENR |= 1 << 8;
    RCC->APB1ENR |= 1 << 2;

    // Set PB1 to analog
    GPIOB->MODER |= 0b11 << 2;

    // Turn on ADC
    ADC1->CR2 = 1 << 0; 

    // Set external trigger to TIM4 CC4
    ADC1->CR2 |= 0b1001 << 24;

    // Set external trigger to any edge 
    ADC1->CR2 |= 0b11 << 28;

    // Set the channel
    ADC1->SQR1 = 0; 
    ADC1->SQR3 = 9; 

    // Enable interrupt on EOC
    ADC1->CR1 = 1 << 5;

    // Enable interrupt for ADC1
    NVIC_ISER[0] = 1 << 18;

    // Setup TIM4
    TIM4->PSC = 15;
    TIM4->ARR = (1000000/rate) - 1;
    TIM4->CCR4 = 0;
    TIM4->CCMR2 |= 0b011 << 12; 

    // Enable CC4 generation
    TIM4->CCER = 1 << 12; 
}

float calculateVolts(int reading)
{
    return 3.3F*((float)reading/(float)4095);
}

void ADC_IRQHandler(void)
{
    if (sampleCount == 0)
    {
        TIM4->CR1 = 0; 
        ADC1->CR2 &= ~(1 << 0); 
        samplesAreCollected = 1;
        memoryIsFreed = 1;
    } 
    else
    {
        samples[sampleCount - 1] = ADC1->DR;
        --sampleCount;
    }
}