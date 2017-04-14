eps = "eps"


class term_str:
    def __init__(self, value, terminate):
        self.__value__ = value
        self.__terminate__ = terminate

    def get_terminate(self):
        return self.__terminate__

    def get_str(self):
        return "{} {}".format(self.__value__, self.__terminate__)

    def __str__(self):
        return "'{}'".format(self.__value__) if self.__terminate__ else self.__value__

    def __hash__(self):
        return hash(self.get_str())

    def __eq__(self, other):
        return self.get_str() == other.get_str()


class grammar_save():
    eps_value = term_str(value="eps", terminate=True)

    def __init__(self, start, rules_list):
        self.__start_symbol__ = start
        self.__rules_list__ = rules_list

    def set_rules(self, rules):
        self.__rules_list__ = rules
        return self

    def get_rules(self):
        return self.__rules_list__

    def get_start_symbol(self):
        return self.__start_symbol__

    def set_start_symbol(self, start):
        self.__start_symbol__ = start

    def __str__(self):
        result = [str(self.__start_symbol__)]
        rules = {}
        for (l_expr, r_expr) in self.__rules_list__:
            value = ' '.join(map(str, r_expr))
            if l_expr in rules:
                rules[l_expr].append(value)
            else:
                rules[l_expr] = [value]
        for (l_expr, betas) in rules.items():
            result.append(str(l_expr) + " = " + ' | '.join(betas))
        return '\n'.join(result)


class Normal_form_Chomsky:
    def __init__(self, grammar):
        self.__grammar__ = grammar
        self.__current_name__ = 0

    def get_cnf(self):
        self.__remove_longest_rule()
        self.__remove_eps_rules()
        self.__remove_chain_rules__()
        self.__remove_useless_rules__()
        self.__remove_pair_terminals()
        self.__remove_useless_rules__()
        return self.__grammar__

    def __get_new__(self):
        new_name = "X" + str(self.__current_name__)
        new_value = term_str(value=new_name, terminate=False)
        self.__current_name__ += 1
        return new_value

    def __get_old__(self, rules, new_value):
        for (l_expr, r_expr) in rules:
            if r_expr == new_value:
                return l_expr
        return None

    def __add_eps_rules__(self, grammar, eps_term):
        flag_added = False
        for (l_expr, r_expr) in grammar.get_rules():
            if l_expr not in eps_term:
                mask = [item in eps_term for item in r_expr]
                if all(mask):
                    flag_added = True
                    eps_term.add(l_expr)
        return flag_added, eps_term

    def __add_pair__(self, pair):
        flag_added = False

        for (l_expr, r_expr) in pair:
            for (l, r) in self.__grammar__.get_rules():
                if len(r_expr) == 1 and \
                                r_expr[0] == l and (l_expr, r) not in pair:
                    pair.append((l_expr, r))
                    flag_added = True
        return flag_added, pair

    def __add_term__(self, term):

        flag_added = False

        for (l_expr, r_expr) in self.__grammar__.get_rules():
            if l_expr not in term:
                mask = [item in term for item in r_expr]
                if all(mask):
                    flag_added = True
                    term.add(l_expr)
        return flag_added, term

    # iteration 1
    def __remove_longest_rule(self):
        rules = set()
        for (l_expr, r_expr) in self.__grammar__.get_rules():
            if len(r_expr) <= 2:
                rules.add((l_expr, r_expr))
                continue
            l_value = l_expr
            for term in r_expr:
                new_term = self.__get_new__()
                rules.add((l_value, (term, new_term)))
                l_value = new_term
            rules.add((l_value, (grammar_save.eps_value,)))

        self.__grammar__.set_rules(rules=rules)

    # iteration 2
    def __remove_eps_rules(self):
        from itertools import combinations, chain
        import copy
        grammar_copy = copy.deepcopy(self.__grammar__)

        eps_term = {grammar_save.eps_value}
        flag, exp_term = self.__add_eps_rules__(grammar=grammar_copy, eps_term=eps_term)
        while flag:
            flag, exp_term = self.__add_eps_rules__(grammar=grammar_copy, eps_term=eps_term)

        rules = set()
        for (l_exprm, r_expr) in grammar_copy.get_rules():
            eps_index = []
            for i, item in enumerate(r_expr):
                if item in exp_term:
                    eps_index.append(i)

            combination = set(chain.from_iterable(
                combinations(eps_index, i)
                for i in range(len(eps_index) + 1)))

            for idx in combination:
                new_r_term = []
                for i, item in enumerate(r_expr):
                    if i not in idx:
                        new_r_term.append(item)
                if len(new_r_term) == 1 \
                        and new_r_term[0] is not grammar_save.eps_value \
                        or len(new_r_term) > 1:
                    rules.add((l_exprm, tuple(new_r_term)))

        if grammar_copy.get_start_symbol() in exp_term:
            start = grammar_copy.get_start_symbol()
            new_start = self.__get_new__()
            grammar_copy.set_start_symbol(new_start)
            rules.add((new_start, (start,)))
            rules.add((new_start, (grammar_save.eps_value,)))

        grammar_copy.set_rules(rules=rules)
        self.__grammar__ = grammar_copy

    # iteration 3
    def __remove_chain_rules__(self):
        pair = [(l, (l,)) for (l, _) in self.__grammar__.get_rules()]

        flag, pair_new = self.__add_pair__(pair=pair)
        while flag:
            flag, pair_new = self.__add_pair__(pair=pair)

        union = self.__grammar__.get_rules().union(set(pair_new))

        rules = {(l_expr, r_expr) for (l_expr, r_expr) in union
                 if len(r_expr) != 1 or r_expr[0].get_terminate()}

        self.__grammar__.set_rules(rules=rules)

    # iteration 4
    def __remove_useless_rules__(self):
        import copy
        grammar = copy.deepcopy(self.__grammar__)
        term = set()
        [term.add(item) for (_, r_expr) in grammar.get_rules()
         for item in r_expr if item.get_terminate()]

        flag, term = self.__add_term__(term=term)
        while flag:
            flag, term = self.__add_term__(term=term)

        rules = {(l_expr, r_expr)
                 for (l_expr, r_expr) in grammar.get_rules()
                 if all(item in term for item in r_expr)}

        grammar.set_rules(rules=rules)
        self.__grammar__ = grammar

    # iteration 5
    def __remove_pair_terminals(self):
        rules = set()
        import copy
        grammar_copy = copy.deepcopy(self.__grammar__)

        for (l_expr, r_expr) in grammar_copy.get_rules():
            r_expr = list(r_expr)
            if len(r_expr) == 2:
                for i, item in enumerate(r_expr):
                    if r_expr[i].get_terminate():
                        new_value = self.__get_old__(rules=rules,
                                                     new_value=(r_expr[i],)) or \
                                    self.__get_new__()

                        rules.add((new_value, (r_expr[i],)))
                        r_expr[i] = new_value

            rules.add((l_expr, tuple(r_expr)))

        grammar_copy.set_rules(rules=rules)
        self.__grammar__ = grammar_copy


class CYK:
    def __init__(self, grammar, words):
        self.__grammar__ = grammar
        self.words = words
        self.size = len(words)
        self.result = [[[] for i in range(self.size)] for j in range(self.size)]
        self.non_terminate = list({l for (l, r) in grammar.get_rules()})

        for i, word in enumerate(self.words):
            for non_terminate in self.non_terminate:
                rule = (non_terminate, (term_str(value=word, terminate=True),))
                if rule in grammar.get_rules():
                    self.result[i][i].append(non_terminate)

    def fit(self):
        from itertools import product
        for k in range(1, self.size + 1):
            for i in range(self.size - k):
                for j in range(i, i + k):
                    for (item_1, item_2) in product(self.result[i][j], self.result[j + 1][i + k]):
                        for l in self.non_terminate:
                            currect_rule = (l, (item_1, item_2))
                            if currect_rule in grammar.get_rules():
                                self.result[i][i + k].append(l)
        return grammar.get_start_symbol() in self.result[0][self.size - 1], \
               [[list(map(str, it)) for it in row] for row in self.result]


class parse_input_file:
    def __init__(self, filename):
        self.file_name = filename

    def parse(self):
        with open(self.file_name) as file:
            line = file.readline().strip()
            begin_symbol = self.__check_term__(line)
            all_rules = []
            for line in file:
                all_rules.append(self.__check_rules__(line))
            all_rules = set().union(*all_rules)
        return begin_symbol, all_rules

    def __check_term__(self, value):
        if value.startswith("'") and value.endswith("'"):
            return term_str(value=value.strip("'"), terminate=True)
        if value == eps:
            return grammar_save.eps_value
        return term_str(value=value, terminate=False)

    def __check_rules__(self, current_line):
        l_expr, equals, r_expr = current_line.partition("=")
        return {(self.__check_term__(l_expr.strip()), tuple(self.__check_term__(it.strip()) for it in item.split()))
                for item in r_expr.split("|")}


def parse_file_with_grammar(filename):
    start_symbol, rules = parse_input_file(filename).parse()
    return grammar_save(start=start_symbol, rules_list=rules)


if __name__ == '__main__':
    import argparse as args

    arguments = args.ArgumentParser(description='Chomsky programm')
    arguments.add_argument('-cnf', '--cnf', dest="cnf", help='Run cnf algo')
    arguments.add_argument('-f', '--file', dest="cnf_f", help='file with grammar')
    arguments.add_argument('-cyk', '--cyk', dest="cyk", help='Run cyk algo')
    arguments.add_argument('-w', '--words', dest="cyk_w", help='file with words')
    args_value = arguments.parse_args()
    print(args_value.cnf)
    print(args_value.cyk)
    use_cnf = False
    use_cyk = False

    if args_value.cnf is not None:
        use_cnf = True
    if args_value.cyk is not None:
        use_cyk = True

    if use_cnf and not use_cyk:
        file_with_grammar = args_value.cnf_f
        print("parse grammar")
        grammar = parse_file_with_grammar(file_with_grammar)
        print("before grammar {} ".format(grammar))
        grammar = Normal_form_Chomsky(grammar=grammar).get_cnf()
        print("after grammar {} ".format(grammar))

    if use_cyk:
        import csv

        file_with_grammar = args_value.cnf_f

        print("parse grammar")
        grammar = parse_file_with_grammar(file_with_grammar)
        print("before grammar {} ".format(grammar))
        grammar = Normal_form_Chomsky(grammar=grammar).get_cnf()
        print("after grammar {} ".format(grammar))

        file_with_words = args_value.cyk_w
        with open(file_with_words, 'r') as file_words:
            words = file_words.read()
            cyk = CYK(grammar=grammar, words=words)
            res, table = cyk.fit()
            print("{} {}".format(words, res))

            with open("result_table.csv", 'w') as f:
                writer = csv.writer(f)
                writer.writerows(table)
