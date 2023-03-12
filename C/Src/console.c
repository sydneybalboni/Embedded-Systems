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
#include "frequency.h"

static void readMemoryWord(uint32_t* ptr);
static void writeMemoryWord(uint32_t* ptr, uint32_t value);
static void dumpMemory(uint8_t*, int);
static void songPlay(char*);
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
    			"	Read memory word:           rmw [address]\n"
                "	Write memory word:          wmw [address] [value]\n"
                "	Memory dump word:           dm [address] [number of bytes]\n"
                "	Play Harry Potter:          harry_potter\n"
                "	Play Sweet Child of Mine:   sweet_child_of_mine\n"
                "	Help:                       help\n"
    			"        Play background             [song name]_background\n"
                "        Measure frequency           measure_freq\n"
                "        Collect wave                collect [amount] [rate]\n"
                "        Get wave                    getwave\n\n");

    return;
}

/**
 * Accepts the input from the main function
*/
void acceptInput(char* str)
{
    char command[30];
    char value1[99];
    char value2[99];

    sscanf(str, "%s %s %s", command, value1, value2);

    //uint32_t value = strtoul(value2, NULL, 0);

    // if ((address % 4) != 0)
    // {
    //     printf("Please use address starting on a word boundary. ");
    //     return;
    // }

    uint32_t* const ptr = (uint32_t*) strtoul(value1, NULL, 0);

    if (strcmp(command, "rmw") ==0)
    {
        readMemoryWord(ptr);
    } 
    else if (strcmp(command, "measure_freq") == 0)
    {
        getFreqy();
    }
    else if (strcmp(command, "wmw") == 0)
    {
        writeMemoryWord(ptr, ((uint32_t)strtoul(value2, NULL, 0)));
    } 
    else if (strcmp(command, "dm") == 0)
    {
        dumpMemory((uint8_t*) ptr, (int)strtoul(value2, NULL, 0));
    } 
    else if (strcmp(command, "help") == 0)
	{
    	help();
	}
    else if (strcmp(command, "collect") == 0)
    {   
        collectSamples((int)strtoul(value1, NULL, 0), (int)strtoul(value2, NULL, 0));
    }
    else if (strcmp(command, "harry_potter") == 0)
    {   
        songPlay(command);
    }
    else if (strcmp(command, "sweet_child_of_mine") == 0)
    {
        songPlay(command);
    }
    else if (strcmp(command, "getwave")== 0)
    {
        retrieveSamples();
    }
    else if (strcmp(command, "harry_potter_background")== 0)
    {   
        songPlay(command);
    }
    else if (strcmp(command, "sweet_child_of_mine_background")== 0)
    {
        songPlay(command);
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
 * Plays a requested song
 * 
 * @param song the song to be played
*/
static void songPlay(char* song)
{
	songSelect(song);
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
