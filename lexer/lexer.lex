%{
#include <iostream>
#include <cstdlib>

size_t position = 0;
size_t line_num = 0;

void colon();
void token(char const * token_type);
void end_position();

%}

%option ansi-prototypes noyywrap yy_scan_string

KW "do"|"while"|"skip"|"read"|"write"|"if"|"then"|"else"
OP \+|-|\*|\/|%|==|!=|<|<=|>|>=|&&|\|\|
BOOL      "true"|"false"
VAR  [\_a-zA-Z][a-zA-Z0-9]* 
RATIONAL    [0-9]+[.][0-9]*|[0-9]+
ASSIGN    :=
SPACE     [ ]
NEW_LINE  \n
TAB       \t
COLON [,|, |;]
UNKNOWN   .

%%

{KW} {
	token("kw");
	position += strlen(yytext) - 1;
	end_position();
	position++;
}

{OP} {
	token("op");
	position += strlen(yytext) - 1;
	position++;
	end_position();
}

{BOOL} {
	token("bool");
	position += strlen(yytext) - 1;
	end_position();
	position++;
}

{VAR} {
	token("var");
	position += strlen(yytext) - 1;
	end_position();
	position++;
}

{RATIONAL} {
	token("num");
	position += strlen(yytext) - 1;
	end_position();
	position++;
}

{ASSIGN} {
	token("assign");
	position += strlen(yytext) - 1;
	end_position();
	position++;
}

{SPACE} { 
	++position; 
}

{NEW_LINE} { 
	++line_num; 
	position = 1; 
}

{TAB} { 
	position += 4; 
}

{COLON}  {
	colon();
	end_position();
	++position;
}

{UNKNOWN} {
	token("unknown");
	end_position();
	++position;
	std::cout << "exit with exp unknow" <<std::endl; 
	std::exit(1);
}

%%

void begin_position() {
	std::cout << " ( " << line_num << " , " << position << " , ";
}

void end_position() {
	std::cout<< position << " )" << std::endl;
}

void colon() {
	std::cout << "colon" ;
	begin_position();
}

void token(const char * type) {
	std::cout << type << " " <<  yytext;
	begin_position();
}

int main() {
	yylex();
}
