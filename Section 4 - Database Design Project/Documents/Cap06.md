# Agrupamentos no Contexto de Álgebra Relacional

Os **Agrupamentos** representam uma extensão importante da álgebra relacional básica, permitindo a organização de tuplas em grupos baseados em valores comuns de atributos específicos e a aplicação de funções de agregação sobre esses grupos. Esta operação é fundamental para análises estatísticas e relatórios resumidos.

## Definição Formal

### Operação de Agrupamento
A operação de agrupamento é definida como:

**γ<sub>G₁, G₂, ..., Gₖ; F₁(A₁), F₂(A₂), ..., Fₘ(Aₘ)</sub>(R)**

Onde:
- γ (gamma) é o símbolo da operação de agrupamento
- G₁, G₂, ..., Gₖ são os atributos de agrupamento
- F₁, F₂, ..., Fₘ são funções de agregação
- A₁, A₂, ..., Aₘ são os atributos sobre os quais as funções são aplicadas
- R é a relação de origem

### Componentes da Operação

#### Atributos de Agrupamento
Definem os critérios para formar grupos. Tuplas com os mesmos valores para esses atributos são agrupadas juntas.

#### Funções de Agregação
Aplicadas aos grupos formados, produzindo um valor único para cada grupo:
- **COUNT**: Conta o número de tuplas
- **SUM**: Soma valores numéricos
- **AVG**: Calcula a média
- **MAX**: Encontra o valor máximo
- **MIN**: Encontra o valor mínimo

## Sintaxe em SQL

```sql
SELECT atributos_agrupamento, funções_agregação
FROM tabela
WHERE condições_filtro
GROUP BY atributos_agrupamento
HAVING condições_grupo
ORDER BY atributos_ordenação;
```

## Exemplos Fundamentais

### Exemplo 1: Agrupamento Simples

**Tabela Vendas:**
| id | vendedor | produto | quantidade | valor |
|----|----------|---------|------------|-------|
| 1 | Ana | Notebook | 2 | 3000 |
| 2 | Bruno | Mouse | 10 | 200 |
| 3 | Ana | Teclado | 5 | 250 |
| 4 | Carlos | Notebook | 1 | 1500 |
| 5 | Bruno | Notebook | 3 | 4500 |
| 6 | Ana | Mouse | 8 | 160 |

**Operação:** γ<sub>vendedor; COUNT(*), SUM(valor)</sub>(Vendas)

```sql
SELECT vendedor, COUNT(*) as total_vendas, SUM(valor) as total_valor
FROM vendas
GROUP BY vendedor;
```

**Resultado:**
| vendedor | total_vendas | total_valor |
|----------|--------------|-------------|
| Ana | 3 | 3410 |
| Bruno | 2 | 4700 |
| Carlos | 1 | 1500 |

### Exemplo 2: Agrupamento Múltiplo

**Operação:** γ<sub>vendedor, produto; COUNT(*), AVG(valor)</sub>(Vendas)

```sql
SELECT vendedor, produto, COUNT(*) as vezes_vendido, AVG(valor) as valor_medio
FROM vendas
GROUP BY vendedor, produto;
```

**Resultado:**
| vendedor | produto | vezes_vendido | valor_medio |
|----------|---------|---------------|-------------|
| Ana | Notebook | 1 | 3000.00 |
| Ana | Teclado | 1 | 250.00 |
| Ana | Mouse | 1 | 160.00 |
| Bruno | Mouse | 1 | 200.00 |
| Bruno | Notebook | 1 | 4500.00 |
| Carlos | Notebook | 1 | 1500.00 |

## Funções de Agregação Detalhadas

### COUNT
```sql
-- Contar todas as tuplas
SELECT departamento, COUNT(*) as total_funcionarios
FROM funcionarios
GROUP BY departamento;

-- Contar valores não nulos
SELECT departamento, COUNT(telefone) as funcionarios_com_telefone
FROM funcionarios
GROUP BY departamento;

-- Contar valores distintos
SELECT departamento, COUNT(DISTINCT cargo) as tipos_cargo
FROM funcionarios
GROUP BY departamento;
```

### SUM e AVG
```sql
-- Soma e média salarial por departamento
SELECT 
    departamento,
    SUM(salario) as folha_pagamento,
    AVG(salario) as salario_medio,
    COUNT(*) as total_funcionarios
FROM funcionarios
GROUP BY departamento;
```

### MAX e MIN
```sql
-- Maior e menor salário por departamento
SELECT 
    departamento,
    MAX(salario) as maior_salario,
    MIN(salario) as menor_salario,
    MAX(salario) - MIN(salario) as diferenca
FROM funcionarios
GROUP BY departamento;
```

## Aplicações no PostgreSQL

### Agrupamento com Datas
```sql
-- Vendas por mês
SELECT 
    EXTRACT(YEAR FROM data_venda) as ano,
    EXTRACT(MONTH FROM data_venda) as mes,
    COUNT(*) as total_vendas,
    SUM(valor) as receita_total
FROM vendas
GROUP BY EXTRACT(YEAR FROM data_venda), EXTRACT(MONTH FROM data_venda)
ORDER BY ano, mes;
```

### Agrupamento com Condições (HAVING)
```sql
-- Departamentos com mais de 5 funcionários
SELECT 
    departamento,
    COUNT(*) as total_funcionarios,
    AVG(salario) as salario_medio
FROM funcionarios
GROUP BY departamento
HAVING COUNT(*) > 5;
```

### Agrupamento com Filtros Prévios
```sql
-- Vendas de produtos caros agrupadas por vendedor
SELECT 
    vendedor,
    COUNT(*) as vendas_produtos_caros,
    SUM(valor) as receita_produtos_caros
FROM vendas
WHERE valor > 1000  -- Filtro antes do agrupamento
GROUP BY vendedor
HAVING SUM(valor) > 5000;  -- Filtro após o agrupamento
```

## Agrupamentos Avançados

### GROUPING SETS
```sql
-- Múltiplos agrupamentos em uma consulta
SELECT 
    departamento,
    cargo,
    COUNT(*) as total
FROM funcionarios
GROUP BY GROUPING SETS (
    (departamento),
    (cargo),
    (departamento, cargo),
    ()  -- Total geral
);
```

### ROLLUP
```sql
-- Hierarquia de agrupamentos
SELECT 
    departamento,
    cargo,
    COUNT(*) as total,
    SUM(salario) as total_salarios
FROM funcionarios
GROUP BY ROLLUP (departamento, cargo);
```

### CUBE
```sql
-- Todas as combinações possíveis de agrupamento
SELECT 
    departamento,
    cargo,
    COUNT(*) as total
FROM funcionarios
GROUP BY CUBE (departamento, cargo);
```

## Window Functions vs GROUP BY

### GROUP BY (Agrupamento Tradicional)
```sql
-- Reduz o número de linhas
SELECT departamento, AVG(salario) as salario_medio
FROM funcionarios
GROUP BY departamento;
```

### Window Functions (Mantém todas as linhas)
```sql
-- Mantém o número original de linhas
SELECT 
    nome,
    departamento,
    salario,
    AVG(salario) OVER (PARTITION BY departamento) as salario_medio_dept
FROM funcionarios;
```

## Propriedades Algébricas

### Comutatividade dos Atributos de Agrupamento
```
γ A,B; F(C) (R) = γ B,A; F(C) (R)
```

### Distributividade com Seleção
```sql
-- Filtro antes do agrupamento (mais eficiente)
SELECT departamento, COUNT(*)
FROM funcionarios
WHERE ativo = true
GROUP BY departamento;

-- Equivalente algébrico: γ departamento; COUNT(*) (σ ativo=true (funcionarios))
```

### Associatividade Limitada
O agrupamento não é completamente associativo, mas certas transformações são possíveis:

```sql
-- Agrupamento aninhado
SELECT departamento, AVG(salario_medio_cargo)
FROM (
    SELECT departamento, cargo, AVG(salario) as salario_medio_cargo
    FROM funcionarios
    GROUP BY departamento, cargo
) sub
GROUP BY departamento;
```

## Otimizações de Performance

### Índices para GROUP BY
```sql
-- Índice para agrupamento por departamento
CREATE INDEX idx_funcionarios_departamento ON funcionarios (departamento);

-- Índice composto para agrupamento múltiplo
CREATE INDEX idx_vendas_vendedor_produto ON vendas (vendedor, produto);

-- Índice cobrindo para evitar acesso à tabela
CREATE INDEX idx_vendas_resumo ON vendas (vendedor, produto) INCLUDE (valor, quantidade);
```

### Ordem dos Atributos no GROUP BY
```sql
-- Mais eficiente: atributo mais seletivo primeiro
SELECT departamento, cargo, COUNT(*)
FROM funcionarios
GROUP BY departamento, cargo;  -- Se departamento é mais seletivo
```

### Pré-agregação com Materialized Views
```sql
-- View materializada para consultas frequentes
CREATE MATERIALIZED VIEW vendas_resumo_mensal AS
SELECT 
    EXTRACT(YEAR FROM data_venda) as ano,
    EXTRACT(MONTH FROM data_venda) as mes,
    vendedor,
    COUNT(*) as total_vendas,
    SUM(valor) as receita_total
FROM vendas
GROUP BY EXTRACT(YEAR FROM data_venda), EXTRACT(MONTH FROM data_venda), vendedor;

-- Atualizar periodicamente
REFRESH MATERIALIZED VIEW vendas_resumo_mensal;
```

## Casos de Uso Práticos

### Análise de Vendas
```sql
-- Desempenho de vendedores por trimestre
SELECT 
    vendedor,
    EXTRACT(QUARTER FROM data_venda) as trimestre,
    COUNT(*) as total_vendas,
    SUM(valor) as receita,
    AVG(valor) as ticket_medio,
    MAX(valor) as maior_venda
FROM vendas
WHERE EXTRACT(YEAR FROM data_venda) = 2024
GROUP BY vendedor, EXTRACT(QUARTER FROM data_venda)
ORDER BY vendedor, trimestre;
```

### Relatórios de RH
```sql
-- Distribuição salarial por departamento e faixa etária
SELECT 
    departamento,
    CASE 
        WHEN idade < 25 THEN 'Jovem'
        WHEN idade BETWEEN 25 AND 40 THEN 'Adulto'
        ELSE 'Sênior'
    END as faixa_etaria,
    COUNT(*) as total_funcionarios,
    AVG(salario) as salario_medio,
    MIN(salario) as salario_minimo,
    MAX(salario) as salario_maximo
FROM funcionarios
GROUP BY departamento, 
    CASE 
        WHEN idade < 25 THEN 'Jovem'
        WHEN idade BETWEEN 25 AND 40 THEN 'Adulto'
        ELSE 'Sênior'
    END;
```

### Análise de Logs
```sql
-- Análise de erros por hora
SELECT 
    DATE_TRUNC('hour', timestamp) as hora,
    nivel_log,
    COUNT(*) as total_eventos,
    COUNT(DISTINCT usuario_id) as usuarios_afetados
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
    AND nivel_log IN ('ERROR', 'WARNING')
GROUP BY DATE_TRUNC('hour', timestamp), nivel_log
ORDER BY hora DESC;
```

## Agrupamentos com Joins

### Agrupamento após Join
```sql
-- Vendas por categoria de produto
SELECT 
    p.categoria,
    COUNT(v.id) as total_vendas,
    SUM(v.valor) as receita_total,
    AVG(v.valor) as ticket_medio
FROM vendas v
JOIN produtos p ON v.produto_id = p.id
GROUP BY p.categoria
ORDER BY receita_total DESC;
```

### Join de Resultados Agrupados
```sql
-- Comparar desempenho de departamentos
WITH desempenho_atual AS (
    SELECT departamento, AVG(salario) as salario_medio_atual
    FROM funcionarios
    WHERE ativo = true
    GROUP BY departamento
),
desempenho_historico AS (
    SELECT departamento, AVG(salario) as salario_medio_historico
    FROM funcionarios_historico
    WHERE ano = 2023
    GROUP BY departamento
)
SELECT 
    da.departamento,
    da.salario_medio_atual,
    dh.salario_medio_historico,
    ((da.salario_medio_atual - dh.salario_medio_historico) / dh.salario_medio_historico) * 100 as crescimento_percentual
FROM desempenho_atual da
JOIN desempenho_historico dh ON da.departamento = dh.departamento;
```

## Considerações Importantes

### NULL Values em Agrupamentos
```sql
-- NULL é tratado como um grupo separado
SELECT departamento, COUNT(*)
FROM funcionarios
GROUP BY departamento;  -- NULL aparecerá como um grupo
```

### Performance com Grandes Volumes
```sql
-- Usar LIMIT com GROUP BY cuidadosamente
SELECT departamento, COUNT(*)
FROM funcionarios
GROUP BY departamento
ORDER BY COUNT(*) DESC
LIMIT 10;  -- LIMIT aplicado após agrupamento
```

### Validação de Resultados
```sql
-- Verificar consistência dos agrupamentos
SELECT 
    SUM(total_por_departamento) as total_geral,
    (SELECT COUNT(*) FROM funcionarios) as total_original
FROM (
    SELECT departamento, COUNT(*) as total_por_departamento
    FROM funcionarios
    GROUP BY departamento
) sub;
```

Os agrupamentos são essenciais para análises de dados e relatórios, permitindo a extração de insights estatísticos e tendências a partir de grandes volumes de dados de forma eficiente e estruturada.