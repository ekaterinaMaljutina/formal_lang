**Как задать граф**

номер_вершины_из номер_вершины_в ребро

номер_вершины_из номер_вершины_в ребро

номер_вершины_из номер_вершины_в ребро

...


**Запуск**
- Если нужно заданный граф, тогда задаем алфивит, путь до грамматики и до графа

  python3 main.py -alp 'acgt' -f ./rna.txt  -f_graph ./graph
- Если случаный граф, то добавляем разбросы вершин и ребер

  python3 main.py -alp 'acgt' -f ./rna.txt  -vertex_from 15 -vertex_to 20 -edge_from 40 --edge_to 60