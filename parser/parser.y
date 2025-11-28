%{ 
    #include "../parser/parser.c"
%}


%union {
    int integerValue;
    char *stringValue;
    int booleanValue;
}

%token <integerValue>   INTEGER
%token <stringValue>    VARIABLE
%token <booleanValue>   BOOLEAN

%token MINUS
%token PLUS
%token DIVIDE
%token STAR
%token EQUAL
%token HAT



%type <integerValue> Addition Multiplication Power Term

/* CFG Rules */
%%


Declaration: VARIABLE EQUAL Addition | Addition
Addition: Addition PLUS Multiplication | Addition MINUS Multiplication | Multiplication
Multiplication: Multiplication STAR Power | Multiplication DIVIDE Power | Power
Power: Term HAT Power | Term
Term: INTEGER 
    | '(' Addition ')' {$$ = $2;}

%%