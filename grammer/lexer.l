%{
    #include <string.h>
    #include <stdlib.h>
    #include "parser.tab.h" /* Connects to the tokens defined in parser.y */
    
    extern void yyerror(const char *msg);
%}

%option noyywrap
%option yylineno

%%

    /* --- Keywords --- */
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

"true"          { yylval.integerValue = 1; return BOOLEAN_LITERAL; }
"false"         { yylval.integerValue = 0; return BOOLEAN_LITERAL; }

    /* --- Variables --- */
[a-zA-Z_][a-zA-Z0-9_]* { 
    yylval.stringValue = strdup(yytext); 
    return VARIABLE; 
}

    /* --- Numbers --- */
[0-9]+          { yylval.integerValue = atoi(yytext); return INTEGER_LITERAL; }
[0-9]*\.[0-9]+  { yylval.floatValue = atof(yytext); return FLOAT_LITERAL; }

    /* --- Multi-Char Operators --- */
"=="            { return EQ; }
"!="            { return NEQ; }
"<="            { return LE; }
">="            { return GE; }
"&&"            { return AND; }
"||"            { return OR; }

    /* --- Single Char Operators --- */
    /* This returns the ASCII char to the parser (e.g., '+' returns 43) */
[-+*/%^=(){};:,<>] { return yytext[0]; }

    /* --- Whitespace & Comments --- */
[ \t\n]         { /* ignore */ }
"//".* { /* ignore single line comments */ }

.               { yyerror("Unknown character"); }

%%