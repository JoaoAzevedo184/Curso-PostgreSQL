# Triggers em PostgreSQL - Guia Completo

## Índice
1. [Introdução](#introdução)
2. [Conceitos Fundamentais](#conceitos-fundamentais)
3. [Tipos de Triggers](#tipos-de-triggers)
4. [Sintaxe Básica](#sintaxe-básica)
5. [Criando Trigger Functions](#criando-trigger-functions)
6. [Exemplos Práticos](#exemplos-práticos)
7. [Variáveis Especiais](#variáveis-especiais)
8. [Controle de Execução](#controle-de-execução)
9. [Boas Práticas](#boas-práticas)
10. [Troubleshooting](#troubleshooting)

## Introdução

Triggers são procedimentos especiais que são executados automaticamente (disparados) em resposta a eventos específicos em uma tabela ou view de um banco de dados PostgreSQL. Eles são fundamentais para implementar regras de negócio, auditoria, validações complexas e manutenção da integridade dos dados.

## Conceitos Fundamentais

### O que é um Trigger?

Um trigger é uma função especial que:
- É executada automaticamente quando eventos específicos ocorrem
- Não pode ser chamada diretamente
- É sempre associada a uma tabela específica
- Executa no contexto da transação que disparou o evento

### Quando Usar Triggers?

- **Auditoria**: Registrar mudanças nos dados
- **Validação**: Implementar regras de negócio complexas
- **Sincronização**: Manter dados relacionados consistentes
- **Cálculos automáticos**: Atualizar campos derivados
- **Logs**: Registrar atividades no banco

## Tipos de Triggers

### Por Momento de Execução

#### BEFORE Triggers
- Executam **antes** da operação DML
- Podem modificar os dados que serão inseridos/atualizados
- Podem cancelar a operação retornando NULL

#### AFTER Triggers
- Executam **após** a operação DML
- Não podem modificar os dados da operação atual
- Úteis para auditoria e operações secundárias

#### INSTEAD OF Triggers
- Apenas para VIEWs
- Substituem a operação padrão
- Permitem operações DML em views complexas

### Por Evento

- **INSERT**: Disparado na inserção de registros
- **UPDATE**: Disparado na atualização de registros
- **DELETE**: Disparado na exclusão de registros
- **TRUNCATE**: Disparado no truncamento da tabela

### Por Granularidade

- **ROW-level**: Executado para cada linha afetada
- **STATEMENT-level**: Executado uma vez por comando SQL

## Sintaxe Básica

### Estrutura Geral

```sql
-- 1. Criar a função do trigger
CREATE OR REPLACE FUNCTION nome_funcao_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Lógica do trigger
    RETURN NEW; -- ou OLD, ou NULL
END;
$$ LANGUAGE plpgsql;

-- 2. Criar o trigger
CREATE TRIGGER nome_trigger
    BEFORE/AFTER INSERT/UPDATE/DELETE
    ON nome_tabela
    FOR EACH ROW/STATEMENT
    EXECUTE FUNCTION nome_funcao_trigger();
```

### Parâmetros do CREATE TRIGGER

```sql
CREATE TRIGGER trigger_name
    { BEFORE | AFTER | INSTEAD OF } 
    { event [ OR ... ] }
    ON table_name
    [ FROM referenced_table_name ]
    [ NOT DEFERRABLE | [ DEFERRABLE ] [ INITIALLY { IMMEDIATE | DEFERRED } ] ]
    [ REFERENCING { { OLD | NEW } TABLE [ AS ] transition_relation_name } [ ... ] ]
    [ FOR [ EACH ] { ROW | STATEMENT } ]
    [ WHEN ( condition ) ]
    EXECUTE { FUNCTION | PROCEDURE } function_name ( arguments );
```

## Criando Trigger Functions

### Função Básica

```sql
CREATE OR REPLACE FUNCTION exemplo_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    -- Para INSERT e UPDATE, NEW contém os novos valores
    -- Para DELETE, OLD contém os valores antes da exclusão
    -- Para UPDATE, OLD contém os valores anteriores
    
    IF TG_OP = 'INSERT' THEN
        -- Lógica para INSERT
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Lógica para UPDATE
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        -- Lógica para DELETE
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

### Função com Validação

```sql
CREATE OR REPLACE FUNCTION validar_dados()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar dados antes da inserção/atualização
    IF NEW.email IS NULL OR NEW.email = '' THEN
        RAISE EXCEPTION 'Email é obrigatório';
    END IF;
    
    IF NEW.idade < 0 OR NEW.idade > 150 THEN
        RAISE EXCEPTION 'Idade deve estar entre 0 e 150 anos';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## Exemplos Práticos

### Exemplo 1: Auditoria Básica

```sql
-- Tabela principal
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP
);

-- Tabela de auditoria
CREATE TABLE usuarios_auditoria (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER,
    operacao VARCHAR(10),
    dados_antigos JSONB,
    dados_novos JSONB,
    usuario_sistema TEXT DEFAULT CURRENT_USER,
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Função de auditoria
CREATE OR REPLACE FUNCTION auditar_usuarios()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO usuarios_auditoria (usuario_id, operacao, dados_novos)
        VALUES (NEW.id, 'INSERT', row_to_json(NEW));
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO usuarios_auditoria (usuario_id, operacao, dados_antigos, dados_novos)
        VALUES (NEW.id, 'UPDATE', row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO usuarios_auditoria (usuario_id, operacao, dados_antigos)
        VALUES (OLD.id, 'DELETE', row_to_json(OLD));
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Triggers de auditoria
CREATE TRIGGER trigger_audit_usuarios_insert
    AFTER INSERT ON usuarios
    FOR EACH ROW EXECUTE FUNCTION auditar_usuarios();

CREATE TRIGGER trigger_audit_usuarios_update
    AFTER UPDATE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION auditar_usuarios();

CREATE TRIGGER trigger_audit_usuarios_delete
    AFTER DELETE ON usuarios
    FOR EACH ROW EXECUTE FUNCTION auditar_usuarios();
```

### Exemplo 2: Atualização Automática de Timestamp

```sql
-- Função para atualizar data de modificação
CREATE OR REPLACE FUNCTION atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar automaticamente
CREATE TRIGGER trigger_atualizar_timestamp
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_timestamp();
```

### Exemplo 3: Validação Complexa

```sql
-- Tabela de pedidos
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    valor_total DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'PENDENTE',
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de itens do pedido
CREATE TABLE itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER REFERENCES pedidos(id),
    produto_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2)
);

-- Função para calcular subtotal e atualizar total do pedido
CREATE OR REPLACE FUNCTION calcular_totais()
RETURNS TRIGGER AS $$
DECLARE
    novo_total DECIMAL(10,2);
BEGIN
    -- Calcular subtotal do item
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        NEW.subtotal = NEW.quantidade * NEW.preco_unitario;
    END IF;
    
    -- Recalcular total do pedido
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        SELECT COALESCE(SUM(
            CASE 
                WHEN id = NEW.id THEN NEW.subtotal
                ELSE subtotal 
            END
        ), 0)
        INTO novo_total
        FROM itens_pedido 
        WHERE pedido_id = NEW.pedido_id;
        
        UPDATE pedidos 
        SET valor_total = novo_total 
        WHERE id = NEW.pedido_id;
        
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        SELECT COALESCE(SUM(subtotal), 0)
        INTO novo_total
        FROM itens_pedido 
        WHERE pedido_id = OLD.pedido_id AND id != OLD.id;
        
        UPDATE pedidos 
        SET valor_total = novo_total 
        WHERE id = OLD.pedido_id;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Triggers para cálculo automático
CREATE TRIGGER trigger_calcular_totais
    BEFORE INSERT OR UPDATE ON itens_pedido
    FOR EACH ROW EXECUTE FUNCTION calcular_totais();

CREATE TRIGGER trigger_recalcular_total_delete
    AFTER DELETE ON itens_pedido
    FOR EACH ROW EXECUTE FUNCTION calcular_totais();
```

### Exemplo 4: Trigger com Condição (WHEN)

```sql
-- Trigger que só executa quando o email é alterado
CREATE TRIGGER trigger_email_changed
    AFTER UPDATE OF email ON usuarios
    FOR EACH ROW
    WHEN (OLD.email IS DISTINCT FROM NEW.email)
    EXECUTE FUNCTION log_email_change();

-- Função para log de mudança de email
CREATE OR REPLACE FUNCTION log_email_change()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO email_changes_log (usuario_id, email_antigo, email_novo, data_mudanca)
    VALUES (NEW.id, OLD.email, NEW.email, CURRENT_TIMESTAMP);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## Variáveis Especiais

### Registros OLD e NEW

```sql
-- NEW: Registro com os novos valores (INSERT, UPDATE)
-- OLD: Registro com os valores anteriores (UPDATE, DELETE)

CREATE OR REPLACE FUNCTION exemplo_old_new()
RETURNS TRIGGER AS $$
BEGIN
    -- Acessar campos específicos
    IF NEW.nome != OLD.nome THEN
        -- Nome foi alterado
    END IF;
    
    -- Modificar valores antes da inserção/atualização
    NEW.nome = UPPER(NEW.nome);
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Variáveis de Contexto

```sql
CREATE OR REPLACE FUNCTION exemplo_variaveis_contexto()
RETURNS TRIGGER AS $$
BEGIN
    -- TG_OP: Tipo de operação ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')
    -- TG_NAME: Nome do trigger
    -- TG_TABLE_NAME: Nome da tabela
    -- TG_TABLE_SCHEMA: Schema da tabela
    -- TG_LEVEL: 'ROW' ou 'STATEMENT'
    -- TG_WHEN: 'BEFORE', 'AFTER', ou 'INSTEAD OF'
    
    RAISE NOTICE 'Trigger % executado na tabela % para operação %', 
                 TG_NAME, TG_TABLE_NAME, TG_OP;
    
    IF TG_OP = 'INSERT' THEN
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

## Controle de Execução

### Cancelar Operação

```sql
CREATE OR REPLACE FUNCTION verificar_permissao()
RETURNS TRIGGER AS $$
BEGIN
    -- Cancelar operação retornando NULL em BEFORE trigger
    IF NOT user_has_permission(CURRENT_USER, TG_TABLE_NAME, TG_OP) THEN
        RAISE EXCEPTION 'Usuário % não tem permissão para % na tabela %', 
                        CURRENT_USER, TG_OP, TG_TABLE_NAME;
        -- Ou simplesmente: RETURN NULL;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

### Ordem de Execução

```sql
-- Triggers são executados em ordem alfabética por padrão
-- Para controlar a ordem, use prefixos numéricos:

CREATE TRIGGER a01_validacao BEFORE INSERT ON tabela FOR EACH ROW ...;
CREATE TRIGGER a02_calculo BEFORE INSERT ON tabela FOR EACH ROW ...;
CREATE TRIGGER a03_auditoria AFTER INSERT ON tabela FOR EACH ROW ...;
```

## Boas Práticas

### 1. Nomenclatura Clara

```sql
-- Padrão sugerido: [momento]_[tabela]_[operacao]_[funcao]
CREATE TRIGGER before_usuarios_insert_validacao ...;
CREATE TRIGGER after_pedidos_update_auditoria ...;
```

### 2. Funções Reutilizáveis

```sql
-- Criar funções genéricas que podem ser reutilizadas
CREATE OR REPLACE FUNCTION generic_audit_function()
RETURNS TRIGGER AS $$
BEGIN
    -- Função de auditoria genérica usando TG_TABLE_NAME
    EXECUTE format('INSERT INTO %I_audit (operation, old_data, new_data, changed_at) 
                    VALUES ($1, $2, $3, $4)', TG_TABLE_NAME)
    USING TG_OP, 
          CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
          CASE WHEN TG_OP != 'DELETE' THEN row_to_json(NEW) ELSE NULL END,
          CURRENT_TIMESTAMP;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

### 3. Tratamento de Erros

```sql
CREATE OR REPLACE FUNCTION safe_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    BEGIN
        -- Operação que pode falhar
        PERFORM risky_operation();
    EXCEPTION
        WHEN OTHERS THEN
            -- Log do erro
            INSERT INTO error_log (table_name, error_message, occurred_at)
            VALUES (TG_TABLE_NAME, SQLERRM, CURRENT_TIMESTAMP);
            
            -- Re-lançar o erro se necessário
            -- RAISE;
    END;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

### 4. Performance

```sql
-- Evite operações custosas em triggers BEFORE
-- Use triggers AFTER para operações secundárias
-- Considere usar WHEN para filtrar execuções desnecessárias
CREATE TRIGGER expensive_operation
    AFTER UPDATE ON large_table
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION handle_status_change();
```

## Gerenciamento de Triggers

### Listar Triggers

```sql
-- Triggers de uma tabela específica
SELECT 
    t.trigger_name,
    t.event_manipulation,
    t.action_timing,
    t.action_statement
FROM information_schema.triggers t
WHERE t.event_object_table = 'nome_tabela';

-- Todos os triggers do schema atual
SELECT 
    schemaname,
    tablename,
    triggername,
    triggerdef
FROM pg_triggers
ORDER BY schemaname, tablename, triggername;
```

### Desabilitar/Habilitar Triggers

```sql
-- Desabilitar um trigger específico
ALTER TABLE nome_tabela DISABLE TRIGGER nome_trigger;

-- Desabilitar todos os triggers de uma tabela
ALTER TABLE nome_tabela DISABLE TRIGGER ALL;

-- Habilitar trigger
ALTER TABLE nome_tabela ENABLE TRIGGER nome_trigger;

-- Habilitar todos os triggers
ALTER TABLE nome_tabela ENABLE TRIGGER ALL;
```

### Remover Triggers

```sql
-- Remover trigger
DROP TRIGGER IF EXISTS nome_trigger ON nome_tabela;

-- Remover função do trigger (se não for mais usada)
DROP FUNCTION IF EXISTS nome_funcao_trigger();
```

## Troubleshooting

### Problemas Comuns

#### 1. Recursão Infinita
```sql
-- PROBLEMA: Trigger que modifica a mesma tabela
CREATE OR REPLACE FUNCTION bad_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Isso causará recursão infinita!
    UPDATE minha_tabela SET contador = contador + 1 WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- SOLUÇÃO: Usar uma flag ou condição
CREATE OR REPLACE FUNCTION good_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Evitar recursão com condição
    IF NEW.trigger_executed IS NULL OR NOT NEW.trigger_executed THEN
        NEW.contador = NEW.contador + 1;
        NEW.trigger_executed = TRUE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### 2. Performance Issues
```sql
-- Identificar triggers problemáticos
SELECT 
    schemaname,
    tablename,
    triggername,
    triggerdef
FROM pg_triggers 
WHERE triggerdef LIKE '%BEFORE%'
  AND tablename IN (
    SELECT tablename 
    FROM pg_stat_user_tables 
    WHERE n_tup_ins + n_tup_upd + n_tup_del > 1000
  );
```

#### 3. Debugging Triggers
```sql
CREATE OR REPLACE FUNCTION debug_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Usar RAISE NOTICE para debug
    RAISE NOTICE 'Trigger % on table % - Operation: %', 
                 TG_NAME, TG_TABLE_NAME, TG_OP;
    RAISE NOTICE 'OLD: %, NEW: %', OLD, NEW;
    
    -- Ou inserir em tabela de log
    INSERT INTO trigger_debug_log (trigger_name, operation, old_data, new_data)
    VALUES (TG_NAME, TG_OP, row_to_json(OLD), row_to_json(NEW));
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

### Monitoramento

```sql
-- Criar tabela para monitorar execuções de triggers
CREATE TABLE trigger_stats (
    trigger_name TEXT,
    table_name TEXT,
    operation TEXT,
    execution_time INTERVAL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Função para medir performance
CREATE OR REPLACE FUNCTION monitor_trigger_performance()
RETURNS TRIGGER AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    start_time := clock_timestamp();
    
    -- Sua lógica aqui
    
    end_time := clock_timestamp();
    
    INSERT INTO trigger_stats (trigger_name, table_name, operation, execution_time)
    VALUES (TG_NAME, TG_TABLE_NAME, TG_OP, end_time - start_time);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

---

*Este documento fornece uma visão abrangente sobre Triggers em PostgreSQL. Para casos específicos ou dúvidas avançadas, consulte a documentação oficial do PostgreSQL.*