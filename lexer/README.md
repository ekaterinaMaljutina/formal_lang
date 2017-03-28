**Зависимости под Linux**: 
- flex
- gcc 
- make

**Запуск**:
- Встроенные тесты:
	- make test
- Cвой тест: 
	- make
	- cat test | ./lexer
	- cat test | ./lexer -f или cat test | ./lexer -filter - без вывода комментариев 

**Очистка**:
- make clean