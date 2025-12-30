%{
    #include "parser.tab.h"
    #include "symboltable.h"
%}

%%

0|[1-9][0-9]*          { yylval.intval    = atoi (yytext); return (INTEGER); }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.tptr      = getsymbol (yytext);
                         if (yylval.tptr == NULL)
                             yylval.tptr  = addsymbol (yytext, 0); // Create if new
                         fprintf (stdout, "[lexer] yylval.tptr -> name is: %s\n", yylval.tptr -> name);
                         return (VARIABLE);
                       }
"="                    { return ('='); }
";"                    { return (';'); }
"+"                    { return ('+'); }
"-"                    { return ('-'); }
"*"                    { return ('*'); }
"/"                    { return ('/'); }
"%"                    { return ('%'); }
"("                    { return ('('); }
")"                    { return (')'); }
\n                     { return (EOL);          }
[ \t\r]                { }
.                      { }

%%

int yywrap()
{
    return (1);
}
