%{ 
    #include "../lexer/lexer.c"
%}

/* Regex Rules */
%%

// variables
[\w_][\w0-9_]+  {}

// numerals and assorted symbols
[0-9]+          {}
[()[\]{}]       {}
"-"             {}
"+"             {}
"="             {}
"*"             {}
"/"             {}
"^"             {}

// conditionals and assorted symbols
"!"             {}
"&"             {}
"%"             {}
">"             {}
"<"             {}
"|"             {}

// ignored
[ \t\n]     {/*ignore white space*/}
(\/\/.*$)   {/*ignore single line comments*/}


%%