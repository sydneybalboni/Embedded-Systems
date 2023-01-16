/**
 ******************************************************************************
 * @file    main.c
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Provides definitions and function prototypes for the lcd display
 *          api in the lcd.c file
 ******************************************************************************
 */

#ifndef LCD_H
#define LCD_H
#include <inttypes.h>

// RCC registers
#define RCC_BASE 0x40023800
#define AHB1ENR_OFFSET 0x30

// Commands
#define FUNCTION_SET 0x38
#define DISPLAY_ON 0x0F
#define DISPLAY_CLEAR 0x01
#define DISPLAY_HOME 0x02
#define ENTRY_SET_MODE 0x06

// GPIO registers
#define GPIOC_BASE 0x40020800
#define GPIOA_BASE 0x40020000
#define MODER_OFFSET 0x00
#define BSRR_OFFSET 0x18
#define IDR_OFFSET 0x10
#define GPIOC_EN (1 << 2)
#define GPIOA_EN (1 << 0)
#define GPIOA_CLEAR_MASK 0xFFFF00
#define GPIOC_CLEAR_MASK 0x3F0000

// Pins
#define SET_PA_PINS_OUTPUT 0x555500
#define SET_PC_PINS_OUTPUT 0x150000
#define CLEAR_DATA_PINS (0xFF << 20)

// Lcd control pins
#define E_SET (1 << 10)
#define RW_SET (1 << 9)
#define RS_SET (1 << 8)
#define E_CLEAR (1 << (10 + 16))
#define RW_CLEAR (1 << (9 + 16))
#define RS_CLEAR (1 << (8 + 16))

// Function prototypes
void lcdInit(void);
void lcdClear(void);
void lcdHome(void);
void lcdSetPosition(int row, int col);
void lcdPrintChar(char character);
int lcdPrintString(char* ptr);
int lcdPrintNum(int num);

#endif
