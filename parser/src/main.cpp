#include <iostream>
#include "tree.hpp"
extern int yyparse(void);
extern FILE* yyin;
std::unique_ptr<tree_node> root;

const char* name = "tree.dot";
char const * header =
        "digraph AST {\n"
        "size=\"7\"\n"
        "node [shape = box];\n";
char const * end = "}\n";

int main(int argc, char* argv[])
{
    if (argc != 2) {
        std::cout<<"input file name"<<std::endl;
        return 1;
    }

    yyin = fopen(argv[1], "r");
    yyparse();
    std::ofstream tree_file(name);
    tree_file << header;
    root->serialize(tree_file);
    tree_file << end;
} 