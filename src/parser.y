%{
    #include <stdio.h>
    #include "symboltable.h"

    int  yylex   (void);
    int  yyerror (const char *);
%}

%union {
    int     intval;
    int    *intptr;
    float   floatval;
    float  *floatptr;
    void   *voidptr;
    struct symbolrecord *tptr;
}

%token            EOL
%token <tptr>     VARIABLE
%token <intval>   INTEGER
%token <floatval> FLOAT
%type  <intval>   expression
%left  '+' '-'               // Left-associative, lower precedence
%left  '*' '/' '%'           // Left-associative, higher precedence
%precedence UMINUS           // Unary minus
%precedence UPLUS            // Unary plus

%%

input:
     | line input
     ;

line:
    expression EOL                    { fprintf (stdout, "%d\n", $1); }
    | VARIABLE '=' expression ';' EOL { $1 -> value = $3; fprintf (stdout, "\t%s = %.d\n", $1 -> name, $3); }
    | EOL
    ;

expression:
    INTEGER                       { $$ = $1;          }
    | VARIABLE                    { $$ = $1 -> value; } // Retrieve variable value
    | expression '+' expression   { $$ = $1 + $3;     }
    | expression '-' expression   { $$ = $1 - $3;     }
    | expression '*' expression   { $$ = $1 * $3;     }
    | expression '/' expression   { $$ = $1 / $3;     }
    | expression '%' expression   { $$ = $1 % $3;     }
    | '(' expression ')'          { $$ = $2;          } // (P)arentheses
    | '+' expression %prec UMINUS { $$ = +$2;         } // Context-dependent precedence
    | '-' expression %prec UMINUS { $$ = -$2;         } // Context-dependent precedence
    ;

%%

int yyerror (const char *yyerrtext)
{
    fprintf (stderr, "[ERROR] %s\n", yyerrtext);
    return (0);
}

int main ()
{
	symboltable  = NULL;
    yyparse ();
}
