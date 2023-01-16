/**
 ******************************************************************************
 * @file    console.c
 * @author  Sydney Balboni
 * @version V1.0
 * @brief   Provides functionality the console application
 ******
 */

#include <stdio.h>
#include "uart_driver.h"
#include <string.h>
#include <inttypes.h>

static void readMemoryWord(uint32_t* ptr);
static void writeMemoryWord(uint32_t* ptr, uint32_t value);
static void dumpMemory(uint8_t*, int);
static void prompt(void);
static void help(void);
static void invalidInput(void);

/**
 * Writes the initial prompt to the console
*/
void initialPrompt(void)
{
    printf("\n\n\n\n\n\n\n\n\n\nWelcome to the basic system control application.\n\n");
    prompt();
    return;
}

/**
 * Writes a smaller prompt to the console
 * to remind the user what to do
*/
static void prompt(void) 
{
    printf("\nType one of the following commands:\n"
    			"	Read memory word:   rmw [address]\n"
                "	Write memory word:  wmw [address] [value]\n"
                "	Memory dump word:   dm [address] [number of bytes]\n"
                "	Help:               help\n\n");

    return;
}

/**
 * Accepts the input from the main function
*/
void acceptInput(char* str)
{
    char command[5];
    unsigned int address;
    char values[99];

    sscanf(str, "%s %x %s", command, &address, values);

    uint32_t value = strtoul(values, NULL, 0);

    if (address % 4)
    {
        printf("Please use address starting on a word boundary. ");
        command[0] = 0;
    }

    uint32_t* const ptr = (uint32_t*) address;

    if (strcmp(command, "rmw") ==0)
    {
        readMemoryWord(ptr);
    } 
    else if (strcmp(command, "wmw") == 0)
    {
        writeMemoryWord(ptr, value);
    } 
    else if (strcmp(command, "dm") == 0)
    {
        dumpMemory((uint8_t*)ptr, value);
    } 
    else if (strcmp(command, "help") == 0)
	{
    	help();
	}
    else 
    {
        invalidInput();
    } 

    return;
}

/**
 * Accepts a memory address and 
 * prints the value stored at 
 * that address
 * 
 * @param ptr address
*/
static void readMemoryWord(uint32_t* ptr)
{
	printf("%#X:	%#X	   %d\n", (unsigned int) ptr, (int)*ptr, (int)*ptr);
    return;
}

/**
 * Accepts a memory address and a value
 * and stores the value at that 
 * memory address
 * 
 * @param ptr address
 * @param value value
*/
static void writeMemoryWord(uint32_t* ptr, uint32_t value)
{
    *ptr = (uint32_t) value;
    printf("%#X:	%#.8X	   %d\n", (unsigned int) ptr, (int)*ptr, (int)*ptr);\
    return;
}


/**
 * Accepts an address and a number of 
 * bytes and dumps the bytes stored at
 * the address
 * 
 * @param ptr address
 * @param bytes number of bytes to dump
*/
static void dumpMemory(uint8_t* ptr, int bytes)
{
	 printf("%#X: ", (unsigned int) ptr);

	 for (int i = 0; i < bytes; ++i)
	 {
		 if (((i % 16 ) == 0) && (i!=0))
		 {
			 printf("\n%#X: ", (unsigned int)(ptr));
		 }
		 printf("%02X ", (char)*ptr);
		 ++ptr; 
	 }
	 return;
}

/**
 * Print out the help paragraph
*/
static void help()
{
	prompt();
}


/**
 * Tells the user that their input is invalid
*/
static void invalidInput()
{
    printf("Please follow correct instruction format.\n\n");
    return;
}
