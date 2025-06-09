# Comandos DML - Manipulação de Dados

## INSERT - Inserir Dados

### Sintaxe Básica
```sql
INSERT INTO nome_tabela (coluna1, coluna2, coluna3)
VALUES (valor1, valor2, valor3);
```

### Inserir um Registro
```sql
-- Especificando colunas
INSERT INTO clientes (nome, email, telefone)
VALUES ('João Silva', 'joao@email.com', '11999999999');

-- Inserindo em todas as colunas (mesma ordem da tabela)
INSERT INTO categorias
VALUES (DEFAULT, 'Eletrônicos', 'Produtos eletrônicos diversos');
```

### Inserir Múltiplos Registros
```sql
INSERT INTO produtos (nome, preco, categoria_id, estoque)
VALUES 
    ('Smartphone', 899.99, 1, 50),
    ('Notebook', 2499.90, 1, 20),
    ('Mouse', 29.90, 1, 100),
    ('Teclado', 89.90, 1, 75);
```

### INSERT com SELECT (Copiar dados)
```sql
-- Inserir dados de uma consulta
INSERT INTO produtos_backup (nome, preco, categoria_id)
SELECT nome, preco, categoria_id 
FROM produtos 
WHERE ativo = true;
```

### INSERT com ON CONFLICT (UPSERT)
```sql
-- PostgreSQL específico - inserir ou atualizar se existir
INSERT INTO clientes (id, nome, email)
VALUES (1, 'João Silva', 'joao.novo@email.com')
ON CONFLICT (id) 
DO UPDATE SET 
    nome = EXCLUDED.nome,
    email = EXCLUDED.email;

-- Ignorar se já existir
INSERT INTO categorias (nome, descricao)
VALUES ('Eletrônicos', 'Categoria de eletrônicos')
ON CONFLICT (nome) DO NOTHING;
```

### INSERT com RETURNING
```sql
-- Retornar dados do registro inserido
INSERT INTO clientes (nome, email)
VALUES ('Maria Santos', 'maria@email.com')
RETURNING id, nome, data_cadastro;

-- Inserir e retornar ID para usar em outra operação
WITH novo_cliente AS (
    INSERT INTO clientes (nome, email)
    VALUES ('Pedro Costa', 'pedro@email.com')
    RETURNING id
)
INSERT INTO pedidos (cliente_id, total)
SELECT id, 0.00 FROM novo_cliente;
```

## UPDATE - Atualizar Dados

### Sintaxe Básica
```sql
UPDATE nome_tabela
SET coluna1 = valor1, coluna2 = valor2
WHERE condição;
```

### Atualizar um Campo
```sql
UPDATE produtos
SET preco = 999.99
WHERE id = 1;
```

### Atualizar Múltiplos Campos
```sql
UPDATE clientes
SET nome = 'João Silva Santos',
    telefone = '11888888888',
    email = 'joao.santos@email.com'
WHERE id = 1;
```

### UPDATE com Condições
```sql
-- Atualizar baseado em condição
UPDATE produtos
SET preco = preco * 0.9  -- Desconto de 10%
WHERE categoria_id = 1 AND estoque > 10;

-- Atualizar usando CASE
UPDATE produtos
SET status = CASE
    WHEN estoque = 0 THEN 'Sem estoque'
    WHEN estoque < 5 THEN 'Estoque baixo'
    ELSE 'Disponível'
END;
```

### UPDATE com JOIN (PostgreSQL)
```sql
UPDATE produtos
SET categoria_nome = c.nome
FROM categorias c
WHERE produtos.categoria_id = c.id;
```

### UPDATE com Subconsulta
```sql
UPDATE pedidos
SET total = (
    SELECT SUM(quantidade * preco_unitario)
    FROM itens_pedido
    WHERE pedido_id = pedidos.id
)
WHERE id IN (SELECT DISTINCT pedido_id FROM itens_pedido);
```

### UPDATE com RETURNING
```sql
UPDATE produtos
SET preco = preco * 1.1  -- Aumento de 10%
WHERE categoria_id = 1
RETURNING id, nome, preco;
```

## DELETE - Deletar Dados

### Sintaxe Básica
```sql
DELETE FROM nome_tabela
WHERE condição;
```

### Deletar Registro Específico
```sql
DELETE FROM clientes
WHERE id = 1;
```

### Deletar com Condições
```sql
-- Deletar produtos sem estoque
DELETE FROM produtos
WHERE estoque = 0;

-- Deletar registros antigos
DELETE FROM pedidos
WHERE data_pedido < '2023-01-01';
```

### Deletar com Subconsulta
```sql
-- Deletar clientes que nunca fizeram pedidos
DELETE FROM clientes
WHERE id NOT IN (
    SELECT DISTINCT cliente_id 
    FROM pedidos 
    WHERE cliente_id IS NOT NULL
);
```

### DELETE com JOIN (usando EXISTS)
```sql
-- Deletar produtos de categorias inativas
DELETE FROM produtos
WHERE EXISTS (
    SELECT 1 FROM categorias
    WHERE categorias.id = produtos.categoria_id
    AND categorias.ativo = false
);
```

### DELETE com RETURNING
```sql
DELETE FROM produtos
WHERE estoque = 0
RETURNING id, nome, preco;
```

### TRUNCATE - Deletar Todos os Dados
```sql
-- Mais rápido que DELETE para limpar tabela inteira
TRUNCATE TABLE nome_tabela;

-- Com reinicialização do SERIAL
TRUNCATE TABLE produtos RESTART IDENTITY;

-- Truncate em cascata (cuidado!)
TRUNCATE TABLE categorias CASCADE;
```

## SELECT - Consultar Dados

### Sintaxe Básica
```sql
SELECT coluna1, coluna2
FROM nome_tabela
WHERE condição
ORDER BY coluna1
LIMIT número;
```

### SELECT Simples
```sql
-- Todas as colunas
SELECT * FROM clientes;

-- Colunas específicas
SELECT nome, email FROM clientes;

-- Com alias
SELECT nome AS cliente_nome, email AS cliente_email
FROM clientes;
```

### WHERE - Condições
```sql
-- Comparações básicas
SELECT * FROM produtos WHERE preco > 100;
SELECT * FROM produtos WHERE nome = 'Smartphone';
SELECT * FROM produtos WHERE categoria_id != 1;

-- Operadores lógicos
SELECT * FROM produtos 
WHERE preco > 50 AND estoque > 0;

SELECT * FROM clientes 
WHERE nome LIKE 'João%' OR email LIKE '%gmail.com';

-- IN e NOT IN
SELECT * FROM produtos 
WHERE categoria_id IN (1, 2, 3);

-- BETWEEN
SELECT * FROM pedidos 
WHERE data_pedido BETWEEN '2024-01-01' AND '2024-12-31';

-- IS NULL / IS NOT NULL
SELECT * FROM clientes WHERE telefone IS NOT NULL;

-- LIKE para busca por padrões
SELECT * FROM produtos WHERE nome LIKE '%phone%';
SELECT * FROM clientes WHERE nome LIKE 'J%';     -- Começa com J
SELECT * FROM produtos WHERE nome LIKE '%_tech'; -- Termina com tech
```

### ORDER BY - Ordenação
```sql
-- Ordem crescente (padrão)
SELECT * FROM produtos ORDER BY preco;

-- Ordem decrescente
SELECT * FROM produtos ORDER BY preco DESC;

-- Múltiplas colunas
SELECT * FROM produtos 
ORDER BY categoria_id ASC, preco DESC;

-- Por posição das colunas
SELECT nome, preco FROM produtos ORDER BY 2 DESC;
```

### LIMIT e OFFSET - Paginação
```sql
-- Primeiros 10 registros
SELECT * FROM produtos LIMIT 10;

-- Pular 10 e pegar próximos 10 (página 2)
SELECT * FROM produtos LIMIT 10 OFFSET 10;

-- Registro mais caro
SELECT * FROM produtos ORDER BY preco DESC LIMIT 1;
```

### DISTINCT - Valores Únicos
```sql
-- Valores únicos
SELECT DISTINCT categoria_id FROM produtos;

-- Combinações únicas
SELECT DISTINCT categoria_id, ativo FROM produtos;
```

### Funções de Agregação
```sql
-- COUNT
SELECT COUNT(*) FROM produtos;
SELECT COUNT(DISTINCT categoria_id) FROM produtos;

-- SUM, AVG, MIN, MAX
SELECT 
    COUNT(*) as total_produtos,
    SUM(estoque) as estoque_total,
    AVG(preco) as preco_medio,
    MIN(preco) as menor_preco,
    MAX(preco) as maior_preco
FROM produtos;
```

### GROUP BY - Agrupamento
```sql
-- Produtos por categoria
SELECT categoria_id, COUNT(*) as quantidade
FROM produtos
GROUP BY categoria_id;

-- Com múltiplas funções
SELECT 
    categoria_id,
    COUNT(*) as quantidade,
    AVG(preco) as preco_medio,
    SUM(estoque) as estoque_total
FROM produtos
GROUP BY categoria_id;
```

### HAVING - Filtrar Grupos
```sql
-- Categorias com mais de 5 produtos
SELECT categoria_id, COUNT(*) as quantidade
FROM produtos
GROUP BY categoria_id
HAVING COUNT(*) > 5;

-- Categorias com preço médio > 100
SELECT categoria_id, AVG(preco) as preco_medio
FROM produtos
GROUP BY categoria_id
HAVING AVG(preco) > 100;
```

### JOINS - Relacionamentos
```sql
-- INNER JOIN
SELECT p.nome, c.nome as categoria
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id;

-- LEFT JOIN
SELECT c.nome, COUNT(p.id) as total_produtos
FROM categorias c
LEFT JOIN produtos p ON c.id = p.categoria_id
GROUP BY c.id, c.nome;

-- Múltiplos JOINs
SELECT 
    cl.nome as cliente,
    p.id as pedido_id,
    pr.nome as produto,
    ip.quantidade,
    ip.preco_unitario
FROM clientes cl
INNER JOIN pedidos p ON cl.id = p.cliente_id
INNER JOIN itens_pedido ip ON p.id = ip.pedido_id
INNER JOIN produtos pr ON ip.produto_id = pr.id;
```

### Subconsultas
```sql
-- Produtos mais caros que a média
SELECT nome, preco
FROM produtos
WHERE preco > (SELECT AVG(preco) FROM produtos);

-- Clientes com pedidos
SELECT nome
FROM clientes
WHERE id IN (SELECT DISTINCT cliente_id FROM pedidos);

-- EXISTS
SELECT nome
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p 
    WHERE p.cliente_id = c.id
);
```

### Common Table Expressions (CTE)
```sql
-- CTE Simples
WITH produtos_caros AS (
    SELECT * FROM produtos WHERE preco > 1000
)
SELECT nome, preco FROM produtos_caros ORDER BY preco DESC;

-- CTE Recursiva (exemplo: hierarquia)
WITH RECURSIVE categoria_hierarquia AS (
    -- Caso base
    SELECT id, nome, parent_id, 1 as nivel
    FROM categorias 
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Caso recursivo
    SELECT c.id, c.nome, c.parent_id, ch.nivel + 1
    FROM categorias c
    INNER JOIN categoria_hierarquia ch ON c.parent_id = ch.id
)
SELECT * FROM categoria_hierarquia ORDER BY nivel, nome;
```

### Window Functions
```sql
-- ROW_NUMBER
SELECT 
    nome,
    preco,
    ROW_NUMBER() OVER (ORDER BY preco DESC) as ranking
FROM produtos;

-- RANK e DENSE_RANK
SELECT 
    nome,
    categoria_id,
    preco,
    RANK() OVER (PARTITION BY categoria_id ORDER BY preco DESC) as rank_categoria
FROM produtos;

-- LAG e LEAD
SELECT 
    nome,
    preco,
    LAG(preco) OVER (ORDER BY preco) as preco_anterior,
    LEAD(preco) OVER (ORDER BY preco) as proximo_preco
FROM produtos;
```

## Exemplos Práticos Completos

### Inserir Dados Relacionados
```sql
-- Inserir categoria e produtos
INSERT INTO categorias (nome, descricao) 
VALUES ('Informática', 'Produtos de informática e tecnologia')
RETURNING id;

-- Usar o ID retornado (suponha que seja 1)
INSERT INTO produtos (nome, preco, categoria_id, estoque)
VALUES 
    ('Monitor 24"', 599.90, 1, 15),
    ('Impressora', 299.90, 1, 8),
    ('Webcam', 159.90, 1, 25);
```

### Relatório de Vendas
```sql
SELECT 
    c.nome as cliente,
    COUNT(p.id) as total_pedidos,
    SUM(p.total) as valor_total,
    AVG(p.total) as ticket_medio,
    MAX(p.data_pedido) as ultimo_pedido
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nome
HAVING COUNT(p.id) > 0
ORDER BY valor_total DESC;
```

### Atualização em Lote
```sql
-- Reajustar preços por categoria
UPDATE produtos 
SET preco = CASE 
    WHEN categoria_id = 1 THEN preco * 1.05  -- Eletrônicos +5%
    WHEN categoria_id = 2 THEN preco * 1.03  -- Roupas +3%
    ELSE preco * 1.02                        -- Outros +2%
END
WHERE ativo = true;
```

### Limpeza de Dados
```sql
-- Deletar pedidos órfãos e itens relacionados
DELETE FROM itens_pedido 
WHERE pedido_id IN (
    SELECT id FROM pedidos 
    WHERE cliente_id NOT IN (SELECT id FROM clientes)
);

DELETE FROM pedidos 
WHERE cliente_id NOT IN (SELECT id FROM clientes);
```