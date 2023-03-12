/**
 ******************************************************************************
 * @file    delay.h
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Provides prototypes and defintions for the frequency.c file
 ******************************************************************************
 */


#ifndef FREQUENCY_H
#define FREQUENCY_H

#include "regs.h"

typedef struct
{   
    unsigned int value;
    unsigned int min;
    unsigned int max;
} FREQUENCY;

void getFreqy(void);

// Timer constants
#define CEN 1
#define CC1EN 1
#define CC1NE 1
#define CC1S 0b01
#define CC1E 1
#define CC1IE (1<<1)
#define MAX_VALUE 0xFFFFFFFF
#define TICK_VALUE (double)62.5

#endif