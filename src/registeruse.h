#ifndef   _REGISTERUSE_H
#define   _REGISTERUSE_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define  REG_ALLOCATED     0
#define  REG_AVAILABLE     1
#define  REG_UNAVAILABLE   2

#define  REG_ATTR_GENERAL  1
#define  REG_ATTR_INTEGER  2
#define  REG_ATTR_FLOAT    4
#define  REG_ATTR_STRING   8
#define  REG_ATTR_STACK   16

#define  NUM_REGISTERS    16

struct registerindex
{
    uint8_t *name;
    uint8_t *alias;
    uint8_t  id;
	uint8_t  attr;
	uint8_t  state;
};
typedef struct registerindex regidx;

extern regidx *registers;
void    initregs  (void);
regidx *getreg    (uint8_t);
void    freereg   (regidx *);
void    clearregs (void);

#endif // _REGISTERUSE_H
