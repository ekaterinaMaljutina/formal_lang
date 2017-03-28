%{
#include <iostream>
#include <cstdlib>

size_t position = 0;
size_t line_num = 0;

void colon(const char * t);
void token(char const * token_type);
void token_str(char const * token_type);
void end_position();
void count_lines();

bool filter = false;

%}

%option ansi-prototypes noyywrap yy_scan_string

ComMultLine 		[(][*][^*]*[*]+([^*)][^*]*[*]+)*[)]
KW 					"do"|"while"|"skip"|"read"|"write"|"if"|"then"|"else"
POWER 				\*\*
OP 					\+|-|\*|\/|%|==|!=|<|<=|>|>=|&&|\|\|
BOOL      			"true"|"false"
VAR 				[\_a-zA-Z][\_a-zA-Z0-9]* 
int 				\-?(0|[1-9][0-9]*(e[\+\-]?[0-9]*)?)
double_1  			\-?(0|([1-9][0-9]*))\.[0-9]*(e[\+\-]?[0-9]*)?
double_2  			\-?\.[0-9]+(e[\+\-]?[0-9]*)?
RATIONAL    		({int}|{double_1}|{double_2})
ASSIGN    			:=
SPACE     			[ ]
NEW_LINE  			\n
TAB       			\t
COLON 				[\(|\)|;]
COMMENT  			\/\/.*$
UNKNOWN   			.

%%

{ComMultLine} {
	count_lines();
	if (!filter) {
		yytext[0] = ' ';
		yytext[1] = ' ';
		int size = strlen(yytext);
		yytext[size-1] = ' ';
		yytext[size-2] = ' ';	
		token_str("multi_line_comment");
		std::cout<<std::endl;
	}
}

{POWER} {
	token("power");
	position += strlen(yytext) - 1;
	end_position();
	position++;
}

{KW} {
	token("kw");
	position += strlen(yytext) - 1;
	end_position();
	position++;
}

{COMMENT} {
	if (!filter) {
		token("comment");
		position += strlen(&yytext[2]) - 1;
		++line_num;
		end_position();
		position = 1;
	}else {
		position += strlen(&yytext[2]);
		++line_num;
	}

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

void count_lines() {
	size_t i = 0;
	for (i = 0; yytext[i] != '\0'; i++) {
		if (yytext[i] == '\n') {
			yytext[i] = ' ';
			position = 1;
			line_num++;
		}
		else {
			if (yytext[i] == '\t') {
				position += 8 - (position % 8); 
			} else { 
				position++;
			}
		}
	}
} 

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

void token_str(const char * type) {
	std::cout << type << " " <<  yytext;
}

void token(const char * type) {
	token_str(type);
	begin_position();
}

int main(int argc, char* argv[]) {
	if (argc == 2 && (strcmp(argv[1],"-f") || strcmp(argv[1],"-filter") )) {
		filter = true;
	}
	yylex();
}
