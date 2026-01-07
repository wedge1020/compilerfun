#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#define  TRUE  1
#define  FALSE 0

////////////////////////////////////////////////////////////////////////////////////////
//
// Declare global variables
//
uint8_t     lookahead; // lookahead character
                              
////////////////////////////////////////////////////////////////////////////////////////
//
// getsymbol(): obtain character from input stream
//
void getsymbol (void)
{
   lookahead  = fgetc (stdin);
}
                              
////////////////////////////////////////////////////////////////////////////////////////
//
// showerror(): report an error
//
void showerror (uint8_t *msg)
{
    fprintf (stderr, "[error] %s\n", msg);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// aborterror(): report an error and exit
//
void aborterror (uint8_t *msg)
{
    showerror (msg);
    exit (1);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// expected(): report what was expected
//
void expected (uint8_t *msg)
{
    uint8_t  str[64];
    sprintf ((char *) str, "%s expected", msg);
    aborterror (str);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// match(): match a specific input character
//
void match (uint8_t  symbol)
{
    uint8_t  str[2];

    if (lookahead == symbol)
    {
        getsymbol ();
    }
    else
    {
        sprintf ((char *) str, "%c", symbol);
        expected (str);
    }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// issymbol(): recognize an alpha character
//
uint8_t  issymbol (uint8_t symbol)
{
    uint8_t  status  = FALSE;

    if (((symbol    >= 'A')  &&
         (symbol    <= 'Z')) ||
        ((symbol    >= 'a')  &&
         (symbol    <= 'z')))
    {
        status       = TRUE;
    }

    return (status);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// isnumber(): recognize a decimal digit
//
uint8_t  isnumber (uint8_t symbol)
{
    uint8_t  status  = FALSE;

    if ((symbol     >= '0')  &&
         (symbol    <= '9')) 
    {
        status       = TRUE;
    }

    return (status);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// isaddop(): recognize an addition operation
//
uint8_t  isaddop (uint8_t  symbol)
{
    uint8_t  result  = FALSE;
    if ((symbol     == '+') ||
        (symbol     == '-'))
    {
        result       = TRUE;
    }

    return (result);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// getname(): get an identifier
//
uint8_t  getname (void)
{
    uint8_t  value            = '\0';
    uint8_t  str[5];

    if (issymbol (lookahead) == FALSE)
    {
        sprintf ((char *) str, "%s", "name");
        expected (str);
    }

    value                     = lookahead;
    getsymbol ();

    return (value); 
}

////////////////////////////////////////////////////////////////////////////////////////
//
// getnumber(): get a number
//
uint8_t  getnumber (void)
{
    uint8_t  value            = '\0';
    uint8_t  str[8];

    if (isnumber (lookahead) == FALSE)
    {
        sprintf ((char *) str, "%s", "integer");
        expected (str);
    }

    value                     = lookahead;
    getsymbol ();

    return (value); 
}

////////////////////////////////////////////////////////////////////////////////////////
//
// emit(): output a string with indentation
//
void emit (uint8_t *msg)
{
    fprintf (stdout, "    %s", msg);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// emitline(): output a string with indentation and newline
//
void emitline (uint8_t *msg)
{
    emit (msg);
    fprintf (stdout, "\n");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// factor(): parse and translate a math factor
//
void factor (void)
{
    uint8_t  str[32];

    if (lookahead == '(')
    {
        match ('(');
        expression ();
        match (')');
    }
    else
    {
        sprintf ((char *) str, "MOV   R0,    %c", getnumber ());
        emitline (str);
    }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// multiply(): recognize and translate a multiplication
//
void multiply (void)
{
    match ('*');
    factor ();
    emitline ((char *) "POP   R1");
    emitline ((char *) "IMUL  R0,    R1");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// divide(): recognize and translate a division
//
void divide (void)
{
    match ('/');
    factor ();
    emitline ((char *) "POP   R1");
    emitline ((char *) "IDIV  R1,    R0");
    emitline ((char *) "MOV   R0,    R1");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// modulus(): recognize and translate a modulus
//
void modulus (void)
{
    match ('%');
    factor ();
    emitline ((char *) "POP   R1");
    emitline ((char *) "IMOD  R1,    R0");
    emitline ((char *) "MOV   R0,    R1");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// term(): parse and translate a math term
//
void term (void)
{
    factor ();
    
    while ((lookahead == '*') ||
           (lookahead == '/') ||
           (lookahead == '%'))
    {
        emitline ((char *) "PUSH  R0");

        switch (lookahead)
        {
            case '*':
                multiply ();
                break;

            case '/':
                divide ();
                break;

            case '%':
                modulus ();
                break;

            default:
                expected ((char *) "multiply operation");
                break;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// add(): recognize and translate an addition
//
void add (void)
{
    match ('+');
    term ();
    emitline ((char *) "POP   R1");
    emitline ((char *) "IADD  R0,    R1");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// subtract(): recognize and translate a subtraction
//
void subtract (void)
{
    match ('-');
    term ();
    emitline ((char *) "POP   R1");
    emitline ((char *) "ISUB  R0,    R1");
    emitline ((char *) "ISGN  R0");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// expression(): parse and translate an expression
//
void expression (void)
{
    if (isaddop (lookahead) == TRUE)
    {
        emitline ((char *) "MOV   R0,    0");
    }
    else
    {
        term ();
    }
    
    while (isaddop (lookahead) == TRUE)
    {
        emitline ((char *) "PUSH  R0");

        switch (lookahead)
        {
            case '+':
                add ();
                break;

            case '-':
                subtract ();
                break;

            default:
                expected ((char *) "add operation");
                break;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// initialize(): initialize everything
//
void initialize (void)
{
    getsymbol ();
}

////////////////////////////////////////////////////////////////////////////////////////
//
// main(): where we start
//
int32_t  main ()
{
    initialize ();
    expression ();

    return (0);
}
