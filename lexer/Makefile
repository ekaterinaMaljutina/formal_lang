
all: lex 
	g++ lexer.cpp -o lexer

lex: lexer.lex
	lex -o lexer.cpp lexer.lex

clean:
	rm lexer.cpp
	rm ./lexer
	rm out.test

test: all
	cat test.test > out.test
	echo "result:" >> out.test
	cat test.test | ./lexer >> out.test 
	echo >> out.test 
	cat test1.test >> out.test
	echo "result:" >> out.test
	cat test1.test | ./lexer >> out.test
