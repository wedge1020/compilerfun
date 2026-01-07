# part 2: expression parsing

This is where  initial functionality started to  take place, implementing
parsing for our basic arithmetic  expressions, starting with addition and
subtraction,  then adding  in  multiplication/division/modulus, and  then
parenthesis. Full PEMDAS, proper assembly language output.

Implementing  for modulus  wasn't  in  the tutorial.  But  seeing as  how
similar it is to division (IMOD vs IDIV), easy enough to do.

## pascal to C translation challenge: figuring out that is a subset

The big stumbling block, at least for C, was the following logic:

```
{---------------------------------------------------------------}
{ Parse and Translate an Expression }

procedure Expression;
begin
   Term;
   while Look in ['+', '-'] do begin
      EmitLn('MOVE D0,D1');
      case Look of
       '+': Add;
       '-': Subtract;
      else Expected('Addop');
      end;
   end;
end;
{---------------------------------------------------------------}
```

Specifically, what in the heck is happening with THIS line:

```
   while Look in ['+', '-'] do begin
```

Initially, I thought this was looping our `lookahead` variable through an
array of the addition operators.

But this immediately didn't seem  to make sense: why destroy `lookahead`?
It is ALREADY supposed to be one of those two things.

Also, trying to implement a loop just made no sense.

So, a little googling and apparently  that's a subset check. Ah! Now THAT
makes more sense.

```
    uint8_t  result  = FALSE;
    if ((symbol     == '+') ||
        (symbol     == '-'))
    {
        result       = TRUE;
    }
```

... just a compound `if` will do the trick. And indeed, it did.

I got a little lazy presently with  my string handling, so there's a slew
of compiler  warnings complaining about  how `int8_t  *` is not  `char *`
even though  it really is. I'll  fix them eventually, or  smooth them out
with further compiler functionality when it comes on-line.

It will compile, and works.

## bash

Generally, the bash translation from C went without issue.

However, input proved to be a problem. It really didn't like encountering
'+' and '-' in  the input stream. Initially, if I  escaped them, it would
work *better*, but with increasing sophistication, things kept breaking.

After several overhauls, I ended up with a reliable file-based scheme:

  * I generate a temporary file, containing the current **line** of input
  * the `lookahead` is a single character stored in another temp file

I just constantly reload my `lookahead` variable from that file in all of
the places it is needed, as I was having some odd variable scoping issues
where it wasn't being updated, or data was lost.

At this point it works.

... onwards to part 3
