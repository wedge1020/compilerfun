%{
    #include <stdio.h>
    #include <stdint.h>
    #include <stdlib.h>
    #include "symboltable.h"

    symrec *symboltable;

    int  yylex   (void);
    int  yyerror (const char *);
%}

%union {
    int32_t              intval;
    int32_t             *intptr;
    float                floatval;
    float               *floatptr;
    void                *voidptr;
    struct symbolrecord *tptr;
    struct argumentnode *argv;
}

%token            EOL
%token <tptr>     VARIABLE FUNCTION
%token <intval>   INTEGER
%token <floatval> FLOAT
%type  <intval>   expression arglist
//%type  <argv>     arglist
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
    | VARIABLE '=' expression ';' EOL { symrec *tmp = getsymbol ($1 -> name);
                                        if (tmp          == NULL)
                                            tmp           = addsymbol ($1 -> name, $3);
                                        else
                                            tmp -> data.intvalue  = $3;
                                        fprintf (stdout, "[parser] %8s: %d\n", tmp -> name, tmp -> data.intvalue);
                                      }
    | EOL
    ;

arglist: expression
       | arglist ',' expression   { $$ = $3; }
       ;

expression:
    INTEGER                       { $$ = $1;                          }
    | VARIABLE                    { $$ = $1 -> data.intvalue;         } // Retrieve variable value
    | FUNCTION '(' arglist ')'    { $$ = call_function ($1, $3);      } // function call
    | expression '+' expression   { $$ = $1 + $3;                     }
    | expression '-' expression   { $$ = $1 - $3;                     }
    | expression '*' expression   { $$ = $1 * $3;                     }
    | expression '/' expression   { $$ = $1 / $3;                     }
    | expression '%' expression   { $$ = $1 % $3;                     }
    | '(' expression ')'          { $$ = $2;                          } // (P)arentheses
    | '+' expression %prec UMINUS { $$ = +$2;                         } // Context-dependent precedence
    | '-' expression %prec UMINUS { $$ = -$2;                         } // Context-dependent precedence
    ;

arglist: expression             { argnode *tmp  = (argnode *) malloc (sizeof (argnode));
                                  tmp -> value  = $1;
                                  tmp -> next   = NULL;
                                  $$            = tmp;
                                }
       | arglist ',' expression { argnode *tmp  = (argnode *) malloc (sizeof (argnode));
                                  tmp -> value  = $3;
                                  tmp -> next   = $1;
                                  $$            = tmp;
                                }
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
    return (0);
}
