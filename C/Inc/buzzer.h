/**
 ******************************************************************************
 * @file    buzzer.h
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Provides defintions and prototypes for buzzer.c
 ******
*/

#ifndef BUZZER_H
#define BUZZER_H

#include <inttypes.h>

#define F_CPU 16000000UL

// RCC registers
#define RCC_BASE 0x40023800
#define AHB1ENR_OFFSET 0x30

// Constants
#define ALTFUN 0b10
#define AF2 0b0010
#define CC1EN 1

#define HALF_PERIOD 625000

#define TOGGLE 0b011

// Note struct
struct note
{
    int frequency;
    int duration;
}

// SysTick struct
typedef struct 
{
    uint32_t CTRL;
    uint32_t LOAD;
    uint32_t VAL;
    uint32_t CALIB;
} STK;

// GPIO struct
typedef struct 
{
    uint32_t MODER;
    uint32_t OTYPER;
    uint32_t OSPEEDER;
    uint32_t PUPDR;
    uint32_t IDR;
    uint32_t ODR;
    uint32_t BSRR;
    uint32_t LCKR;
    uint32_t AFRL;
    uint32_t AFRH;
} GPIOx; 

// TIM3 struct
typedef struct 
{
    uint32_t CR1;
    uint32_t CR2;
    uint32_t SMCR;
    uint32_t DIER;
    uint32_t SR;
    uint32_t EGR;
    uint32_t CCMR1;
    uint32_t CCMR2;
    uint32_t CCER;
    uint32_t CNT;
    uint32_t PSC;
    uint32_t ARR;
    uint32_t reserved1;
    uint32_t CCR1;
    uint32_t CCR2;
    uint32_t CCR3;
    uint32_t CCR4;
    uint32_t reserved2;
    uint32_t DCR;
    uint32_t DMAR;
    uint32_t OR;
} TIMx; 

// Prototypes
void buzzerInit(void);
void playSong(NOTE[] song);

#endif