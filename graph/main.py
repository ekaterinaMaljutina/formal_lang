from grammar import CYK_with_tree, parse_file_with_grammar, \
    Normal_form_Chomsky
from generate_graph import create_random_graph
from generate_rna import generate_rna_task
from collections import defaultdict
import pydot
import sys


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
    print('vertex = {}, edges = {}'.format(len(vertexies), len(edges)))

    initialize = []
    if (grammar.get_start_symbol(), (grammar.eps_value,)) in grammar.get_rules():
        for vertex in vertexies:
            initialize.append((vertex, vertex, grammar.get_start_symbol()))

    non_terms_to_non_terms = defaultdict(list)
    for vertex_1, vertex_2, edge in edges:
        for l_exp, r_expr in grammar.get_rules():
            if len(r_expr) == 1 and r_expr[0].get_terminate() \
                    and str(r_expr[0]).strip("'") == edge:
                initialize.append((vertex_1, vertex_2, l_exp))
            if len(r_expr) == 2 and (not r_expr[0].get_terminate()
                                     or r_expr[1].get_terminate()):
                non_terms_to_non_terms[r_expr].append(l_exp)
    result = set(initialize)
    flag = True
    while flag:
        adding = set()
        start_vertex = defaultdict(list)
        for item in result:
            vertex, _, _ = item
            start_vertex[vertex].append(item)
        flag = False
        # print("vvvvv")
        for vertex_1_from, vertex_1_to, non_term_1 in result:
            for vertex_2_from, vertex_2_to, non_term_2 in start_vertex[vertex_1_to]:
                for non_term in non_terms_to_non_terms[(non_term_1, non_term_2)]:
                    item = (vertex_1_from, vertex_2_to, non_term)
                    if item not in result and item not in adding:
                        flag = True
                        adding.add(item)
        print('current len = {}, added = {}'.format(len(result), len(adding)))
        result.update(adding)
        sys.stdout.flush()

    return [item for item in result if item[2] == grammar.get_start_symbol()]


def main():
    alphabet = '()'
    file_with_grammar = 'rna.txt'
    # 'rna.txt'  # './simple_grammar'
    # graph = generate_rna_task()
    grammar = parse_file_with_grammar(file_with_grammar)
    grammar = Normal_form_Chomsky(grammar=grammar).get_cnf()
    print("current grammar {} ".format(grammar))
    alphabet_rna = 'acgt'
    graph = create_random_graph(alphabet_rna, [15, 20], [100, 150])
    # draw_graph(graph)

    res = cyk(graph=graph, grammar=grammar)
    print('\n result tuples:')
    res_path = '{} --> {}'
    res = [res_path.format(str(ver1), str(ver2)) for ver1, ver2, _ in res]
    for item in res:
        print(item)


if __name__ == '__main__':
    main()
