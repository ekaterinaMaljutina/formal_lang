

all: lex yacс
	g++ -std=c++11  \
	bin/lexer.cpp bin/parser.cpp src/main.cpp -o bin/parser

yacс:
	bison -o bin/parser.cpp -d -v src/parser.y 

lex: src/lexer.lex
	lex -o bin/lexer.cpp src/lexer.lex

clean:
	rm  bin/*
	rm tree.dot
	rm tree.pdf
	rm lexer.log

graph:
	dot -Tpdf  -Gdpi=350 -o tree.pdf tree.dot 
	evince tree.pdf
