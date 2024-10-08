parser: lex.yy.c y.tab.c
	gcc -g lex.yy.c y.tab.c -o parser

lex.yy.c: y.tab.c lexer.l
	lex lexer.l

y.tab.c: parser.y
	yacc -d parser.y

clean: 
	rm -rf lex.yy.c y.tab.c y.tab.h parser