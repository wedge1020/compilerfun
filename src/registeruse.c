#include "registeruse.h"

void initregs (void)
{
    int32_t  index     = 0;

    registers      = (regidx *) malloc (sizeof (regidx) * NUM_REGISTERS);
    if (registers == NULL)
    {
        fprintf (stderr, "[initregs] could not malloc for registers!\n");
        exit (3);
    }

    for (index = 0; index < NUM_REGISTERS; index++)
    {
        registers[index].name  = (uint8_t *) malloc (sizeof (uint8_t) * 4);
        registers[index].id    = index;
        registers[index].attr  = REG_AVAILABLE    |
                                 REG_ATTR_GENERAL |
                                 REG_ATTR_INTEGER |
                                 REG_ATTR_FLOAT;
    }
    registers[11].alias        = (uint8_t *) malloc (sizeof (uint8_t) * 4);
    registers[12].alias        = (uint8_t *) malloc (sizeof (uint8_t) * 4);
    registers[13].alias        = (uint8_t *) malloc (sizeof (uint8_t) * 4);
    registers[14].alias        = (uint8_t *) malloc (sizeof (uint8_t) * 4);
    registers[15].alias        = (uint8_t *) malloc (sizeof (uint8_t) * 4);

    strncpy ((char *) registers[0].name,  "R0",  3);
    strncpy ((char *) registers[1].name,  "R1",  3);
    strncpy ((char *) registers[2].name,  "R2",  3);
    strncpy ((char *) registers[3].name,  "R3",  3);
    strncpy ((char *) registers[4].name,  "R4",  3);
    strncpy ((char *) registers[5].name,  "R5",  3);
    strncpy ((char *) registers[6].name,  "R6",  3);
    strncpy ((char *) registers[7].name,  "R7",  3);
    strncpy ((char *) registers[8].name,  "R8",  3);
    strncpy ((char *) registers[9].name,  "R9",  3);
    strncpy ((char *) registers[10].name, "R10", 4);
    strncpy ((char *) registers[11].name, "R11", 4);
    strncpy ((char *) registers[12].name, "R12", 4);
    strncpy ((char *) registers[13].name, "R13", 4);
    strncpy ((char *) registers[14].name, "R14", 4);
    strncpy ((char *) registers[15].name, "R15", 4);

    strncpy ((char *) registers[11].alias, "CR", 4);
    strncpy ((char *) registers[12].alias, "SR", 4);
    strncpy ((char *) registers[13].alias, "DR", 4);
    strncpy ((char *) registers[14].alias, "BP", 4);
    strncpy ((char *) registers[15].alias, "SP", 4);

    for (index = 11; index <= 13; index++)
    {
        registers[index].attr   = REG_ATTR_STRING;
        registers[index].state  = REG_UNAVAILABLE;
    }

    for (index = 14; index <= 15; index++)
    {
        registers[index].attr   = REG_ATTR_STACK;
        registers[index].state  = REG_UNAVAILABLE;
    }
}

regidx *getreg    (uint8_t  attributes)
{
    int32_t  index              = 0;
    int32_t  attr               = 0;
    regidx  *selected_register  = NULL;

    for (index = 0; index < NUM_REGISTERS; index++)
    {
        if (registers[index].state                 == REG_AVAILABLE)
        {
            for (attr = REG_ATTR_GENERAL; attr <= REG_ATTR_FLOAT; attr *= 2)
            {
                if ((registers[index].attr & attr) == (attributes & attr))
                {
                    selected_register               = (registers+index);
                    registers[index].state          = REG_ALLOCATED;
                }
                else
                {
                    selected_register               = NULL;
                    registers[index].state          = REG_AVAILABLE;
                }
            }
        }
    }

    return (selected_register);
}

void    freereg   (regidx *oldreg)
{
    if (oldreg -> state != REG_UNAVAILABLE)
    {
        oldreg -> state  = REG_AVAILABLE;
    }
}

void    clearregs (void)
{
    int32_t  index                  = 0;
    
    for (index = 0; index < NUM_REGISTERS; index++)
    {
        if (registers[index].state != REG_UNAVAILABLE)
        {
            registers[index].state  = REG_AVAILABLE;
        }
    }
}
