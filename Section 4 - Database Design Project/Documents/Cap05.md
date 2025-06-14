# Exercício Projeto 1 - Sistema Editora On-Line

## Descrição do Sistema

A Editora On-Line pretende exibir todo o seu acervo de livros por meio da Internet. A Home Page exibe os lançamentos dos últimos 30 dias. Estes livros deverão estar divididos por categoria e sobre cada livro de uma determinada categoria serão fornecidas informações técnicas, como: autores, número de páginas, preço e um pequeno resumo da obra. 

O site também deverá permitir que o internauta pesquise um determinado livro por título, autor ou ISBN. No que tange ao comércio eletrônico, o site da editora On-Line terá todas as etapas necessárias para a escolha de um ou mais livros a serem adquiridos pela Internet, em que o próprio internauta monta a sua cesta de compras, altera quantidades, indica o local da entrega, etc. 

O frete deverá ser calculado de acordo com a localidade que se encontra o cliente e uma vez encerrado o pedido, este receberá um e-mail com a confirmação da compra.

## Análise do Sistema

### 1. Entidades Identificadas

- **LIVRO**
- **CATEGORIA**
- **CLIENTE**
- **AUTOR**
- **VENDA**
- **ENDEREÇO**
- **CIDADE**
- **ESTADO**

### 2. Atributos das Entidades

**LIVRO**:
+ idLivro
+ nome
+ preço
+ sinopse
+ data_lançamento
+ numero_paginas
+ isbn

**CATEGORIA**:
+ idCtegoria
+ nome

**CLIENTE**:
+ idCliente
+ nome

**AUTOR**:
+ idAutor
+ nome

**VENDA**:
+ idVenda
+ quantidade
+ frete
+ valor

**ENDEREÇO**:
+ idEndereço
+ logradouro
+ numero
+ cep

**CIDADE**:
+ idCidade
+ nome

**ESTADO**:
+ idEstado
+ nome

### 3. Relacionamentos Identificados

- Livro tem Categoria
- Livro tem Autor
- Venda possui Livro
- Venda possui Cliente
- Cliente possui Endereço
- Endereço está Cidade
- Cidade está Estado
