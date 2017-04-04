#include <vector>
#include <memory>
#include <fstream>

struct tree_node {
    tree_node(std::string const& str)
        :label(str)
    {}

    void add_child(tree_node* child) {
        children_.emplace_back(child);
    }

    void serialize(std::ostream& os) {
        for (auto & child : children_) {
            os << "\"" << label << "\""
                   << " -> "
                   << "\"" << child->label << "\"" << std::endl;
        }

        for (auto & child : children_)
            child->serialize(os);
    }

private:
    std::string label;
    std::vector<std::shared_ptr<tree_node>> children_;
};
