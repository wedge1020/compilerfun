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
            exit (2);
        }

        tmp                 = tmp -> next;
    }

    tmp -> name             = (char *) malloc (sizeof (char) * strlen (name));
    tmp -> value            = value;
    tmp -> next             = NULL;
    memcpy (name, tmp -> name, strlen (name));

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
