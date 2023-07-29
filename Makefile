default:
	bison -d -v parser.y
	flex lexer.l
	gcc -c lex.yy.c parser.tab.c ast.c symbol_table.c
	gcc -o a lex.yy.o parser.tab.o ast.o symbol_table.o -lfl
clean:
	rm -f *.o *.exe *.stackdump *.output parser.tab.c parser.tab.h lex.yy.c a