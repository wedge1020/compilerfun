# part 3: more expressions (variables)

## M68K/PC translation

The immediate issue, more of an  architectural one, is the tutorial's use
of the following M68000 instruction:

```MOVE X(PC),D0```

The purpose of which is to move information from a program-counter offset
memory address into the indicated data register D0.

'X'  would  be the  particular  variable  offset,  added to  the  program
counter.

### round one

At first glance,  this seems odd, as I've always  understood variables to
be  packed together  at  the end  of the  program's  memory space.  Doing
something based on  an offset of the program counter  would seem to leave
gaps,  as not  everything is  a variable.  Also, the  larger the  program
becomes on less memory-abundant systems (sure, not incredibly likely, but
still), would potentially lead to issues.

### a potential Vircon32 solution disconnected from reality

Furthermore, Vircon32 does not have direct access to the program counter.

I did  some digging,  and found this  righteously awesome  technique that
could give  us access to  the value  of the program  counter (Instruction
Pointer Register on Vircon32):

```
    CALL getIPval
getIPval:
    POP  R0
```

... this is  one of those reasons  I love assembly, and  the hacky tricks
you can pull  off. I laughed and  chuckled for far too long  when I first
saw this.

Basically:  we  CALL the  indicated  subroutine  (`getIPval`) which  just
happens to be the VERY NEXT LINE;  technically it doesn't need to be, but
we technically don't need to have a subroutine: we just need to CALL one,
as that  will PUSH the  current value of  the Instruction Pointer  to the
stack.

So, if we then immediately turn around  and POP the top of the stack into
some free register (R0 in this case): what's at the top of the stack? THE
VALUE OF THE INSTRUCTION POINTER!

Having no intention to RET, we've  gained access to that information that
otherwise wasn't directly accessible to us.

Of course,  just starting into  part 3, I still  don't know if  this will
prove useful. But, I suppose to start off with, better than nothing.

Beautiful thing  is, this has NOTHING  to do with the  local machine, but
with the target machine. So, C  or bash, this detail doesn't matter. Once
we figure out  how to do what  we need to do in  Vircon32 assembly, we're
set.

My current Vircon32 assembly solution is:

```
    CALL  fhack
fhack:
    POP   R1
    LEA   R0,    [R1+X]
```

This gives us access to the current value of the Instruction Pointer, and
assuming we need the ADDRESS at that offset location, this might actually
be a perfect application of the `LEA` instruction.

Should  we  actually  need  the information  AT  that  calculated  memory
address, we just add another `MOV`, dereferencing R0.

### round two

Thinking further on  this ```MOVE X(PC),D0```, I **have**  to be thinking
of  something wrong.  Probably in  reverse.  I must  be interpreting  the
Program Counter  aspect incorrectly, as  I continue  to not see  a solid,
consistent benefit to this.

I saw  another example  mentioning the  use of a  table existing  at some
point  in memory.  This  is  what matches  my  expectations  based on  my
understanding.  We want  an offset  within the  **table**, not  an offset
based on where in the program we are.

So then:  how to square the  difference between what I  understand is the
likely productive  and viable approach,  and what  I observe seems  to be
going on?

What  we need  is some  way of  linking a  table offset  to a  particular
variable. If  `x` is  the first  variable, it would  be the  first offset
(offset 0) in the variable table in memory.

But, how  do we  accomplish this?  The current  code has  no notion  of a
table. I would hope that is  coming soon (although, seemingly not in part
3). So, are these variables just for variable sake? Probably.

But  then, why  do  this  reference against  the  program counter?  There
certainly must be more inane fillers than something that in and of itself
would cause confusion trying to analyze the code.

Unless, at its  core, it IS somehow exactly what  we **will** want later.
Just, again: **how**?

If the **PC** register on the M68000 contains the Program Counter, and is
at  least directly  readable,  how will  this  facilitate variable  value
lookups?

As I said,  as a very sparse and memory-wasting  technique, if our *base*
value was something  like the end of our program  data, this could indeed
work, if only  for single instances of a given  variable (what happens if
`x`  is used  twice, or  more? We'd  then be  offsetting to  a different,
further offset in memory, and not having the same data be involved.

Unless? What  if we  stored memory  addresses at  each of  these instance
offsets,  then through  dereferencing  we'd have  the  same data.  Wholly
inefficient, redundant, but certainly workable.

In the  end, I think  it would be helpful  if the author  explained their
reasoning and  the concepts  behind this  line, even  if just  within the
context  of the  M68000, if  they insist  on doing  this most  minimal of
connections, as  it feels like  a loose, unresolved thread.  Which, sure,
I've learned  some things,  but it  remains unresolved.  I don't  want to
overhaul the logic, not yet knowing what the author has in mind for this.

I can live with knowing it is just minimal filler. But if so, please tell
us so!  Then, I can  just narrowly focus on  coming up with  the Vircon32
equivalent of that M68000 process  (which, from my current understanding,
I have done).

### further thoughts

Upon investigating  this further, it seems  we might be dealing  with the
very outskirts of Operating System  runtime interfacing, as this assembly
action is  the very basis of  program independent code, the  "PIC" we see
with libraries, allowing  for offset mapping to routines  no matter where
they get loaded into memory.

Since I'm  focusing more on  a **freestanding** implementation,  any such
attempt to interface with an OS will be for naught.

So, something to keep in mind as we progress.

Also, I maintain  my confusion over the pointlessness  of the instruction
as given: the point of program independent code is to calculate an offset
from  the  program counter.  That  offset  is  where the  magic  happens:
allowing our code to interface with other resources.

There needs to  be some calculation involved. What is  'X'? It would seem
that we need an additional step, knowing where we are in the program, and
knowing where  `X` resides in  any variable table, then  calculating that
distance. THAT  is what  is added  to the program  counter in  our `LEA`.
Currently we seem to be entirely lacking that.
