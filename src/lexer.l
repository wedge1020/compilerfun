%{
    #include "parser.tab.h"
%}

%%

0|[1-9][0-9]* { yylval.intval  = atoi (yytext); return (INTEGER); }
"("                     { return (OPEN_PARENS);  }
")"                     { return (CLOSE_PARENS); }
"+"                     { return (PLUS);         }
"-"                     { return (MINUS);        }
"*"                     { return (MULTIPLY);     }
"/"                     { return (DIVIDE);       }
"%"                     { return (MODULUS);      }
\n                      { return (EOL);          }
[ \t\r]                 { }
.                       { }

%%

int yywrap() { }
