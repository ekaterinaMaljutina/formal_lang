from grammar import CYK_with_tree, parse_file_with_grammar, \
    Normal_form_Chomsky
from generate_graph import create_random_graph
from collections import defaultdict
import pydot


def draw_graph(graph, filename='dots.dot'):
    vertexies, edges = graph
    graph = pydot.Dot(graph_type='digraph')
    str_to_node = {}
    for vertex in vertexies:
        node = pydot.Node(str(vertex))
        graph.add_node(node)
        str_to_node[str(vertex)] = node

    for vertex_1, vertex_2, edge in edges:
        node_1 = str_to_node[str(vertex_1)]
        node_2 = str_to_node[str(vertex_2)]
        graph.add_edge(pydot.Edge(node_1, node_2, label=edge))
    del str_to_node
    graph.write(filename)
    graph.write_png(filename + '.png')


def cyk(graph, grammar):
    vertexies, edges = graph

    result = []
    if (grammar.get_start_symbol(), (grammar.eps_value,)) in grammar.get_rules():
        for vertex in vertexies:
            result.append((vertex, vertex, grammar.get_start_symbol()))

    for vertex_1, vertex_2, edge in edges:
        for (l_exp, r_expr) in grammar.get_rules():
            if len(r_expr) == 1 and r_expr[0].get_terminate() \
                    and str(r_expr[0]).strip("'") == edge:
                result.append((vertex_1, vertex_2, l_exp))

    non_terms_to_non_terms = defaultdict(list)
    for (l_exp, r_expr) in grammar.get_rules():
        if len(r_expr) == 2 and (not r_expr[0].get_terminate()
                                 or r_expr[1].get_terminate()):
            non_terms_to_non_terms[tuple(r_expr)].append(l_exp)

    result_set = set(result)
    flag = True
    while flag:
        adding = set()
        start_vertex = defaultdict(list)
        for item in result_set:
            vertex, _, _ = item
            start_vertex[vertex].append(item)
        flag = False
        for vertex_1_from, vertex_1_to, non_term_1 in result_set:
            for vertex_2_from, vertex_2_to, non_term_2 in start_vertex[vertex_1_to]:
                for non_term in non_terms_to_non_terms[(non_term_1, non_term_2)]:
                    item = (vertex_1_from, vertex_2_to, non_term)
                    if item not in result_set and item not in adding:
                        flag = True
                        adding.add(item)
        result_set.update(adding)

    return [item for item in result_set if item[2] == grammar.get_start_symbol()]


def main():
    alphabet = '()'
    file_with_grammar = './simple_grammar'
    grammar = parse_file_with_grammar(file_with_grammar)
    grammar = Normal_form_Chomsky(grammar=grammar).get_cnf()
    print("current grammar {} ".format(grammar))
    graph = create_random_graph(alphabet)
    draw_graph(graph)

    res = cyk(graph=graph, grammar=grammar)
    print('\n result tuples:')
    res_path = '{} --> {}'
    res = [res_path.format(str(ver1), str(ver2)) for ver1, ver2, _ in res]
    for item in res:
        print(item)

if __name__ == '__main__':
    main()
