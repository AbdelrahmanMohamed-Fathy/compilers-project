%{ 
    #include "../src/lexer.c"
%}

/* Regex Rules 
*  NOTE: comments inside this section MUST be indented
*/
%%

    /* variables */
[\w_][\w0-9_]+  {return VARIABLE;}

    /* numerals and assorted symbols */
[()[\]{},:;]    {return yytext[0];}
[0-9]+          {return INTEGER;}
"-"             {return MINUS;}
"+"             {return PLUS;}
"="             {return EQUAL;}
"*"             {return STAR;}
"/"             {return DIVIDE;}
"^"             {return HAT;}
"%"             {return REMAINDER;}

    /* conditionals and assorted symbols */
"!"             {return NOT;}
"&"             {return AMPERSAND;}
">"             {return GREATER;}
"<"             {return LESSER;}
"|"             {return OR;}

    /* Keywords */
"do"            {return DO;}
"while"         {return WHILE;}
"for"           {return FOR;}
"if"            {return IF;}
"else"           {return ELSE;}
"switch"        {return SWITCH;}
"case"          {return CASE;}

    /* ignored */
[ \t\n]     {/*ignore white space*/}
(\/\/.\n)   {/*ignore single line comments*/}


%%