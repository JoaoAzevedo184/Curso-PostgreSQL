# Views SQL - PostgreSQL

As Views são tabelas virtuais baseadas no resultado de uma consulta SQL. Elas não armazenam dados fisicamente, mas apresentam dados de uma ou mais tabelas de forma organizada e personalizada.

## Conceitos Fundamentais

### O que são Views?
Uma View é uma consulta SQL armazenada no banco de dados que pode ser tratada como uma tabela virtual. Quando consultada, a View executa a consulta subjacente e retorna os resultados.

### Características das Views
- **Virtuais**: Não armazenam dados, apenas a definição da consulta
- **Dinâmicas**: Sempre mostram dados atualizados das tabelas base
- **Reutilizáveis**: Podem ser usadas em outras consultas como se fossem tabelas
- **Seguras**: Podem ocultar colunas sensíveis ou complexidade das consultas

## Criando Views

### Sintaxe Básica
```sql
CREATE VIEW nome_da_view AS
SELECT colunas
FROM tabelas
WHERE condições;
```

### Exemplo Simples
```sql
-- View básica para funcionários ativos
CREATE VIEW funcionarios_ativos AS
SELECT 
    id,
    nome,
    email,
    departamento,
    salario,
    data_admissao
FROM funcionarios
WHERE status = 'ativo';

-- Usando a view
SELECT * FROM funcionarios_ativos
WHERE departamento = 'TI';
```

## Tipos de Views

### 1. Views Simples
Baseadas em uma única tabela com filtros ou seleção de colunas.

```sql
-- View para produtos em estoque
CREATE VIEW produtos_disponiveis AS
SELECT 
    produto_id,
    nome_produto,
    categoria,
    preco,
    quantidade_estoque
FROM produtos
WHERE quantidade_estoque > 0
AND status = 'ativo';

-- View para clientes premium
CREATE VIEW clientes_premium AS
SELECT 
    cliente_id,
    nome,
    email,
    cidade,
    data_cadastro
FROM clientes
WHERE categoria = 'premium'
AND status = 'ativo';
```

### 2. Views com JOINs
Combinam dados de múltiplas tabelas.

```sql
-- View completa de pedidos com informações do cliente
CREATE VIEW pedidos_completos AS
SELECT 
    p.pedido_id,
    p.data_pedido,
    p.valor_total,
    p.status as status_pedido,
    c.nome as nome_cliente,
    c.email as email_cliente,
    c.cidade,
    c.estado
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.cliente_id;

-- View de vendas por produto com categoria
CREATE VIEW vendas_por_produto AS
SELECT 
    p.produto_id,
    p.nome_produto,
    cat.nome_categoria,
    SUM(ip.quantidade) as total_vendido,
    SUM(ip.quantidade * ip.preco_unitario) as receita_total,
    COUNT(DISTINCT ip.pedido_id) as numero_pedidos
FROM produtos p
JOIN categorias cat ON p.categoria_id = cat.categoria_id
JOIN itens_pedido ip ON p.produto_id = ip.produto_id
JOIN pedidos ped ON ip.pedido_id = ped.pedido_id
WHERE ped.status = 'concluido'
GROUP BY p.produto_id, p.nome_produto, cat.nome_categoria;
```

### 3. Views com Agregações
Apresentam dados sumarizados e estatísticas.

```sql
-- View de resumo de vendas por mês
CREATE VIEW vendas_mensais AS
SELECT 
    EXTRACT(YEAR FROM data_pedido) as ano,
    EXTRACT(MONTH FROM data_pedido) as mes,
    COUNT(*) as total_pedidos,
    SUM(valor_total) as receita_total,
    AVG(valor_total) as ticket_medio,
    COUNT(DISTINCT cliente_id) as clientes_unicos
FROM pedidos
WHERE status = 'concluido'
GROUP BY EXTRACT(YEAR FROM data_pedido), EXTRACT(MONTH FROM data_pedido);

-- View de performance por funcionário
CREATE VIEW performance_funcionarios AS
SELECT 
    f.funcionario_id,
    f.nome,
    f.departamento,
    COUNT(v.venda_id) as total_vendas,
    COALESCE(SUM(v.valor_venda), 0) as receita_gerada,
    COALESCE(AVG(v.valor_venda), 0) as ticket_medio,
    CASE 
        WHEN COUNT(v.venda_id) >= 50 THEN 'Alto'
        WHEN COUNT(v.venda_id) >= 20 THEN 'Médio'
        ELSE 'Baixo'
    END as nivel_performance
FROM funcionarios f
LEFT JOIN vendas v ON f.funcionario_id = v.funcionario_id
WHERE f.status = 'ativo'
GROUP BY f.funcionario_id, f.nome, f.departamento;
```

## Views Avançadas

### Views com Subconsultas
```sql
-- View de clientes VIP com análise de comportamento
CREATE VIEW clientes_vip AS
SELECT 
    c.cliente_id,
    c.nome,
    c.email,
    c.data_cadastro,
    stats.total_pedidos,
    stats.valor_total_gasto,
    stats.ticket_medio,
    stats.ultimo_pedido,
    CASE 
        WHEN stats.ultimo_pedido >= CURRENT_DATE - INTERVAL '30 days' THEN 'Ativo'
        WHEN stats.ultimo_pedido >= CURRENT_DATE - INTERVAL '90 days' THEN 'Moderado'
        ELSE 'Inativo'
    END as status_atividade
FROM clientes c
JOIN (
    SELECT 
        cliente_id,
        COUNT(*) as total_pedidos,
        SUM(valor_total) as valor_total_gasto,
        AVG(valor_total) as ticket_medio,
        MAX(data_pedido) as ultimo_pedido
    FROM pedidos
    WHERE status = 'concluido'
    GROUP BY cliente_id
    HAVING SUM(valor_total) >= 5000
) stats ON c.cliente_id = stats.cliente_id;
```

### Views com Window Functions
```sql
-- View de ranking de produtos por categoria
CREATE VIEW ranking_produtos_categoria AS
SELECT 
    p.produto_id,
    p.nome_produto,
    cat.nome_categoria,
    p.preco,
    COALESCE(vendas.total_vendido, 0) as quantidade_vendida,
    COALESCE(vendas.receita, 0) as receita_produto,
    ROW_NUMBER() OVER (
        PARTITION BY cat.categoria_id 
        ORDER BY COALESCE(vendas.total_vendido, 0) DESC
    ) as ranking_categoria,
    DENSE_RANK() OVER (
        ORDER BY COALESCE(vendas.receita, 0) DESC
    ) as ranking_geral
FROM produtos p
JOIN categorias cat ON p.categoria_id = cat.categoria_id
LEFT JOIN (
    SELECT 
        produto_id,
        SUM(quantidade) as total_vendido,
        SUM(quantidade * preco_unitario) as receita
    FROM itens_pedido ip
    JOIN pedidos p ON ip.pedido_id = p.pedido_id
    WHERE p.status = 'concluido'
    GROUP BY produto_id
) vendas ON p.produto_id = vendas.produto_id
WHERE p.status = 'ativo';
```

## Gerenciamento de Views

### Visualizar Views Existentes
```sql
-- Listar todas as views do schema atual
SELECT 
    schemaname,
    viewname,
    viewowner
FROM pg_views
WHERE schemaname = 'public';

-- Ver definição de uma view específica
SELECT definition
FROM pg_views
WHERE viewname = 'funcionarios_ativos';
```

### Alterando Views
```sql
-- Substituir uma view existente
CREATE OR REPLACE VIEW funcionarios_ativos AS
SELECT 
    id,
    nome,
    email,
    departamento,
    salario,
    data_admissao,
    telefone  -- Nova coluna adicionada
FROM funcionarios
WHERE status = 'ativo'
AND data_demissao IS NULL;  -- Nova condição
```

### Removendo Views
```sql
-- Remover uma view
DROP VIEW funcionarios_ativos;

-- Remover view se existir (sem erro se não existir)
DROP VIEW IF EXISTS funcionarios_ativos;

-- Remover view e suas dependências
DROP VIEW funcionarios_ativos CASCADE;
```

## Views Materializadas

Views materializadas armazenam os resultados fisicamente, oferecendo melhor performance para consultas complexas.

### Criando View Materializada
```sql
-- View materializada para relatório de vendas
CREATE MATERIALIZED VIEW relatorio_vendas_trimestral AS
SELECT 
    EXTRACT(YEAR FROM data_pedido) as ano,
    EXTRACT(QUARTER FROM data_pedido) as trimestre,
    cat.nome_categoria,
    COUNT(DISTINCT p.pedido_id) as total_pedidos,
    SUM(ip.quantidade) as total_itens_vendidos,
    SUM(ip.quantidade * ip.preco_unitario) as receita_total,
    AVG(p.valor_total) as ticket_medio
FROM pedidos p
JOIN itens_pedido ip ON p.pedido_id = ip.pedido_id
JOIN produtos prod ON ip.produto_id = prod.produto_id
JOIN categorias cat ON prod.categoria_id = cat.categoria_id
WHERE p.status = 'concluido'
GROUP BY 
    EXTRACT(YEAR FROM data_pedido),
    EXTRACT(QUARTER FROM data_pedido),
    cat.categoria_id,
    cat.nome_categoria;
```

### Atualizando Views Materializadas
```sql
-- Atualizar dados da view materializada
REFRESH MATERIALIZED VIEW relatorio_vendas_trimestral;

-- Atualizar sem bloquear consultas (requer UNIQUE INDEX)
REFRESH MATERIALIZED VIEW CONCURRENTLY relatorio_vendas_trimestral;
```

### Índices em Views Materializadas
```sql
-- Criar índice para melhor performance
CREATE INDEX idx_relatorio_vendas_ano_trimestre 
ON relatorio_vendas_trimestral (ano, trimestre);

-- Índice único necessário para REFRESH CONCURRENTLY
CREATE UNIQUE INDEX idx_relatorio_vendas_unique
ON relatorio_vendas_trimestral (ano, trimestre, nome_categoria);
```

## Casos de Uso Práticos

### 1. Segurança e Controle de Acesso
```sql
-- View que oculta informações sensíveis
CREATE VIEW funcionarios_publico AS
SELECT 
    nome,
    departamento,
    cargo,
    email,
    telefone
FROM funcionarios
WHERE status = 'ativo';
-- Salário e informações pessoais não são expostos
```

### 2. Simplificação de Consultas Complexas
```sql
-- View que simplifica relatório complexo de vendas
CREATE VIEW dashboard_vendas AS
SELECT 
    'Hoje' as periodo,
    COUNT(*) as total_pedidos,
    SUM(valor_total) as receita,
    AVG(valor_total) as ticket_medio
FROM pedidos
WHERE DATE(data_pedido) = CURRENT_DATE
AND status = 'concluido'

UNION ALL

SELECT 
    'Esta Semana' as periodo,
    COUNT(*) as total_pedidos,
    SUM(valor_total) as receita,
    AVG(valor_total) as ticket_medio
FROM pedidos
WHERE data_pedido >= DATE_TRUNC('week', CURRENT_DATE)
AND status = 'concluido'

UNION ALL

SELECT 
    'Este Mês' as periodo,
    COUNT(*) as total_pedidos,
    SUM(valor_total) as receita,
    AVG(valor_total) as ticket_medio
FROM pedidos
WHERE data_pedido >= DATE_TRUNC('month', CURRENT_DATE)
AND status = 'concluido';
```

### 3. Padronização de Dados
```sql
-- View que padroniza apresentação de dados
CREATE VIEW contatos_padronizados AS
SELECT 
    cliente_id,
    UPPER(TRIM(nome)) as nome_padronizado,
    LOWER(TRIM(email)) as email_padronizado,
    REGEXP_REPLACE(telefone, '[^0-9]', '', 'g') as telefone_numerico,
    INITCAP(cidade) as cidade_formatada,
    UPPER(estado) as estado_padronizado
FROM clientes
WHERE status = 'ativo';
```

## Performance e Otimização

### Dicas de Performance
1. **Use índices nas tabelas base**: Views herdam a performance das tabelas subjacentes
2. **Evite views muito complexas**: Podem ser lentas para consultas frequentes
3. **Considere views materializadas**: Para consultas complexas executadas frequentemente
4. **Monitore planos de execução**: Use EXPLAIN para analisar performance

### Exemplo de Análise de Performance
```sql
-- Analisar performance de uma view
EXPLAIN ANALYZE
SELECT * FROM vendas_por_produto
WHERE total_vendido > 100;
```

## Boas Práticas

### Nomenclatura
- Use nomes descritivos e consistentes
- Prefixos como `vw_` podem ajudar a identificar views
- Documente o propósito da view

### Estrutura
```sql
-- Exemplo bem documentado
CREATE VIEW vw_clientes_ativos_detalhado AS
/*
Propósito: Apresentar informações completas de clientes ativos
Inclui: dados pessoais, estatísticas de compra, classificação
Atualização: Dados em tempo real
*/
SELECT 
    -- Identificação
    c.cliente_id,
    c.nome,
    c.email,
    
    -- Localização
    c.cidade,
    c.estado,
    
    -- Estatísticas
    stats.total_pedidos,
    stats.valor_total_gasto,
    
    -- Classificação
    CASE 
        WHEN stats.valor_total_gasto >= 10000 THEN 'VIP'
        WHEN stats.valor_total_gasto >= 5000 THEN 'Premium'
        ELSE 'Regular'
    END as categoria_cliente
    
FROM clientes c
LEFT JOIN (
    SELECT 
        cliente_id,
        COUNT(*) as total_pedidos,
        SUM(valor_total) as valor_total_gasto
    FROM pedidos
    WHERE status = 'concluido'
    GROUP BY cliente_id
) stats ON c.cliente_id = stats.cliente_id
WHERE c.status = 'ativo';
```

### Manutenção
1. **Documente as views**: Inclua comentários sobre propósito e uso
2. **Teste impactos**: Antes de alterar, verifique dependências
3. **Monitore usage**: Identifique views não utilizadas
4. **Mantenha atualizadas**: Revise periodicamente se ainda atendem às necessidades

As Views são uma ferramenta fundamental no PostgreSQL para organizar, simplificar e securizar o acesso aos dados, proporcionando uma camada de abstração poderosa entre as aplicações e a estrutura física do banco de dados.