%{
#include "y.tab.h"
#include <ctype.h>
#include <string.h>

void yyerror (char *s);
int yylex();
%}

%%
(?i:entity)       { return ENTITY; }
(?i:architecture) { return ARCHITECTURE; }
(?i:signal)       { return SIGNAL; }
(?i:is)           { return IS; }
(?i:of)           { return OF; }
(?i:begin)        { return BEGIN_TOKEN; }
(?i:end)          { return END; }
"<="              { return ASSIGNMENT_OP; }
"exit"            { return EXIT_COMMAND; }

[a-zA-Z][a-zA-Z0-9_]* { 
    yylval.string = strdup(yytext); 
    return IDENTIFIER; 
}

[~`!$%^&*()#@0-9][a-zA-Z0-9_#@]* { yylval.string = strdup(yytext); return INVALID_IDENTIFIER; }

[\n]              { yylineno++; }
[ \t\r]+          { /* ignore whitespace */ }
[:=;]             { return yytext[0]; }

.                 { return UNRECOGNIZED; }

%%
int yywrap(void) { return 1; }