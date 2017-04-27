import random
from grammar import term_str


class get_new_name:
    __current_name__ = 0

    @staticmethod
    def get():
        new_name = "X" + str(get_new_name.__current_name__)
        new_value = term_str(value=new_name, terminate=False)
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

    return vertex_list, edges_list


    # a = 'abc'
    # vertex, edge = create_random_graph(a)
    # vertex = [str(value) for value in vertex]
    # print(vertex)
