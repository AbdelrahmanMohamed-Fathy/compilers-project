%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "../src/symbol_table.h"
    #include "../src/quads.h"

    int yylex(void);
    void yyerror(const char *s);
    extern int yylineno;
    extern FILE* yyin;
    int returnValue = 0;

    /* Semantic Helper */
    void check_usage(char* name) {
        Symbol* s = lookup(name);
        if (s == NULL) {
            fprintf(stderr, "Semantic Error at line %d: Variable '%s' used before declaration.\n", yylineno, name);
            returnValue = 1; 
        } else if (s->is_initialized == 0) {
            fprintf(stderr, "Warning at line %d: Variable '%s' is used but may be uninitialized.\n", yylineno, name);
        }
    }
%}

%union {
    int integerValue;
    float floatValue;
    char *stringValue;
}

%token <integerValue> INTEGER_LITERAL BOOLEAN_LITERAL
%token <floatValue>   FLOAT_LITERAL
%token <stringValue>  VARIABLE
%token TYPE_INT TYPE_FLOAT TYPE_STRING TYPE_BOOL TYPE_VOID
%token IF ELSE DO WHILE FOR REPEAT UNTIL SWITCH CASE BREAK DEFAULT RETURN
%token EQ NEQ LE GE AND OR

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

%type <stringValue> Expression Assignment ArgumentList FunctionHeader FunctionStart
%type <integerValue> Type
%type <stringValue> IF_Marker

%%

Program: GlobalStatements { 
            printf((returnValue == 0) ? ("\n--- Compilation Successful ---\n") : ("\n--- Compilation Failed ---\n"));
            print_symbol_table(); 
            print_quads(); 
         } ;

GlobalStatements: GlobalStatements GlobalElement 
                | /* empty */ 
                ;

GlobalElement: FunctionDefinition 
             | FunctionPrototype
             | Statement 
             ;

/* --- Functions --- */
FunctionStart: Type VARIABLE {
    Symbol* s = lookup($2);
    if (s == NULL) {
        insert($2, $1, current_scope);
    }
    enter_scope(); // Enter scope BEFORE parameters are parsed
    $$ = $2;
};

/* 2. Update Header to use FunctionStart */
FunctionHeader: FunctionStart '(' Parameters ')' {
    $$ = $1; 
};

/* 3. Update Definition: Remove the extra enter_scope() */
FunctionDefinition: FunctionHeader {
    emit("FUNC_START", $1, NULL, NULL);
    // Scope was already entered in FunctionStart
} Block {
    emit("FUNC_END", $1, NULL, NULL);
    exit_scope();
};

/* 4. Update Prototype: Must call exit_scope() because it entered one */
FunctionPrototype: FunctionHeader ';' { exit_scope(); };

Parameters: ParameterList | TYPE_VOID | /* empty */ ;
ParameterList: ParameterList ',' Type VARIABLE { insert($4, $3, current_scope); }
             | Type VARIABLE { insert($2, $1, current_scope); } ;

/* --- Statements --- */
StatementList: StatementList Statement | /* empty */ ;

Statement: Declaration ';'
         | Assignment ';'
         | Expression ';'    
         | IfStatement
         | LoopStatement
         | SwitchStatement
         | BREAK ';' { emit("GOTO", top_label(), NULL, NULL); }
         | RETURN ';' { emit("RET", NULL, NULL, NULL); }
         | RETURN Expression ';' { emit("RET", $2, NULL, NULL); }
         | Block
         | ';'                
         ;

Block: '{' { enter_scope(); } StatementList '}' { exit_scope(); } ;

/* --- Control Flow --- */
IfStatement: IF '(' Expression ')' IF_Marker Statement %prec LOWER_THAN_ELSE {
                emit("LABEL", $5, NULL, NULL);
             }
           | IF '(' Expression ')' IF_Marker Statement ELSE {
                char *exitL = new_label();
                emit("GOTO", exitL, NULL, NULL);
                emit("LABEL", $5, NULL, NULL);
                $<stringValue>$ = exitL;
             } Statement {
                emit("LABEL", $<stringValue>8, NULL, NULL);
             } ;

IF_Marker: {
            char *label = new_label();
            emit("IF_FALSE_GOTO", $<stringValue>-1, NULL, label); 
            $$ = label;
        } ;

LoopStatement: WHILE {
                char *startL = new_label();
                emit("LABEL", startL, NULL, NULL);
                $<stringValue>$ = startL;
             } '(' Expression ')' {
                char *exitL = new_label();
                emit("IF_FALSE_GOTO", $4, NULL, exitL);
                push_label(exitL);
             } Statement {
                emit("GOTO", $<stringValue>2, NULL, NULL);
                emit("LABEL", pop_label(), NULL, NULL);
             } 
             | REPEAT {
                char *startL = new_label();
                char *exitL = new_label();
                emit("LABEL", startL, NULL, NULL);
                push_label(exitL);
                $<stringValue>$ = startL;
             } Statement UNTIL '(' Expression ')' ';' {
                emit("IF_FALSE_GOTO", $6, NULL, $<stringValue>2);
                emit("LABEL", pop_label(), NULL, NULL);
             }
             | FOR '(' { enter_scope(); } ForInit ';' {
                char *condL = new_label();
                emit("LABEL", condL, NULL, NULL);
                $<stringValue>$ = condL;
             } Expression ';' {
                char *exitL = new_label();
                char *bodyL = new_label();
                char *incrL = new_label();
                emit("IF_GOTO", $7, NULL, bodyL);
                emit("GOTO", exitL, NULL, NULL);
                emit("LABEL", incrL, NULL, NULL);
                push_label(exitL);
                push_label(incrL); 
                $<stringValue>$ = bodyL;
             } Assignment ')' {
                emit("GOTO", $<stringValue>6, NULL, NULL);
                emit("LABEL", $<stringValue>9, NULL, NULL);
             } Statement {
                char *incr = pop_label();
                emit("GOTO", incr, NULL, NULL);
                emit("LABEL", pop_label(), NULL, NULL);
                exit_scope(); // Remove the loop iterator from the symbol table
             } ;

ForInit: Type VARIABLE '=' Expression { 
                insert($2, $1, current_scope); 
                Symbol* s = lookup($2);
                if(s) s->is_initialized = 1;
                emit("=", $4, NULL, $2);
             }
       | Assignment 
       | /* empty */ 
       ;

SwitchStatement: SWITCH '(' Expression ')' {
                    char *exitL = new_label();
                    push_label(exitL);
                    $<stringValue>$ = $3;
                 } '{' CaseList '}' {
                    emit("LABEL", pop_label(), NULL, NULL);
                 } ;

CaseList: CaseList Case | /* empty */ ;
Case: CASE INTEGER_LITERAL ':' {
        char *nextCase = new_label();
        char *v = malloc(16); sprintf(v, "%d", $2);
        char *t = new_temp();
        emit("==", $<stringValue>-1, v, t);
        emit("IF_FALSE_GOTO", t, NULL, nextCase);
        $<stringValue>$ = nextCase;
      } StatementList {
        emit("LABEL", $<stringValue>4, NULL, NULL);
      }
    | DEFAULT ':' StatementList ;

/* --- Expressions --- */
Expression: INTEGER_LITERAL { char *v=malloc(16); sprintf(v,"%d",$1); $$=v; }
          | FLOAT_LITERAL   { char *v=malloc(16); sprintf(v,"%g",$1); $$=v; }
          | BOOLEAN_LITERAL { char *v=malloc(16); sprintf(v, $1 ? "true" : "false"); $$=v; }
          | VARIABLE        { check_usage($1); $$=$1; }
          | VARIABLE '(' ArgumentList ')' {
                check_usage($1);
                char *t = new_temp();
                emit("CALL", $1, NULL, t); 
                $$ = t;
            }
          | Expression '+' Expression { char *t=new_temp(); emit("+",$1,$3,t); $$=t; }
          | Expression '-' Expression { char *t=new_temp(); emit("-",$1,$3,t); $$=t; }
          | Expression '*' Expression { char *t=new_temp(); emit("*",$1,$3,t); $$=t; }
          | Expression '/' Expression { char *t=new_temp(); emit("/",$1,$3,t); $$=t; }
          | Expression '%' Expression { char *t=new_temp(); emit("%",$1,$3,t); $$=t; }
          | Expression '^' Expression { char *t=new_temp(); emit("^",$1,$3,t); $$=t; }
          | Expression EQ  Expression { char *t=new_temp(); emit("==",$1,$3,t); $$=t; }
          | Expression NEQ Expression { char *t=new_temp(); emit("!=",$1,$3,t); $$=t; }
          | Expression LE  Expression { char *t=new_temp(); emit("<=",$1,$3,t); $$=t; }
          | Expression GE  Expression { char *t=new_temp(); emit(">=",$1,$3,t); $$=t; }
          | Expression '<' Expression { char *t=new_temp(); emit("<",$1,$3,t); $$=t; }
          | Expression '>' Expression { char *t=new_temp(); emit(">",$1,$3,t); $$=t; }
          | Expression AND Expression { char *t=new_temp(); emit("&&",$1,$3,t); $$=t; }
          | Expression OR  Expression { char *t=new_temp(); emit("||",$1,$3,t); $$=t; }
          | '!' Expression            { char *t=new_temp(); emit("!",$2,NULL,t); $$=t; }
          | '-' Expression %prec UMINUS { char *t=new_temp(); emit("UMINUS",$2,NULL,t); $$=t; }
          | '(' Expression ')'        { $$ = $2; }
          ;

ArgumentList: ArgumentList ',' Expression { emit("PARAM", $3, NULL, NULL); }
            | Expression { emit("PARAM", $1, NULL, NULL); }
            | /* empty */ { $$ = "0"; }
            ;

Declaration: Type VARIABLE { insert($2, $1, current_scope); }
           | Type VARIABLE '=' Expression { 
                insert($2, $1, current_scope);
                Symbol* s = lookup($2);
                if(s) s->is_initialized = 1;
                emit("=", $4, NULL, $2);
             } ;

Type: TYPE_INT {$$=1;} | TYPE_FLOAT {$$=2;} | TYPE_STRING {$$=3;} | TYPE_BOOL {$$=4;} | TYPE_VOID {$$=0;} ;

Assignment: VARIABLE '=' Expression {
                check_usage($1);
                Symbol* s = lookup($1);
                if(s) s->is_initialized = 1;
                emit("=", $3, NULL, $1);
                $$ = $1; 
            } ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error at line %d: %s\n", yylineno, s);
    returnValue = 1;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) { perror(argv[1]); return 1; }
        yyin = file;
    }
    yyparse();
    return returnValue;
}