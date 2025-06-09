# Funções Agregadoras

## Conceito
As funções agregadoras (ou de agregação) executam cálculos em um conjunto de valores e retornam um único resultado. São essenciais para análises estatísticas e relatórios.

## Funções Básicas

### COUNT - Contar Registros
```sql
-- Contar todos os registros
SELECT COUNT(*) FROM produtos;

-- Contar registros não nulos
SELECT COUNT(telefone) FROM clientes;

-- Contar valores únicos
SELECT COUNT(DISTINCT categoria_id) FROM produtos;

-- Count com condição
SELECT COUNT(*) FROM produtos WHERE ativo = true;
```

### SUM - Somar Valores
```sql
-- Soma simples
SELECT SUM(preco) FROM produtos;

-- Soma com condição
SELECT SUM(preco) FROM produtos WHERE categoria_id = 1;

-- Soma calculada
SELECT SUM(quantidade * preco_unitario) as total_vendas
FROM itens_pedido;

-- Soma por grupo
SELECT categoria_id, SUM(estoque) as estoque_total
FROM produtos
GROUP BY categoria_id;
```

### AVG - Média
```sql
-- Média simples
SELECT AVG(preco) FROM produtos;

-- Média com precisão
SELECT ROUND(AVG(preco), 2) as preco_medio FROM produtos;

-- Média por categoria
SELECT categoria_id, AVG(preco) as preco_medio
FROM produtos
GROUP BY categoria_id;

-- Média excluindo outliers
SELECT AVG(preco) FROM produtos 
WHERE preco BETWEEN 10 AND 1000;
```

### MIN e MAX - Mínimo e Máximo
```sql
-- Valores mínimo e máximo
SELECT MIN(preco) as menor_preco, MAX(preco) as maior_preco
FROM produtos;

-- Por categoria
SELECT 
    categoria_id,
    MIN(preco) as menor_preco,
    MAX(preco) as maior_preco
FROM produtos
GROUP BY categoria_id;

-- Com datas
SELECT 
    MIN(data_pedido) as primeiro_pedido,
    MAX(data_pedido) as ultimo_pedido
FROM pedidos;
```

## Funções Estatísticas Avançadas

### STDDEV - Desvio Padrão
```sql
-- Desvio padrão da população
SELECT STDDEV_POP(preco) FROM produtos;

-- Desvio padrão da amostra
SELECT STDDEV_SAMP(preco) FROM produtos;

-- Por categoria
SELECT categoria_id, STDDEV(preco) as desvio_preco
FROM produtos
GROUP BY categoria_id;
```

### VARIANCE - Variância
```sql
-- Variância da população
SELECT VAR_POP(preco) FROM produtos;

-- Variância da amostra
SELECT VAR_SAMP(preco) FROM produtos;
```

### Percentis
```sql
-- Percentil 50 (mediana)
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY preco) as mediana
FROM produtos;

-- Múltiplos percentis
SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY preco) as q1,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY preco) as mediana,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY preco) as q3
FROM produtos;

-- Percentil discreto
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY preco)
FROM produtos;
```

## Funções de String

### STRING_AGG - Concatenar Valores
```sql
-- Concatenar nomes de produtos por categoria
SELECT 
    categoria_id,
    STRING_AGG(nome, ', ') as produtos
FROM produtos
GROUP BY categoria_id;

-- Com ordenação
SELECT 
    categoria_id,
    STRING_AGG(nome, ', ' ORDER BY nome) as produtos_ordenados
FROM produtos
GROUP BY categoria_id;

-- Usando separador personalizado
SELECT STRING_AGG(nome, ' | ' ORDER BY preco DESC) as produtos_por_preco
FROM produtos;
```

### ARRAY_AGG - Criar Arrays
```sql
-- Array de preços por categoria
SELECT 
    categoria_id,
    ARRAY_AGG(preco) as precos
FROM produtos
GROUP BY categoria_id;

-- Array com ordenação
SELECT 
    categoria_id,
    ARRAY_AGG(nome ORDER BY preco DESC) as produtos_ordenados
FROM produtos
GROUP BY categoria_id;
```

## Funções Lógicas

### BOOL_AND e BOOL_OR
```sql
-- Verificar se todos os produtos estão ativos
SELECT BOOL_AND(ativo) as todos_ativos FROM produtos;

-- Verificar se algum produto está ativo
SELECT BOOL_OR(ativo) as algum_ativo FROM produtos;

-- Por categoria
SELECT 
    categoria_id,
    BOOL_AND(ativo) as todos_ativos,
    BOOL_OR(ativo) as algum_ativo
FROM produtos
GROUP BY categoria_id;
```

## Combinando Funções Agregadoras

### Análise Estatística Completa
```sql
SELECT 
    categoria_id,
    COUNT(*) as total_produtos,
    SUM(estoque) as estoque_total,
    AVG(preco) as preco_medio,
    MIN(preco) as menor_preco,
    MAX(preco) as maior_preco,
    STDDEV(preco) as desvio_preco,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY preco) as mediana_preco
FROM produtos
WHERE ativo = true
GROUP BY categoria_id
ORDER BY categoria_id;
```

### Relatório de Vendas por Período
```sql
SELECT 
    DATE_TRUNC('month', data_pedido) as mes,
    COUNT(*) as total_pedidos,
    COUNT(DISTINCT cliente_id) as clientes_unicos,
    SUM(total) as faturamento_total,
    AVG(total) as ticket_medio,
    MIN(total) as menor_pedido,
    MAX(total) as maior_pedido
FROM pedidos
WHERE data_pedido >= '2024-01-01'
GROUP BY DATE_TRUNC('month', data_pedido)
ORDER BY mes;
```

## Funções com FILTER

### Contagem Condicional
```sql
-- PostgreSQL 9.4+
SELECT 
    categoria_id,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE ativo = true) as ativos,
    COUNT(*) FILTER (WHERE estoque = 0) as sem_estoque,
    AVG(preco) FILTER (WHERE ativo = true) as preco_medio_ativos
FROM produtos
GROUP BY categoria_id;
```

### Múltiplas Condições
```sql
SELECT 
    COUNT(*) as total_pedidos,
    COUNT(*) FILTER (WHERE total > 100) as pedidos_grandes,
    COUNT(*) FILTER (WHERE total BETWEEN 50 AND 100) as pedidos_medios,
    COUNT(*) FILTER (WHERE total < 50) as pedidos_pequenos,
    SUM(total) FILTER (WHERE status = 'finalizado') as vendas_finalizadas
FROM pedidos;
```

## Window Functions com Agregação

### Running Totals (Totais Acumulados)
```sql
SELECT 
    data_pedido,
    total,
    SUM(total) OVER (ORDER BY data_pedido) as total_acumulado
FROM pedidos
ORDER BY data_pedido;
```

### Média Móvel
```sql
SELECT 
    data_pedido,
    total,
    AVG(total) OVER (
        ORDER BY data_pedido 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as media_movel_3_dias
FROM pedidos
ORDER BY data_pedido;
```

### Ranking por Grupos
```sql
SELECT 
    categoria_id,
    nome,
    preco,
    RANK() OVER (PARTITION BY categoria_id ORDER BY preco DESC) as rank_preco,
    AVG(preco) OVER (PARTITION BY categoria_id) as preco_medio_categoria
FROM produtos;
```

## Expressões CASE com Agregação

### Contagem por Faixas
```sql
SELECT 
    categoria_id,
    COUNT(CASE WHEN preco < 50 THEN 1 END) as produtos_baratos,
    COUNT(CASE WHEN preco BETWEEN 50 AND 200 THEN 1 END) as produtos_medios,
    COUNT(CASE WHEN preco > 200 THEN 1 END) as produtos_caros,
    SUM(CASE WHEN ativo = true THEN estoque ELSE 0 END) as estoque_ativo
FROM produtos
GROUP BY categoria_id;
```

### Soma Condicional
```sql
SELECT 
    cliente_id,
    SUM(CASE WHEN status = 'finalizado' THEN total ELSE 0 END) as vendas_finalizadas,
    SUM(CASE WHEN status = 'cancelado' THEN total ELSE 0 END) as vendas_canceladas,
    COUNT(CASE WHEN status = 'pendente' THEN 1 END) as pedidos_pendentes
FROM pedidos
GROUP BY cliente_id;
```

## Funções Agregadoras com Subconsultas

### Comparação com Média Global
```sql
SELECT 
    categoria_id,
    AVG(preco) as preco_medio_categoria,
    (SELECT AVG(preco) FROM produtos) as preco_medio_geral,
    AVG(preco) - (SELECT AVG(preco) FROM produtos) as diferenca_media
FROM produtos
GROUP BY categoria_id;
```

### Top N por Grupo
```sql
-- Produtos mais caros por categoria (top 3)
SELECT categoria_id, nome, preco
FROM (
    SELECT 
        categoria_id, 
        nome, 
        preco,
        ROW_NUMBER() OVER (PARTITION BY categoria_id ORDER BY preco DESC) as rn
    FROM produtos
) ranked
WHERE rn <= 3;
```

## Exemplos Práticos Avançados

### Dashboard de Vendas
```sql
WITH vendas_resumo AS (
    SELECT 
        DATE_TRUNC('day', p.data_pedido) as data_venda,
        COUNT(p.id) as total_pedidos,
        COUNT(DISTINCT p.cliente_id) as clientes_unicos,
        SUM(p.total) as faturamento,
        AVG(p.total) as ticket_medio,
        SUM(ip.quantidade) as itens_vendidos
    FROM pedidos p
    LEFT JOIN itens_pedido ip ON p.id = ip.pedido_id
    WHERE p.data_pedido >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY DATE_TRUNC('day', p.data_pedido)
)
SELECT 
    data_venda,
    total_pedidos,
    clientes_unicos,
    faturamento,
    ticket_medio,
    itens_vendidos,
    -- Médias móveis de 7 dias
    AVG(faturamento) OVER (
        ORDER BY data_venda 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as faturamento_media_7d,
    -- Crescimento dia a dia
    LAG(faturamento) OVER (ORDER BY data_venda) as faturamento_anterior,
    ROUND(
        ((faturamento - LAG(faturamento) OVER (ORDER BY data_venda)) / 
         LAG(faturamento) OVER (ORDER BY data_venda)) * 100, 2
    ) as crescimento_pct
FROM vendas_resumo
ORDER BY data_venda DESC;
```

### Análise de Clientes
```sql
SELECT 
    c.id,
    c.nome,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as valor_total_compras,
    AVG(p.total) as ticket_medio,
    MIN(p.data_pedido) as primeira_compra,
    MAX(p.data_pedido) as ultima_compra,
    -- Classificação de cliente
    CASE 
        WHEN SUM(p.total) > 5000 THEN 'Premium'
        WHEN SUM(p.total) > 1000 THEN 'Gold'
        WHEN SUM(p.total) > 500 THEN 'Silver'
        ELSE 'Bronze'
    END as categoria_cliente,
    -- Recência (dias desde última compra)
    EXTRACT(DAY FROM (CURRENT_DATE - MAX(p.data_pedido))) as dias_ultima_compra
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome
HAVING COUNT(p.id) > 0
ORDER BY valor_total_compras DESC;
```

### Análise de Produtos
```sql
SELECT 
    p.nome,
    cat.nome as categoria,
    COUNT(ip.id) as vezes_vendido,
    SUM(ip.quantidade) as quantidade_total_vendida,
    SUM(ip.quantidade * ip.preco_unitario) as receita_total,
    AVG(ip.preco_unitario) as preco_medio_venda,
    p.preco as preco_atual,
    p.estoque,
    -- Ranking de vendas
    RANK() OVER (ORDER BY SUM(ip.quantidade) DESC) as ranking_vendas,
    -- Margem estimada
    ROUND(
        ((AVG(ip.preco_unitario) - p.preco * 0.6) / AVG(ip.preco_unitario)) * 100, 2
    ) as margem_estimada_pct
FROM produtos p
LEFT JOIN categorias cat ON p.categoria_id = cat.id
LEFT JOIN itens_pedido ip ON p.id = ip.produto_id
WHERE p.ativo = true
GROUP BY p.id, p.nome, cat.nome, p.preco, p.estoque
ORDER BY quantidade_total_vendida DESC NULLS LAST;
```