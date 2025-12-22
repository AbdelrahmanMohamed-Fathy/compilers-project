#ifndef QUADS_H
#define QUADS_H

typedef struct {
    char op[16];
    char arg1[32];
    char arg2[32];
    char res[32];
} Quad;

extern Quad quads[1000];
extern int quad_count;

char* new_label();
char* new_temp();
void emit(char* op, char* arg1, char* arg2, char* res);
void print_quads();

// Label Stack for BREAK support
void push_label(char* l);
char* pop_label();
char* top_label();

#endif