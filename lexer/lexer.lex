%{
#include <iostream>
#include <cstdlib>

size_t position = 0;
size_t line_num = 0;

void colon(const char * t);
void token(char const * token_type);
void end_position();

%}

%option ansi-prototypes noyywrap yy_scan_string

KW "do"|"while"|"skip"|"read"|"write"|"if"|"then"|"else"
OP \+|-|\*|\/|%|==|!=|<|<=|>|>=|&&|\|\|
BOOL      "true"|"false"
VAR  [\_a-zA-Z][\_a-zA-Z0-9]* 
int 		\-?(0|[1-9][0-9]*(e[\+\-]?[0-9]*)?)
double_1  	\-?(0|([1-9][0-9]*))\.[0-9]*(e[\+\-]?[0-9]*)?
double_2  	\-?\.[0-9]+(e[\+\-]?[0-9]*)?
RATIONAL    ({int}|{double_1}|{double_2})
ASSIGN    :=
SPACE     [ ]
NEW_LINE  \n
TAB       \t
COLON [\(|\)|;]
COMMENT  \/\/.*$
UNKNOWN   .

%%

{KW} {
	token("kw");

	position += strlen(yytext) - 1;
	end_position();
	position++;
}

{COMMENT} {
	token("comment");
	position += strlen(&yytext[2]) - 1;
	++line_num;
	end_position();
	position = 1;

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
	colon(yytext);
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

void colon(const char * t) {
	std::cout << "colon " << t ;
	begin_position();
}

void token(const char * type) {
	std::cout << type << " " <<  yytext;
	begin_position();
}

int main() {
	yylex();
}
