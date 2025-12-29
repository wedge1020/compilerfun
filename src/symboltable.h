#ifndef  _SYMBOLTABLE_H
#define  _SYMBOLTABLE_H

struct symbolrecord
{
    uint8_t             *name;
    int32_t              type;
    union
    {
        int32_t          intvalue;
        float            floatvalue;
        //func_t           functionptr;
    } data;
    struct symbolrecord *next;
};
typedef struct symbolrecord symrec;

extern symrec *symboltable;
symrec *addsymbol (const uint8_t *, int32_t);
symrec *getsymbol (const uint8_t *);

#endif
