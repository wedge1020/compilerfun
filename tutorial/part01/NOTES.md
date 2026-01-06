# PART 1: THE CRADLE

Aside from the overview and  author's particular aims/approach, there was
the initial code (author called the  "cradle") that was presented in this
part.

## Pascal

The  code  of  the  tutorial  is  written  in  pascal,  my  first  format
programming language,  learned in college  over 26 years ago  (clear into
the  last  millennium, if  just  barely).  While  I  learned it  using  a
command-line compiler  on an  OpenVMS system, and  it certainly  has some
syntactical differences from that of Borland Turbo Pascal, I should still
be able to navigate my way through most of the code.

At least for this part: that assumption proved correct.

To further update  things, I will be testing all  the Pascal code against
the FreePascal 3.2.2 compiler, to  ensure it compiles (and hopefully with
no warnings). So all three variants should be viable in present day.

## C

As stated,  one of my target  languages for implementing my  own compiler
exploration efforts, from  following along and trying out  things in this
tutorial, is C.

There was no trouble converting the pascal  code to C in this part of the
tutorial. The  conceptual similarities and  rather verbose nature  of the
pascal made for easy conversion of logic.

And: everything generally seems to work  (compiles, at any rate- not much
is going on yet).

`compiler.c`  is where  all the  logic is  currently housed,  and doesn't
require any special compiling options. I went with my standard:

`gcc -Wall --std=gnu18 -o compiler compiler.c`

At least on my system, x86_64/Linux  running gcc 12.2.0, it compiles with
no notes, warnings, or errors.

It  also doesn't  yet  do anything.  But:  this is  a  conversion of  the
author's "cradle" code.

## BASH

From  the C  port, I  then converted  into BASH.  Not all  that big  of a
challenge, at least not for the cradle.

Part  2 would  offer up  some wrinkles  requiring some  overhauls of  the
input.  For now,  it runs  without issue  (and like  the C  version, does
nothing).

Run with:

`./compiler.sh`

... onto part 2!
