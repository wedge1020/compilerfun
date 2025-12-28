%{
    #include "parser.tab.h"
%}

%%

0|[1-9][0-9]* { yylval.intval  = atoi (yytext); return (INTEGER); }
"+"           { return ('+'); }
"-"           { return ('-'); }
"*"           { return ('*'); }
"/"           { return ('/'); }
"%"           { return ('%'); }
"("           { return ('('); }
")"           { return (')'); }
\n            { return (EOL);          }
[ \t\r]       { }
.             { }

%%

int yywrap() { }
