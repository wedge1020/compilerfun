%glr-parser

%{
    #include <stdio.h>

    int  yylex   (void);
    int  yyerror (char *);
%}

%union {
    int    intval;
    float  floatval;
}

%token EOL
%token<intval> INTEGER
%token PLUS MINUS MULTIPLY DIVIDE MODULUS
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
          | expression PLUS     expression { $$ = $1 + $3; }
          | expression MINUS    expression { $$ = $1 - $3; }
          | expression MULTIPLY expression { $$ = $1 * $3; }
          | expression DIVIDE   expression { $$ = $1 / $3; }
          | expression MODULUS  expression { $$ = $1 % $3; }
          ;

%%

int yyerror (char *yyerrtext) {
    fprintf (stderr, "[ERROR] %s\n", yyerrtext);
    return (0);
}

int main () {
    yyparse ();
}
