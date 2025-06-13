# União e Intersecção

As operações de **União** (∪) e **Intersecção** (∩) são operações binárias fundamentais da álgebra relacional que permitem combinar dados de duas relações compatíveis, baseadas na teoria de conjuntos matemáticos.

## Compatibilidade de Relações

Para que as operações de união e intersecção sejam válidas, as relações devem ser **compatíveis para união**, ou seja:

1. **Mesmo número de atributos**: As duas relações devem ter o mesmo número de colunas
2. **Domínios compatíveis**: Os atributos correspondentes devem ter tipos de dados compatíveis
3. **Ordem dos atributos**: A ordem das colunas deve ser considerada na comparação

## Operação União (∪)

### Definição Formal

A operação de união é definida como:

**R ∪ S**

Onde R e S são relações compatíveis para união.

### Características da União

- **Combina todas as tuplas**: Inclui todas as tuplas de ambas as relações
- **Elimina duplicatas**: Tuplas idênticas aparecem apenas uma vez no resultado
- **Operação comutativa**: R ∪ S = S ∪ R
- **Operação associativa**: (R ∪ S) ∪ T = R ∪ (S ∪ T)
- **Elemento neutro**: R ∪ ∅ = R (onde ∅ é o conjunto vazio)

### Sintaxe em SQL

```sql
SELECT colunas FROM tabela1
UNION
SELECT colunas FROM tabela2;
```

Para manter duplicatas:
```sql
SELECT colunas FROM tabela1
UNION ALL
SELECT colunas FROM tabela2;
```

## Operação Intersecção (∩)

### Definição Formal

A operação de intersecção é definida como:

**R ∩ S**

Onde R e S são relações compatíveis para união.

### Características da Intersecção

- **Tuplas comuns**: Inclui apenas tuplas que existem em ambas as relações
- **Elimina duplicatas**: Por definição, não há duplicatas no resultado
- **Operação comutativa**: R ∩ S = S ∩ R
- **Operação associativa**: (R ∩ S) ∩ T = R ∩ (S ∩ T)
- **Elemento neutro**: R ∩ R = R

### Sintaxe em SQL

```sql
SELECT colunas FROM tabela1
INTERSECT
SELECT colunas FROM tabela2;
```

## Exemplos Práticos

### Exemplo 1: União de Funcionários

**Tabela Funcionarios_SP:**
| id | nome | cargo | salario |
|----|------|-------|---------|
| 1 | Ana | Analista | 5000 |
| 2 | Bruno | Gerente | 8000 |
| 3 | Carlos | Desenvolvedor | 6000 |

**Tabela Funcionarios_RJ:**
| id | nome | cargo | salario |
|----|------|-------|---------|
| 4 | Diana | Analista | 5200 |
| 2 | Bruno | Gerente | 8000 |
| 5 | Eduardo | Designer | 4500 |

**Operação:** Funcionarios_SP ∪ Funcionarios_RJ

```sql
SELECT id, nome, cargo, salario FROM funcionarios_sp
UNION
SELECT id, nome, cargo, salario FROM funcionarios_rj;
```

**Resultado:**
| id | nome | cargo | salario |
|----|------|-------|---------|
| 1 | Ana | Analista | 5000 |
| 2 | Bruno | Gerente | 8000 |
| 3 | Carlos | Desenvolvedor | 6000 |
| 4 | Diana | Analista | 5200 |
| 5 | Eduardo | Designer | 4500 |

Note que Bruno (id=2) aparece apenas uma vez, mesmo estando em ambas as tabelas.

### Exemplo 2: União com UNION ALL

```sql
SELECT id, nome, cargo, salario FROM funcionarios_sp
UNION ALL
SELECT id, nome, cargo, salario FROM funcionarios_rj;
```

**Resultado com UNION ALL:**
| id | nome | cargo | salario |
|----|------|-------|---------|
| 1 | Ana | Analista | 5000 |
| 2 | Bruno | Gerente | 8000 |
| 3 | Carlos | Desenvolvedor | 6000 |
| 4 | Diana | Analista | 5200 |
| 2 | Bruno | Gerente | 8000 |
| 5 | Eduardo | Designer | 4500 |

### Exemplo 3: Intersecção

**Tabela Clientes_Ativos:**
| id | nome | email |
|----|------|-------|
| 1 | João | joao@email.com |
| 2 | Maria | maria@email.com |
| 3 | Pedro | pedro@email.com |

**Tabela Clientes_Premium:**
| id | nome | email |
|----|------|-------|
| 2 | Maria | maria@email.com |
| 3 | Pedro | pedro@email.com |
| 4 | Ana | ana@email.com |

**Operação:** Clientes_Ativos ∩ Clientes_Premium

```sql
SELECT id, nome, email FROM clientes_ativos
INTERSECT
SELECT id, nome, email FROM clientes_premium;
```

**Resultado:**
| id | nome | email |
|----|------|-------|
| 2 | Maria | maria@email.com |
| 3 | Pedro | pedro@email.com |

## Aplicações no PostgreSQL

### União de Dados Históricos
```sql
-- Combinar vendas de diferentes períodos
SELECT data_venda, produto, quantidade, valor
FROM vendas_2023
UNION
SELECT data_venda, produto, quantidade, valor
FROM vendas_2024
ORDER BY data_venda;
```

### União com Diferentes Fontes
```sql
-- Combinar dados de clientes de diferentes sistemas
SELECT nome, email, 'Sistema_A' as origem
FROM clientes_sistema_a
UNION
SELECT nome, email, 'Sistema_B' as origem
FROM clientes_sistema_b;
```

### Intersecção para Análise
```sql
-- Encontrar produtos vendidos em ambas as lojas
SELECT codigo_produto, nome_produto
FROM produtos_loja_centro
INTERSECT
SELECT codigo_produto, nome_produto
FROM produtos_loja_shopping;
```

### União com Condições
```sql
-- Funcionários ativos de todos os departamentos
SELECT nome, departamento FROM funcionarios WHERE ativo = true AND departamento = 'TI'
UNION
SELECT nome, departamento FROM funcionarios WHERE ativo = true AND departamento = 'Vendas'
UNION
SELECT nome, departamento FROM funcionarios WHERE ativo = true AND departamento = 'RH';
```

## Diferenças entre UNION e UNION ALL

### Performance
- **UNION**: Mais lento devido à verificação e remoção de duplicatas
- **UNION ALL**: Mais rápido, simplesmente concatena os resultados

### Uso de Memória
- **UNION**: Requer mais memória para processar duplicatas
- **UNION ALL**: Uso de memória mais eficiente

### Exemplo Comparativo
```sql
-- Mais lento, remove duplicatas
SELECT categoria FROM produtos_loja_a
UNION
SELECT categoria FROM produtos_loja_b;

-- Mais rápido, mantém duplicatas
SELECT categoria FROM produtos_loja_a
UNION ALL
SELECT categoria FROM produtos_loja_b;
```

## Operações Combinadas

### União e Projeção
```sql
-- União seguida de projeção
SELECT DISTINCT nome, cargo
FROM (
    SELECT nome, cargo, salario FROM funcionarios_sp
    UNION ALL
    SELECT nome, cargo, salario FROM funcionarios_rj
) AS todos_funcionarios;
```

### Intersecção e Seleção
```sql
-- Intersecção com filtro
SELECT id, nome FROM (
    SELECT id, nome FROM clientes WHERE cidade = 'São Paulo'
    INTERSECT
    SELECT id, nome FROM clientes_premium
) AS resultado
WHERE nome LIKE 'A%';
```

## Casos de Uso Comuns

### Consolidação de Dados
```sql
-- Consolidar logs de diferentes servidores
SELECT timestamp, nivel, mensagem, 'Servidor1' as servidor
FROM logs_servidor1
WHERE timestamp >= '2024-01-01'
UNION ALL
SELECT timestamp, nivel, mensagem, 'Servidor2' as servidor
FROM logs_servidor2
WHERE timestamp >= '2024-01-01'
ORDER BY timestamp;
```

### Análise de Membros
```sql
-- Membros que participaram de ambos os eventos
SELECT nome, email
FROM participantes_evento_a
INTERSECT
SELECT nome, email
FROM participantes_evento_b;
```

### Relatórios Unificados
```sql
-- Relatório de todas as transações
SELECT data, 'Venda' as tipo, valor FROM vendas
UNION ALL
SELECT data, 'Compra' as tipo, -valor FROM compras
ORDER BY data DESC;
```

## Limitações e Considerações

### Compatibilidade de Tipos
```sql
-- Erro: tipos incompatíveis
SELECT nome, salario FROM funcionarios  -- salario é numeric
UNION
SELECT nome, data_nascimento FROM pessoas;  -- data_nascimento é date

-- Solução: conversão de tipos
SELECT nome, salario::text FROM funcionarios
UNION
SELECT nome, data_nascimento::text FROM pessoas;
```

### Ordem das Colunas
```sql
-- As colunas devem estar na mesma ordem
SELECT nome, idade FROM tabela1
UNION
SELECT nome, idade FROM tabela2;  -- Correto

-- Não funciona como esperado
SELECT nome, idade FROM tabela1
UNION
SELECT idade, nome FROM tabela2;  -- Ordem diferente
```

## Otimizações no PostgreSQL

### Índices para Union
```sql
-- Índices nas colunas usadas em ORDER BY após UNION
CREATE INDEX idx_vendas_2023_data ON vendas_2023 (data_venda);
CREATE INDEX idx_vendas_2024_data ON vendas_2024 (data_venda);
```

### Particionamento
```sql
-- Usar particionamento em vez de UNION quando apropriado
CREATE TABLE vendas (
    id SERIAL,
    data_venda DATE,
    valor DECIMAL
) PARTITION BY RANGE (data_venda);
```

### Análise de Performance
```sql
-- Verificar plano de execução
EXPLAIN ANALYZE
SELECT nome FROM funcionarios_sp
UNION
SELECT nome FROM funcionarios_rj;
```

## Equivalências com Outras Operações

### União e Diferença
```sql
-- R ∪ S pode ser expressa como:
-- R ∪ (S - R) = R ∪ S
```

### Intersecção usando Joins
```sql
-- Intersecção pode ser implementada com INNER JOIN
SELECT DISTINCT f1.id, f1.nome, f1.cargo, f1.salario
FROM funcionarios_sp f1
INNER JOIN funcionarios_rj f2 
ON f1.id = f2.id 
   AND f1.nome = f2.nome 
   AND f1.cargo = f2.cargo 
   AND f1.salario = f2.salario;
```

As operações de União e Intersecção são fundamentais para combinar dados de múltiplas fontes e realizar análises comparativas, sendo amplamente utilizadas em data warehousing, relatórios consolidados e análise de dados.