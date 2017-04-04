%{
#include <iostream>
#include <cstdlib>
#include <string>
#include <fstream>
#include <sstream>
#include "map"
#include "parser.hpp"

const size_t BUFFER_SIZE = 1024;

std::ofstream lexer_log("lexer.log");

size_t position_begin= 1;
size_t position_end = 1;
size_t line_num = 1;

std::map<std::string, yytokentype> kw_types{
	{ "do", DO },
	{ "while", WHILE },
	{ "skip", SKIP },
	{ "read", READ },
	{ "write", WRITE },
	{ "if", IF },
	{ "then", THEN },
	{ "else", ELSE },
	{ "begin", BEGIN_ },
	{ "end", END }
};


const char* describe_token();
void semicolon();
void token(char const * token_type);
void token_str(char const * token_type);
void end_position();
void count_lines();
void operation(char const * op);

bool filter = true;

%}

%option ansi-prototypes noyywrap yy_scan_string

ComMultLine 		[(][*][^*]*[*]+([^*)][^*]*[*]+)*[)]
KW 					"do"|"while"|"skip"|"read"|"write"|"if"|"then"|"else"|"begin"|"end"
OP_0 				\*|\/|%
OP_1				\+|\-
OP_2 				<|<=|>|>=
OP_3				==|!=
OP_4				&&
OP_5				\|\|
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
LPAREN    			\(
RPAREN    			\)
SEMICOLON 			;
COMMENT  			\/\/.*$
UNKNOWN   			.

%%

{ComMultLine} {
position_begin = position_end;
	if (!filter) {
		yytext[0] = ' ';
		yytext[1] = ' ';
		int size = strlen(yytext);
		yytext[size-1] = ' ';
		yytext[size-2] = ' ';	
		count_lines();
		lexer_log<<std::endl;
	} else {
		count_lines();
	}
}

{KW} {
	position_begin = position_end;
	token("kw");
	position_end += strlen(yytext);
	end_position();
	yylval.str = describe_token();
	return kw_types[yytext];
}

{COMMENT} {
	if (!filter) {
		token("comment");
		position_begin+= strlen(&yytext[2]);
		//++line_num;
		end_position();
		position_begin= 1;
	}else {
		position_begin += strlen(&yytext[2]);
		//++line_num;
	}

}

{OP_0} {
	operation("op_0");
	return OP_0;
}

{OP_1} {
	operation("op_1");
	return OP_1;
}


{OP_2} {
	operation("op_2");
	return OP_2;
}


{OP_3} {
	operation("op_3");
	return OP_3;
}


{OP_4} {
	operation("op_4");
	return OP_4;
}

{OP_5} {
	operation("op_5");
	return OP_5;
}

{BOOL} {
	position_begin = position_end;
	token("bool");
	position_end += strlen(yytext);
	end_position();
	yylval.str = describe_token();
	return BOOL;
}

{VAR} {
	position_begin = position_end;
	token("var");
	position_end+= strlen(yytext);
	end_position();
	yylval.str = describe_token();
	return VAR;
}

{RATIONAL} {
	position_begin = position_end;
	token("num");
	position_end += strlen(yytext);
	end_position();
	yylval.str = describe_token();
	return RATIONAL;
}

{ASSIGN} {
	position_begin = position_end;
	token("assign");
	position_end += strlen(yytext);
	end_position();
	yylval.str = describe_token();
	return ASSIGN;
}

{SPACE} { 
	position_begin = position_end;
	++position_begin;
	++position_end; 
}

{NEW_LINE} { 
	++line_num; 
	position_begin= 1; 
	position_end = 1;
}

{TAB} { 
	position_begin = position_end;
	position_end += 4; 
}
{LPAREN} {
	position_begin = position_end;
	++position_end;
	return LPAREN;
}

{RPAREN} {
	position_begin = position_end;
	++position_end;
	return RPAREN;
}

{SEMICOLON}  {
	position_begin = position_end;
	semicolon();
	++position_end;
	yylval.str = describe_token();
	return SEMICOLON;
}


{UNKNOWN} {
	lexer_log << "exit with exp unknow" <<std::endl; 
	std::exit(1);
}

%%

void count_lines() {
	size_t i = 0;
	//lexer_log<<"MLC ";
	//lexer_log<< "begin (line = " << line_num << ", pos_begin = " << position<< ")";
	for (i = 0; yytext[i] != '\0'; i++) {
		if (yytext[i] == '\n') {
			yytext[i] = ' ';
			position_end = 1;
			position_begin = 1;
			line_num++;
		}
		else {
			if (yytext[i] == '\t') {
				position_end += 8 - (position_end% 8); 
			} else { 
				position_end++;
			}
		}
	}
	//token_str("");
	//lexer_log<<" end (line = " << line_num << ", pos =  " << position<< ")"<<std::endl;
	
} 

void operation(char const * op) {
	position_begin = position_end;
	token(op);
	position_end+= strlen(yytext);
	end_position();
	yylval.str = describe_token();
}

void begin_position() {
	lexer_log << "(line = " << line_num << ", pos_begin = " << position_begin<< ", end_pos = ";
}

void end_position() {
	lexer_log<< position_end<< ")" << std::endl;
}

void semicolon() {
	lexer_log << "semicolon" <<"\t\t";
	begin_position();
	lexer_log << std::endl;
}

void token_str(const char * type) {
	lexer_log << type << "\t\t" <<  yytext <<"\t\t";
}

void token(const char * type) {
	token_str(type);
	begin_position();
}

const char* describe_token(){
	char* buf = new char[BUFFER_SIZE];
	sprintf(buf, "%s(%zd : %zd : %zd)", yytext, line_num, position_begin, position_end);
	return buf;
}