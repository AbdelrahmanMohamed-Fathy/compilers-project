%{ 
    #include "../parser/parser.c"
%}

%token INTEGER

/* CFG Rules */
%%

Expression: Expression '+' Term | Term
Term: Term '*' INTEGER | INTEGER

%%