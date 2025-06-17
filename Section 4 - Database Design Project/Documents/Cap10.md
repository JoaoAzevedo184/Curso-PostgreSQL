# Exercício

Aplique as formas normais considerando a tabela abaixo (nem todas podem ser aplicadas):

| Nº Pedido | Cód. Vendedor | Vendedor | Cód. Cliente | Cliente | Endereço     | CGC      | Cód. Produto | Qtde | Descrição | Valor Total |
|-----------|---------------|----------|--------------|---------|--------------|----------|---------------|------|-----------|-------------|
| 1234      | 1             | DDDDD    | 1            | AAAAA   | Rua XXXXX    | 1111111  | 43            | 20   | Álcool    | 345,00      |
| 1234      | 1             | DDDDD    | 1            | AAAAA   | Rua XXXXX    | 1111111  | 76            | 10   | Tecido    | 100,00      |
| 1234      | 1             | DDDDD    | 1            | AAAAA   | Rua XXXXX    | 1111111  | 09            | 12   | Cimento   | 500,00      |
| 4321      | 2             | FFFFFF   | 2            | BBBBB   | Rua YYYYY    | 2222222  | 87            | 12   | Pregos    | 100,00      |
| 4321      | 2             | FFFFFF   | 2            | BBBBB   | Rua YYYYY    | 2222222  | 43            | 10   | Álcool    | 134,00      |
| 4321      | 2             | FFFFFF   | 2            | BBBBB   | Rua YYYYY    | 2222222  | 15            | 10   | Cola      | 245,00      |
| 9876      | 3             | GGGGG    | 3            | CCCCC   | Rua CCCCC    | 3333333  | 76            | 10   | Tecido    | 100,00      |
| 9876      | 3             | GGGGG    | 3            | CCCCC   | Rua CCCCC    | 3333333  | 87            | 06   | Pregos    | 50,00       |
| 9876      | 3             | GGGGG    | 3            | CCCCC   | Rua CCCCC    | 3333333  | 09            | 12   | Cimento   | 500,00      |


## 1FN

1FN – Todos os atributos devem possuir apenas valores atômicos.
+ dividir o atributo endereço em tipo logradouro e endereço.

## 2FN

2FN – Não deve possuir dependência funcional parcial. Este campo não chave depende de toda a chave?

## 3FN

3FN – Não deve possuir dependência funcional transitiva.

## BCNF

Não é usada.

## 4FN

4FN – Não deve possuir dependência funcional multivalorada.

## 5FN

Não é usada.