%{
    #include <string.h>
    #include <stdlib.h>
    #include "parser.tab.h"
    extern void yyerror(const char *msg);
%}

%option noyywrap
%option yylineno

%%

"int"           { return TYPE_INT; }
"float"         { return TYPE_FLOAT; }
"string"        { return TYPE_STRING; }
"boolean"       { return TYPE_BOOL; }
"void"          { return TYPE_VOID; }
"do"            { return DO; }
"while"         { return WHILE; }
"repeat"        { return REPEAT; }
"until"         { return UNTIL; }
"for"           { return FOR; }
"if"            { return IF; }
"else"          { return ELSE; }
"switch"        { return SWITCH; }
"case"          { return CASE; }
"break"         { return BREAK; }
"default"       { return DEFAULT; }
"return"        { return RETURN; }

"true"          { yylval.integerValue = 1; return BOOLEAN_LITERAL; }
"false"         { yylval.integerValue = 0; return BOOLEAN_LITERAL; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.stringValue = strdup(yytext); return VARIABLE; }
[0-9]+          { yylval.integerValue = atoi(yytext); return INTEGER_LITERAL; }
[0-9]*\.[0-9]+  { yylval.floatValue = atof(yytext); return FLOAT_LITERAL; }

"=="            { return EQ; }
"!="            { return NEQ; }
"<="            { return LE; }
">="            { return GE; }
"&&"            { return AND; }
"||"            { return OR; }

[-+*/%^=(){};:,<>!] { return yytext[0]; }

[ \t\n]         { /* ignore */ }
"//".* { /* ignore single line comments */ }
"/*"([^*]|\*+[^*/])*"\*"+"/" { /* Ignore multi-line comments */ }

.               { yyerror("Unknown character"); }

%%