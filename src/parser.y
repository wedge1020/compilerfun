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
%token OPEN_PARENS CLOSE_PARENS MULTIPLY DIVIDE MODULUS PLUS MINUS
%type<intval> expression

%%

input:
     | line input
     ;

line:
    expression EOL { fprintf (stdout, "%d\n", $1); }
    | EOL
    ;

expression: INTEGER { $$ = $1; }
          | expression MULTIPLY expression { $$ = $1 * $3; }
          | expression DIVIDE   expression { $$ = $1 / $3; }
          | expression MODULUS  expression { $$ = $1 % $3; }
          | expression PLUS     expression { $$ = $1 + $3; }
          | expression MINUS    expression { $$ = $1 - $3; }
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
