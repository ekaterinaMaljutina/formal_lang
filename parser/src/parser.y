%{
#include <iostream>
#include <string>
#include <memory>
#include <cstdint>
#include "parser.hpp"
#include <fstream>
#include <sstream>
#include "../src/tree.hpp"

extern size_t position_begin;
extern size_t position_end;
extern size_t line_num;

extern int yylex(void);

extern std::unique_ptr<tree_node> root;

void yyerror(const char* message) {
	std::cerr << "Parse error! " << 
	"Message: " << message << std::endl;
	std::cerr << "line = " << line_num << ", pos_begin = " << position_begin <<", pos_end = "<< position_end	 << std::endl;
}

%}

%union{
    const char* str;
    struct tree_node* node;
}

%token <str> DO
%token <str> WHILE
%token <str> WRITE
%token <str> READ
%token <str> IF
%token <str> THEN
%token <str> ELSE
%token <str> VAR
%token <str> RATIONAL
%token <str> ASSIGN
%token <str> SEMICOLON
%token <str> OP_0
%token <str> OP_1
%token <str> OP_2
%token <str> OP_3
%token <str> OP_4
%token <str> OP_5
%token <str> BOOL
%token <str> SKIP
%token <str> END
%token <str> BEGIN_
%token LPAREN
%token RPAREN

%type <node> program
%type <node> statement
%type <node> expr_term
%type <node> expr
%type <node> statement_term

%left OP_5
%left OP_4
%left OP_3
%left OP_2
%left OP_1
%left OP_0

%start program

%%
program:
	statement
	{
		$$ = $1;
		root.reset($$);
	};

expr_term:
	BOOL 
	{
		$$ = new tree_node(std::string($1));
		delete[] $1;
	}
	|
	VAR
	{
		std::cout<<"var = " << std::string($1)<<std::endl;
		$$ = new tree_node(std::string($1));
		delete[] $1;
	}
	|
	RATIONAL
	{
		$$ = new tree_node(std::string($1));
		delete[] $1;
	};

expr:
	expr_term
	{
		$$ = $1;
	}
	|
	expr OP_0 expr
	{
		$$ = new tree_node(std::string($2));
		$$->add_child($1);
		$$->add_child($3);
		delete[] $2;
	}
	|
	expr OP_1 expr
	{
		$$ = new tree_node(std::string($2));
		$$->add_child($1);
		$$->add_child($3);
		delete[] $2;
	}
	|
	expr OP_2 expr
	{
		$$ = new tree_node(std::string($2));
		$$->add_child($1);
		$$->add_child($3);
		delete[] $2;
	}
	|
	expr OP_3 expr
	{
		$$ = new tree_node(std::string($2));
		$$->add_child($1);
		$$->add_child($3);
		delete[] $2;
	}
	|
	expr OP_4 expr
	{
		$$ = new tree_node(std::string($2));
		$$->add_child($1);
		$$->add_child($3);
		delete[] $2;
	}
	|
	expr OP_5 expr
	{
		$$ = new tree_node(std::string($2));
		$$->add_child($1);
		$$->add_child($3);
		delete[] $2;
	}
	|
	LPAREN expr_term RPAREN 
	{
		$$ = $2;
	}
	|
	LPAREN expr OP_0 expr RPAREN
	{
		$$ = new tree_node(std::string($3));
		$$->add_child($2);
		$$->add_child($4);
		delete[] $3;
	}
	|
	LPAREN expr OP_1 expr RPAREN
	{
		$$ = new tree_node(std::string($3));
		$$->add_child($2);
		$$->add_child($4);
		delete[] $3;
	}
	|
	LPAREN expr OP_2 expr RPAREN
	{
		$$ = new tree_node(std::string($3));
		$$->add_child($2);
		$$->add_child($4);
		delete[] $3;
	}
	|
	LPAREN expr OP_3 expr RPAREN
	{
		$$ = new tree_node(std::string($3));
		$$->add_child($2);
		$$->add_child($4);
		delete[] $3;
	}
	|
	LPAREN expr OP_4 expr RPAREN
	{
		$$ = new tree_node(std::string($3));
		$$->add_child($2);
		$$->add_child($4);
		delete[] $3;
	}
	|
	LPAREN expr OP_5 expr RPAREN
	{
		$$ = new tree_node(std::string($3));
		$$->add_child($2);
		$$->add_child($4);
		delete[] $3;
	};


statement:
	statement_term
	{
		$$ = $1;
	}
	|
	statement SEMICOLON statement_term
	{
		std::cout<<std::string($2)<<std::endl;
		$$ = new tree_node(std::string($2));
		$$->add_child($1);
		$$->add_child($3);
		delete[] $2;
	};


statement_term:
	SKIP 
	{
		std::cout<<std::string($1)<<" "<<std::endl;
		$$ = new tree_node(std::string($1));
		delete[] $1;
	}
	|
	VAR ASSIGN expr
	{
		std::cout<<std::string($1)<<" "<<std::string($2)<<std::endl;
		$$ = new tree_node($2);
		auto variable_node = new tree_node($1);
		$$->add_child(variable_node);
		$$->add_child($3);
		delete[] $1; delete[] $2;
	}
	|
	WRITE LPAREN  expr RPAREN 
	{
		std::cout<<std::string($1)<<" "<<std::endl;
		$$ = new tree_node(std::string($1));
		$$->add_child($3);
		delete[] $1;
	}
	|
	READ LPAREN  VAR RPAREN 
	{
		std::cout<<std::string($1)<<" "<<std::string($3)<<std::endl;
		$$ = new tree_node(std::string($1));
		$$->add_child(new tree_node(std::string($3)));
		delete[] $1;
	}
	|
	IF expr THEN statement ELSE BEGIN_ statement END
	{
		std::stringstream ss;
		ss << $1 << " " << $3 << " " << $5 << " " << $6 <<std::endl;
		$$ = new tree_node(ss.str());
		$$->add_child($2);
		$$->add_child($4);
		$$->add_child($7);
		delete[] $1; delete[] $3; delete[] $5;delete[] $6;
	}
	|
	IF expr THEN BEGIN_ statement END ELSE statement 
	{
		std::stringstream ss;
		ss << $1 << " " << $3 << " " << $4 << " " << $6 << " " << $7<<std::endl;
		$$ = new tree_node(ss.str());
		$$->add_child($2);
		$$->add_child($5);
		$$->add_child($8);
		delete[] $1; delete[] $3; delete[] $4;delete[] $6; delete[] $7;
	}
	|
	IF expr THEN statement ELSE statement 
	{
		std::stringstream ss;
		std::cout << $1 << " " << $3 << " " << $5 <<std::endl;
		ss << $1 << " " << $3 << " " << $5 ;
		$$ = new tree_node(ss.str());
		$$->add_child($2);
		$$->add_child($4);
		$$->add_child($6);
		delete[] $1; delete[] $3; delete[] $5;
	}
	|
	WHILE expr DO BEGIN_ statement END
	{
		$$ = new tree_node(std::string($1) + " " + $3 + " " + $4 + " " + $6);
		$$->add_child($2);
		$$->add_child($5);
		delete[] $1;
		delete[] $3;
		delete[] $4;
		delete[] $6;
	}
	/*|
	WHILE expr DO statement
	{
		$$ = new tree_node(std::string($1) + " " + $3);
		$$->add_child($2);
		$$->add_child($4);
		delete[] $1;
		delete[] $3;
	}*/;

%%