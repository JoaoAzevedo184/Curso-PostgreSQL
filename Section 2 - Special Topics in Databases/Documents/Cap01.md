# Índices no PostgreSQL

## Introdução

Índices são estruturas de dados que melhoram drasticamente a performance de consultas ao banco de dados, funcionando como um "atalho" para localizar dados rapidamente. No PostgreSQL, os índices são fundamentais para otimização de queries e podem significar a diferença entre uma consulta que executa em milissegundos versus uma que demora minutos.

## Conceitos Fundamentais

### O que são Índices?

Um índice é uma estrutura de dados separada que mantém referências ordenadas aos dados da tabela original. É similar a um índice remissivo de um livro, permitindo localizar informações rapidamente sem precisar percorrer todo o conteúdo.

### Como Funcionam

```sql
-- Sem índice: Scan completo da tabela
SELECT * FROM usuarios WHERE email = 'user@example.com';
-- PostgreSQL precisa verificar TODAS as linhas

-- Com índice: Busca direta
CREATE INDEX idx_usuarios_email ON usuarios(email);
-- PostgreSQL vai diretamente ao registro
```

## Tipos de Índices no PostgreSQL

### 1. B-Tree (Padrão)

O tipo mais comum, ideal para comparações de igualdade e intervalos:

```sql
-- Índice B-Tree básico
CREATE INDEX idx_usuarios_nome ON usuarios(nome);

-- Índice composto (múltiplas colunas)
CREATE INDEX idx_pedidos_cliente_data ON pedidos(cliente_id, data_pedido);

-- Índice com ordenação específica
CREATE INDEX idx_produtos_preco_desc ON produtos(preco DESC);

-- Índice parcial (com condição WHERE)
CREATE INDEX idx_usuarios_ativos ON usuarios(nome) 
WHERE ativo = true;
```

### 2. Hash

Otimizado apenas para comparações de igualdade:

```sql
-- Índice Hash para buscas exatas
CREATE INDEX idx_hash_cpf ON clientes USING HASH(cpf);

-- Ideal para: WHERE cpf = '12345678901'
-- NÃO funciona para: WHERE cpf LIKE '123%'
```

### 3. GIN (Generalized Inverted Index)

Excelente para tipos de dados compostos como arrays, JSONB e texto completo:

```sql
-- Índice GIN para JSONB
CREATE INDEX idx_gin_metadados ON produtos USING GIN(metadados);

-- Para arrays
CREATE INDEX idx_gin_tags ON artigos USING GIN(tags);

-- Para busca de texto completo
CREATE INDEX idx_gin_busca ON documentos USING GIN(to_tsvector('portuguese', conteudo));
```

### 4. GiST (Generalized Search Tree)

Ideal para dados geométricos, intervalos e buscas de proximidade:

```sql
-- Para tipos geométricos
CREATE INDEX idx_gist_localizacao ON pontos USING GiST(coordenadas);

-- Para intervalos de tempo
CREATE INDEX idx_gist_periodo ON eventos USING GiST(data_inicio, data_fim);

-- Para busca de texto (alternativa ao GIN)
CREATE INDEX idx_gist_texto ON documentos USING GiST(to_tsvector('portuguese', texto));
```

### 5. SP-GiST (Space-Partitioned GiST)

Para dados não balanceados como endereços IP, números de telefone:

```sql
-- Para endereços IP
CREATE INDEX idx_spgist_ip ON logs USING SPGIST(ip_address);

-- Para números de telefone
CREATE INDEX idx_spgist_telefone ON contatos USING SPGIST(telefone);
```

### 6. BRIN (Block Range Index)

Eficiente para tabelas muito grandes com dados naturalmente ordenados:

```sql
-- Para tabelas grandes com dados ordenados cronologicamente
CREATE INDEX idx_brin_data ON logs_sistema USING BRIN(created_at);

-- Ocupa pouco espaço mas é eficaz para dados sequenciais
CREATE INDEX idx_brin_id ON transacoes USING BRIN(id);
```

## Índices Especiais

### Índices Únicos

```sql
-- Garantem unicidade dos dados
CREATE UNIQUE INDEX idx_unique_email ON usuarios(email);

-- Índice único composto
CREATE UNIQUE INDEX idx_unique_produto_fornecedor 
ON produtos(codigo, fornecedor_id);

-- Índice único parcial
CREATE UNIQUE INDEX idx_unique_username_ativo 
ON usuarios(username) WHERE ativo = true;
```

### Índices Funcionais

```sql
-- Índice em expressão
CREATE INDEX idx_email_lower ON usuarios(LOWER(email));

-- Índice em função customizada
CREATE INDEX idx_nome_sem_acentos ON pessoas(unaccent(nome));

-- Índice em expressão complexa
CREATE INDEX idx_nome_completo ON usuarios(nome || ' ' || sobrenome);

-- Para buscas case-insensitive
CREATE INDEX idx_busca_produto ON produtos(UPPER(nome));
```

### Índices Parciais

```sql
-- Apenas registros ativos
CREATE INDEX idx_usuarios_ativos_email ON usuarios(email) 
WHERE ativo = true;

-- Apenas pedidos recentes
CREATE INDEX idx_pedidos_recentes ON pedidos(cliente_id) 
WHERE data_pedido >= '2024-01-01';

-- Apenas registros com valor específico
CREATE INDEX idx_produtos_promocao ON produtos(nome) 
WHERE em_promocao = true AND estoque > 0;
```

## Estratégias de Indexação

### 1. Índices para WHERE Clauses

```sql
-- Para consultas frequentes
SELECT * FROM pedidos WHERE cliente_id = 123;
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);

-- Para múltiplas condições
SELECT * FROM produtos WHERE categoria = 'eletrônicos' AND preco < 1000;
CREATE INDEX idx_produtos_categoria_preco ON produtos(categoria, preco);
```

### 2. Índices para ORDER BY

```sql
-- Para ordenação
SELECT * FROM usuarios ORDER BY data_cadastro DESC;
CREATE INDEX idx_usuarios_data_desc ON usuarios(data_cadastro DESC);

-- Para ordenação múltipla
SELECT * FROM produtos ORDER BY categoria, preco DESC;
CREATE INDEX idx_produtos_cat_preco ON produtos(categoria, preco DESC);
```

### 3. Índices para JOIN

```sql
-- Tabelas relacionadas
SELECT u.nome, p.total 
FROM usuarios u 
JOIN pedidos p ON u.id = p.cliente_id;

-- Índices necessários
CREATE INDEX idx_pedidos_cliente_id ON pedidos(cliente_id);
-- usuarios(id) já tem índice por ser PRIMARY KEY
```

### 4. Índices para GROUP BY

```sql
-- Para agregações
SELECT categoria, COUNT(*) FROM produtos GROUP BY categoria;
CREATE INDEX idx_produtos_categoria ON produtos(categoria);

-- Para agregações complexas
SELECT cliente_id, DATE_TRUNC('month', data_pedido), SUM(total)
FROM pedidos 
GROUP BY cliente_id, DATE_TRUNC('month', data_pedido);

CREATE INDEX idx_pedidos_cliente_mes ON pedidos(cliente_id, DATE_TRUNC('month', data_pedido));
```

## Otimização de Consultas

### Analisando Performance

```sql
-- Ver plano de execução
EXPLAIN SELECT * FROM usuarios WHERE email = 'test@example.com';

-- Ver plano com custos reais
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM pedidos 
WHERE data_pedido BETWEEN '2024-01-01' AND '2024-12-31';

-- Ver estatísticas de uso de índices
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### Forçando Uso de Índices

```sql
-- Desabilitar scan sequencial para teste
SET enable_seqscan = OFF;

-- Executar query para forçar uso de índice
SELECT * FROM usuarios WHERE nome = 'João';

-- Reabilitar scan sequencial
SET enable_seqscan = ON;
```

## Manutenção de Índices

### Monitoramento

```sql
-- Tamanho dos índices
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as tamanho
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;

-- Índices não utilizados
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
    AND indexrelname NOT LIKE '%_pkey';
```

### Reconstrução e Manutenção

```sql
-- Recriar índice
REINDEX INDEX idx_usuarios_email;

-- Recriar todos os índices de uma tabela
REINDEX TABLE usuarios;

-- Recriar todos os índices de um schema
REINDEX SCHEMA public;

-- Analisar estatísticas da tabela
ANALYZE usuarios;

-- Atualizar estatísticas específicas
ANALYZE usuarios(email, nome);
```

### Índices Concorrentes

```sql
-- Criar índice sem bloquear a tabela
CREATE INDEX CONCURRENTLY idx_produtos_nome ON produtos(nome);

-- Remover índice sem bloquear
DROP INDEX CONCURRENTLY idx_produtos_nome;
```

## Casos de Uso Avançados

### Índices para Texto Completo

```sql
-- Configurar busca de texto completo
ALTER TABLE artigos ADD COLUMN busca_tsvector tsvector;

-- Atualizar campo de busca
UPDATE artigos SET busca_tsvector = to_tsvector('portuguese', titulo || ' ' || conteudo);

-- Criar índice GIN
CREATE INDEX idx_artigos_busca ON artigos USING GIN(busca_tsvector);

-- Trigger para manter atualizado
CREATE OR REPLACE FUNCTION atualizar_busca_artigos()
RETURNS TRIGGER AS $$
BEGIN
    NEW.busca_tsvector := to_tsvector('portuguese', NEW.titulo || ' ' || NEW.conteudo);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_busca_artigos
    BEFORE INSERT OR UPDATE ON artigos
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_busca_artigos();
```

### Índices para JSONB

```sql
-- Dados JSONB de exemplo
CREATE TABLE eventos (
    id SERIAL PRIMARY KEY,
    dados JSONB
);

-- Índice para chaves específicas
CREATE INDEX idx_eventos_tipo ON eventos USING GIN((dados->>'tipo'));

-- Índice para arrays em JSONB
CREATE INDEX idx_eventos_tags ON eventos USING GIN((dados->'tags'));

-- Índice para todo o documento JSONB
CREATE INDEX idx_eventos_dados ON eventos USING GIN(dados);

-- Consultas otimizadas
SELECT * FROM eventos WHERE dados->>'tipo' = 'compra';
SELECT * FROM eventos WHERE dados->'tags' ? 'importante';
SELECT * FROM eventos WHERE dados @> '{"status": "ativo"}';
```

### Índices para Dados Geoespaciais

```sql
-- Extensão PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Tabela com dados geográficos
CREATE TABLE lojas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    localizacao GEOMETRY(POINT, 4326)
);

-- Índice espacial
CREATE INDEX idx_lojas_localizacao ON lojas USING GIST(localizacao);

-- Consultas espaciais otimizadas
SELECT nome FROM lojas 
WHERE ST_DWithin(
    localizacao, 
    ST_SetSRID(ST_Point(-46.6333, -23.5505), 4326), 
    1000  -- 1km de raio
);
```

## Boas Práticas

### Quando Criar Índices

**Criar quando:**
- Colunas usadas frequentemente em WHERE
- Colunas usadas em JOIN
- Colunas usadas em ORDER BY
- Colunas com alta seletividade (poucos valores repetidos)
- Foreign keys sem índice automático

**Evitar quando:**
- Tabelas muito pequenas (< 1000 registros)
- Colunas com baixa seletividade (muitos valores repetidos)
- Tabelas com muitas operações INSERT/UPDATE/DELETE

### Ordem das Colunas em Índices Compostos

```sql
-- Ordem correta: mais seletiva primeiro
CREATE INDEX idx_pedidos_status_cliente ON pedidos(status, cliente_id);
-- status tem poucos valores distintos
-- cliente_id tem muitos valores distintos

-- Se a consulta é sempre:
SELECT * FROM pedidos WHERE cliente_id = 123 AND status = 'ativo';

-- Melhor índice seria:
CREATE INDEX idx_pedidos_cliente_status ON pedidos(cliente_id, status);
```

### Monitoramento Contínuo

```sql
-- Query para identificar tabelas que precisam de índices
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    seq_tup_read / seq_scan as avg_seq_read
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_tup_read DESC;

-- Query para encontrar índices duplicados
SELECT 
    t1.indexname as index1,
    t2.indexname as index2,
    t1.tablename
FROM pg_indexes t1
JOIN pg_indexes t2 ON t1.tablename = t2.tablename
WHERE t1.indexdef = t2.indexdef
    AND t1.indexname < t2.indexname;
```

## Troubleshooting Common Issues

### Índice Não Está Sendo Usado

```sql
-- Verificar se estatísticas estão atualizadas
ANALYZE nome_tabela;

-- Verificar configurações do planejador
SHOW enable_indexscan;
SHOW random_page_cost;
SHOW seq_page_cost;

-- Verificar se o índice está corrompido
REINDEX INDEX nome_indice;
```

### Performance Degradada

```sql
-- Verificar fragmentação de índices
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan > 0
ORDER BY pg_relation_size(indexrelid) DESC;

-- Reorganizar índices fragmentados
REINDEX INDEX nome_indice;
```

Os índices são uma das ferramentas mais importantes para otimização de performance no PostgreSQL. O uso adequado pode transformar consultas lentas em operações extremamente rápidas, mas requer planejamento cuidadoso e monitoramento contínuo.