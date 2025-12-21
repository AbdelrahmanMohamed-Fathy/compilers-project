.PHONY: all build clean test quiet_test

clean:
	rm -rf bin

test:
	pytest -s --tb=no

quiet_test:
	pytest --tb=no

build:
	mkdir bin
	bison -Wcounterexamples -d -v grammer/parser.y --file-prefix="bin/parser"
	flex -o bin/lex.yy.c grammer/lexer.l
	gcc bin/parser.tab.c bin/lex.yy.c src/symbol_table.c src/quads.c -o bin/compiler.exe -lm

all:
	$(MAKE) clean
	$(MAKE) build
	$(MAKE) quiet_test