# part 3: more expressions (variables)

## M68K/PC translation

The immediate issue, more of an  architectural one, is the tutorial's use
of the following M68000 instruction:

```MOVE X(PC),D0```

The purpose of which is to move information from a program-counter offset
memory address into the indicated data register D0.

'X'  would  be the  particular  variable  offset,  added to  the  program
counter.

At first glance,  this seems odd, as I've always  understood variables to
be  packed together  at  the end  of the  program's  memory space.  Doing
something based on  an offset of the program counter  would seem to leave
gaps,  as not  everything is  a variable.  Also, the  larger the  program
becomes on less memory-abundant systems (sure, not incredibly likely, but
still), would potentially lead to issues.

Furthermore, Vircon32 does not have direct access to the program counter.

I did  some digging,  and found this  righteously awesome  technique that
could give  us access to  the value  of the program  counter (Instruction
Pointer Register on Vircon32):

```
    CALL getIPval
getIPval:
    POP R0
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
