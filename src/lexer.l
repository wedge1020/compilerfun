%{
    #include "parser.tab.h"
    #include "symboltable.h"
%}

%%

0|[1-9][0-9]*          { yylval.intval    = atoi (yytext); return (INTEGER); }
[a-zA-Z_][a-zA-Z0-9_]* { symrec *tmp      = getsymbol ((uint8_t *) yytext);
                         if (tmp         == NULL)
                             tmp          = addsymbol ((uint8_t *) yytext, 0); // default to variable
                         
                         yylval.tptr      = tmp;
                         fprintf (stdout, "[lexer] yylval.tptr -> name is: %s\n", yylval.tptr -> name);
                         if (tmp -> type == 1)
                             return (FUNCTION);
                         else
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
    return (0);
}
