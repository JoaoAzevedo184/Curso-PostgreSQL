# Avaliação Prática – Banco de Dados

## 1. Criação do Banco de Dados
Crie um banco de dados chamado `BIBLIOTECA`.

## 2. Criação e População das Tabelas

### 2.1 Tabela EDITORA

#### Estrutura:
| Campo     | Observações                                    |
|-----------|-----------------------------------------------|
| IdEditora | Inteiro, não nulo, chave primária, auto inc.  |
| Nome      | Caractere, não nulo e único                   |

#### Dados para Inserção:
| Nome           |
|----------------|
| Bookman        |
| Edgard Blusher |
| Nova Terra     |
| Brasport       |

### 2.2 Tabela CATEGORIA

#### Estrutura:
| Campo        | Observações                                    |
|-------------|-----------------------------------------------|
| IdCategoria | Inteiro, não nulo, chave primária, auto inc.  |
| Nome        | Caractere, não nulo e único                   |

#### Dados para Inserção:
| Nome           |
|----------------|
| Banco de Dados |
| HTML           |
| Java           |
| PHP            |

### 2.3 Tabela AUTOR

#### Estrutura:
| Campo    | Observações                                    |
|----------|-----------------------------------------------|
| IdAutor  | Inteiro, não nulo, chave primária, auto inc.  |
| Nome     | Caractere e não nulo                          |

#### Dados para Inserção:
| Nome                      |
|--------------------------|
| Waldemar Setzer          |
| Flávio Soares           |
| John Watson             |
| Rui Rossi dos Santos    |
| Antonio Pereira de Resende|
| Claudiney Calixto Lima   |
| Evandro Carlos Teruel    |
| Ian Graham               |
| Fabrício Xavier         |
| Pablo Dalloglio         |

### 2.4 Tabela LIVRO

#### Estrutura:
| Campo       | Observações                                          |
|-------------|-----------------------------------------------------|
| IdLivro     | Inteiro, não nulo, chave primária, auto inc.        |
| IdEditora   | Inteiro, não nulo, FK para tabela EDITORA           |
| IdCategoria | Inteiro, não nulo, FK para tabela CATEGORIA         |
| Nome        | Caractere, não nulo e único                         |

#### Dados para Inserção:
| Editora        | Categoria      | Nome                                                |
|----------------|----------------|-----------------------------------------------------|
| Edgard Blusher | Banco de Dados | Banco de Dados – 1 Edição                         |
| Bookman        | Banco de Dados | Oracle DataBase 11G Administração                  |
| Nova Terra     | Java           | Programação de Computadores em Java                |
| Brasport       | Java           | Programação Orientada a Aspectos em Java           |
| Brasport       | HTML           | HTML5 – Guia Prático                              |
| Nova Terra     | HTML           | XHTML: Guia de Referência para Desenvolvimento na Web|
| Bookman        | PHP            | PHP para Desenvolvimento Profissional              |
| Edgard Blusher | PHP            | PHP com Programação Orientada a Objetos           |

### 2.5 Tabela LIVRO_AUTOR

#### Estrutura:
| Campo    | Observações                                    |
|----------|-----------------------------------------------|
| IdLivro  | Inteiro, não nulo, FK para tabela LIVRO       |
| IdAutor  | Inteiro, não nulo, FK para tabela AUTOR       |
| **Obs:** | Chave primária composta (IdLivro + IdAutor)   |

#### Dados para Inserção:
| Livro                                               | Autor                     |
|----------------------------------------------------|--------------------------|
| Banco de Dados – 1 Edição                          | Waldemar Setzer          |
| Banco de Dados – 1 Edição                          | Flávio Soares            |
| Oracle DataBase 11G Administração                   | John Watson              |
| Programação de Computadores em Java                 | Rui Rossi dos Santos     |
| Programação Orientada a Aspectos em Java            | Antonio P. de Resende    |
| Programação Orientada a Aspectos em Java            | Claudiney Calixto Lima   |
| HTML5 – Guia Prático                               | Evandro Carlos Teruel    |
| XHTML: Guia de Referência para Desenvolvimento Web  | Ian Graham               |
| PHP para Desenvolvimento Profissional               | Fabrício Xavier          |
| PHP com Programação Orientada a Objetos            | Pablo Dalloglio          |

### 2.6 Tabela ALUNO

#### Estrutura:
| Campo    | Observações                                    |
|----------|-----------------------------------------------|
| IdAluno  | Inteiro, não nulo, chave primária, auto inc.  |
| Nome     | Caractere e não nulo                          |

#### Dados para Inserção:
| Nome     |
|----------|
| Mario    |
| João     |
| Paulo    |
| Pedro    |
| Maria    |

### 2.7 Tabela EMPRESTIMO

#### Estrutura:
| Campo            | Observações                                          |
|------------------|-----------------------------------------------------|
| IdEmprestimo     | Inteiro, não nulo, chave primária, auto inc.        |
| IdAluno          | Inteiro, não nulo, FK para tabela ALUNO             |
| Data_Emprestimo  | Data, não nulo, default CURRENT_DATE                |
| Data_Devolucao   | Data, não nulo                                      |
| Valor            | Decimal, não nulo                                    |
| Devolvido        | Char(1), não nulo                                   |

#### Dados para Inserção:
| Aluno  | Data Empréstimo | Data Devolução | Valor  | Devolvido |
|--------|----------------|----------------|---------|-----------|
| Mario  | 02/05/2012     | 12/05/2012     | 10,00   | S         |
| Mario  | 23/04/2012     | 03/05/2012     | 5,00    | N         |
| João   | 10/05/2012     | 20/05/2012     | 12,00   | N         |
| Paulo  | 10/05/2012     | 20/05/2012     | 8,00    | S         |
| Pedro  | 05/05/2012     | 15/05/2012     | 15,00   | N         |
| Pedro  | 07/05/2012     | 17/05/2012     | 20,00   | S         |
| Pedro  | 08/05/2012     | 18/05/2012     | 5,00    | S         |

### 2.8 Tabela EMPRESTIMO_LIVRO

#### Estrutura:
| Campo         | Observações                                    |
|--------------|-----------------------------------------------|
| IdEmprestimo | Inteiro, não nulo, FK para tabela EMPRESTIMO  |
| IdLivro      | Inteiro, não nulo, FK para tabela LIVRO       |
| **Obs:**     | Chave primária composta (IdEmprestimo, IdLivro)|

#### Dados para Inserção:
| Empréstimo                    | Livro                                    |
|------------------------------|------------------------------------------|
| Primeiro empréstimo Mario    | Banco de Dados – 1 Edição               |
| Segundo empréstimo Mario     | Programação Orientada a Aspectos em Java |
| Segundo empréstimo Mario     | Programação de Computadores em Java      |
| Empréstimo João             | Oracle DataBase 11G Administração        |
| Empréstimo João             | PHP para Desenvolvimento Profissional    |
| Empréstimo Paulo            | HTML5 – Guia Prático                     |
| Primeiro empréstimo Pedro    | Programação Orientada a Aspectos em Java |
| Segundo empréstimo Pedro     | XHTML: Guia de Referência...            |
| Segundo empréstimo Pedro     | Banco de Dados – 1 Edição               |
| Terceiro empréstimo Pedro    | PHP com Programação Orientada a Objetos |

## 3. Índices

### Tabela EMPRESTIMO:
| Campo           |
|-----------------|
| Data_Emprestimo |
| Data_Devolucao  |

## 4. Exercícios

### 4.1 Consultas Simples
1. O nome dos autores em ordem alfabética
2. O nome dos alunos que começam com a letra P
3. O nome dos livros da categoria Banco de Dados ou Java
4. O nome dos livros da editora Bookman
5. Os empréstimos realizados entre 05/05/2012 e 10/05/2012
6. Os empréstimos que não foram feitos entre 05/05/2012 e 10/05/2012
7. Os empréstimos que os livros já foram devolvidos

### 4.2 Consultas com Agrupamento
1. A quantidade total de livros
2. O somatório do valor dos empréstimos
3. A média do valor dos empréstimos
4. O maior valor dos empréstimos
5. O menor valor dos empréstimos
6. O somatório do valor dos empréstimos entre 05/05/2012 e 10/05/2012
7. A quantidade de empréstimos entre 01/05/2012 e 05/05/2012

### 4.3 Consultas com JOIN

#### Views a Serem Criadas
1. View de Livros (LIVRO)
   - Nome do livro
   - Categoria
   - Editora

2. View de Autoria (LIVRO_AUTOR)
   - Nome do livro
   - Nome do autor

#### Consultas Específicas
1. O nome dos livros do autor Ian Graham (LIVRO_AUTOR)
2. O nome do aluno, data do empréstimo e data de devolução (EMPRESTIMO)
3. O nome de todos os livros que foram emprestados (EMPRESTIMO_LIVRO)