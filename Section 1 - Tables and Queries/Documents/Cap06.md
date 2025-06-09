# Subconsultas SQL - PostgreSQL

As subconsultas (subqueries) são consultas SQL aninhadas dentro de outras consultas. Elas permitem resolver problemas complexos dividindo-os em partes menores e mais gerenciáveis.

## Conceitos Fundamentais

### O que são Subconsultas?
Uma subconsulta é uma consulta SELECT executada dentro de outra consulta SQL. A subconsulta é executada primeiro e seu resultado é usado pela consulta principal.

### Características Principais
- Sempre envolvidas por parênteses
- Podem retornar um valor único, uma linha ou múltiplas linhas
- Podem ser usadas em SELECT, WHERE, FROM, HAVING
- Podem ser correlacionadas ou não-correlacionadas

## Tipos de Subconsultas

### 1. Subconsultas Escalares
Retornam um único valor (uma linha, uma coluna).

```sql
-- Encontrar funcionários com salário acima da média
SELECT nome, salario
FROM funcionarios
WHERE salario > (
    SELECT AVG(salario) 
    FROM funcionarios
);

-- Mostrar o salário máximo junto com os dados do funcionário
SELECT 
    nome,
    salario,
    (SELECT MAX(salario) FROM funcionarios) as salario_maximo
FROM funcionarios;
```

### 2. Subconsultas de Linha Única
Retornam uma linha com múltiplas colunas.

```sql
-- Comparar com múltiplos valores
SELECT nome, departamento, salario
FROM funcionarios
WHERE (departamento, salario) = (
    SELECT departamento, MAX(salario)
    FROM funcionarios
    WHERE departamento = 'TI'
    GROUP BY departamento
);
```

### 3. Subconsultas de Múltiplas Linhas
Retornam várias linhas, usadas com operadores como IN, ANY, ALL.

```sql
-- Funcionários nos departamentos com mais de 10 pessoas
SELECT nome, departamento
FROM funcionarios
WHERE departamento IN (
    SELECT departamento
    FROM funcionarios
    GROUP BY departamento
    HAVING COUNT(*) > 10
);
```

## Operadores para Subconsultas

### IN e NOT IN
```sql
-- Clientes que fizeram pedidos em 2024
SELECT nome
FROM clientes
WHERE cliente_id IN (
    SELECT DISTINCT cliente_id
    FROM pedidos
    WHERE EXTRACT(YEAR FROM data_pedido) = 2024
);

-- Produtos nunca vendidos
SELECT nome_produto
FROM produtos
WHERE produto_id NOT IN (
    SELECT produto_id
    FROM itens_pedido
    WHERE produto_id IS NOT NULL
);
```

### EXISTS e NOT EXISTS
```sql
-- Clientes com pelo menos um pedido
SELECT nome
FROM clientes c
WHERE EXISTS (
    SELECT 1
    FROM pedidos p
    WHERE p.cliente_id = c.cliente_id
);

-- Categorias sem produtos
SELECT nome_categoria
FROM categorias c
WHERE NOT EXISTS (
    SELECT 1
    FROM produtos p
    WHERE p.categoria_id = c.categoria_id
);
```

### ANY e ALL
```sql
-- Funcionários com salário maior que qualquer funcionário do RH
SELECT nome, salario
FROM funcionarios
WHERE salario > ANY (
    SELECT salario
    FROM funcionarios
    WHERE departamento = 'RH'
);

-- Funcionários com salário maior que todos os funcionários do RH
SELECT nome, salario
FROM funcionarios
WHERE salario > ALL (
    SELECT salario
    FROM funcionarios
    WHERE departamento = 'RH'
);
```

## Subconsultas por Localização

### Subconsultas no SELECT
```sql
-- Mostrar total de pedidos por cliente
SELECT 
    c.nome,
    c.email,
    (SELECT COUNT(*) 
     FROM pedidos p 
     WHERE p.cliente_id = c.cliente_id) as total_pedidos,
    (SELECT COALESCE(SUM(valor_total), 0) 
     FROM pedidos p 
     WHERE p.cliente_id = c.cliente_id) as total_gasto
FROM clientes c;
```

### Subconsultas no WHERE
```sql
-- Produtos com preço acima da média da categoria
SELECT nome_produto, preco, categoria_id
FROM produtos p1
WHERE preco > (
    SELECT AVG(preco)
    FROM produtos p2
    WHERE p2.categoria_id = p1.categoria_id
);
```

### Subconsultas no FROM
```sql
-- Usar subconsulta como tabela temporária
SELECT 
    categoria,
    AVG(total_vendas) as media_vendas_categoria
FROM (
    SELECT 
        p.categoria_id as categoria,
        SUM(ip.quantidade * ip.preco_unitario) as total_vendas
    FROM produtos p
    JOIN itens_pedido ip ON p.produto_id = ip.produto_id
    GROUP BY p.produto_id, p.categoria_id
) as vendas_por_produto
GROUP BY categoria;
```

### Subconsultas no HAVING
```sql
-- Departamentos com salário médio acima da média geral
SELECT 
    departamento,
    AVG(salario) as salario_medio
FROM funcionarios
GROUP BY departamento
HAVING AVG(salario) > (
    SELECT AVG(salario)
    FROM funcionarios
);
```

## Subconsultas Correlacionadas

Subconsultas que referenciam colunas da consulta externa.

```sql
-- Funcionários com salário acima da média do seu departamento
SELECT nome, departamento, salario
FROM funcionarios f1
WHERE salario > (
    SELECT AVG(salario)
    FROM funcionarios f2
    WHERE f2.departamento = f1.departamento
);

-- Top 3 produtos mais vendidos por categoria
SELECT produto_id, nome_produto, categoria_id, total_vendido
FROM (
    SELECT 
        p.produto_id,
        p.nome_produto,
        p.categoria_id,
        (SELECT COALESCE(SUM(quantidade), 0)
         FROM itens_pedido ip
         WHERE ip.produto_id = p.produto_id) as total_vendido,
        ROW_NUMBER() OVER (
            PARTITION BY p.categoria_id 
            ORDER BY (SELECT COALESCE(SUM(quantidade), 0)
                     FROM itens_pedido ip
                     WHERE ip.produto_id = p.produto_id) DESC
        ) as ranking
    FROM produtos p
) as ranking_produtos
WHERE ranking <= 3;
```

## Exemplos Práticos Avançados

### Análise de Vendas
```sql
-- Relatório completo de vendas por cliente
SELECT 
    c.nome as cliente,
    c.cidade,
    (SELECT COUNT(*) 
     FROM pedidos p 
     WHERE p.cliente_id = c.cliente_id) as total_pedidos,
    (SELECT COALESCE(SUM(valor_total), 0) 
     FROM pedidos p 
     WHERE p.cliente_id = c.cliente_id) as total_compras,
    (SELECT MAX(data_pedido) 
     FROM pedidos p 
     WHERE p.cliente_id = c.cliente_id) as ultimo_pedido,
    CASE 
        WHEN (SELECT COUNT(*) FROM pedidos p WHERE p.cliente_id = c.cliente_id) = 0 
        THEN 'Sem Compras'
        WHEN (SELECT MAX(data_pedido) FROM pedidos p WHERE p.cliente_id = c.cliente_id) < CURRENT_DATE - INTERVAL '90 days'
        THEN 'Inativo'
        ELSE 'Ativo'
    END as status_cliente
FROM clientes c
ORDER BY total_compras DESC;
```

### Ranking e Comparações
```sql
-- Funcionários e sua posição no ranking salarial do departamento
SELECT 
    nome,
    departamento,
    salario,
    (SELECT COUNT(*) 
     FROM funcionarios f2 
     WHERE f2.departamento = f1.departamento 
     AND f2.salario > f1.salario) + 1 as posicao_ranking,
    (SELECT COUNT(*) 
     FROM funcionarios f2 
     WHERE f2.departamento = f1.departamento) as total_departamento
FROM funcionarios f1
ORDER BY departamento, salario DESC;
```

### Análise Temporal
```sql
-- Comparar vendas mensais com o mês anterior
WITH vendas_mensais AS (
    SELECT 
        EXTRACT(YEAR FROM data_pedido) as ano,
        EXTRACT(MONTH FROM data_pedido) as mes,
        SUM(valor_total) as total_vendas
    FROM pedidos
    GROUP BY EXTRACT(YEAR FROM data_pedido), EXTRACT(MONTH FROM data_pedido)
)
SELECT 
    ano,
    mes,
    total_vendas,
    (SELECT total_vendas 
     FROM vendas_mensais vm2 
     WHERE vm2.ano = vm1.ano 
     AND vm2.mes = vm1.mes - 1) as vendas_mes_anterior,
    total_vendas - COALESCE(
        (SELECT total_vendas 
         FROM vendas_mensais vm2 
         WHERE vm2.ano = vm1.ano 
         AND vm2.mes = vm1.mes - 1), 0
    ) as diferenca
FROM vendas_mensais vm1
ORDER BY ano, mes;
```

## Performance e Otimização

### Dicas de Performance
1. **Prefira JOINs quando possível**: Geralmente mais eficientes que subconsultas correlacionadas
2. **Use EXISTS ao invés de IN**: Para verificar existência, EXISTS é mais eficiente
3. **Evite subconsultas no SELECT**: Podem ser executadas para cada linha
4. **Use LIMIT em subconsultas**: Quando aplicável, para reduzir o processamento

### Comparação: Subconsulta vs JOIN
```sql
-- Usando subconsulta (pode ser menos eficiente)
SELECT nome
FROM clientes
WHERE cliente_id IN (
    SELECT cliente_id
    FROM pedidos
    WHERE data_pedido >= '2024-01-01'
);

-- Usando JOIN (geralmente mais eficiente)
SELECT DISTINCT c.nome
FROM clientes c
JOIN pedidos p ON c.cliente_id = p.cliente_id
WHERE p.data_pedido >= '2024-01-01';
```

## Common Table Expressions (CTEs)

Uma alternativa mais legível às subconsultas complexas:

```sql
-- Usando CTE para maior clareza
WITH vendas_por_cliente AS (
    SELECT 
        cliente_id,
        SUM(valor_total) as total_vendas,
        COUNT(*) as total_pedidos
    FROM pedidos
    GROUP BY cliente_id
),
clientes_vip AS (
    SELECT cliente_id
    FROM vendas_por_cliente
    WHERE total_vendas > 10000
)
SELECT 
    c.nome,
    vc.total_vendas,
    vc.total_pedidos
FROM clientes c
JOIN vendas_por_cliente vc ON c.cliente_id = vc.cliente_id
WHERE c.cliente_id IN (SELECT cliente_id FROM clientes_vip);
```

## Boas Práticas

1. **Mantenha as subconsultas simples**: Subconsultas complexas podem ser difíceis de manter
2. **Use aliases descritivos**: Facilita a leitura e manutenção do código
3. **Teste a performance**: Compare subconsultas com JOINs para seu caso específico
4. **Considere CTEs**: Para subconsultas complexas, CTEs podem ser mais legíveis
5. **Trate valores NULL**: Cuidado com NOT IN quando a subconsulta pode retornar NULL

As subconsultas são uma ferramenta poderosa no SQL que permite resolver problemas complexos de forma estruturada e lógica. Com prática, você pode usá-las para criar consultas sofisticadas e eficientes.