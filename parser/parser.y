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



%type <integerValue> IntergerExpression Addition Multiplication Power IntegerTerm
%type <booleanValue> Statement StatementTerm

/* CFG Rules */
%%


Declaration: VARIABLE EQUAL Expression | Expression
Expression: IntergerExpression 

IntergerExpression: Addition
Addition: Addition PLUS Multiplication | Addition MINUS Multiplication | Multiplication
Multiplication: Multiplication STAR Power | Multiplication DIVIDE Power | MINUS Power | Power
Power: IntegerTerm HAT Power | IntegerTerm
IntegerTerm: INTEGER 
    | '(' IntergerExpression ')' {$$ = $2;}

Statement:  | Expression | StatementTerm
StatementTerm: '(' Statement ')' | BOOLEAN

%%