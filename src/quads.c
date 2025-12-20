#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "quads.h"

Quad quads[1000];
int quad_count = 0;
int temp_count = 0;

char* new_temp() {
    char* t = malloc(10);
    sprintf(t, "t%d", temp_count++);
    return t;
}

void emit(char* op, char* arg1, char* arg2, char* res) {
    strcpy(quads[quad_count].op, op);
    strcpy(quads[quad_count].arg1, arg1 ? arg1 : "");
    strcpy(quads[quad_count].arg2, arg2 ? arg2 : "");
    strcpy(quads[quad_count].res, res);
    quad_count++;
}

void print_quads() {
    printf("\n--- Intermediate Code (Quadruples) ---\n");
    for(int i = 0; i < quad_count; i++) {
        printf("%d: (%s, %s, %s, %s)\n", i, quads[i].op, quads[i].arg1, quads[i].arg2, quads[i].res);
    }
}