# TUTORIAL: LET'S BUILD A COMPILER!

Originally by: Jack W. Crenshaw, Ph.D. (August 19, 1988)

Copyright (C) 1988 Jack W. Crenshaw. All rights reserved.

Updated and reformatted in github-style  markdown, adding in variants for
BASH and C alongside the originally-provided Pascal code.

# PART V(C): LOOPS

## TABLE OF CONTENTS

  * [OVERVIEW](#OVERVIEW)
  * [THE WHILE STATEMENT](#THE-WHILE-STATEMENT)
  * [THE LOOP STATEMENT](#THE-LOOP-STATEMENT)
  * [REPEAT-UNTIL](#REPEAT-UNTIL)
  * [THE FOR LOOP](#THE-FOR-LOOP)
  * [THE DO STATEMENT](#THE-DO-STATEMENT)
  * [THE BREAK STATEMENT](#THE-BREAK-STATEMENT)
  * [CONCLUSION](#CONCLUSION)

## OVERVIEW

In this  subsection, we will  look at  the implementation of  the various
looping constructs.

It is broken  out from the original  part 5 README in an  attempt to make
things more digestible.

## THE WHILE STATEMENT

The next  type of  statement should  be easy, since  we already  have the
process down pat. The syntax I've chosen for the **WHILE** statement is:

```
    WHILE <condition> <block> ENDWHILE
```

I know,  I know, we don't  REALLY need separate kinds  of terminators for
each construct ... you can see that by the fact that in our one-character
version,  '**e**' is  used for  all  of them.  But I  also remember  MANY
debugging sessions in Pascal, trying to track down a wayward **END** that
the compiler obviously  thought I meant to put somewhere  else. It's been
my experience that specific and unique keywords, although they add to the
vocabulary of  the language, give a  bit of error-checking that  is worth
the extra work for the compiler writer.

Now, consider what the **WHILE** should be translated into. It should be:

### M68000 details

```
L1:  <condition>
     BEQ L2
     <block>
     BRA L1
L2:
```

As before, comparing the two  representations gives us the actions needed
at each point.

```
    WHILE          { L1 = NewLabel;
                     PostLabel(L1) }
    <condition>    { Emit(BEQ L2) }
    <block>
    ENDWHILE       { Emit(BRA L1);
                     PostLabel(L2) }
```

### Vircon32 details

```
L1:  <condition>
     JT    R0,    L2
     <block>
     JMP   L1
L2:
```

As before, comparing the two  representations gives us the actions needed
at each point:

```
    WHILE          { L1 = newlabel ();
                     postlabel (L1); }
    <condition>    { sprintf (str, "JT    R0,    %s", L2);
                     emit (str); }
    <block>
    ENDWHILE       { sprintf (str, "JMP   %s", L1);
                     emit (BRA L1);
                     postlabel (L2); }
```

The code follows immediately from the syntax:

### Pascal variant: implementing the `DoWhile` procedure

```
{--------------------------------------------------------------}
{ Parse and Translate a WHILE Statement }

procedure DoWhile;
var L1, L2: string;
begin
    Match('w');
    L1 := NewLabel;
    L2 := NewLabel;
    PostLabel(L1);
    Condition;
    EmitLn('BEQ ' + L2);
    Block;
    Match('e');
    EmitLn('BRA ' + L1);
    PostLabel(L2);
end;
{--------------------------------------------------------------}
```

### C variant: implementing the `dowhile()` procedure

```
//////////////////////////////////////////////////////////////////////////////
//
// dowhile(): parse and translate a WHILE statement
//
void dowhile (void)
{
    uint8_t *L1  = NULL;
    uint8_t *L2  = NULL;
    uint8_t  str[32];

    match ('w');

    L1           = newlabel ();
    L2           = newlabel ();

    postlabel (L1);
    condition ();

    sprintf (str, "JT    R0,    %s", L2);
    emitline (str);

    block ();

    match ('e');

    sprintf (str, "JMP   %s", L1);
    emitline (str);

    postlabel (L2);
}
```

### BASH variant: implementing the `dowhile()` procedure

```
##############################################################################
##
## dowhile(): parse and translate a WHILE statement
##
function dowhile ()
{
    match "w"

    L1=$(newlabel)
    L2=$(newlabel)

    postlabel "${L1}"

    condition
    emitline "JT    R0,    ${L2}"
    block
    match "e"
    emitline "JMP   ${L1}"

    postlabel "${L2}"
}
```

Since we've  got a  new statement,  we have to  add a  call to  it within
procedure Block:

### Pascal variant: updating `Block` procedure

```
{--------------------------------------------------------------}
{ Recognize and Translate a Statement Block }

procedure Block;
begin
    while not(Look in ['e', 'l']) do begin
        case Look of
            'i': DoIf;
            'w': DoWhile;
        else Other;
        end;
    end;
end;
{--------------------------------------------------------------}
```

### C variant: updating `block()` function

```
//////////////////////////////////////////////////////////////////////////////
//
// block(): recognize and translate a statement block
//
void block (void)
{
    while ((lookahead != 'e') ||
           (lookahead != 'l'))
    {
        switch (lookahead)
        {
            case 'i':
                doif ();
                break;

            case 'w':
                dowhile ();
                break;

            default:
                other ();
                break;
        }
    }
}
```

### BASH variant: updating `block()` function

```
##############################################################################
##
## block(): recognize and translate a statement block
##
function block()
{
    lookahead=$(cat ${TMPFILE}.lookahead)
    while [ ! "${lookahead}" = "e" ] || [ ! "${lookahead}" = "l" ]; do

        case "${lookahead}" in
            'i')
                doif
                ;;
            'w')
                doif
                ;;
            *)
                other
                ;;
        esac
    done
}
```

No other changes are necessary.

OK, try the  new program. Note that this time,  the *<condition>* code is
INSIDE the upper label, which is just where we wanted it. Try some nested
loops. Try some loops within IF's, and some IF's within loops. If you get
a bit  confused as  to what  you should type,  don't be  discouraged: you
write bugs  in other  languages, too,  don't you? It'll  look a  lot more
meaningful when we get full keywords.

I hope by now  that you're beginning to get the idea  that this really IS
easy. All we have to do to accomodate  a new construct is to work out the
syntax-directed translation of it. The  code almost falls out from there,
and it doesn't  affect any of the other routines.  Once you've gotten the
feel of the  thing, you'll see that  you can add new  constructs about as
fast as you can dream them up.

## THE LOOP STATEMENT

We could stop right here, and have a language that works. It's been shown
many  times that  a high-order  language  with only  two constructs,  the
**IF** and  the **WHILE**,  is sufficient to  write structured  code. But
we're on a roll now, so let's richen up the repertoire a bit.

This construct is even easier, since it  has no condition test at all ...
it's an  infinite loop.  What's the point  of such a  loop? Not  much, by
itself, but  later on we're going  to add a **BREAK**  command, that will
give  us a  way out.  This makes  the language  considerably richer  than
Pascal, which has  no break, and also avoids the  funny WHILE(1) or WHILE
TRUE of C and Pascal.

The syntax is simply:

```
    LOOP <block> ENDLOOP
```

... and the syntax-directed translation is:

```
   LOOP       { L = NewLabel;
                PostLabel(L)  }
   <block>
   ENDLOOP    { Emit(BRA L)   }
```

The corresponding  code is shown  below. Since I've already  used '**l**'
for the  **ELSE**, I've used the  last letter, '**p**', as  the "keyword"
this time.

### Pascal variant: implementing `DoLoop` procedure

```
{--------------------------------------------------------------}
{ Parse and Translate a LOOP Statement }

procedure DoLoop;
var L: string;
begin
    Match('p');
    L := NewLabel;
    PostLabel(L);
    Block;
    Match('e');
    EmitLn('BRA ' + L);
end;
{--------------------------------------------------------------}
```

### C variant: implementing `doloop()` function

```
//////////////////////////////////////////////////////////////////////////////
//
// doloop(): parse and translate a LOOP statement
//
function doloop()
{
    uint8_t *L  = NULL;
    uint8_t  str[32];

    match ('p');

    L           = newlabel ();
    postlabel (L);

    block ();

    match ('e');

    sprintf (str, "JMP   %s", L);
    emitline (str);
}
```

### BASH variant: implementing `doloop()` function

```
##############################################################################
##
## doloop(): parse and translate a LOOP statement
##
function doloop()
{
    match "p"
    L=$(newlabel)
    postlabel "${L}"
    block
    match "e"
    emitline "JMP   ${L}"
}
```

When you insert this routine, don't forget  to add a line in **Block** to
call it.

## REPEAT-UNTIL

Here's one construct that I lifted right from Pascal. The syntax is:

```
    REPEAT <block> UNTIL <condition>
```

... and the syntax-directed translation is:

```
  REPEAT         { L = NewLabel;    |  REPEAT       { L=(newlabel);
                   PostLabel(L)  }  |                 postlabel "${L}" }
  <block>                           |  <block>
  UNTIL                             |  UNTIL
  <condition>    { Emit(BEQ L)   }  |  <condition>  { emit "IEQ R0, R1";
                                    |                 emit "JT  R0, ${L}" }
```

As usual, the code falls out pretty easily:

### Pascal variant: implementing `DoRepeat` procedure

```
{--------------------------------------------------------------}
{ Parse and Translate a REPEAT Statement }

procedure DoRepeat;
var L: string;
begin
    Match('r');
    L := NewLabel;
    PostLabel(L);
    Block;
    Match('u');
    Condition;
    EmitLn('BEQ ' + L);
end;
{--------------------------------------------------------------}
```

### C variant: implementing `dorepeat()` function

```
//////////////////////////////////////////////////////////////////////////////
//
// dorepeat(): parse and translate a REPEAT statement
//
function dorepeat()
{
    uint8_t *L  = NULL;
    uint8_t  str[32];

    match ('r');

    L           = newlabel ();

    postlabel (L);

    block ();
    match ('u');

    condition ();

    sprintf (str, "IEQ   R0,    R1");
    emitline (str);
    sprintf (str, "JT    R0,    %s", L);
    emitline (str);
}
```

### BASH variant: implementing `dorepeat()` function

```
##############################################################################
##
## dorepeat(): parse and translate a REPEAT statement
##
function dorepeat()
{
    match "r"

    L=$(newlabel)
    postlabel "${L}"

    block

    match "u"

    condition

    emitline "IEQ   R0,    R1"
    emitline "JT    R0,    ${L}"
}
```

As before, we have to add the call to **DoRepeat** within **Block**. This
time,  there's  a  difference,  though.  I decided  to  use  '**r**'  for
**REPEAT** (naturally), but I also  decided to use '**u**' for **UNTIL**.
This means that the '**u**' must be added to the set of characters in the
while-test. These are the characters that signal an exit from the current
block ... the "follow" characters, in compiler jargon.

### Pascal variant: updating `Block` procedure

```
{--------------------------------------------------------------}
{ Recognize and Translate a Statement Block }

procedure Block;
begin
    while not(Look in ['e', 'l', 'u']) do begin
        case Look of
            'i': DoIf;
            'w': DoWhile;
            'p': DoLoop;
            'r': DoRepeat;
            else Other;
        end;
    end;
end;
{--------------------------------------------------------------}
```

### C variant: updating `block()` function

```
//////////////////////////////////////////////////////////////////////////////
//
// block(): recognize and translate a statement block
//
function doloop()
{
    while ((lookahead != 'e') ||
           (lookahead != 'l') ||
           (lookahead != 'u'))
    {
        switch (lookahead)
        {
            case 'i':
                doif ();
                break;

            case 'w':
                dowhile ();
                break;

            case 'p':
                doloop ();
                break;

            case 'r':
                dorepeat ();
                break;

            default:
                other ();
                break;
        }
    }
}
```

### BASH variant: updating `block()` function

```
##############################################################################
##
## block(): recognize and translate a statement block
##
function block()
{
    lookahead=$(cat ${TMPFILE}.lookahead)
    while [ ! "${lookahead}" = "e" ] || \
          [ ! "${lookahead}" = "l" ] || \
          [ ! "${lookahead}" = "u" ]; do

        case "${lookahead}" in
            'i')
                doif
                ;;
            'w')
                dowhile
                ;;
            'p')
                doloop
                ;;
            'r')
                dorepeat
                ;;
            *)
                other
                ;;
        esac
    done
}
```

## THE FOR LOOP

The **FOR** loop is  a very handy one to have around, but  it's a bear to
translate. That's  not so much because  the construct itself is  hard ...
it's only a loop after all ...  but simply because it's hard to implement
in assembler language.  Once the code is figured out,  the translation is
straightforward enough.

C fans love the  FOR-loop of that language (and, in  fact, it's easier to
code), but I've chosen instead a syntax  very much like the one from good
ol' BASIC:

```
    FOR <ident> = <expr1> TO <expr2> <block> ENDFOR
```

The translation of a  **FOR** loop can be just about  as difficult as you
choose to make it, depending upon the  way you decide to define the rules
as  to how  to handle  the limits.  Does expr2  get evaluated  every time
through the loop, for  example, or is it treated as  a constant limit? Do
you always go through  the loop at least once, as in  FORTRAN, or not? It
gets  simpler if  you  adopt the  point  of view  that  the construct  is
equivalent to:


```
    <ident> = <expr1>
    TEMP = <expr2>
    WHILE <ident> <= TEMP
    <block>
    ENDWHILE
```

Notice that  with this definition  of the  loop, **<block>** will  not be
executed at all if **<expr1>** is initially larger than **<expr2>**.

### M68000 details

The 68000 code needed to do this  is trickier than anything we've done so
far. I  had a couple  of tries  at it, putting  both the counter  and the
upper limit on the stack, both in  registers, etc. I finally arrived at a
hybrid arrangement,  in which the loop  counter is in memory  (so that it
can be accessed  within the loop), and  the upper limit is  on the stack.
The translated code came out like this:

```
     <ident>             get name of loop counter
     <expr1>             get initial value
     LEA <ident>(PC),A0  address the loop counter
     SUBQ #1,D0          predecrement it
     MOVE D0,(A0)        save it
     <expr1>             get upper limit
     MOVE D0,-(SP)       save it on stack

L1:  LEA <ident>(PC),A0  address loop counter
     MOVE (A0),D0        fetch it to D0
     ADDQ #1,D0          bump the counter
     MOVE D0,(A0)        save new value
     CMP (SP),D0         check for range
     BLE L2              skip out if D0 > (SP)
     <block>
     BRA L1              loop for next pass
L2:  ADDQ #2,SP          clean up the stack
```

### Vircon32 details

```
     <ident>                      ; get name of loop counter
     <expr1>                      ; get initial value
     LEA   R1,      [R2+<ident>]  ; address the loop counter
     ISUB  R0,      1             ; predecrement it
     MOV   [R1],    R0            ; save it
     <expr1>                      ; get upper limit
     PUSH  R0                     ; save it on stack

L1:  LEA   R1,      [R2+<ident>]  ; address loop counter
     MOVE  [R1],    R0            ; fetch it to D0
     IADD  R0,      1             ; bump the counter
     MOV   R0,      [R1]          ; save new value
     POP   R3
     ILE   R3,      R0            ; check for range
     PUSH  R3
     JT    L2                     ; skip out if R0 > upper limit
     <block>
     JMP   L1                     ; loop for next pass
L2:  POP   R3                     ; clean up the stack
```

Wow! That  seems like a lot  of code ... the  line containing **<block>**
seems to almost get lost. But that's the best I could do with it. I guess
it helps to keep in mind that  it's really only sixteen words, after all.
If anyone else can optimize this better, please let me know.

Still, the parser routine is pretty easy now that we have the code:

### Pascal variant: implementing `DoFor` procedure

```
{--------------------------------------------------------------}
{ Parse and Translate a FOR Statement }

procedure DoFor;
var L1, L2: string;
    Name: char;
begin
    Match('f');
    L1 := NewLabel;
    L2 := NewLabel;
    Name := GetName;
    Match('=');
    Expression;
    EmitLn('SUBQ #1,D0');
    EmitLn('LEA ' + Name + '(PC),A0');
    EmitLn('MOVE D0,(A0)');
    Expression;
    EmitLn('MOVE D0,-(SP)');
    PostLabel(L1);
    EmitLn('LEA ' + Name + '(PC),A0');
    EmitLn('MOVE (A0),D0');
    EmitLn('ADDQ #1,D0');
    EmitLn('MOVE D0,(A0)');
    EmitLn('CMP (SP),D0');
    EmitLn('BGT ' + L2);
    Block;
    Match('e');
    EmitLn('BRA ' + L1);
    PostLabel(L2);
    EmitLn('ADDQ #2,SP');
end;
{--------------------------------------------------------------}
```

Since we don't have expressions in this  parser, I used the same trick as
for Condition, and wrote the routine:

### Pascal variant: implementing `Expression` procedure

```
{--------------------------------------------------------------}
{ Parse and Translate an Expression }
{ This version is a dummy }

Procedure Expression;
begin
   EmitLn('<expr>');
end;
{--------------------------------------------------------------}
```

### C variant: implementing `expression()` function

```
//////////////////////////////////////////////////////////////////////////////
//
// expression(): parse and translate an expression
//
void expression (void)
{
    emitline ("<expr>");
}
```

### BASH variant: implementing `expression()` function

```
##############################################################################
##
## expression(): parse and translate an expression
##
function expression()
{
    emitline "<expr>"
}
```

Give it  a try. Once  again, don't forget to  add the call  in **Block**.
Since we don't have any input  for the dummy version of **Expression**, a
typical input line would look something like

```
     afi=bece
```

Well, it *DOES* generate a lot of code, doesn't it? But at least it's the
*RIGHT* code.

## THE DO STATEMENT

All this made me  wish for a simpler version of the  FOR loop. The reason
for all the code above is the need to have the loop counter accessible as
a variable within the loop. If all we  need is a counting loop to make us
go through something  a specified number of times, but  don't need access
to the counter itself, there is a much easier solution.

### M68000 details

The 68000 has a "decrement and branch nonzero" instruction built in which
is ideal for  counting. For good measure, let's add  this construct, too.
This will be the last of our loop structures.

The syntax and its translation is:

```
    DO
    <expr>         { EmitLn('SUBQ #1,D0');
                     L = NewLabel;
                     PostLabel(L);
                     EmitLn('MOVE D0,-(SP)')  }
    <block>
    ENDDO          { EmitLn('MOVE (SP)+,D0');
                     EmitLn('DBRA D0,' + L)   }
```

### Vircon32 details

On  Vircon32, relational  comparisons are  distinctly separate  from jump
instructions. So, assuming I understand  the M68000 `DBRA` instruction as
described above, the equivelent should look something like:

```
    DO
    <expr>         { emitline ("ISUB  R0,    1");
                     L  = newlabel ();
                     postlabel (L);
                     emitline ("PUSH  R0");       }
    <block>
    ENDDO          { emitline ("POP   R0");
                     emitline ("INE   R0,    0");
                     sprintf (spr, "JT    R0,    %s", L);
                     emitline (str);                      }
```

That's  quite a  bit simpler!  The  loop will  execute **<expr>**  times.
Here's the code:


{--------------------------------------------------------------}
{ Parse and Translate a DO Statement }

procedure Dodo;
var L: string;
begin
   Match('d');
   L := NewLabel;
   Expression;
   EmitLn('SUBQ #1,D0');
   PostLabel(L);
   EmitLn('MOVE D0,-(SP)');
   Block;
   EmitLn('MOVE (SP)+,D0');
   EmitLn('DBRA D0,' + L);
end;
{--------------------------------------------------------------}


I  think you'll  have  to agree,  that's  a whole  lot  simpler than  the
classical FOR. Still, each construct has its place.

## THE BREAK STATEMENT

Earlier I promised you a  **BREAK** statement to accompany **LOOP**. This
is one I'm sort  of proud of. On the face of it  a **BREAK** seems really
tricky. My first  approach was to just  use it as an  extra terminator to
**Block**, and split all the loops into two parts, just as I did with the
**ELSE** half of  an **IF**. That turns out not  to work, though, because
the **BREAK** statement  is almost certainly not going to  show up at the
same level as the  loop itself. The most likely place  for a **BREAK** is
right  after an  **IF**,  which would  cause  it to  exit  to the  **IF**
construct, not the  enclosing loop. WRONG. The **BREAK** has  to exit the
inner **LOOP**, even if it's nested down into several levels of **IF**s.

My  next  thought was  that  I  would just  store  away,  in some  global
variable,  the ending  label of  the  innermost loop.  That doesn't  work
either, because  there may be  a break from an  inner loop followed  by a
break  from an  outer one.  Storing the  label for  the inner  loop would
clobber the label for the outer one. So the global variable turned into a
stack. Things were starting to get messy.

Then I decided to take my own advice. Remember in the last session when I
pointed out how  well the *implicit stack of a  recursive descent parser*
was serving our  needs? I said that if  you begin to see the  need for an
external stack  you might be  doing something wrong.  Well, I was.  It is
indeed possible to  let the recursion built into our  parser take care of
everything, and the solution is so simple that it's surprising.

The secret is to note that  every **BREAK** statement has to occur within
a block ... there's no  place else for it to be. So all  we have to do is
to  pass into  **Block** the  exit address  of the  innermost loop.  Then
it  can  pass the  address  to  the  routine  that translates  the  break
instruction. Since  an **IF**  statement doesn't  change the  loop level,
procedure **DoIf** doesn't need to do anything except pass the label into
ITS blocks  (both of them).  Since loops DO  change the level,  each loop
construct simply  ignores whatever label is  above it and passes  its own
exit label along.

All this is easier  to show you than it is  to describe. I'll demonstrate
with the easiest loop, which is **LOOP**:

```
{--------------------------------------------------------------}
{ Parse and Translate a LOOP Statement }

procedure DoLoop;
var L1, L2: string;
begin
   Match('p');
   L1 := NewLabel;
   L2 := NewLabel;
   PostLabel(L1);
   Block(L2);
   Match('e');
   EmitLn('BRA ' + L1);
   PostLabel(L2);
end;
{--------------------------------------------------------------}
```


Notice that **DoLoop** now has TWO labels, not just one. The second is to
give  the **BREAK**  instruction a  target  to jump  to. If  there is  no
**BREAK** within the loop, we've wasted a label and cluttered up things a
bit, but there's no harm done.

Note also that **Block** now has a parameter, which for loops will always
be the exit address. The new version of **Block** is:

```
{--------------------------------------------------------------}
{ Recognize and Translate a Statement Block }

procedure Block(L: string);
begin
   while not(Look in ['e', 'l', 'u']) do begin
      case Look of
       'i': DoIf(L);
       'w': DoWhile;
       'p': DoLoop;
       'r': DoRepeat;
       'f': DoFor;
       'd': DoDo;
       'b': DoBreak(L);
       else Other;
      end;
   end;
end;
{--------------------------------------------------------------}
```

Again, notice that all  **Block** does with the label is  to pass it into
**DoIf** and **DoBreak**. The loop constructs don't need it, because they
are going to pass their own label anyway.

The new version of **DoIf** is:

```
{--------------------------------------------------------------}
{ Recognize and Translate an IF Construct }

procedure Block(L: string); Forward;

procedure DoIf(L: string);
var L1, L2: string;
begin
   Match('i');
   Condition;
   L1 := NewLabel;
   L2 := L1;
   EmitLn('BEQ ' + L1);
   Block(L);
   if Look = 'l' then begin
      Match('l');
      L2 := NewLabel;
      EmitLn('BRA ' + L2);
      PostLabel(L1);
      Block(L);
   end;
   Match('e');
   PostLabel(L2);
end;
{--------------------------------------------------------------}
```

Here, the  only thing that  changes is the  addition of the  parameter to
procedure **Block**. An **IF** statement  doesn't change the loop nesting
level, so **DoIf** just passes the label along. No matter how many levels
of **IF** nesting we have, the same label will be used.

Now, remember that **DoProgram** also calls **Block**, so it now needs to
pass it a label.  An attempt to exit the outermost block  is an error, so
**DoProgram** passes a null label which is caught by **DoBreak**:

```
{--------------------------------------------------------------}
{ Recognize and Translate a BREAK }

procedure DoBreak(L: string);
begin
   Match('b');
   if L <> '' then
      EmitLn('BRA ' + L)
   else Abort('No loop to break from');
end;
{--------------------------------------------------------------}
```

```
{--------------------------------------------------------------}
{ Parse and Translate a Program }

procedure DoProgram;
begin
   Block('');
   if Look <> 'e' then Expected('End');
   EmitLn('END')
end;
{--------------------------------------------------------------}
```

That ALMOST  takes care  of everything.  Give it  a try,  see if  you can
"break"  it <pun>.  Careful,  though. By  this time  we've  used so  many
letters, it's  hard to think  of characters that aren't  now representing
reserved words.  Remember: before  you try the  program, you're  going to
have to edit every occurence of **Block** in the other loop constructs to
include the new parameter. Do it just like I did for **LOOP**.

I said ALMOST above. There is one slight problem: if you take a hard look
at the  code generated for  **DO**, you'll see that  if you break  out of
this loop,  the value  of the loop  counter is still  left on  the stack.
We're going to have to fix that! A  shame ... that was one of our smaller
routines, but it can't be helped.  Here's a version that doesn't have the
problem:

```
{--------------------------------------------------------------}
{ Parse and Translate a DO Statement }

procedure Dodo;
var L1, L2: string;
begin
   Match('d');
   L1 := NewLabel;
   L2 := NewLabel;
   Expression;
   EmitLn('SUBQ #1,D0');
   PostLabel(L1);
   EmitLn('MOVE D0,-(SP)');
   Block(L2);
   EmitLn('MOVE (SP)+,D0');
   EmitLn('DBRA D0,' + L1);
   EmitLn('SUBQ #2,SP');
   PostLabel(L2);
   EmitLn('ADDQ #2,SP');
end;
{--------------------------------------------------------------}
```

The two extra  instructions, the `SUBQ` and `ADDQ`, take  care of leaving
the stack in the right shape.

## CONCLUSION

At this point we have created a number of control constructs ... a richer
set,  really,  than that  provided  by  almost  any other  pro-  gramming
language. And,  except for the  **FOR** loop, it  was pretty easy  to do.
Even that one was tricky only because it's tricky in assembly language.

I'll conclude this session here. To wrap  the thing up with a red ribbon,
we  really should  have a  go at  having real  keywords instead  of these
mickey-mouse  single-character  things.  You've  already  seen  that  the
extension to multi-character words is not  difficult, but in this case it
will make a big difference in the appearance of our input code. I'll save
that little bit for the next  installment. In that installment we'll also
address Boolean  expressions, so we can  get rid of the  dummy version of
**Condition** that we've used here. See you then.

For reference purposes, here is  the  completed  parser  for this
session:

### Pascal variant: completed parser program from this section

```
{--------------------------------------------------------------}
program Branch;

{--------------------------------------------------------------}
{ Constant Declarations }

const TAB = ^I;
      CR  = ^M;

{--------------------------------------------------------------}
{ Variable Declarations }

var Look  : char;              { Lookahead Character }
    Lcount: integer;           { Label Counter }

{--------------------------------------------------------------}
{ Read New Character From Input Stream }

procedure GetChar;
begin
   Read(Look);
end;

{--------------------------------------------------------------}
{ Report an Error }

procedure Error(s: string);
begin
   WriteLn;
   WriteLn(^G, 'Error: ', s, '.');
end;

{--------------------------------------------------------------}
{ Report Error and Halt }

procedure Abort(s: string);
begin
   Error(s);
   Halt;
end;

{--------------------------------------------------------------}
{ Report What Was Expected }

procedure Expected(s: string);
begin
   Abort(s + ' Expected');
end;

{--------------------------------------------------------------}
{ Match a Specific Input Character }

procedure Match(x: char);
begin
   if Look = x then GetChar
   else Expected('''' + x + '''');
end;

{--------------------------------------------------------------}
{ Recognize an Alpha Character }

function IsAlpha(c: char): boolean;
begin
   IsAlpha := UpCase(c) in ['A'..'Z'];
end;

{--------------------------------------------------------------}
{ Recognize a Decimal Digit }

function IsDigit(c: char): boolean;
begin
   IsDigit := c in ['0'..'9'];
end;

{--------------------------------------------------------------}
{ Recognize an Addop }

function IsAddop(c: char): boolean;
begin
   IsAddop := c in ['+', '-'];
end;

{--------------------------------------------------------------}
{ Recognize White Space }

function IsWhite(c: char): boolean;
begin
   IsWhite := c in [' ', TAB];
end;

{--------------------------------------------------------------}
{ Skip Over Leading White Space }

procedure SkipWhite;
begin
   while IsWhite(Look) do
      GetChar;
end;

{--------------------------------------------------------------}
{ Get an Identifier }

function GetName: char;
begin
   if not IsAlpha(Look) then Expected('Name');
   GetName := UpCase(Look);
   GetChar;
end;

{--------------------------------------------------------------}
{ Get a Number }

function GetNum: char;
begin
   if not IsDigit(Look) then Expected('Integer');
   GetNum := Look;
   GetChar;
end;

{--------------------------------------------------------------}
{ Generate a Unique Label }

function NewLabel: string;
var S: string;
begin
   Str(LCount, S);
   NewLabel := 'L' + S;
   Inc(LCount);
end;

{--------------------------------------------------------------}
{ Post a Label To Output }

procedure PostLabel(L: string);
begin
   WriteLn(L, ':');
end;

{--------------------------------------------------------------}
{ Output a String with Tab }

procedure Emit(s: string);
begin
   Write(TAB, s);
end;

{--------------------------------------------------------------}

{ Output a String with Tab and CRLF }

procedure EmitLn(s: string);
begin
   Emit(s);
   WriteLn;
end;

{--------------------------------------------------------------}
{ Parse and Translate a Boolean Condition }

procedure Condition;
begin
   EmitLn('<condition>');
end;

{--------------------------------------------------------------}
{ Parse and Translate a Math Expression }

procedure Expression;
begin
   EmitLn('<expr>');
end;

{--------------------------------------------------------------}
{ Recognize and Translate an IF Construct }

procedure Block(L: string); Forward;

procedure DoIf(L: string);
var L1, L2: string;
begin
   Match('i');
   Condition;
   L1 := NewLabel;
   L2 := L1;
   EmitLn('BEQ ' + L1);
   Block(L);
   if Look = 'l' then begin
      Match('l');
      L2 := NewLabel;
      EmitLn('BRA ' + L2);
      PostLabel(L1);
      Block(L);
   end;
   Match('e');
   PostLabel(L2);
end;

{--------------------------------------------------------------}
{ Parse and Translate a WHILE Statement }

procedure DoWhile;
var L1, L2: string;
begin
   Match('w');
   L1 := NewLabel;
   L2 := NewLabel;
   PostLabel(L1);
   Condition;
   EmitLn('BEQ ' + L2);
   Block(L2);
   Match('e');
   EmitLn('BRA ' + L1);
   PostLabel(L2);
end;

{--------------------------------------------------------------}
{ Parse and Translate a LOOP Statement }

procedure DoLoop;
var L1, L2: string;
begin
   Match('p');
   L1 := NewLabel;
   L2 := NewLabel;
   PostLabel(L1);
   Block(L2);
   Match('e');
   EmitLn('BRA ' + L1);
   PostLabel(L2);
end;

{--------------------------------------------------------------}
{ Parse and Translate a REPEAT Statement }

procedure DoRepeat;
var L1, L2: string;
begin
   Match('r');
   L1 := NewLabel;
   L2 := NewLabel;
   PostLabel(L1);
   Block(L2);
   Match('u');
   Condition;
   EmitLn('BEQ ' + L1);
   PostLabel(L2);
end;

{--------------------------------------------------------------}
{ Parse and Translate a FOR Statement }

procedure DoFor;
var L1, L2: string;
    Name: char;
begin
   Match('f');
   L1 := NewLabel;
   L2 := NewLabel;
   Name := GetName;
   Match('=');
   Expression;
   EmitLn('SUBQ #1,D0');
   EmitLn('LEA ' + Name + '(PC),A0');
   EmitLn('MOVE D0,(A0)');
   Expression;
   EmitLn('MOVE D0,-(SP)');
   PostLabel(L1);
   EmitLn('LEA ' + Name + '(PC),A0');
   EmitLn('MOVE (A0),D0');
   EmitLn('ADDQ #1,D0');
   EmitLn('MOVE D0,(A0)');
   EmitLn('CMP (SP),D0');
   EmitLn('BGT ' + L2);
   Block(L2);
   Match('e');
   EmitLn('BRA ' + L1);
   PostLabel(L2);
   EmitLn('ADDQ #2,SP');
end;

{--------------------------------------------------------------}
{ Parse and Translate a DO Statement }

procedure Dodo;
var L1, L2: string;
begin
   Match('d');
   L1 := NewLabel;
   L2 := NewLabel;
   Expression;
   EmitLn('SUBQ #1,D0');
   PostLabel(L1);
   EmitLn('MOVE D0,-(SP)');
   Block(L2);
   EmitLn('MOVE (SP)+,D0');
   EmitLn('DBRA D0,' + L1);
   EmitLn('SUBQ #2,SP');
   PostLabel(L2);
   EmitLn('ADDQ #2,SP');
end;

{--------------------------------------------------------------}
{ Recognize and Translate a BREAK }

procedure DoBreak(L: string);
begin
   Match('b');
   EmitLn('BRA ' + L);
end;

{--------------------------------------------------------------}
{ Recognize and Translate an "Other" }

procedure Other;
begin
   EmitLn(GetName);
end;

{--------------------------------------------------------------}
{ Recognize and Translate a Statement Block }

procedure Block(L: string);
begin
   while not(Look in ['e', 'l', 'u']) do begin
      case Look of
       'i': DoIf(L);
       'w': DoWhile;
       'p': DoLoop;
       'r': DoRepeat;
       'f': DoFor;
       'd': DoDo;
       'b': DoBreak(L);
       else Other;
      end;
   end;
end;

{--------------------------------------------------------------}
{ Parse and Translate a Program }

procedure DoProgram;
begin
   Block('');
   if Look <> 'e' then Expected('End');
   EmitLn('END')
end;

{--------------------------------------------------------------}
{ Initialize }

procedure Init;
begin
   LCount := 0;
   GetChar;
end;

{--------------------------------------------------------------}
{ Main Program }

begin
   Init;
   DoProgram;
end.
{--------------------------------------------------------------}
```
