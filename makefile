.PHONY: all build clean

clean:
	rm -rf bin

build:
	mkdir bin
	bison -d -v parser/parser.y --file-prefix="bin/parser"
	flex -o bin/lex.yy.c lexer/lexer.l
	gcc bin/parser.tab.c bin/lex.yy.c -o bin/compiler.exe

all:
	$(MAKE) clean
	$(MAKE) build