%{ 
    #include "../lexer/lexer.c"
%}

/* Regex Rules 
*  NOTE: comments inside this section MUST be indented
*/
%%

    /* variables */
[\w_][\w0-9_]+  {return VARIABLE;}

    /* numerals and assorted symbols */
[0-9]+          {return INTEGER;}
[()[\]{}]       {return yytext[0];}
"-"             {return MINUS;}
"+"             {return PLUS;}
"="             {return EQUAL;}
"*"             {return STAR;}
"/"             {return DIVIDE;}
"^"             {return HAT;}

    /* conditionals and assorted symbols */
"!"             {}
"&"             {}
"%"             {}
">"             {}
"<"             {}
"|"             {}

    /* ignored */
[ \t\n]     {/*ignore white space*/}
(\/\/.*$)   {/*ignore single line comments*/}


%%