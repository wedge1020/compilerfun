#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "symboltable.h"

symrec *addsymbol (const uint8_t *name, int32_t value)
{
    symrec *tmp             = symboltable;

    if (tmp                == NULL)
    {
        tmp                 = (symrec *) malloc (sizeof (symrec) * 1);
        if (tmp            == NULL)
        {
            fprintf (stderr, "[addsymbol] Could not malloc() for symrec!\n");
            exit (2);
        }
        symboltable         = tmp;
    }
    else
    {
        while (tmp -> next != NULL)
        {
            tmp             = tmp -> next;
        }

        tmp -> next         = (symrec *) malloc (sizeof (symrec) * 1);
        if (tmp            == NULL)
        {
            fprintf (stderr, "[addsymbol] Could not malloc() for symrec!\n");
            exit (3);
        }

        tmp                 = tmp -> next;
    }

    fprintf (stdout, "[addsymbol] name length is: %lu\n", strlen ((const char *) name));
    tmp -> name             = (uint8_t *) calloc (strlen ((const char *) name) + 1, sizeof (uint8_t));
    if (tmp -> name        == NULL)
    {
        fprintf (stderr, "[addsymbol] Could not calloc() for tmp -> name!\n");
        exit (4);
    }
    tmp -> data.intvalue    = value;
    tmp -> next             = NULL;
    strncpy ((char *) tmp -> name, (const char *) name, strlen ((const char *) name));

    return (tmp);
}

symrec *getsymbol (const uint8_t *name)
{
    int32_t  chk  = 0;
    size_t   len  = 0;
    symrec  *tmp  = symboltable;
    while (tmp   != NULL)
    {
        len       = strlen ((const char *) name);
        chk       = strncmp ((const char *) name, (char *) tmp -> name, len);
        if (chk  == 0)
        {
            break;
        }

        tmp       = tmp -> next;
    }

    return (tmp);
}
