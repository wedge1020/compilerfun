# TUTORIAL: LET'S BUILD A COMPILER!

Originally by: Jack W. Crenshaw, Ph.D. (August 19, 1988)

Copyright (C) 1988 Jack W. Crenshaw. All rights reserved.

Updated and reformatted in github-style  markdown, adding in variants for
BASH and C alongside the originally-provided Pascal code.

# PART V, PREDENDUM A: REGISTER MANAGEMENT

## TABLE OF CONTENTS

  * [REGISTER MANAGEMENT](#REGISTER-MANAGEMENT)

## REGISTER MANAGEMENT

Here we  will take an excursion  from the current tutorial,  investing in
some infrastructure to facilitate our selection and loop endeavours.

As  was explored  in part  4 of  the tutorial  with the  variable-related
symbol  table, there  exists a  growing need  for register  management as
well, especially as the details of constructs being implemented increases
in complexity.

Relying on the same  base register for storing all our  data seems like a
recipe for  disaster, plus,  with multiple  registers available,  why not
make  them all  available for  potential  use? That  is the  aim of  this
section.

### Pascal variant: declare our global `RegTable` array

Since  the M68000  the Pascal  side of  the tutorial  targets has  8 data
registers (D0 through D7), we will  make an 8-element array to manage the
registers.

In the  beginning of your  code, just  after the declaration  of variable
`Look`, insert the line:

```
    RegTable: Array[0..7] of integer;
```

### C variant: declare our global `regtable` array

Since the  Vircon32 the  C side  of the tutorial  targets has  16 general
purpose registers (R0  through R15), we could make a  16-element array to
manage the registers. But, since some of the registers have specific uses
in various situations  (such as string operations  and stack operations),
we  essentially  only  have  R0-R10,  or  11  general  purpose  registers
available for use.

So, an 11 element array will be declared.

In the  beginning of your  code, just  after the declaration  of variable
`lookahead`, insert the line:

```
uint8_t  regtable[11];
```

### BASH variant: declare our global `regtable` array and file

Since the  Vircon32 the  C side  of the tutorial  targets has  16 general
purpose registers (R0  through R15), we could make a  16-element array to
manage the registers. But, since some of the registers have specific uses
in various situations  (such as string operations  and stack operations),
we  essentially  only  have  R0-R10,  or  11  general  purpose  registers
available for use.

So, an 11 element array will be declared.

In the  beginning of your  code, just  after the declaration  of variable
`lookahead` and generation of the `TMPFILE`, add the lines:

```
REGLIST="R0 R1 R2 R3 R4 R5 R6 R7 R8 R9 R10"
declare -A regtable
echo -n                                            >  ${TMPFILE}.regtable
```

We also need to initialize the array, so add this procedure:

### Pascal variant: implementing `InitRegTable` procedure

```
{---------------------------------------------------------------}
{ Initialize the Register Array }

procedure InitRegTable;
var i: char;
begin
    for i := 0 to 7 do
        RegTable[i] := 0;
end;
{---------------------------------------------------------------}
```

### C variant: implementing `initregtable()` function

```
//////////////////////////////////////////////////////////////////////////////
//
// initregtable(): initialize the register array
//
void initregtable (void)
{
    int32_t  index       = 0;

    for (index = 0; index < 11; index++)
    {
        regtable[index]  = 0;
    }
}
```

### BASH variant: implementing `initregtable()` function

Since  we can  make  use  of associative  arrays  in  BASH, allowing  our
register  names  to be  our  array  element  access  point, we  will  use
`REGLIST` to drive our loop:

```
##############################################################################
##
## initregtable(): initialize the register array
##
function initregtable ()
{
    for reg in ${REGLIST}; do
        regtable["${reg}"]=0
    done
    echo "${regtable[*]}"                             >  ${TMPFILE}.regtable
}
```

You must also insert a call to `InitRegTable`, in procedure `Init`.

Next, we  require a means  of querying the  `RegTable` array to  grab the
next available register for use. Since  we initialized each element to 0,
that will correspond with register availability, whereas a non-zero value
(1 in our case) will indicate the register is allocated for use.

### Pascal variant: implementing `GetRegister` function

Get the next available register. If none are available, return a -1.

```
{---------------------------------------------------------------}
{ Obtain available Register from the Register Array }

function GetRegister: integer;
var i: integer;
begin
    for i := 0 to 7 do
        if RegTable[i] = 0 then break;
    if i = 8 then i := -1;
    GetRegister := i;
end;
{---------------------------------------------------------------}
```

### C variant: implementing `getregister()` function

```
////////////////////////////////////////////////////////////////////////////
//
// getregister(): obtain available register from the register array (if
//                no register is available return a -1)
//
uint8_t  getregister (void)
{
    int32_t  index           = 0;
    int32_t  result          = -1;

    for (index = 0; index < 11; index++)
    {
        if (regtable[index] == 0)
        {
            result           = index;
            break;
        }
    }

    return (result);
}
```

### BASH variant: implementing `getregister()` function

```
##############################################################################
##
## getregister(): obtain available register from the register array (if
##                no register is available return the string "none")
##
function getregister()
{
    result="none"

    for reg in ${REGLIST}; do
        if [ "${regtable[${reg}]}" -eq 0 ]; then
            result="${reg}"
            break;
        fi
    done

    echo "${result}"
}
```

We also  need a way to  deallocate a register  once we are done  with it.
Following some of the naming conventions in this tutorial we will do that
in a procedure  called `PutRegister`, which will take the  register as an
argument (the index value) and reset  it to 0, indicating it is available
for future use.

### Pascal variant: implementing `PutRegister` procedure

```
{---------------------------------------------------------------}
{ Clear indicated Register from use in the Register Array }

procedure PutRegister(i: integer);
begin
    RegTable[i] := 0;
end;
{---------------------------------------------------------------}
```

### C variant: implementing `putregister()` function

```
//////////////////////////////////////////////////////////////////////////////
//
// putregister(): clear indicated register from use in the register array
//
void putregister (uint8_t  reg)
{
    regtable[reg]  = 0;
}
```

### BASH variant: implementing `putregister()` function

```
##############################################################################
##
## putregister(): clear indicated register from use in the register array
##
function putregister()
{
    reg="${1}"
    regtable[${reg}]=0
    echo "${regtable[*]}"                             >  ${TMPFILE}.regtable
}
```
