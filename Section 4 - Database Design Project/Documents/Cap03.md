# Operação Select (Seleção)

A operação **Select** (σ - sigma) é uma das operações fundamentais da álgebra relacional que permite filtrar tuplas (linhas) de uma relação com base em uma condição específica, criando uma nova relação contendo apenas as tuplas que satisfazem o critério estabelecido.

## Definição Formal

A operação de seleção é definida como:

**σ<sub>condição</sub>(R)**

Onde:
- σ (sigma) é o símbolo da operação de seleção
- condição é um predicado que especifica os critérios de filtragem
- R é a relação (tabela) de origem

## Características Principais

### Filtragem Horizontal
A seleção opera horizontalmente na tabela, escolhendo quais linhas (tuplas) devem aparecer no resultado com base nos critérios estabelecidos.

### Preservação de Schema
O resultado mantém a mesma estrutura (colunas) da relação original, alterando apenas quais tuplas são incluídas.

### Condições Booleanas
A condição deve ser uma expressão booleana que pode ser avaliada como verdadeira ou falsa para cada tupla.

### Operação Unária
A seleção é uma operação unária, ou seja, opera sobre uma única relação por vez.

## Tipos de Condições

### Comparações Simples
- **Igualdade**: atributo = valor
- **Desigualdade**: atributo ≠ valor  
- **Comparações**: atributo > valor, atributo < valor, atributo ≥ valor, atributo ≤ valor

### Operadores Lógicos
- **AND (∧)**: Combina condições que devem ser verdadeiras simultaneamente
- **OR (∨)**: Combina condições onde pelo menos uma deve ser verdadeira  
- **NOT (¬)**: Nega uma condição

### Operadores Especiais
- **LIKE**: Para correspondência de padrões
- **IN**: Para verificar se um valor está em um conjunto
- **BETWEEN**: Para intervalos de valores
- **IS NULL / IS NOT NULL**: Para verificar valores nulos

## Sintaxe em SQL

A operação de seleção em SQL é implementada através da cláusula **WHERE**:

```sql
SELECT *
FROM tabela
WHERE condição;
```

## Exemplos Práticos

### Exemplo 1: Seleção Simples

**Tabela Funcionarios:**
| id | nome | cargo | salario | departamento | idade |
|----|------|-------|---------|--------------|-------|
| 1 | Ana | Analista | 5000 | TI | 28 |
| 2 | Bruno | Gerente | 8000 | Vendas | 35 |
| 3 | Carlos | Analista | 4800 | TI | 24 |
| 4 | Diana | Desenvolvedora | 6500 | TI | 30 |
| 5 | Eduardo | Vendedor | 3500 | Vendas | 26 |

**Operação:** σ<sub>departamento = 'TI'</sub>(Funcionarios)

```sql
SELECT * 
FROM funcionarios 
WHERE departamento = 'TI';
```

**Resultado:**
| id | nome | cargo | salario | departamento | idade |
|----|------|-------|---------|--------------|-------|
| 1 | Ana | Analista | 5000 | TI | 28 |
| 3 | Carlos | Analista | 4800 | TI | 24 |
| 4 | Diana | Desenvolvedora | 6500 | TI | 30 |

### Exemplo 2: Seleção com Múltiplas Condições

**Operação:** σ<sub>departamento = 'TI' ∧ salario > 5000</sub>(Funcionarios)

```sql
SELECT * 
FROM funcionarios 
WHERE departamento = 'TI' AND salario > 5000;
```

**Resultado:**
| id | nome | cargo | salario | departamento | idade |
|----|------|-------|---------|--------------|-------|
| 4 | Diana | Desenvolvedora | 6500 | TI | 30 |

### Exemplo 3: Seleção com OR

**Operação:** σ<sub>cargo = 'Gerente' ∨ salario > 6000</sub>(Funcionarios)

```sql
SELECT * 
FROM funcionarios 
WHERE cargo = 'Gerente' OR salario > 6000;
```

**Resultado:**
| id | nome | cargo | salario | departamento | idade |
|----|------|-------|---------|--------------|-------|
| 2 | Bruno | Gerente | 8000 | Vendas | 35 |
| 4 | Diana | Desenvolvedora | 6500 | TI | 30 |

## Aplicações no PostgreSQL

### Seleção com Comparações Numéricas
```sql
-- Funcionários com salário entre 4000 e 6000
SELECT nome, salario 
FROM funcionarios 
WHERE salario BETWEEN 4000 AND 6000;

-- Funcionários com idade maior que 25
SELECT nome, idade 
FROM funcionarios 
WHERE idade > 25;
```

### Seleção com Strings
```sql
-- Nomes que começam com 'A'
SELECT nome 
FROM funcionarios 
WHERE nome LIKE 'A%';

-- Cargos específicos
SELECT nome, cargo 
FROM funcionarios 
WHERE cargo IN ('Analista', 'Desenvolvedor', 'Programador');
```

### Seleção com Datas
```sql
-- Funcionários contratados no último ano
SELECT nome, data_contratacao 
FROM funcionarios 
WHERE data_contratacao >= CURRENT_DATE - INTERVAL '1 year';

-- Funcionários contratados em um mês específico
SELECT nome, data_contratacao 
FROM funcionarios 
WHERE EXTRACT(MONTH FROM data_contratacao) = 3;
```

### Seleção com Valores Nulos
```sql
-- Funcionários sem telefone cadastrado
SELECT nome 
FROM funcionarios 
WHERE telefone IS NULL;

-- Funcionários com todos os dados preenchidos
SELECT nome 
FROM funcionarios 
WHERE email IS NOT NULL AND telefone IS NOT NULL;
```

## Propriedades Importantes

### Comutatividade
Múltiplas seleções podem ser aplicadas em qualquer ordem:
```
σ condição1 (σ condição2 (R)) = σ condição2 (σ condição1 (R))
```

### Combinação de Condições
Múltiplas seleções com AND podem ser combinadas:
```
σ condição1 (σ condição2 (R)) = σ condição1 ∧ condição2 (R)
```

### Idempotência
Aplicar a mesma seleção múltiplas vezes produz o mesmo resultado:
```
σ condição (σ condição (R)) = σ condição (R)
```

## Otimizações no PostgreSQL

### Índices para Seleção
```sql
-- Criar índices para colunas frequentemente filtradas
CREATE INDEX idx_funcionarios_departamento ON funcionarios (departamento);
CREATE INDEX idx_funcionarios_salario ON funcionarios (salario);

-- Índice composto para múltiplas condições
CREATE INDEX idx_funcionarios_dept_salario 
ON funcionarios (departamento, salario);
```

### Índices Parciais
```sql
-- Índice apenas para registros ativos
CREATE INDEX idx_funcionarios_ativos 
ON funcionarios (nome) 
WHERE ativo = true;
```

### Estatísticas da Tabela
```sql
-- Atualizar estatísticas para melhor otimização
ANALYZE funcionarios;

-- Verificar estatísticas de uma coluna
SELECT * FROM pg_stats 
WHERE tablename = 'funcionarios' AND attname = 'departamento';
```

## Exemplos Avançados

### Seleção com Subconsultas
```sql
-- Funcionários com salário acima da média
SELECT nome, salario 
FROM funcionarios 
WHERE salario > (SELECT AVG(salario) FROM funcionarios);
```

### Seleção com Expressões Regulares
```sql
-- Emails com domínio específico (PostgreSQL)
SELECT nome, email 
FROM funcionarios 
WHERE email ~ '@empresa\.com$';
```

### Seleção com Funções
```sql
-- Funcionários contratados nos últimos 30 dias
SELECT nome, data_contratacao 
FROM funcionarios 
WHERE data_contratacao > NOW() - INTERVAL '30 days';

-- Funcionários cujo nome tem mais de 5 caracteres
SELECT nome 
FROM funcionarios 
WHERE LENGTH(nome) > 5;
```

## Casos de Uso Comuns

### Filtragem de Dados para Relatórios
```sql
-- Vendas do trimestre atual
SELECT * 
FROM vendas 
WHERE data_venda >= DATE_TRUNC('quarter', CURRENT_DATE);
```

### Controle de Acesso
```sql
-- Dados visíveis para determinado usuário
SELECT * 
FROM documentos 
WHERE proprietario_id = 123 OR publico = true;
```

### Limpeza de Dados
```sql
-- Registros com dados inconsistentes
SELECT * 
FROM clientes 
WHERE email NOT LIKE '%@%' OR telefone IS NULL;
```

### Auditoria e Monitoramento
```sql
-- Transações suspeitas
SELECT * 
FROM transacoes 
WHERE valor > 10000 AND horario BETWEEN '22:00' AND '06:00';
```

## Considerações de Performance

### Seletividade
Condições mais seletivas (que retornam menos linhas) devem ser colocadas primeiro em consultas com múltiplas condições AND.

### Uso de Índices
Sempre considere criar índices para colunas frequentemente usadas em condições WHERE, especialmente em tabelas grandes.

### Evitar Funções em Condições
```sql
-- Menos eficiente
SELECT * FROM funcionarios WHERE UPPER(nome) = 'ANA';

-- Mais eficiente
SELECT * FROM funcionarios WHERE nome = 'Ana';
```

### Análise de Planos de Execução
```sql
-- Verificar como PostgreSQL executa a consulta
EXPLAIN ANALYZE 
SELECT * FROM funcionarios WHERE departamento = 'TI';
```

A operação Select é fundamental para filtrar dados de forma eficiente e é uma das operações mais utilizadas em consultas SQL, sendo essencial para construir sistemas de banco de dados performáticos e funcionais.