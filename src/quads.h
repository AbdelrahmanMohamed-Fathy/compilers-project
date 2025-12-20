#ifndef QUADS_H
#define QUADS_H

typedef struct {
    char op[10];
    char arg1[50];
    char arg2[50];
    char res[50];
} Quad;

extern Quad quads[1000];
extern int quad_count;

/* Function Prototypes */
char* new_temp();
void emit(char* op, char* arg1, char* arg2, char* res);
void print_quads();

#endif