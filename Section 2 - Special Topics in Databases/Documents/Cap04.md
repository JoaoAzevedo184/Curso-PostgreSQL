# Domínios em PostgreSQL - Guia Completo

## Índice
1. [Introdução](#introdução)
2. [Conceitos Fundamentais](#conceitos-fundamentais)
3. [Criando Domínios](#criando-domínios)
4. [Sintaxe e Parâmetros](#sintaxe-e-parâmetros)
5. [Restrições (Constraints)](#restrições-constraints)
6. [Exemplos Práticos](#exemplos-práticos)
7. [Modificando Domínios](#modificando-domínios)
8. [Usando Domínios em Tabelas](#usando-domínios-em-tabelas)
9. [Vantagens e Desvantagens](#vantagens-e-desvantagens)
10. [Boas Práticas](#boas-práticas)
11. [Gerenciamento e Manutenção](#gerenciamento-e-manutenção)

## Introdução

Domínios no PostgreSQL são tipos de dados definidos pelo usuário que são baseados em tipos existentes, mas com restrições específicas aplicadas. Eles funcionam como "apelidos" para tipos de dados com validações customizadas, permitindo reutilização e padronização de regras de negócio em todo o banco de dados.

## Conceitos Fundamentais

### O que é um Domínio?

Um domínio é essencialmente um tipo de dados customizado que:
- É baseado em um tipo de dados existente (tipo base)
- Pode ter restrições (constraints) específicas
- Pode ter um valor padrão
- Pode permitir ou não valores NULL
- É reutilizável em múltiplas tabelas e colunas

### Benefícios dos Domínios

- **Consistência**: Garante que as mesmas regras sejam aplicadas em todo o banco
- **Reutilização**: Define uma vez, usa em vários lugares
- **Manutenibilidade**: Alterações centralizadas nas regras de negócio
- **Legibilidade**: Nomes descritivos melhoram a documentação do esquema
- **Validação**: Aplicação automática de restrições

### Quando Usar Domínios?

- Validação de formatos específicos (CPF, email, telefone)
- Restrições de valores (faixas numéricas, listas de valores)
- Padronização de tipos comuns no sistema
- Implementação de regras de negócio a nível de dados

## Criando Domínios

### Sintaxe Básica

```sql
CREATE DOMAIN nome_dominio AS tipo_base
    [ COLLATE collation ]
    [ DEFAULT expressao ]
    [ constraint [ ... ] ];
```

### Exemplo Simples

```sql
-- Domínio para email
CREATE DOMAIN email AS VARCHAR(255)
    CHECK (VALUE ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Usando o domínio
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    email_usuario email  -- Usando o domínio
);
```

## Sintaxe e Parâmetros

### Parâmetros Completos

```sql
CREATE DOMAIN domain_name AS data_type
    [ COLLATE collation ]
    [ DEFAULT expression ]
    [ constraint [ constraint [...] ] ]

-- Onde constraint pode ser:
[ CONSTRAINT constraint_name ]
{ NOT NULL | NULL | CHECK (expression) }
```

### Exemplos de Parâmetros

```sql
-- Com valor padrão
CREATE DOMAIN status_ativo AS BOOLEAN DEFAULT TRUE;

-- Com NOT NULL
CREATE DOMAIN codigo_produto AS VARCHAR(20) NOT NULL;

-- Com COLLATE (para strings)
CREATE DOMAIN nome_pessoa AS VARCHAR(100) 
    COLLATE "pt_BR.UTF-8" 
    NOT NULL;

-- Múltiplas restrições
CREATE DOMAIN idade_pessoa AS INTEGER
    DEFAULT 0
    CHECK (VALUE >= 0 AND VALUE <= 150)
    NOT NULL;
```

## Restrições (Constraints)

### CHECK Constraints

```sql
-- Validação de CPF (formato básico)
CREATE DOMAIN cpf AS VARCHAR(14)
    CHECK (VALUE ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$');

-- Validação de CEP
CREATE DOMAIN cep AS VARCHAR(9)
    CHECK (VALUE ~ '^\d{5}-\d{3}$');

-- Faixa de valores
CREATE DOMAIN nota_escolar AS DECIMAL(3,1)
    CHECK (VALUE >= 0.0 AND VALUE <= 10.0);

-- Lista de valores permitidos
CREATE DOMAIN genero AS VARCHAR(10)
    CHECK (VALUE IN ('masculino', 'feminino', 'outro', 'prefiro_nao_informar'));
```

### NOT NULL e NULL

```sql
-- Domínio que não permite NULL
CREATE DOMAIN documento_obrigatorio AS VARCHAR(50) NOT NULL;

-- Domínio que permite NULL explicitamente (padrão)
CREATE DOMAIN telefone_opcional AS VARCHAR(20) NULL;
```

### Constraint com Nome

```sql
CREATE DOMAIN salario_funcionario AS DECIMAL(10,2)
    CONSTRAINT salario_positivo CHECK (VALUE > 0)
    CONSTRAINT salario_maximo CHECK (VALUE <= 50000.00);
```

## Exemplos Práticos

### Exemplo 1: Validações de Documentos Brasileiros

```sql
-- CPF com validação de formato
CREATE DOMAIN cpf_br AS VARCHAR(14)
    CHECK (VALUE ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$')
    CONSTRAINT cpf_formato_erro 
    CHECK (VALUE ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$');

-- CNPJ com validação de formato
CREATE DOMAIN cnpj_br AS VARCHAR(18)
    CHECK (VALUE ~ '^\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}$');

-- CEP brasileiro
CREATE DOMAIN cep_br AS VARCHAR(9)
    DEFAULT '00000-000'
    CHECK (VALUE ~ '^\d{5}-\d{3}$');

-- Telefone brasileiro (formato básico)
CREATE DOMAIN telefone_br AS VARCHAR(15)
    CHECK (VALUE ~ '^\(\d{2}\)\s\d{4,5}-\d{4}$');
```

### Exemplo 2: Domínios de Negócio

```sql
-- Status de pedido
CREATE DOMAIN status_pedido AS VARCHAR(20)
    DEFAULT 'pendente'
    CHECK (VALUE IN ('pendente', 'processando', 'enviado', 'entregue', 'cancelado'));

-- Prioridade de tarefa
CREATE DOMAIN prioridade_tarefa AS VARCHAR(10)
    DEFAULT 'media'
    CHECK (VALUE IN ('baixa', 'media', 'alta', 'critica'));

-- Percentual (0 a 100)
CREATE DOMAIN percentual AS DECIMAL(5,2)
    DEFAULT 0.00
    CHECK (VALUE >= 0.00 AND VALUE <= 100.00);

-- Avaliação (1 a 5 estrelas)
CREATE DOMAIN avaliacao_estrelas AS INTEGER
    CHECK (VALUE >= 1 AND VALUE <= 5);
```

### Exemplo 3: Domínios Financeiros

```sql
-- Valor monetário positivo
CREATE DOMAIN valor_positivo AS DECIMAL(15,2)
    CHECK (VALUE >= 0.00);

-- Valor monetário com limite
CREATE DOMAIN valor_produto AS DECIMAL(10,2)
    CHECK (VALUE >= 0.01 AND VALUE <= 999999.99);

-- Taxa percentual (0% a 100%)
CREATE DOMAIN taxa_percentual AS DECIMAL(5,4)
    DEFAULT 0.0000
    CHECK (VALUE >= 0.0000 AND VALUE <= 1.0000);

-- Moeda (código ISO)
CREATE DOMAIN codigo_moeda AS CHAR(3)
    DEFAULT 'BRL'
    CHECK (VALUE ~ '^[A-Z]{3}$');
```

### Exemplo 4: Domínios de Sistema

```sql
-- Email com validação robusta
CREATE DOMAIN email_valido AS VARCHAR(320)  -- RFC 5321 limit
    CHECK (
        VALUE ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
        AND LENGTH(VALUE) >= 6
        AND LENGTH(VALUE) <= 320
    );

-- URL válida (validação básica)
CREATE DOMAIN url_valida AS TEXT
    CHECK (VALUE ~ '^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');

-- Código de cor hexadecimal
CREATE DOMAIN cor_hex AS VARCHAR(7)
    DEFAULT '#000000'
    CHECK (VALUE ~ '^#[0-9A-Fa-f]{6}$');

-- Nome de usuário
CREATE DOMAIN nome_usuario AS VARCHAR(50)
    CHECK (
        VALUE ~ '^[a-zA-Z0-9_]{3,50}$'
        AND VALUE !~ '^[0-9]'  -- Não pode começar com número
    );
```

## Modificando Domínios

### Adicionando Restrições

```sql
-- Adicionar nova constraint
ALTER DOMAIN email_valido 
    ADD CONSTRAINT email_min_length 
    CHECK (LENGTH(VALUE) >= 6);

-- Adicionar constraint NOT NULL
ALTER DOMAIN codigo_produto 
    SET NOT NULL;
```

### Removendo Restrições

```sql
-- Remover constraint específica
ALTER DOMAIN email_valido 
    DROP CONSTRAINT email_min_length;

-- Remover NOT NULL
ALTER DOMAIN codigo_produto 
    DROP NOT NULL;
```

### Alterando Valor Padrão

```sql
-- Definir novo valor padrão
ALTER DOMAIN status_pedido 
    SET DEFAULT 'novo';

-- Remover valor padrão
ALTER DOMAIN status_pedido 
    DROP DEFAULT;
```

### Renomeando Domínios

```sql
-- Renomear domínio
ALTER DOMAIN email_valido 
    RENAME TO endereco_email;

-- Renomear constraint
ALTER DOMAIN endereco_email 
    RENAME CONSTRAINT email_formato 
    TO formato_email_valido;
```

## Usando Domínios em Tabelas

### Definindo Colunas com Domínios

```sql
-- Tabela usando vários domínios
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email endereco_email,
    cpf cpf_br,
    telefone telefone_br,
    cep cep_br,
    status status_pedido DEFAULT 'ativo',
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de produtos
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    preco valor_produto,
    desconto percentual DEFAULT 0.00,
    avaliacao avaliacao_estrelas,
    cor_principal cor_hex,
    status status_pedido DEFAULT 'disponivel'
);
```

### Inserindo Dados

```sql
-- Inserções válidas
INSERT INTO clientes (nome, email, cpf, telefone, cep) VALUES
    ('João Silva', 'joao@email.com', '123.456.789-01', '(11) 9999-8888', '01234-567'),
    ('Maria Santos', 'maria@teste.com', '987.654.321-09', '(21) 8888-7777', '87654-321');

-- Esta inserção falhará devido às validações do domínio
INSERT INTO clientes (nome, email, cpf) VALUES
    ('Pedro', 'email-inválido', '123456789');  -- Email e CPF inválidos
```

### Consultando Dados com Domínios

```sql
-- Consultas normais funcionam naturalmente
SELECT nome, email, cpf 
FROM clientes 
WHERE status = 'ativo';

-- Filtros específicos usando as características do domínio
SELECT * FROM produtos 
WHERE preco BETWEEN 10.00 AND 100.00
  AND avaliacao >= 4;
```

## Vantagens e Desvantagens

### Vantagens

**Consistência de Dados**
```sql
-- Uma vez definido, o domínio garante consistência
CREATE DOMAIN preco_padrao AS DECIMAL(10,2) CHECK (VALUE >= 0);

-- Usado em múltiplas tabelas
CREATE TABLE produtos (id SERIAL, preco preco_padrao);
CREATE TABLE servicos (id SERIAL, valor preco_padrao);
-- Ambas terão a mesma validação
```

**Manutenibilidade**
```sql
-- Alterar regra em um lugar
ALTER DOMAIN preco_padrao 
    ADD CONSTRAINT preco_maximo CHECK (VALUE <= 999999.99);
-- Afeta todas as tabelas que usam o domínio
```

**Documentação Implícita**
```sql
-- O nome do domínio documenta o propósito
CREATE TABLE funcionarios (
    id SERIAL,
    salario_base salario_funcionario,  -- Fica claro o que é
    bonus percentual                   -- Tipo autodocumentado
);
```

### Desvantagens

**Rigidez**
```sql
-- Dificulta mudanças específicas em uma tabela
-- Se uma tabela precisar de regra diferente, pode ser problemático
```

**Complexidade de Debug**
```sql
-- Erros podem ser menos claros
-- ERROR: value for domain cpf_br violates check constraint "cpf_br_check"
-- Pode ser menos específico que constraint na tabela
```

**Dependências**
```sql
-- Não é possível dropar domínio se estiver sendo usado
DROP DOMAIN email_valido;  -- Falhará se houver tabelas usando
```

## Boas Práticas

### Nomenclatura

```sql
-- Use nomes descritivos e padronizados
CREATE DOMAIN email_address AS VARCHAR(320) ...;     -- Bom
CREATE DOMAIN e AS VARCHAR(320) ...;                 -- Ruim

-- Padrão sugerido: [contexto_]tipo_negocio
CREATE DOMAIN fin_valor_monetario AS DECIMAL(15,2) ...;
CREATE DOMAIN usr_nome_usuario AS VARCHAR(50) ...;
CREATE DOMAIN doc_cpf_brasileiro AS VARCHAR(14) ...;
```

### Validações Robustas

```sql
-- Combine múltiplas validações
CREATE DOMAIN senha_segura AS VARCHAR(255)
    CHECK (LENGTH(VALUE) >= 8)                    -- Mínimo 8 caracteres
    CHECK (VALUE ~ '[A-Z]')                       -- Pelo menos 1 maiúscula
    CHECK (VALUE ~ '[a-z]')                       -- Pelo menos 1 minúscula
    CHECK (VALUE ~ '[0-9]')                       -- Pelo menos 1 número
    CHECK (VALUE ~ '[^A-Za-z0-9]');              -- Pelo menos 1 especial
```

### Organização por Schema

```sql
-- Criar schema específico para domínios
CREATE SCHEMA dominios;

-- Definir domínios no schema dedicado
CREATE DOMAIN dominios.email AS VARCHAR(320) ...;
CREATE DOMAIN dominios.cpf AS VARCHAR(14) ...;
CREATE DOMAIN dominios.telefone AS VARCHAR(15) ...;

-- Usar com referência completa ou search_path
CREATE TABLE usuarios (
    email dominios.email,
    cpf dominios.cpf
);
```

### Documentação

```sql
-- Use COMMENTs para documentar domínios
CREATE DOMAIN codigo_produto AS VARCHAR(20)
    CHECK (VALUE ~ '^[A-Z]{2}\d{4}[A-Z]{2}$');

COMMENT ON DOMAIN codigo_produto IS 
    'Código de produto no formato: 2 letras + 4 dígitos + 2 letras (ex: AB1234CD)';
```

### Evolução Controlada

```sql
-- Planeje mudanças graduais
-- 1. Adicionar nova constraint como opcional
ALTER DOMAIN email_address 
    ADD CONSTRAINT email_domain_allowed 
    CHECK (VALUE ~ '@(empresa\.com|empresa\.com\.br)$');

-- 2. Migrar dados se necessário
-- 3. Remover constraint antiga se aplicável
```

## Gerenciamento e Manutenção

### Listando Domínios

```sql
-- Listar todos os domínios
SELECT 
    domain_name,
    data_type,
    character_maximum_length,
    is_nullable,
    domain_default
FROM information_schema.domains
WHERE domain_schema = 'public'
ORDER BY domain_name;

-- Detalhes completos dos domínios
SELECT 
    n.nspname AS schema_name,
    t.typname AS domain_name,
    pg_catalog.format_type(t.typbasetype, t.typtypmod) AS base_type,
    NOT t.typnotnull AS is_nullable,
    t.typdefault AS default_value,
    pg_catalog.obj_description(t.oid, 'pg_type') AS description
FROM pg_catalog.pg_type t
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE t.typtype = 'd'
  AND n.nspname = 'public'
ORDER BY t.typname;
```

### Verificando Uso de Domínios

```sql
-- Encontrar tabelas que usam um domínio específico
SELECT 
    t.table_schema,
    t.table_name,
    c.column_name,
    c.domain_name
FROM information_schema.columns c
JOIN information_schema.tables t ON (
    c.table_name = t.table_name 
    AND c.table_schema = t.table_schema
)
WHERE c.domain_name = 'email_address'
  AND t.table_type = 'BASE TABLE'
ORDER BY t.table_schema, t.table_name, c.column_name;
```

### Verificando Constraints de Domínios

```sql
-- Listar constraints de domínios
SELECT 
    domain_name,
    constraint_name,
    check_clause
FROM information_schema.domain_constraints dc
JOIN information_schema.check_constraints cc 
    ON dc.constraint_name = cc.constraint_name
WHERE domain_schema = 'public'
ORDER BY domain_name, constraint_name;
```

### Removendo Domínios

```sql
-- Verificar dependências antes de remover
SELECT 
    'ALTER TABLE ' || table_schema || '.' || table_name || 
    ' ALTER COLUMN ' || column_name || ' TYPE ' || 
    CASE 
        WHEN data_type = 'character varying' THEN 'VARCHAR(' || character_maximum_length || ')'
        WHEN data_type = 'numeric' THEN 'DECIMAL(' || numeric_precision || ',' || numeric_scale || ')'
        ELSE data_type 
    END || ';' AS alter_statement
FROM information_schema.columns
WHERE domain_name = 'nome_dominio_para_remover';

-- Executar os ALTERs gerados acima, depois:
DROP DOMAIN nome_dominio_para_remover;
```

### Backup e Restore de Domínios

```sql
-- Script para backup de definições de domínios
SELECT 
    'CREATE DOMAIN ' || domain_name || ' AS ' || data_type ||
    CASE 
        WHEN character_maximum_length IS NOT NULL 
        THEN '(' || character_maximum_length || ')'
        WHEN numeric_precision IS NOT NULL 
        THEN '(' || numeric_precision || 
             CASE WHEN numeric_scale > 0 THEN ',' || numeric_scale ELSE '' END || ')'
        ELSE ''
    END ||
    CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
    CASE WHEN domain_default IS NOT NULL THEN ' DEFAULT ' || domain_default ELSE '' END ||
    ';' AS create_statement
FROM information_schema.domains
WHERE domain_schema = 'public'
ORDER BY domain_name;
```

### Monitoramento de Performance

```sql
-- Verificar se constraints de domínio estão impactando performance
-- (Analisar planos de execução de queries que usam colunas com domínios)

EXPLAIN ANALYZE
SELECT * FROM tabela_com_dominios 
WHERE coluna_dominio = 'valor_teste';
```

### Migração de Domínios

```sql
-- Exemplo de migração segura de domínio
-- 1. Criar novo domínio
CREATE DOMAIN email_v2 AS VARCHAR(320)
    CHECK (VALUE ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    CHECK (LENGTH(VALUE) >= 6);

-- 2. Adicionar nova coluna temporária
ALTER TABLE usuarios ADD COLUMN email_temp email_v2;

-- 3. Migrar dados
UPDATE usuarios SET email_temp = email WHERE email IS NOT NULL;

-- 4. Verificar integridade
SELECT COUNT(*) FROM usuarios WHERE email IS NOT NULL AND email_temp IS NULL;

-- 5. Remover coluna antiga e renomear nova
ALTER TABLE usuarios DROP COLUMN email;
ALTER TABLE usuarios RENAME COLUMN email_temp TO email;

-- 6. Remover domínio antigo
DROP DOMAIN email_address;
```

---

*Este documento fornece uma visão abrangente sobre Domínios em PostgreSQL, cobrindo desde conceitos básicos até técnicas avançadas de gerenciamento e manutenção.*