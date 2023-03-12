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
#include "delay.h"
#include "regs.h"
#include <string.h>
#include <inttypes.h>

static void playNote(int, float);
static void playSong(NOTE[]);
static void playBackgroundSong(NOTE[]);
static void playNoteBackground(NOTE);

static volatile RCCr* const RCC = (RCCr*)0x40023800;
static volatile TIMx* const TIM3 = (TIMx*)0x40000400;
static volatile GPIO* const GPIOB = (GPIO*)0x40020400;
static volatile uint32_t* const NVIC_ISER = (uint32_t*)0xE000E100;

// Note count to pass to ISR
static uint32_t noteCount;

// Flag to indicate a song is playing
static unsigned int isPlayingSong;

// Keeps track of the index of the current note
static unsigned int currentNote;

// Pointer to which song to play
static NOTE* songPtr;

static NOTE HARRY_POTTER[] = {{B5, 2}, {E3, 3}, {G3, 1}, {F3, 2}, {E3, 4}, {B3, 2}, {A3, 6}, 
    {F3, 6}, {E3, 3}, {G3, 1}, {F3, 2}, {DSHARP3, 4}, {F3, 2}, {B5, 6}, {REST, 4}, {B4, 2}, {E3, 3}, 
    {G3, 1}, {F3, 2}, {E3, 4}, {B3, 2}, {D3, 4}, {CSHARP3, 2}, {C3, 4}, {GSHARP3, 2}, {C3, 3}, {B3, 1}, 
    {ASHARP3, 2}, {B4, 4}, {G3, 2}, {E3, 6}, {-1, -1}};

static NOTE SWEET_CHILD_OF_MINE[] = {{D4, 1}, {D3, 1}, {A3, 1}, {D4, 1}, {G3, 1}, {D4, 1}, {F3, 1}, 
    {D4, 1},  {REST, 0.2}, {D4, 1}, {D3, 1}, {A3, 1}, {D4, 1}, {G3, 1}, {D4, 1}, {F3, 1}, {D4, 1}, 
    {REST, 0.2}, {D4, 1}, {D3, 1}, {A3, 1}, {D4, 1}, {G3, 1}, {D4, 1}, {F3, 1}, {D4, 1}, {REST, 0.2}, 
    {D4, 1}, {D3, 1}, {A3, 1}, {D4, 1}, {G3, 1}, {D4, 1}, {F3, 1}, {D4, 1}, {REST, 0.2}, {D4, 1}, {D3, 1}, 
    {A3, 1}, {D4, 1}, {G3, 1}, {D4, 1}, {F3, 1}, {D4, 1}, {REST, 0.2}, {D4, 1}, {D3, 1}, {A3, 1}, {D4, 1}, 
    {G3, 1}, {D4, 1}, {F3, 1}, {D4, 1}, {REST, 0.2}, {D4, 1}, {D3, 1}, {A3, 1}, {D4, 1}, {G3, 2}, {F3, 2}, 
    {-1, -1}};

/**
 * Initializes the buzzer
*/
void buzzerInit()
{
    // Turn on port and TIM3
    RCC->AHB1ENR |= (1<<1);
    RCC->APB1ENR |= (1<<1);

    // Configure PB4 for alternate function
    GPIOB->MODER &= ~(0b11<<8);
    GPIOB->MODER |= (ALTFUN<<8);

    // Configure alternate function
    GPIOB->AFRL &= ~(0b1111<<16);
    GPIOB->AFRL |= (AF2<<16);
     
    // Set half-period count
    TIM3->ARR |= 625000;
    TIM3->CCR1 |= 625000;
    
    // Set output mode to "toggle on matched"
    TIM3->CCMR1 &= ~(0b111<<4);
    TIM3->CCMR1 |= (TOGGLE<<4);

    // Enable interrupt
    NVIC_ISER[0] = 1<<29;
    TIM3->DIER = 1;

    // Enable output 
    TIM3->CCER |= CC1EN;
    return;
}

/**
 * Takes user input for which song to play
 * then plays the song
 * 
 * @param song the song to be played
*/
void songSelect(char* song)
{
    if (strcmp(song, "harry_potter") == 0)
    {
        playSong(HARRY_POTTER);
    } 
    else if (strcmp(song, "sweet_child_of_mine") == 0)
    {
        playSong(SWEET_CHILD_OF_MINE);
    }
    if (strcmp(song, "harry_potter_background") == 0)
    {
        playBackgroundSong(HARRY_POTTER);
    } 
    else if (strcmp(song, "sweet_child_of_mine_background") == 0)
    {
        playBackgroundSong(SWEET_CHILD_OF_MINE);
    }
    return;
}

/**
 * Plays the song
 * 
 * @param song the song to play
*/
static void playSong(NOTE song[])
{
    if (isPlayingSong) {printf("Song is already playing.");}

    for (int i = 0; song[i].duration != -1; ++i)
    {
        playNote(song[i].frequency, song[i].duration);
    }
}

/**
 * Plays a song in the background
 * 
 * @param song the song to play
*/
static void playBackgroundSong(NOTE song[])
{
    isPlayingSong = 1;
    songPtr = song;
    currentNote = 0;
    playNoteBackground(songPtr[currentNote]);
    return;
}

/**
 * Plays a single note
 * 
 * @param frequency the note's frequency
 * @param duration the note's duration
*/
static void playNote(int frequency, float duration)
{
    // Set up timer to play note
    TIM3->ARR = 16000000UL/(2*frequency);
    TIM3->CCR1 = 16000000UL/(2*frequency);

    // Turn on counter 
    TIM3->CR1 |= CEN;

    delayMS(32*duration);

    // Turn off counter
    TIM3->CR1 &= ~(CEN);
    
    return;
}

/**
 * PLays a note in the timer interrupt
 * 
 * @param note the note to play
*/
static void playNoteBackground(NOTE note)
{
    // Quarter note is 4000000UL
    
    // 2*time*note
    noteCount = (EIGHTH_NOTE*note.duration)/(CPU_FREQUENCY/(2*note.frequency));
    
    // clock/(2*note)
    TIM3->ARR = CPU_FREQUENCY/(2*note.frequency);
    TIM3->CCR1 = CPU_FREQUENCY/(2*note.frequency);
    TIM3->CR1 = CEN;
}

void TIM3_IRQHandler(void)
{
    // Clear interrupt flag
    TIM3->SR = 0;

    --noteCount;

    if (noteCount == 0)
    {
        // Increment to next note
        ++currentNote;
        TIM3->CR1 = 0;
        playNoteBackground(songPtr[currentNote]);
    }

    if (songPtr[currentNote].duration == -1)
    {
        // Stop timer
        TIM3->CR1 = 0;
        isPlayingSong = 0;
        noteCount = 0;
    }
    
}

