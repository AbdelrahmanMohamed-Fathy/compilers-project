#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;
int current_scope = 0;

extern int returnValue;

void insert(char* name, int type, int scope) {
    // Check if already declared in SAME scope (Semantic Error check)
    for(int i = 0; i < symbolCount; i++) {
        if(strcmp(symbolTable[i].name, name) == 0 && symbolTable[i].scope == scope) {
            fprintf(stderr, "Semantic Error: Variable '%s' already declared in this scope.\n", name);
            returnValue = 1;
            return;
        }
    }
    strcpy(symbolTable[symbolCount].name, name);
    symbolTable[symbolCount].type = type;
    symbolTable[symbolCount].scope = scope;
    symbolTable[symbolCount].is_initialized = 0;
    symbolCount++;
}

Symbol* lookup(char* name) {
    // Search from current scope upwards
    for(int i = symbolCount - 1; i >= 0; i--) {
        if(strcmp(symbolTable[i].name, name) == 0 && symbolTable[i].scope <= current_scope) {
            return &symbolTable[i];
        }
    }
    return NULL;
}

void enter_scope() { current_scope++; }
void exit_scope() { 
    // Optional: Clean up symbols of the exiting scope
    current_scope--; 
}

void print_symbol_table() {
    printf("\n%-15s %-10s %-10s %-10s\n", "Identifier", "Type", "Scope", "Init?");
    printf("--------------------------------------------------\n");
    for (int i = 0; i < symbolCount; i++) {
        printf("%-15s %-10d %-10d %-10s\n", 
               symbolTable[i].name, 
               symbolTable[i].type, 
               symbolTable[i].scope,
               symbolTable[i].is_initialized ? "Yes" : "No");
    }
}