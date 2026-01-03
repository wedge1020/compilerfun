# TUTORIAL: LET'S BUILD A COMPILER!

Originally by: Jack W. Crenshaw, Ph.D. (August 19, 1988)

Copyright (C) 1988 Jack W. Crenshaw. All rights reserved.

Updated and reformatted in github-style  markdown, adding in variants for
BASH and C alongside the originally-provided Pascal code.

# PART V(B): SELECTION LOGIC

## TABLE OF CONTENTS

  * [OVERVIEW](#OVERVIEW)
  * [THE IF STATEMENT](#THE-IF-STATEMENT)
  * [CONDITIONS](#CONDITIONS)
  * [ELSE CLAUSE](#ELSE-CLAUSE)
  * [CONCLUSION](#CONCLUSION)

## OVERVIEW

In  this subsection,  we  will look  at the  implementation  of the  `IF`
statement.

It is broken  out from the original  part 5 README in an  attempt to make
things more digestible.

## THE IF STATEMENT

With that bit of explanation out of the way, we're finally ready to begin
coding the IF-statement parser. In fact, we've almost already done it! As
usual, I'll  be using our  single-character approach, with  the character
'**i**' for  **IF**, and '**e**'  for **ENDIF**  (as well as  **END** ...
that  dual  nature  causes  no  confusion).  I'll  also,  for  now,  skip
completely the character for the branch condition, which we still have to
define.

The code for **DoIf** is:

### Pascal variant: implementing `DoIf` procedure

```
{--------------------------------------------------------------}
{ Recognize and Translate an IF Construct }

procedure Block; Forward;

procedure DoIf;
var L: string;
begin
    Match('i');
    L := NewLabel;
    Condition;
    EmitLn('BEQ ' + L);
    Block;
    Match('e');
    PostLabel(L);
end;
{--------------------------------------------------------------}
```

### C variant: implementing `doif()` function

```
//////////////////////////////////////////////////////////////////////////////
//
// doif(): recognize and translate an IF construct
//
void doif (void)
{
    uint8_t *labelstring  = NULL;
    uint8_t  str[32];

    match ('i');

    labelstring           = newlabel ();

    condition ();

    sprintf (str, "JT    R0,    %s", labelstring);
    emitline (str);

    block ();

    match ('e');

    postlabel (labelstring);
}
```

### BASH variant: implementing `doif()` function

```
##############################################################################
##
## doif(): recognize and translate an IF construct
##
function doif()
{
    match "i"
    labelstring=$(newlabel)
    condition
    emitline "JT    R0,    ${labelstring}"
    block
    match "e"
    postlabel "${labelstring}"
}
```

Add this routine to your program, and change **block** to reference it as
follows:

### Pascal variant: updating the `Block` procedure

```
{--------------------------------------------------------------}
{ Recognize and Translate a Statement Block }

procedure Block;
begin
    while not(Look in ['e']) do begin
        case Look of
            'i': DoIf;
            'o': Other;
        end;
    end;
end;
{--------------------------------------------------------------}
```

### C variant: updating the `block()` function

```
//////////////////////////////////////////////////////////////////////////////
//
// block(): recognize and translate a statement block
//
void block (void)
{
    while (lookahead != 'e')
    {
        switch (lookahead)
        {
            case 'i':
                doif ();
                break;

            case 'o':
                other ();
                break;
        }
    }
}
```

### BASH variant: updating the `block()` function

```
##############################################################################
##
## block(): recognize and translate a statement block
##
function block()
{
    lookahead=$(cat ${TMPFILE}.lookahead)
    while [ ! "${lookahead}" = "e" ]; do

        case "${lookahead}" in
            'i')
                doif
                ;;
            'o')
                other
                ;;
        esac
    done
}
```

## CONDITIONS

Notice the reference to  procedure **Condition**. Eventually, we'll write
a routine that  can parse and translate any Boolean  condition we care to
give  it. But  that's a  whole installment  by itself  (the next  one, in
fact). For now,  let's just make it  a dummy that emits  some text. Write
the following routine:

### Pascal variant: implementing the `Condition` procedure

```
{--------------------------------------------------------------}
{ Parse and Translate a Boolean Condition }
{ This version is a dummy }

Procedure Condition;
begin
    EmitLn('<condition>');
end;
{--------------------------------------------------------------}
```

### C variant: implementing the `condition()` function

```
//////////////////////////////////////////////////////////////////////////////
//
// condition(): parse and translate a boolean condition  (this version is
//              a  dummy)
//
void condition (void)
{
    emitline ("<condition>");
}
```

### BASH variant: implementing the `condition()` function

```
##############################################################################
##
## condition(): parse and translate a boolean condition  (this version is
##              a dummy)
##
function condition()
{
    emitline "<condition>"
}
```

Insert this procedure  in your program just before **DoIf**.  Now run the
program. Try a string like:

```
    aibece
```

As you can  see, the parser seems to recognize  the construct and inserts
the object code  at the right places.  Now try a set  of nested **IF**'s,
like:

```
    aibicedefe
```

## ELSE CLAUSE

It's starting to look real, eh?

Now that we have the general idea (and the tools such as the notation and
the procedures **NewLabel**  and **PostLabel**), it's a piece  of cake to
extend the parser to include other constructs. The first (and also one of
the trickiest) is to add the **ELSE** clause to **IF**. The BNF is

```
    IF <condition> <block> [ ELSE <block>] ENDIF
```

The tricky  part arises simply because  there is an optional  part, which
doesn't occur in the other constructs.

### M68000 details

The corresponding output code should be:

```
     <condition>
     BEQ L1
     <block>
     BRA L2
L1:  <block>
L2:  ...
```

This leads us to the following syntax-directed translation:

```
    IF
    <condition>    { L1 = NewLabel;
                     L2 = NewLabel;
                     Emit(BEQ L1) }
    <block>
    ELSE           { Emit(BRA L2);
                     PostLabel(L1) }
    <block>
    ENDIF          { PostLabel(L2) }
```

### Vircon32 details

The corresponding output code should be:

```
    <condition>
    JT    R0,    L1
    <block>
    JMP   L2
L1:  <block>
L2:  ...
```

This  leads us  to the  following syntax-directed  translation (in  C and
BASH):

```
    IF
    <condition>    { L1  = newlabel();  // BASH: L1=$(newlabel)
                     L2  = newlabel();  // BASH: L2=$(newlabel)
                     sprintf (str, "JT    R0,    %s", L1);
                     emit (str); }
    <block>
    ELSE           { sprintf (str, "JMP   %s", L2);
                     emit (str);
                     postlabel (L1); }
    <block>
    ENDIF          { postlabel (L2); }
```

Comparing this with the case for an *ELSE-less* **IF** gives us a clue as
to how to  handle both situations. The  code below does it.  (Note that I
use an '**l**' for the **ELSE**, since '**e**' is otherwise occupied):

### Pascal variant: updating `DoIf` procedure for `ELSE` clauses

```
{--------------------------------------------------------------}
{ Recognize and Translate an IF Construct }

procedure DoIf;
var L1, L2: string;
begin
    Match('i');
    Condition;
    L1 := NewLabel;
    L2 := L1;
    EmitLn('BEQ ' + L1);
    Block;
    if Look = 'l' then begin
        Match('l');
        L2 := NewLabel;
        EmitLn('BRA ' + L2);
        PostLabel(L1);
        Block;
    end;
    Match('e');
    PostLabel(L2);
end;
{--------------------------------------------------------------}
```

### C variant: updating `doif()` function for `ELSE` clauses

```
//////////////////////////////////////////////////////////////////////////////
//
// doif(): recognize and translate an IF construct
//
void doif (void)
{
    uint8_t *L1    = NULL;
    uint8_t *L2    = NULL;
    uint8_t  str[32];

    match ('i');
    condition ();

    L1             = newlabel ();

    sprintf (str, "JT    R0,    %s", L1);
    emitline (str);

    block ();

    if (lookahead == 'l')
    {
        match ('l');
        L2         = newlabel ();

        sprintf (str, "JMP   %s", L2);
        emitline (str);

        postlabel (L1);
        block ();
    }

    match ('e');
    postlabel (L2);
}
```

### BASH variant: updating `doif()` function for `ELSE` clauses

```
##############################################################################
##
## doif(): recognize and translate an IF construct
##
function doif()
{
    match "i"
    condition

    L1=$(newlabel)
    emitline "JT    R0,    ${L1}"

    block

    lookahead=$(cat ${TMPFILE}.lookahead)
    if [ "${lookahead}" = "l" ]; then
        match "l"

        L2=$(newlabel)
        emitline "JMP   ${L2}"

        postlabel "${L1}"
        block
    fi

    match "e"
    postlabel "${L2}"
}
```

There you have it. A complete  IF parser/translator, in 19/35/28 lines of
code.

Give it a try now.  Try something like:

```
    aiblcede
```

Did it work? Now,  just to be sure we haven't  broken the ELSE-less case,
try:

```
    aibece
```

Now try some nested **IF**'s. Try anything you like, including some badly
formed statements. Just remember that  '**e**' is not a legal "**other**"
statement.

## CONCLUSION

At this  point we  have the basic  framework for the  `IF` and  `ELSE` in
place,  deferring  actual  condition  evaluation  until  part  6  of  the
tutorial.

As we  will soon  see, this  provides the  foundation for  another useful
programming construct, the various loops we can utilize, coming up in the
next subsection.
