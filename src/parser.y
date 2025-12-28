%{
    #include <stdio.h>

    int  yylex   (void);
    int  yyerror (const char *);
%}

%union {
    int    intval;
    float  floatval;
}

%token EOL
%token<intval> INTEGER
%token<floatval> FLOAT
%type<intval> expression
%left '+' '-'     // Left-associative, lower precedence
%left '*' '/' '%' // Left-associative, higher precedence
%precedence UMINUS /* Unary minus (e.g., -5) */
%precedence UPLUS  /* Unary plus  (e.g., +5) */

%%

input:
     | line input
     ;

line:
    expression EOL { fprintf (stdout, "%d\n", $1); }
    | EOL
    ;

expression:
    INTEGER                       { $$ = $1;      }
    | expression '+' expression   { $$ = $1 + $3; }
    | expression '-' expression   { $$ = $1 - $3; }
    | expression '*' expression   { $$ = $1 * $3; }
    | expression '/' expression   { $$ = $1 / $3; }
    | expression '%' expression   { $$ = $1 % $3; }
    | '(' expression ')'          { $$ = $2;      } /* (P)arentheses */
    | '-' expression %prec UMINUS { $$ = -$2;     } /* Context-dependent precedence */
    | '+' expression %prec UMINUS { $$ = +$2;     } /* Context-dependent precedence */
    ;

%%

int yyerror (const char *yyerrtext)
{
    fprintf (stderr, "[ERROR] %s\n", yyerrtext);
    return (0);
}

int main ()
{
    yyparse ();
}
