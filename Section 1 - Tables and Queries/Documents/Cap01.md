# Guia SQL PostgreSQL - Comandos e Estruturas de Tabela

## Comandos Básicos

### Conectar ao PostgreSQL
```sql
-- Via psql (terminal)
psql -h localhost -U usuario -d nome_database

-- Listar databases
\l

-- Conectar a um database específico
\c nome_database

-- Listar tabelas
\dt
```

### Comandos de Database
```sql
-- Criar database
CREATE DATABASE nome_database;

-- Deletar database
DROP DATABASE nome_database;

-- Usar database (no PostgreSQL, use \c)
\c nome_database;
```

## Criação de Tabela

### Sintaxe Básica
```sql
CREATE TABLE nome_tabela (
    coluna1 tipo_dado [restrições],
    coluna2 tipo_dado [restrições],
    coluna3 tipo_dado [restrições],
    [restrições_tabela]
);
```

### Exemplo Prático
```sql
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    idade INTEGER,
    data_nascimento DATE,
    salario DECIMAL(10,2),
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Comandos de Modificação de Tabela
```sql
-- Adicionar coluna
ALTER TABLE nome_tabela ADD COLUMN nova_coluna tipo_dado;

-- Remover coluna
ALTER TABLE nome_tabela DROP COLUMN nome_coluna;

-- Modificar tipo de coluna
ALTER TABLE nome_tabela ALTER COLUMN nome_coluna TYPE novo_tipo;

-- Renomear tabela
ALTER TABLE nome_antigo RENAME TO nome_novo;

-- Deletar tabela
DROP TABLE nome_tabela;
```

## Atributos (Colunas)

### Definição de Atributos
```sql
CREATE TABLE exemplo (
    -- Nome da coluna + Tipo de dado + Restrições
    id INTEGER NOT NULL,
    nome VARCHAR(50) DEFAULT 'Sem nome',
    preco DECIMAL(8,2) CHECK (preco > 0)
);
```

### Restrições Comuns
```sql
-- NOT NULL: Campo obrigatório
nome VARCHAR(100) NOT NULL

-- DEFAULT: Valor padrão
status VARCHAR(20) DEFAULT 'ativo'

-- UNIQUE: Valor único na tabela
email VARCHAR(150) UNIQUE

-- CHECK: Validação personalizada
idade INTEGER CHECK (idade >= 0 AND idade <= 120)
```

## Tipos de Atributos

### Tipos Primitivos Numéricos
```sql
-- Números inteiros
SMALLINT        -- -32,768 a 32,767
INTEGER (INT)   -- -2,147,483,648 a 2,147,483,647
BIGINT          -- -9,223,372,036,854,775,808 a 9,223,372,036,854,775,807
SERIAL          -- Auto-incremento (1 a 2,147,483,647)
BIGSERIAL       -- Auto-incremento grande

-- Números decimais
DECIMAL(p,s)    -- Precisão fixa (p=total dígitos, s=decimais)
NUMERIC(p,s)    -- Sinônimo de DECIMAL
REAL            -- Ponto flutuante (6 dígitos de precisão)
DOUBLE PRECISION -- Ponto flutuante (15 dígitos de precisão)
```

### Tipos de Texto
```sql
-- Texto com tamanho fixo
CHAR(n)         -- Exatamente n caracteres
CHARACTER(n)    -- Sinônimo de CHAR

-- Texto com tamanho variável
VARCHAR(n)      -- Até n caracteres
CHARACTER VARYING(n) -- Sinônimo de VARCHAR

-- Texto sem limite
TEXT            -- Texto de qualquer tamanho
```

### Tipos de Data e Hora
```sql
-- Data
DATE            -- Apenas data (YYYY-MM-DD)

-- Hora
TIME            -- Apenas hora (HH:MM:SS)
TIME WITH TIME ZONE -- Hora com fuso horário

-- Data e hora
TIMESTAMP       -- Data e hora (YYYY-MM-DD HH:MM:SS)
TIMESTAMP WITH TIME ZONE -- Com fuso horário

-- Intervalo
INTERVAL        -- Período de tempo
```

### Outros Tipos Importantes
```sql
-- Lógico
BOOLEAN         -- true, false, null

-- Binário
BYTEA           -- Dados binários

-- JSON
JSON            -- Dados JSON
JSONB           -- JSON binário (mais eficiente)

-- UUID
UUID            -- Identificador único universal

-- Arrays
INTEGER[]       -- Array de inteiros
TEXT[]          -- Array de textos
```

### Exemplos Práticos de Tipos
```sql
CREATE TABLE exemplo_tipos (
    -- Numéricos
    id SERIAL,
    quantidade INTEGER,
    preco DECIMAL(10,2),
    percentual REAL,
    
    -- Texto
    codigo CHAR(10),
    nome VARCHAR(100),
    descricao TEXT,
    
    -- Data/Hora
    data_nascimento DATE,
    hora_cadastro TIME,
    timestamp_completo TIMESTAMP,
    
    -- Outros
    ativo BOOLEAN,
    configuracoes JSON,
    tags TEXT[]
);
```

## Chave Primária (Primary Key)

### Definição
A chave primária é um campo (ou combinação de campos) que identifica unicamente cada registro na tabela.

### Características
- Não pode ser NULL
- Deve ser única
- Não pode ser duplicada
- Uma tabela pode ter apenas uma chave primária

### Sintaxe - Chave Simples
```sql
-- Método 1: Na definição da coluna
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100)
);

-- Método 2: Como restrição da tabela
CREATE TABLE usuarios (
    id SERIAL,
    nome VARCHAR(100),
    PRIMARY KEY (id)
);

-- Método 3: Adicionando depois
CREATE TABLE usuarios (
    id SERIAL,
    nome VARCHAR(100)
);

ALTER TABLE usuarios ADD PRIMARY KEY (id);
```

### Chave Primária Composta
```sql
CREATE TABLE vendas_produtos (
    venda_id INTEGER,
    produto_id INTEGER,
    quantidade INTEGER,
    preco DECIMAL(10,2),
    PRIMARY KEY (venda_id, produto_id)
);
```

### SERIAL como Chave Primária
```sql
-- SERIAL = INTEGER + AUTO_INCREMENT
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

-- Equivale a:
CREATE SEQUENCE categorias_id_seq;
CREATE TABLE categorias (
    id INTEGER DEFAULT nextval('categorias_id_seq') PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);
```

## Chave Estrangeira (Foreign Key)

### Definição
A chave estrangeira é um campo que cria um vínculo entre duas tabelas, referenciando a chave primária de outra tabela.

### Características
- Mantém integridade referencial
- Pode ser NULL (a menos que especificado NOT NULL)
- Deve corresponder a um valor existente na tabela referenciada

### Sintaxe Básica
```sql
-- Método 1: Na definição da coluna
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id),
    data_pedido DATE
);

-- Método 2: Como restrição da tabela
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER,
    data_pedido DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

### Exemplo Completo com Duas Tabelas
```sql
-- Tabela pai (referenciada)
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE
);

-- Tabela filha (que referencia)
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    total DECIMAL(10,2),
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

### Ações de Referência
```sql
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER,
    total DECIMAL(10,2),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
        ON DELETE CASCADE      -- Deleta pedidos se cliente for deletado
        ON UPDATE CASCADE      -- Atualiza referência se ID do cliente mudar
);
```

### Opções de ON DELETE e ON UPDATE
```sql
-- ON DELETE/UPDATE opções:
CASCADE         -- Propaga a ação
RESTRICT        -- Impede a ação (padrão)
SET NULL        -- Define como NULL
SET DEFAULT     -- Define valor padrão
NO ACTION       -- Não faz nada
```

### Exemplo com Múltiplas Chaves Estrangeiras
```sql
CREATE TABLE pedidos_produtos (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL,
    produto_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2),
    
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT
);
```

### Adicionando Chave Estrangeira Posteriormente
```sql
-- Criar tabela sem FK
CREATE TABLE comentarios (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER,
    texto TEXT,
    data_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Adicionar FK depois
ALTER TABLE comentarios 
ADD CONSTRAINT fk_comentarios_usuario 
FOREIGN KEY (usuario_id) REFERENCES usuarios(id);

-- Remover FK
ALTER TABLE comentarios 
DROP CONSTRAINT fk_comentarios_usuario;
```

### Verificando Restrições
```sql
-- Ver todas as constraints de uma tabela
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'nome_tabela';

-- Ver detalhes das foreign keys
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY';
```

## Exemplo Prático Completo

```sql
-- Criar tabelas com relacionamentos
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT
);

CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL CHECK (preco > 0),
    categoria_id INTEGER NOT NULL,
    estoque INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    data_nascimento DATE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pendente',
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT
);

CREATE TABLE itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL,
    produto_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL,
    
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT
);
```