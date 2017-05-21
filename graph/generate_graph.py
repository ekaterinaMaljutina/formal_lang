import random
from grammar import term_str


class get_new_name:
    __current_name__ = 0

    @staticmethod
    def get():
        new_name = "X" + str(get_new_name.__current_name__)
        new_value = str(term_str(value=new_name, terminate=False))
        get_new_name.__current_name__ += 1
        return new_value


def create_random_graph(alphabet, size_vertex=[3, 4], size_edge=[5, 5]):
    vertexies = random.randint(size_vertex[0], size_vertex[1])
    edges = random.randint(size_edge[0], size_edge[1])

    vertex_list = []
    for i in range(vertexies):
        vertex_list.append(get_new_name.get())

    edges_list = []
    for i in range(edges):
        vertex_1 = random.choice(vertex_list)
        vertex_2 = random.choice(vertex_list)
        edge = random.choice(alphabet)
        edges_list.append((vertex_1, vertex_2, edge))

    # save_graph(edges_list, './graph_test/500_rna')
    return vertex_list, edges_list


def save_graph(edges_list, filename):
    with open(filename, 'w') as f:
        for vertex_1, vertex_2, edge in edges_list:
            f.write("{} {} {} \n".format(vertex_1[1:], vertex_2[1:], edge))


# create_random_graph('acgt', [70, 75], [500, 510])
