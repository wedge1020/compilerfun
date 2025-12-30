#ifndef  _SYMBOLTABLE_H
#define  _SYMBOLTABLE_H

typedef int32_t (*func_t)(argnode *);

/* Update your func_t to accept the list */
//typedef int32_t (*variadic_func_t)(argnode *);

struct symbolrecord
{
    uint8_t             *name;
    int32_t              type;
    union
    {
        int32_t          intvalue;
        float            floatvalue;
        func_t           funcptr;
    } data;
    struct symbolrecord *next;
};
typedef struct symbolrecord symrec;

struct argumentnode
{
    int32_t              value;
    struct argumentnode *next;
};
typedef struct argumentnode argnode;

extern symrec *symboltable;
symrec *addsymbol (const uint8_t *, int32_t);
symrec *getsymbol (const uint8_t *);

#endif
