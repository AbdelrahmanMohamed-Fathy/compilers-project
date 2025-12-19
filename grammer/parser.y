%{ 
    #include "../src/parser.c"
    #include <math.h>
    
    int yylex();
    void yyerror(const char *s);
%}

%union {
    int integerValue;
    char *stringValue;
}

/* --- Tokens --- */
%token <integerValue>   INTEGER BOOLEAN
%token <stringValue>    VARIABLE

%token IF ELSE DO WHILE FOR SWITCH CASE
%token PLUS MINUS DIVIDE STAR REMAINDER HAT
%token EQUAL NOT AMPERSAND OR GREATER LESSER

/* --- Precedence & Associativity (Lowest to Highest) --- */


/* 1. Resolve Dangling Else */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

/* 2. Logic Operators */
%left OR
%left AMPERSAND

/* 3. Relational Operators */
%left EQUAL NOT GREATER LESSER 

/* 4. Arithmetic Operators */
%left PLUS MINUS
%left STAR DIVIDE REMAINDER

/* 5. Exponentiation*/
%right HAT

/* 6. Unary Operators (Highest Priority) */
%nonassoc UMINUS NOT_OP

/* Types */
%type <integerValue> Expression

%%

/* ================================================================ */
Program: Function

/* Declaration:  */

Function: FunctionDeclaration Statement

FunctionDeclaration: VARIABLE '(' ParameterList ')'
ParameterList: ParameterList ',' VARIABLE | VARIABLE | /* empty */

/* ================================================================ */
/* Statements */

Statement: Expression ';'
         | '{' StatementList '}' 
         | IfStatement
         | LoopStatement
         | SwitchStatement
         | ';'
         
StatementList: StatementList Statement 
             | Statement

IfStatement: IF '(' Expression ')' Statement %prec LOWER_THAN_ELSE
           | IF '(' Expression ')' Statement ELSE Statement

LoopStatement: WHILE '(' Expression ')' Statement
             | DO Statement WHILE '(' Expression ')'
             | FOR '(' Expression ';' Expression ';' Expression ')' Statement

CaseStatement: CASE INTEGER ':' Statement CaseStatement | /* empty */

SwitchStatement: SWITCH '(' Expression ')' '{' CaseStatement '}'


/* ================================================================ */
/* Combined Expressions */

Expression: 
      /* Constants & Vars */
      INTEGER                       { $$ = $1; }
    | BOOLEAN                       { $$ = $1; }
    | VARIABLE                      { /* $$ = lookup($1); */ }
    
    /* Binary Arithmetic */
    | Expression PLUS Expression    { $$ = $1 + $3; }
    | Expression MINUS Expression   { $$ = $1 - $3; }
    | Expression STAR Expression    { $$ = $1 * $3; }
    | Expression DIVIDE Expression  { $$ = $1 / $3; }
    | Expression REMAINDER Expression { $$ = $1 % $3; }
    | Expression HAT Expression     { $$ = pow($1, $3); }

    /* Relational (Returns 0 or 1) */
    | Expression EQUAL EQUAL Expression     { $$ = ($1 == $4); } 
    | Expression NOT EQUAL Expression       { $$ = ($1 != $4); }
    | Expression GREATER Expression         { $$ = ($1 > $3); }
    | Expression LESSER Expression          { $$ = ($1 < $3); }
    | Expression GREATER EQUAL Expression   { $$ = ($1 >= $4); }
    | Expression LESSER EQUAL Expression    { $$ = ($1 <= $4); }

    /* Logical */
    | Expression OR OR Expression               { $$ = $1 || $4; }
    | Expression AMPERSAND AMPERSAND Expression { $$ = $1 && $4; }

    /* Unary Operations */
    | MINUS Expression %prec UMINUS { $$ = -$2; }
    | NOT Expression %prec NOT_OP   { $$ = !$2; }

    /* Grouping */
    | '(' Expression ')'            { $$ = $2; }
%%