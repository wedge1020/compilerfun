#include "defs.h"
#include "data.h"
#include "decl.h"

// Miscellaneous functions
// Copyright (c) 2019 Warren Toomey, GPL3

////////////////////////////////////////////////////////////////////////////////////////
//
// Ensure that the current token is t,
// and fetch the next token. Otherwise
// throw an error 
//
void match (int t, char *what)
{
    if (Token.token == t)
    {
        scan (&Token);
    }
    else
    {
        fatals ("Expected", what);
    }
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Match a semicolon and fetch the next token
//
void semi (void)
{
    match (T_SEMI, ";");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Match a left brace and fetch the next token
//
void lbrace (void)
{
    match (T_LBRACE, "{");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Match a right brace and fetch the next token
//
void rbrace (void)
{
    match (T_RBRACE, "}");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Match a left parenthesis and fetch the next token
//
void lparen (void)
{
    match (T_LPAREN, "(");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Match a right parenthesis and fetch the next token
//
void rparen (void)
{
    match (T_RPAREN, ")");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Match an identifier and fetch the next token
//
void ident (void)
{
    match(T_IDENT, "identifier");
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Print out fatal messages
//
void fatal (char *string)
{
    fprintf (stderr, "%s on line %d\n", string, Line);
    exit (1);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Print out fatal messages (string:string)
//
void fatals (char *string1, char *string2)
{
    fprintf (stderr, "%s:%s on line %d\n", string1, string2, Line);
    exit (1);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Print out fatal messages (string:integer)
//
void fatald (char *string, int value)
{
    fprintf (stderr, "%s:%d on line %d\n", string, value, Line);
    exit (1);
}

////////////////////////////////////////////////////////////////////////////////////////
//
// Print out fatal messages (string:char)
//
void fatalc (char *string, int symbol)
{
    fprintf (stderr, "%s:%c on line %d\n", string, symbol, Line);
    exit (1);
}
