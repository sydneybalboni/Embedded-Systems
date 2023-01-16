/**
 ******************************************************************************
 * @file    lcd.c
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Provides functionality for using the lcd display on the
 *          Embedded Systems board
 ******************************************************************************
 */

#include <stdio.h>
#include "lcd.h"
#include "delay.h"
#include <string.h>

static void portInit(void);
static void writeExec(char);
static void writeData(char);
static void writeInstr(char);

/**
 * Initializes the lcd display
*/
void lcdInit()
{
    portInit();

    delayMS(40);

    // Write function set
    writeInstr(FUNCTION_SET);
    delayUS(40);

    // Write function set
    writeInstr(FUNCTION_SET);
    delayMS(40);

    // Write display on/off control
    writeInstr(DISPLAY_ON);
    delayUS(40);
    
    // Write display clear
    writeInstr(DISPLAY_CLEAR);
    delayUS(40);

    // Write entry mode set
    writeInstr(ENTRY_SET_MODE);
    delayMS(40);

    return;
}

/**
 * Clears the lcd display
*/
void lcdClear()
{
    writeInstr(DISPLAY_CLEAR);
    return;
}

/**
 * Moves lcd cursor to home 
*/
void lcdHome() 
{
    writeInstr(DISPLAY_HOME);
    return;
}

/**
 * Sets the position of the lcd cursor
 * 
 * @param row row of position
 * @param col column of position
*/
void lcdSetPosition(int row, int column)
{
    int data = (((row << 6) | column) | 1 << 7);
    writeInstr(data);

    return;
}

/**
 * Prints a character to the lcd display
 * 
 * @param character character to print
*/
void lcdPrintChar(char character)
{
    writeData(character);
    return;
}

/**
 * Prints a string to the lcd display
 * 
 * @param ptr ptr to string
 * @return number of characters printed
*/
int lcdPrintString(char* ptr)
{
    int count = 0;

    while (*ptr != '\0')
    {
        lcdPrintChar(*ptr);
        ptr++;
        count++;
    }
    return count;
}

/**
 * Prints a number to the lcd display
 * 
 * @param num number to print
 * @return number of characters printed
*/
int lcdPrintNum(int num) 
{
    // Create string
    char str[16];
    
    // Format number to string
    sprintf(str, "%d", num);

    return lcdPrintString(str);
}

/**
 * Initializes ports
*/
static void portInit() 
{
    // Enable clocks
    volatile uint32_t *const RCC_AHB1ENR = (uint32_t *)(RCC_BASE + AHB1ENR_OFFSET);
    *RCC_AHB1ENR |= (GPIOC_EN | GPIOA_EN);

    // Set PA4-PA11 to output
    volatile uint32_t *const GPIOA_MODER = (uint32_t *)(GPIOA_BASE + MODER_OFFSET);
    *GPIOA_MODER &= ~(GPIOA_CLEAR_MASK);
    *GPIOA_MODER |= SET_PA_PINS_OUTPUT; 

    // Set PC8-PC10 to output
    volatile uint32_t *const GPIOC_MODER = (uint32_t *)(GPIOC_BASE + MODER_OFFSET);
    *GPIOC_MODER &= ~(GPIOC_CLEAR_MASK);
    *GPIOC_MODER |= SET_PC_PINS_OUTPUT;

    return;
}

/**
 * Executes a write to lcd display
*/
static void writeExec(char data)
{
    // Clear output pins
    volatile uint32_t *const GPIOA_BSRR = (uint32_t *)(GPIOA_BASE + BSRR_OFFSET);
    *GPIOA_BSRR |= CLEAR_DATA_PINS;

    // Apply data to port A
    *GPIOA_BSRR |= (data << 4);

    // Set RW low and E high
    volatile uint32_t *const GPIOC_BSRR = (uint32_t *)(GPIOC_BASE + BSRR_OFFSET);
    *GPIOC_BSRR |= (RW_CLEAR | E_SET);

    delayUS(460);

    // Set E low
    *GPIOC_BSRR |= E_CLEAR;

    delayMS(1);

    return;
}

/**
 * Writes data to the lcd display
*/
static void writeData(char data)
{
    // Set RS high
    volatile uint32_t *const GPIOC_BSRR = (uint32_t *)(GPIOC_BASE + BSRR_OFFSET);
    *GPIOC_BSRR |= (RS_SET);

    // Write data
    writeExec(data);

    return;
}

/**
 * Writes instruction to the lcd display
*/
static void writeInstr(char data)
{
    // Set RS low 
    volatile uint32_t *const GPIOC_BSRR = (uint32_t *)(GPIOC_BASE + BSRR_OFFSET);
    *GPIOC_BSRR |= (RS_CLEAR);

    // Write instruction
    writeExec(data);

    return;
}
