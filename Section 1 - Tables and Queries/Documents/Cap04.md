# Guia SQL PostgreSQL - Relacionamentos com JOIN

## Conceito de JOIN

O JOIN é uma operação que permite combinar registros de duas ou mais tabelas baseado em uma condição de relacionamento. É fundamental para trabalhar com bancos de dados relacionais.

## Tipos de Relacionamentos

### 1:1 (Um para Um)
```sql
-- Exemplo: Cliente e Endereço Principal
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE
);

CREATE TABLE enderecos_principais (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER UNIQUE NOT NULL,
    rua VARCHAR(200),
    cidade VARCHAR(100),
    cep VARCHAR(8),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

### 1:N (Um para Muitos)
```sql
-- Exemplo: Cliente e Pedidos
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    data_pedido DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

### N:N (Muitos para Muitos)
```sql
-- Exemplo: Produtos e Categorias (através de tabela intermediária)
CREATE TABLE produtos_categorias (
    produto_id INTEGER,
    categoria_id INTEGER,
    PRIMARY KEY (produto_id, categoria_id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);
```

## Estrutura das Tabelas de Exemplo

```sql
-- Criando tabelas para exemplos
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    descricao TEXT
);

CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2),
    categoria_id INTEGER,
    estoque INTEGER DEFAULT 0,
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    cidade VARCHAR(100)
);

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER,
    data_pedido DATE,
    total DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pendente',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER,
    produto_id INTEGER,
    quantidade INTEGER,
    preco_unitario DECIMAL(10,2),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- Inserindo dados de exemplo
INSERT INTO categorias (nome, descricao) VALUES 
    ('Eletrônicos', 'Produtos eletrônicos'),
    ('Roupas', 'Vestuário em geral'),
    ('Livros', 'Literatura e educação');

INSERT INTO produtos (nome, preco, categoria_id, estoque) VALUES 
    ('Smartphone', 899.99, 1, 50),
    ('Camiseta', 29.90, 2, 100),
    ('Livro SQL', 45.00, 3, 30),
    ('Notebook', 2499.90, 1, 15),
    ('Calça Jeans', 89.90, 2, 75);

INSERT INTO clientes (nome, email, cidade) VALUES 
    ('João Silva', 'joao@email.com', 'São Paulo'),
    ('Maria Santos', 'maria@email.com', 'Rio de Janeiro'),
    ('Pedro Costa', 'pedro@email.com', 'Belo Horizonte');

INSERT INTO pedidos (cliente_id, data_pedido, total, status) VALUES 
    (1, '2024-01-15', 929.89, 'finalizado'),
    (2, '2024-01-16', 119.80, 'finalizado'),
    (1, '2024-01-17', 45.00, 'pendente');

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES 
    (1, 1, 1, 899.99),
    (1, 2, 1, 29.90),
    (2, 2, 2, 29.90),
    (2, 5, 1, 89.90),
    (3, 3, 1, 45.00);
```

## INNER JOIN

### Conceito
Retorna apenas os registros que têm correspondência em ambas as tabelas.

### Sintaxe
```sql
SELECT colunas
FROM tabela1
INNER JOIN tabela2 ON tabela1.coluna = tabela2.coluna;
```

### Exemplos Básicos
```sql
-- Produtos com suas categorias
SELECT 
    p.nome as produto,
    p.preco,
    c.nome as categoria
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- Pedidos com dados do cliente
SELECT 
    p.id as pedido_id,
    c.nome as cliente,
    p.data_pedido,
    p.total
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.id;
```

### INNER JOIN com Múltiplas Tabelas
```sql
-- Detalhes completos dos itens de pedido
SELECT 
    c.nome as cliente,
    p.id as pedido_id,
    p.data_pedido,
    pr.nome as produto,
    cat.nome as categoria,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) as subtotal
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
INNER JOIN itens_pedido ip ON p.id = ip.pedido_id
INNER JOIN produtos pr ON ip.produto_id = pr.id
INNER JOIN categorias cat ON pr.categoria_id = cat.id
ORDER BY c.nome, p.data_pedido;
```

### INNER JOIN com Condições Adicionais
```sql
-- Produtos vendidos apenas em pedidos finalizados
SELECT DISTINCT
    pr.nome as produto,
    pr.preco,
    cat.nome as categoria
FROM produtos pr
INNER JOIN itens_pedido ip ON pr.id = ip.produto_id
INNER JOIN pedidos p ON ip.pedido_id = p.id
INNER JOIN categorias cat ON pr.categoria_id = cat.id
WHERE p.status = 'finalizado'
ORDER BY cat.nome, pr.nome;
```

## LEFT JOIN (LEFT OUTER JOIN)

### Conceito
Retorna todos os registros da tabela da esquerda e os correspondentes da direita. Se não houver correspondência, retorna NULL para as colunas da direita.

### Sintaxe
```sql
SELECT colunas
FROM tabela1
LEFT JOIN tabela2 ON tabela1.coluna = tabela2.coluna;
```

### Exemplos Básicos
```sql
-- Todos os clientes e seus pedidos (incluindo clientes sem pedidos)
SELECT 
    c.nome as cliente,
    c.email,
    p.id as pedido_id,
    p.data_pedido,
    p.total
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
ORDER BY c.nome;

-- Todas as categorias e quantidade de produtos
SELECT 
    c.nome as categoria,
    COUNT(p.id) as total_produtos
FROM categorias c
LEFT JOIN produtos p ON c.id = p.categoria_id
GROUP BY c.id, c.nome
ORDER BY total_produtos DESC;
```

### Identificando Registros Órfãos
```sql
-- Clientes que nunca fizeram pedidos
SELECT 
    c.nome as cliente,
    c.email
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
WHERE p.id IS NULL;

-- Categorias sem produtos
SELECT 
    c.nome as categoria_vazia
FROM categorias c
LEFT JOIN produtos p ON c.id = p.categoria_id
WHERE p.id IS NULL;
```

### LEFT JOIN com Agregações
```sql
-- Resumo de vendas por cliente
SELECT 
    c.nome as cliente,
    c.cidade,
    COUNT(p.id) as total_pedidos,
    COALESCE(SUM(p.total), 0) as valor_total_compras,
    COALESCE(AVG(p.total), 0) as ticket_medio
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome, c.cidade
ORDER BY valor_total_compras DESC;
```

## RIGHT JOIN (RIGHT OUTER JOIN)

### Conceito
Retorna todos os registros da tabela da direita e os correspondentes da esquerda. É o oposto do LEFT JOIN.

### Sintaxe
```sql
SELECT colunas
FROM tabela1
RIGHT JOIN tabela2 ON tabela1.coluna = tabela2.coluna;
```

### Exemplos
```sql
-- Todos os pedidos e clientes (mesmo pedidos órfãos)
SELECT 
    p.id as pedido_id,
    p.data_pedido,
    p.total,
    c.nome as cliente
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.cliente_id;

-- Equivalente com LEFT JOIN (mais comum)
SELECT 
    p.id as pedido_id,
    p.data_pedido,
    p.total,
    c.nome as cliente
FROM pedidos p
LEFT JOIN clientes c ON p.cliente_id = c.id;
```

## FULL OUTER JOIN

### Conceito
Retorna todos os registros quando há correspondência em qualquer uma das tabelas. Combina LEFT e RIGHT JOIN.

### Sintaxe
```sql
SELECT colunas
FROM tabela1
FULL OUTER JOIN tabela2 ON tabela1.coluna = tabela2.coluna;
```

### Exemplos
```sql
-- Todos os clientes e pedidos (clientes sem pedidos + pedidos órfãos)
SELECT 
    c.nome as cliente,
    p.id as pedido_id,
    p.data_pedido,
    p.total
FROM clientes c
FULL OUTER JOIN pedidos p ON c.id = p.cliente_id;

-- Identificar inconsistências
SELECT 
    c.nome as cliente,
    p.id as pedido_id,
    CASE 
        WHEN c.id IS NULL THEN 'Pedido órfão'
        WHEN p.id IS NULL THEN 'Cliente sem pedidos'
        ELSE 'OK'
    END as status
FROM clientes c
FULL OUTER JOIN pedidos p ON c.id = p.cliente_id
WHERE c.id IS NULL OR p.id IS NULL;
```

## CROSS JOIN

### Conceito
Retorna o produto cartesiano de duas tabelas (cada registro da primeira tabela combinado com cada registro da segunda).

### Sintaxe
```sql
SELECT colunas
FROM tabela1
CROSS JOIN tabela2;
```

### Exemplos
```sql
-- Todas as combinações possíveis de produtos e categorias
SELECT 
    p.nome as produto,
    c.nome as categoria
FROM produtos p
CROSS JOIN categorias c
ORDER BY p.nome, c.nome;

-- Matriz de preços (exemplo teórico)
SELECT 
    p1.nome as produto1,
    p2.nome as produto2,
    (p1.preco + p2.preco) as preco_combo
FROM produtos p1
CROSS JOIN produtos p2
WHERE p1.id < p2.id  -- Evitar duplicatas
ORDER BY preco_combo;
```

## SELF JOIN

### Conceito
JOIN de uma tabela com ela mesma, útil para dados hierárquicos ou comparações dentro da mesma tabela.

### Exemplo com Hierarquia
```sql
-- Criando tabela de funcionários com hierarquia
CREATE TABLE funcionarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    cargo VARCHAR(50),
    salario DECIMAL(10,2),
    gerente_id INTEGER,
    FOREIGN KEY (gerente_id) REFERENCES funcionarios(id)
);

INSERT INTO funcionarios (nome, cargo, salario, gerente_id) VALUES
    ('Carlos Silva', 'Diretor', 15000, NULL),
    ('Ana Costa', 'Gerente', 8000, 1),
    ('Pedro Santos', 'Vendedor', 3000, 2),
    ('Maria Oliveira', 'Vendedora', 3200, 2);

-- Funcionários com seus gerentes
SELECT 
    f.nome as funcionario,
    f.cargo,
    g.nome as gerente,
    g.cargo as cargo_gerente
FROM funcionarios f
LEFT JOIN funcionarios g ON f.gerente_id = g.id;
```

### Comparações na Mesma Tabela
```sql
-- Produtos mais caros que outros da mesma categoria
SELECT 
    p1.nome as produto,
    p1.preco,
    p2.nome as produto_comparacao,
    p2.preco as preco_comparacao
FROM produtos p1
INNER JOIN produtos p2 ON p1.categoria_id = p2.categoria_id
WHERE p1.preco > p2.preco
ORDER BY p1.categoria_id, p1.preco DESC;
```

## JOINs com Subconsultas

### JOIN com Subconsulta no FROM
```sql
-- Clientes com seus gastos totais
SELECT 
    c.nome,
    vendas.total_pedidos,
    vendas.valor_total
FROM clientes c
INNER JOIN (
    SELECT 
        cliente_id,
        COUNT(*) as total_pedidos,
        SUM(total) as valor_total
    FROM pedidos
    GROUP BY cliente_id
) vendas ON c.id = vendas.cliente_id;
```

### JOIN com Subconsulta Correlacionada
```sql
-- Produtos com preço acima da média da categoria
SELECT 
    p.nome,
    p.preco,
    c.nome as categoria,
    media_cat.preco_medio_categoria
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id
INNER JOIN (
    SELECT 
        categoria_id,
        AVG(preco) as preco_medio_categoria
    FROM produtos
    GROUP BY categoria_id
) media_cat ON p.categoria_id = media_cat.categoria_id
WHERE p.preco > media_cat.preco_medio_categoria;
```

## Otimização de JOINs

### Uso de Índices
```sql
-- Criar índices para melhorar performance dos JOINs
CREATE INDEX idx_produtos_categoria ON produtos(categoria_id);
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_itens_pedido ON itens_pedido(pedido_id);
CREATE INDEX idx_itens_produto ON itens_pedido(produto_id);
```

### Ordem dos JOINs
```sql
-- Melhor performance: começar com tabelas menores
SELECT p.nome, c.nome as categoria
FROM categorias c  -- Tabela menor primeiro
INNER JOIN produtos p ON c.id = p.categoria_id;
```

### Filtros no WHERE vs ON
```sql
-- Filtro no WHERE (aplicado após o JOIN)
SELECT p.nome, c.nome as categoria
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id
WHERE p.preco > 100;

-- Filtro no ON (aplicado durante o JOIN) - pode ser mais eficiente
SELECT p.nome, c.nome as categoria
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id AND p.preco > 100;
```

## Exemplos Práticos Avançados

### Relatório de Vendas Completo
```sql
SELECT 
    c.nome as cliente,
    c.cidade,
    cat.nome as categoria,
    pr.nome as produto,
    p.data_pedido,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) as subtotal,
    -- Totais por cliente
    SUM(ip.quantidade * ip.preco_unitario) OVER (PARTITION BY c.id) as total_cliente,
    -- Ranking de clientes por valor
    RANK() OVER (ORDER BY SUM(ip.quantidade * ip.preco_unitario) OVER (PARTITION BY c.id) DESC) as ranking_cliente
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
INNER JOIN itens_pedido ip ON p.id = ip.pedido_id
INNER JOIN produtos pr ON ip.produto_id = pr.id
INNER JOIN categorias cat ON pr.categoria_id = cat.id
WHERE p.status = 'finalizado'
ORDER BY total_cliente DESC, c.nome, p.data_pedido;
```

### Análise de Produtos Não Vendidos
```sql
SELECT 
    p.nome as produto_nao_vendido,
    c.nome as categoria,
    p.preco,
    p.estoque,
    -- Calcular tempo sem venda
    COALESCE(
        EXTRACT(DAY FROM (CURRENT_DATE - MAX(ped.data_pedido))), 
        999
    ) as dias_sem_venda
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN itens_pedido ip ON p.id = ip.produto_id
LEFT JOIN pedidos ped ON ip.pedido_id = ped.id
GROUP BY p.id, p.nome, c.nome, p.preco, p.estoque
HAVING COUNT(ip.id) = 0 OR MAX(ped.data_pedido) < CURRENT_DATE - INTERVAL '30 days'
ORDER BY dias_sem_venda DESC;
```

### Dashboard Executivo
```sql
WITH vendas_mes AS (
    SELECT 
        DATE_TRUNC('month', p.data_pedido) as mes,
        COUNT(DISTINCT p.id) as pedidos,
        COUNT(DISTINCT p.cliente_id) as clientes_unicos,
        SUM(ip.quantidade * ip.preco_unitario) as faturamento
    FROM pedidos p
    INNER JOIN itens_pedido ip ON p.id = ip.pedido_id
    WHERE p.status = 'finalizado'
    GROUP BY DATE_TRUNC('month', p.data_pedido)
),
categoria_vendas AS (
    SELECT 
        cat.nome as categoria,
        SUM(ip.quantidade * ip.preco_unitario) as faturamento_categoria,
        COUNT(DISTINCT p.cliente_id) as clientes_categoria
    FROM categorias cat
    INNER JOIN produtos pr ON cat.id = pr.categoria_id
    INNER JOIN itens_pedido ip ON pr.id = ip.produto_id
    INNER JOIN pedidos p ON ip.pedido_id = p.id
    WHERE p.status = 'finalizado'
    GROUP BY cat.id, cat.nome
)
SELECT 
    vm.mes,
    vm.pedidos,
    vm.clientes_unicos,
    vm.faturamento,
    vm.faturamento / vm.pedidos as ticket_medio,
    -- Crescimento mês a mês
    LAG(vm.faturamento) OVER (ORDER BY vm.mes) as faturamento_mes_anterior,
    ROUND(
        ((vm.faturamento - LAG(vm.faturamento) OVER (ORDER BY vm.mes)) / 
         LAG(vm.faturamento) OVER (ORDER BY vm.mes)) * 100, 2
    ) as crescimento_pct
FROM vendas_mes vm
ORDER BY vm.mes DESC;
```

### Análise de Relacionamento Cliente-Produto
```sql
-- Matriz de afinidade cliente-categoria
SELECT 
    c.nome as cliente,
    STRING_AGG(
        cat.nome || ' (' || COUNT(ip.id)::text || ')', 
        ', ' ORDER BY COUNT(ip.id) DESC
    ) as categorias_preferidas,
    COUNT(DISTINCT cat.id) as variedade_categorias,
    SUM(ip.quantidade * ip.preco_unitario) as valor_total
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
INNER JOIN itens_pedido ip ON p.id = ip.pedido_id
INNER JOIN produtos pr ON ip.produto_id = pr.id
INNER JOIN categorias cat ON pr.categoria_id = cat.id
WHERE p.status = 'finalizado'
GROUP BY c.id, c.nome
ORDER BY valor_total DESC;
```