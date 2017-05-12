from generate_graph import create_random_graph
import numpy as np
import random


alphabet = 'acgt'
comlit_pair = ['ac', 'ca', 'gt', 'tg']


def generate_rna_task():
    graph = create_random_graph(alphabet, [500, 550], [1000, 1100])
    grammar = generate_grammar_rna()
    with open('rna.txt', 'w') as f:
        f.write(grammar)
    return graph


def generate_grammar_rna():
    def temp(item):
        return ' | '.join(map(lambda s: '\'{}\' '.format(s), item))

    def circle(item=alphabet):
        circle = 'O = {}\n'.format(temp(item))
        circle += 'T = O O \n'
        circle += 'C = T T | O T | T O\n'
        return circle

    grammar = 'S \n'

    item_S = ""
    item_D = ""
    item_B = ""
    item_G = ""
    for i in range(4):
        pair = comlit_pair[i]
        item_S += '{} | {} {} '.format(
            ' \'{}\' D \'{}\' '.format(pair[0], pair[1]),
            ' \'{}\' S \'{}\' '.format(pair[0], pair[1]),
            "" if i == 3 else '|'
        )
        item_D += '\'{}\' B B B \'{}\' {}'.format(pair[0], pair[1], "" if i == 3 else '|')
        item_B += '{} | {} {} '.format(
            ' \'{}\' G \'{}\' '.format(pair[0], pair[1]),
            ' \'{}\' B \'{}\' '.format(pair[0], pair[1]),
            "" if i == 3 else '|'
        )
        item_G += '\'{}\' C \'{}\' {}'.format(pair[0], pair[1], "" if i == 3 else '|')

    grammar += 'S = {} \n'.format(item_S)
    grammar += 'D = {} \n'.format(item_D)
    grammar += 'B = {} \n'.format(item_B)
    grammar += 'G = {} \n'.format(item_G)
    grammar += circle()
    return grammar

# generate_grammar_rna()
