all:
	bison -d -v parser.y
	flex lexerl.l
	gcc parser.tab.c lex.yy.c -o compiler.exe