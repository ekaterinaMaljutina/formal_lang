#include <iostream>
#include "tree.hpp"
extern int yyparse(void);
extern FILE* yyin;
std::unique_ptr<tree_node> root;

const char* AST_FILENAME = "tree.dot";
char const * AST_FILE_HEADER =
        "digraph AST {\n"
        "\trankdir=TB;\n"
        "size=\"6,5\"\n"
        "node [shape = box];\n";
char const * AST_FILE_FOOTER = "}\n";

void usage(const char* filename) {
    std::cerr << "Usage: " << std::endl << "\t" << filename 
    << " <input-file>" << std::endl;
}

int main(int argc, char* argv[])
{
    if (argc != 2) {
        usage(argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    yyparse();
    std::ofstream tree_file(AST_FILENAME);
    tree_file << AST_FILE_HEADER;
    root->serialize(tree_file);
    tree_file << AST_FILE_FOOTER;
} 