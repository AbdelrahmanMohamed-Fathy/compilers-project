.PHONY: all build clean test

clean:
	rm -rf bin

test:
	pytest

build:
	mkdir bin
	bison -Wcounterexamples -d -v grammer/parser.y --file-prefix="bin/parser"
	flex -o bin/lex.yy.c grammer/lexer.l
	gcc bin/parser.tab.c bin/lex.yy.c -o bin/compiler.exe -lm

all:
	$(MAKE) clean
	$(MAKE) build
	$(MAKE) test