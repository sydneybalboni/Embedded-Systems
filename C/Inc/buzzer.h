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
#include <stdio.h>

// RCC registers
#define RCC_BASE 0x40023800
#define AHB1ENR_OFFSET 0x30
#define APB1ENR_OFFSET 0x40


// Timer constants
#define ALTFUN 0b10
#define AF2 0b0010
#define CC1EN 1
#define HALF_PERIOD 625000
#define TOGGLE 0b011
#define EIGHTH_NOTE 4000000UL
#define CPU_FREQUENCY 16000000UL
#define CEN 1

// Note frequencies
#define C3 65
#define CSHARP3 139
#define D3 147
#define DSHARP3 156
#define E3 165
#define F3 175
#define FSHARP3 185
#define G3 196
#define GSHARP3 208
#define A3 220
#define ASHARP3 233
#define B3 246
#define C4 262
#define CSHARP4 277
#define D4 294
#define DSHARP4 311
#define E4 330
#define F4 349
#define FSHARP4 370
#define G4 392
#define GSHARP4 415
#define A4 440
#define ASHARP4 466
#define B4 494
#define REST 0
#define B5 125

// Note struct
typedef struct
{   
    int frequency;
    float duration;
} NOTE;

// Prototypes
void buzzerInit(void);
void songSelect(char*);

#endif