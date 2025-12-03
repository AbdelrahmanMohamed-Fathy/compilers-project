%{ 
    #include "../src/parser.c"
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
%token REMAINDER

%token NOT
%token AMPERSAND
%token GREATER
%token LESSER
%token OR

%token WHILE
%token FOR
%token IF
%token ELSE
%token SWITCH
%token CASE

%type <integerValue> IntergerExpression Addition Multiplication Power IntegerTerm
/* %type <booleanValue> Statement StatementTerm */

/* CFG Rules */
%%
Program: Function


    /* Functions */
Function: FunctionDeclaration ';'
        | FunctionDeclaration Statement

FunctionDeclaration: VARIABLE '(' ParameterList ')'
ParameterList: ParameterList ',' VARIABLE | VARIABLE

    /* Generic Statements */
Statement: Expression ';'
         | '{' StatementList '}' 
         | IfStatement
         | ';'
             
StatementList: StatementList Statement 
             | Statement

Expression: VARIABLE 
          | IntergerExpression 
          /* | BooleanExpression  TODO make this*/

    /* IF statements */
IfStatement: IfHeader Statement ElseStatement

IfHeader: IF '(' Expression ')'

ElseStatement: ELSE Statement | ;

    /* Loop Statments */
/* LoopStatement: ForStatement | WhileStatement; */

    /* Integer operations*/
IntergerExpression: Addition

Addition: Addition PLUS Multiplication  {$$ = $1 + $3;}
        | Addition MINUS Multiplication {$$ = $1 - $3;}
        | Multiplication                {$$ = $1;}

Multiplication: Multiplication STAR Power   {$$ = $1 * $3;}
              | Multiplication DIVIDE Power {$$ = $1 / $3;}
              | MINUS Power                 {$$ = -1 * $2;} 
              | Power                       {$$ = $1;}

Power: IntegerTerm HAT Power    {$$ = pow($1,$3);}
     | IntegerTerm              {$$ = $1;}

IntegerTerm: '(' IntergerExpression ')' {$$ = $2;} 
           | INTEGER                    {$$ = $1;}

/* Statement:  | Expression | StatementTerm */
/* StatementTerm: '(' Statement ')' | BOOLEAN */

%%
