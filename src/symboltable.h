#ifndef  _SYMBOLTABLE_H
#define  _SYMBOLTABLE_H

struct symbolrecord
{
    char                *name;
    int                  value;
    struct symbolrecord *next;
};
typedef struct symbolrecord symrec;

symrec *symboltable;
symrec *addsymbol (char const *, int);
symrec *getsymbol (char const *);

#endif
