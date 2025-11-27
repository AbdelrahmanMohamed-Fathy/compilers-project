#include <stdio.h>
#include <stdlib.h>
extern FILE *yyin;

int yylex(void);

void yyerror(const char *errMsg)
{
    perror(errMsg);
    exit(1);
}

int main(int argc, char **argv)
{
    if (argc < 2)
    {
        perror("no input file");
    }

    yyin = fopen(argv[1], "r");
}