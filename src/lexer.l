%{
	#include "parser.tab.h"
%}

%%

[0-9]+ { yylval.intval = atoi (yytext); return (INTEGER); }
"+"    { return (PLUS);     }
"-"    { return (MINUS);    }
"*"    { return (MULTIPLY); }
"/"    { return (DIVIDE);   }
"%"    { return (MODULUS);  }
\n     { return (EOL);      }
[ \t]  { }
.      { }

%%

int yywrap() { }
