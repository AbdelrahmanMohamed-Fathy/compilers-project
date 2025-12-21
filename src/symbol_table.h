#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define MAX_SYMBOLS 500

typedef struct
{
    char name[50];
    int type; // 1: INT, 2: FLOAT, 3: BOOL, etc.
    int scope;
    int is_initialized; // For semantic check: "Variables used before being initialised"
} Symbol;

/* External declarations so variables are shared across files */
extern Symbol symbolTable[MAX_SYMBOLS];
extern int symbolCount;
extern int current_scope;

/* Function Prototypes */
void insert(char *name, int type, int scope);
Symbol *lookup(char *name);
void enter_scope();
void exit_scope();
void print_symbol_table();

#endif