%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <string.h>

    /* Including logic files directly for simplicity in the build process */
    #include "../src/symbol_table.h"
    #include "../src/quads.h"

    int yylex(void);
    void yyerror(const char *s);
    extern int yylineno;
    extern FILE* yyin;

    int returnValue = 0;

    /* Semantic Helper: Check if variable exists before use */
    void check_usage(char* name) {
        if (lookup(name) == NULL) {
            fprintf(stderr, "Semantic Error at line %d: Variable '%s' used before declaration.\n", yylineno, name);
            returnValue = 1;
        }
    }
%}

%union {
    int integerValue;
    float floatValue;
    char *stringValue;
}

/* --- Tokens --- */
%token <integerValue> INTEGER_LITERAL BOOLEAN_LITERAL
%token <floatValue>   FLOAT_LITERAL
%token <stringValue>  VARIABLE
%token TYPE_INT TYPE_FLOAT TYPE_STRING TYPE_BOOL TYPE_VOID
%token IF ELSE DO WHILE FOR REPEAT UNTIL SWITCH CASE BREAK DEFAULT
%token EQ NEQ LE GE AND OR

/* --- Precedence & Associativity --- */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%right '='              
%left OR
%left AND
%left EQ NEQ
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/' '%'
%right '^'
%right '!' UMINUS       

/* Expressions return the string name of the variable/temporary */
%type <stringValue> Expression Assignment 
%type <integerValue> Type

%%

/* ================================================================ */
Program: StatementList { 
            printf((returnValue == 0) ? ("\n--- Compilation Successful ---\n") : ("\n--- Compilation Failed ---\n"));
            print_symbol_table(); 
            print_quads(); 
         } ;

StatementList: StatementList Statement 
             | /* empty */ 
             ;

Statement: Declaration ';'
         | Assignment ';'
         | Expression ';'    
         | IfStatement
         | LoopStatement
         | SwitchStatement
         | Block
         | ';'               
         ;

Block: '{' { enter_scope(); } StatementList '}' { exit_scope(); } ;

/* --- Declarations --- */
Declaration: Type VARIABLE { 
                insert($2, $1, current_scope); 
             }
           | Type VARIABLE '=' Expression { 
                insert($2, $1, current_scope);
                Symbol* s = lookup($2);
                if(s) s->is_initialized = 1;
                emit("=", $4, NULL, $2); // Quad: x = val
             }
           ;

Type: TYPE_INT {$$=1;} | TYPE_FLOAT {$$=2;} | TYPE_STRING {$$=3;} | TYPE_BOOL {$$=4;} | TYPE_VOID {$$=0;} ;

/* --- Assignment --- */
Assignment: VARIABLE '=' Expression {
                check_usage($1);
                Symbol* s = lookup($1);
                if(s) s->is_initialized = 1;
                emit("=", $3, NULL, $1);
                $$ = $1; 
            } ;

IfStatement: IF '(' Expression ')' Statement %prec LOWER_THAN_ELSE
           | IF '(' Expression ')' Statement ELSE Statement

LoopStatement: REPEAT {
                // mid-rule action: store the current quad count to jump back to
                $<integerValue>$ = quad_count; 
             } 
             Statement UNTIL '(' Expression ')' ';' {
                char target[10];
                sprintf(target, "L%d", $<integerValue>2);
                emit("IF_FALSE_GOTO", $6, NULL, target);
             }
             | WHILE '(' Expression ')' Statement
             | DO Statement WHILE '(' Expression ')' ';'
             | FOR '(' Assignment ';' Expression ';' Assignment ')' Statement
             ;

SwitchStatement: SWITCH '(' Expression ')' '{' CaseList '}' ;

CaseList: CaseList Case | /* empty */ ;

Case: CASE INTEGER_LITERAL ':' StatementList
    | DEFAULT ':' StatementList
    ;

/* --- Expressions (Quadruple Generation) --- */
Expression: INTEGER_LITERAL {
                char *val = malloc(16);
                sprintf(val, "%d", $1);
                $$ = val;
            }
          | FLOAT_LITERAL {
                char *val = malloc(16);
                sprintf(val, "%g", $1);
                $$ = val;
            }
          | VARIABLE {
                check_usage($1);
                Symbol* s = lookup($1);
                if(s && !s->is_initialized)
                    fprintf(stderr, "Warning at line %d: Variable '%s' may be uninitialized.\n", yylineno, $1);
                $$ = $1;
            }
          | Expression '+' Expression {
                char *t = new_temp();
                emit("+", $1, $3, t);
                $$ = t;
            }
          | Expression '-' Expression {
                char *t = new_temp();
                emit("-", $1, $3, t);
                $$ = t;
            }
          | Expression '*' Expression {
                char *t = new_temp();
                emit("*", $1, $3, t);
                $$ = t;
            }
          | Expression '/' Expression {
                char *t = new_temp();
                emit("/", $1, $3, t);
                $$ = t;
            }
          | Expression EQ Expression {
                char *t = new_temp();
                emit("==", $1, $3, t);
                $$ = t;
            }
          | Expression '<' Expression {
                char *t = new_temp();
                emit("<", $1, $3, t);
                $$ = t;
            }
          | '(' Expression ')' { 
                $$ = $2; 
            }
          ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error at line %d: %s\n", yylineno, s);
    returnValue = 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror(argv[1]);
            return 1;
        }
        yyin = file;
    }
    yyparse();
    return returnValue;
}