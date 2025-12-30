#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "symboltable.h"

symrec *addsymbol (char const *name, int value)
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

    fprintf (stdout, "[addsymbol] name length is: %lu\n", strlen (name));
    tmp -> name             = (char *) calloc (strlen (name) + 1, sizeof (char));
    if (tmp -> name        == NULL)
    {
        fprintf (stderr, "[addsymbol] Could not calloc() for tmp -> name!\n");
        exit (4);
    }
    tmp -> value            = value;
    tmp -> next             = NULL;
    strncpy (tmp -> name, (char *) name, strlen (name));

    return (tmp);
}

symrec *getsymbol (char const *name)
{
    int     chk  = 0;
    size_t  len  = 0;
    symrec *tmp  = symboltable;
    while (tmp  != NULL)
    {
        len      = strlen (name);
        chk      = strncmp (name, tmp -> name, len);
        if (chk == 0)
        {
            break;
        }

        tmp      = tmp -> next;
    }

    return (tmp);
}
