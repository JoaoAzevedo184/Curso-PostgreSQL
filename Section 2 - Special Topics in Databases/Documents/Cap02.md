# Stored Procedures no PostgreSQL

## Introdução

Stored Procedures (Procedimentos Armazenados) são blocos de código SQL que ficam armazenados no banco de dados e podem ser executados quando necessário. No PostgreSQL 11+, os procedures diferem das funções por não retornarem valores e poderem gerenciar transações de forma mais flexível, incluindo commits e rollbacks explícitos.

## Diferenças entre Functions e Procedures

### Functions (Funções)
- **Sempre retornam um valor**
- Executam dentro de uma transação existente
- Não podem fazer COMMIT/ROLLBACK explícito
- Podem ser usadas em SELECT, WHERE, etc.
- Chamadas com `SELECT função()`

### Procedures (Procedimentos)
- **Não retornam valores**
- Podem gerenciar suas próprias transações
- Podem fazer COMMIT/ROLLBACK explícito
- Apenas executam ações/operações
- Chamadas com `CALL procedimento()`

## Sintaxe Básica

### Estrutura Geral

```sql
CREATE [OR REPLACE] PROCEDURE nome_procedimento(
    parametro1 tipo1,
    parametro2 tipo2 DEFAULT valor_default,
    INOUT parametro3 tipo3
)
LANGUAGE linguagem
AS $$
    -- corpo do procedimento
$$;
```

### Procedure Simples

```sql
-- Procedure básico para inserir log
CREATE OR REPLACE PROCEDURE inserir_log(
    mensagem TEXT,
    nivel TEXT DEFAULT 'INFO'
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO sistema_logs (mensagem, nivel, data_criacao)
    VALUES (mensagem, nivel, NOW());
    
    -- Commit explícito
    COMMIT;
END;
$$;

-- Chamada do procedure
CALL inserir_log('Sistema iniciado', 'INFO');
```

## Gerenciamento de Transações

### COMMIT e ROLLBACK Explícitos

```sql
-- Procedure com controle de transação
CREATE OR REPLACE PROCEDURE processar_pedidos_lote()
LANGUAGE plpgsql
AS $$
DECLARE
    pedido RECORD;
    contador INTEGER := 0;
    erro_contador INTEGER := 0;
BEGIN
    -- Processar pedidos pendentes
    FOR pedido IN 
        SELECT id, cliente_id, valor_total 
        FROM pedidos 
        WHERE status = 'pendente'
        ORDER BY data_pedido
    LOOP
        BEGIN
            -- Iniciar processamento do pedido
            UPDATE pedidos 
            SET status = 'processando', 
                data_processamento = NOW()
            WHERE id = pedido.id;
            
            -- Validar dados do pedido
            IF pedido.valor_total <= 0 THEN
                RAISE EXCEPTION 'Valor inválido para pedido %', pedido.id;
            END IF;
            
            -- Processar pagamento (simulação)
            INSERT INTO transacoes_pagamento (pedido_id, valor, status)
            VALUES (pedido.id, pedido.valor_total, 'aprovado');
            
            -- Atualizar status final
            UPDATE pedidos 
            SET status = 'processado'
            WHERE id = pedido.id;
            
            -- Commit a cada pedido processado
            COMMIT;
            contador := contador + 1;
            
        EXCEPTION
            WHEN OTHERS THEN
                -- Rollback apenas deste pedido
                ROLLBACK;
                
                -- Marcar pedido com erro
                UPDATE pedidos 
                SET status = 'erro', 
                    observacoes = 'Erro no processamento: ' || SQLERRM
                WHERE id = pedido.id;
                
                COMMIT;
                erro_contador := erro_contador + 1;
        END;
    END LOOP;
    
    -- Log final do processamento
    INSERT INTO sistema_logs (mensagem, nivel)
    VALUES (
        format('Processamento concluído: %s sucessos, %s erros', 
               contador, erro_contador),
        'INFO'
    );
    COMMIT;
END;
$$;
```

### Savepoints em Procedures

```sql
-- Procedure com savepoints para controle granular
CREATE OR REPLACE PROCEDURE transferir_valores_complexo(
    conta_origem INTEGER,
    conta_destino INTEGER,
    valor DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    saldo_origem DECIMAL;
    taxa_transferencia DECIMAL := 2.50;
BEGIN
    -- Savepoint inicial
    SAVEPOINT inicio_transferencia;
    
    BEGIN
        -- Verificar saldo
        SELECT saldo INTO saldo_origem
        FROM contas 
        WHERE id = conta_origem
        FOR UPDATE;
        
        IF saldo_origem < (valor + taxa_transferencia) THEN
            RAISE EXCEPTION 'Saldo insuficiente';
        END IF;
        
        -- Savepoint após validação
        SAVEPOINT validacao_completa;
        
        -- Debitar da conta origem
        UPDATE contas 
        SET saldo = saldo - valor - taxa_transferencia,
            ultima_movimentacao = NOW()
        WHERE id = conta_origem;
        
        -- Savepoint após débito
        SAVEPOINT debito_realizado;
        
        -- Creditar na conta destino
        UPDATE contas 
        SET saldo = saldo + valor,
            ultima_movimentacao = NOW()
        WHERE id = conta_destino;
        
        -- Registrar transferência
        INSERT INTO historico_transferencias (
            conta_origem, conta_destino, valor, taxa, data_transferencia
        ) VALUES (
            conta_origem, conta_destino, valor, taxa_transferencia, NOW()
        );
        
        -- Commit final
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback para savepoint apropriado
            ROLLBACK TO SAVEPOINT inicio_transferencia;
            
            -- Log do erro
            INSERT INTO sistema_logs (mensagem, nivel)
            VALUES (
                format('Erro na transferência de %s para %s: %s', 
                       conta_origem, conta_destino, SQLERRM),
                'ERROR'
            );
            COMMIT;
            
            -- Re-raise do erro
            RAISE;
    END;
END;
$$;
```

## Parâmetros INOUT

### Procedures com Parâmetros de Entrada e Saída

```sql
-- Procedure que modifica parâmetros INOUT
CREATE OR REPLACE PROCEDURE calcular_desconto_produto(
    INOUT preco DECIMAL,
    IN categoria TEXT,
    IN cliente_vip BOOLEAN DEFAULT FALSE,
    OUT desconto_aplicado DECIMAL,
    OUT preco_final DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    percentual_desconto DECIMAL := 0;
BEGIN
    -- Calcular desconto baseado na categoria
    CASE categoria
        WHEN 'eletronicos' THEN percentual_desconto := 0.10;
        WHEN 'roupas' THEN percentual_desconto := 0.15;
        WHEN 'livros' THEN percentual_desconto := 0.05;
        ELSE percentual_desconto := 0;
    END CASE;
    
    -- Desconto adicional para VIP
    IF cliente_vip THEN
        percentual_desconto := percentual_desconto + 0.05;
    END IF;
    
    -- Calcular valores
    desconto_aplicado := preco * percentual_desconto;
    preco_final := preco - desconto_aplicado;
    
    -- Modificar parâmetro INOUT
    preco := preco_final;
    
    COMMIT;
END;
$$;

-- Chamada com parâmetros INOUT
DO $$
DECLARE
    meu_preco DECIMAL := 100.00;
    desconto DECIMAL;
    final DECIMAL;
BEGIN
    CALL calcular_desconto_produto(meu_preco, 'eletronicos', TRUE, desconto, final);
    
    RAISE NOTICE 'Preço original modificado: %', meu_preco;
    RAISE NOTICE 'Desconto: %', desconto;
    RAISE NOTICE 'Preço final: %', final;
END;
$$;
```

## Procedures para Manutenção de Dados

### Limpeza Automática de Dados

```sql
-- Procedure para limpeza de dados antigos
CREATE OR REPLACE PROCEDURE limpar_dados_antigos()
LANGUAGE plpgsql
AS $$
DECLARE
    registros_removidos INTEGER;
    tabela_info RECORD;
BEGIN
    -- Array de tabelas para limpeza
    FOR tabela_info IN 
        VALUES 
            ('logs_sistema', 'data_criacao', 30),
            ('sessoes_usuario', 'ultima_atividade', 7),
            ('cache_temporario', 'criado_em', 1),
            ('tentativas_login', 'data_tentativa', 14)
    LOOP
        -- Executar limpeza para cada tabela
        EXECUTE format(
            'DELETE FROM %I WHERE %I < NOW() - INTERVAL ''%s days''',
            tabela_info.column1,  -- nome da tabela
            tabela_info.column2,  -- coluna de data
            tabela_info.column3   -- dias para manter
        );
        
        GET DIAGNOSTICS registros_removidos = ROW_COUNT;
        
        -- Log da limpeza
        INSERT INTO sistema_logs (mensagem, nivel)
        VALUES (
            format('Limpeza %s: %s registros removidos', 
                   tabela_info.column1, registros_removidos),
            'INFO'
        );
        
        -- Commit a cada tabela
        COMMIT;
    END LOOP;
    
    -- VACUUM das tabelas limpas
    VACUUM ANALYZE logs_sistema, sessoes_usuario, cache_temporario, tentativas_login;
END;
$$;
```

### Sincronização de Dados

```sql
-- Procedure para sincronizar dados entre tabelas
CREATE OR REPLACE PROCEDURE sincronizar_estatisticas_cliente()
LANGUAGE plpgsql
AS $$
DECLARE
    cliente RECORD;
    stats RECORD;
BEGIN
    -- Processar cada cliente
    FOR cliente IN SELECT id FROM clientes WHERE ativo = true
    LOOP
        BEGIN
            -- Calcular estatísticas do cliente
            SELECT 
                COUNT(*) as total_pedidos,
                COALESCE(SUM(valor_total), 0) as valor_total_pedidos,
                COALESCE(AVG(valor_total), 0) as valor_medio_pedido,
                MAX(data_pedido) as ultimo_pedido
            INTO stats
            FROM pedidos 
            WHERE cliente_id = cliente.id;
            
            -- Atualizar ou inserir estatísticas
            INSERT INTO estatisticas_cliente (
                cliente_id, total_pedidos, valor_total, valor_medio, ultimo_pedido, atualizado_em
            ) VALUES (
                cliente.id, stats.total_pedidos, stats.valor_total_pedidos, 
                stats.valor_medio_pedido, stats.ultimo_pedido, NOW()
            )
            ON CONFLICT (cliente_id) 
            DO UPDATE SET
                total_pedidos = EXCLUDED.total_pedidos,
                valor_total = EXCLUDED.valor_total,
                valor_medio = EXCLUDED.valor_medio,
                ultimo_pedido = EXCLUDED.ultimo_pedido,
                atualizado_em = EXCLUDED.atualizado_em;
            
            -- Commit a cada 100 clientes
            IF cliente.id % 100 = 0 THEN
                COMMIT;
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                -- Log do erro e continua
                INSERT INTO sistema_logs (mensagem, nivel)
                VALUES (
                    format('Erro ao sincronizar cliente %s: %s', 
                           cliente.id, SQLERRM),
                    'ERROR'
                );
                COMMIT;
        END;
    END LOOP;
    
    -- Commit final
    COMMIT;
    
    -- Log de conclusão
    INSERT INTO sistema_logs (mensagem, nivel)
    VALUES ('Sincronização de estatísticas concluída', 'INFO');
    COMMIT;
END;
$$;
```

## Procedures para ETL (Extract, Transform, Load)

### Importação de Dados

```sql
-- Procedure para importar dados de arquivo CSV
CREATE OR REPLACE PROCEDURE importar_produtos_csv(
    caminho_arquivo TEXT,
    delimitador TEXT DEFAULT ','
)
LANGUAGE plpgsql
AS $$
DECLARE
    linha RECORD;
    contador_sucesso INTEGER := 0;
    contador_erro INTEGER := 0;
    temp_table_name TEXT;
BEGIN
    -- Criar tabela temporária
    temp_table_name := 'temp_produtos_' || extract(epoch from now())::bigint;
    
    EXECUTE format('
        CREATE TEMP TABLE %I (
            codigo TEXT,
            nome TEXT,
            categoria TEXT,
            preco TEXT,
            estoque TEXT
        )', temp_table_name);
    
    -- Importar dados do CSV para tabela temporária
    EXECUTE format('
        COPY %I FROM %L WITH (FORMAT CSV, HEADER true, DELIMITER %L)',
        temp_table_name, caminho_arquivo, delimitador);
    
    -- Processar cada linha da tabela temporária
    FOR linha IN EXECUTE format('SELECT * FROM %I', temp_table_name)
    LOOP
        BEGIN
            -- Validar e inserir dados
            INSERT INTO produtos (codigo, nome, categoria_id, preco, estoque)
            SELECT 
                linha.codigo,
                linha.nome,
                c.id,
                linha.preco::DECIMAL,
                linha.estoque::INTEGER
            FROM categorias c
            WHERE c.nome = linha.categoria;
            
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Categoria não encontrada: %', linha.categoria;
            END IF;
            
            contador_sucesso := contador_sucesso + 1;
            
            -- Commit a cada 1000 registros
            IF contador_sucesso % 1000 = 0 THEN
                COMMIT;
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                -- Log do erro
                INSERT INTO log_importacao (
                    arquivo, linha_dados, erro, data_erro
                ) VALUES (
                    caminho_arquivo, 
                    row_to_json(linha)::TEXT, 
                    SQLERRM, 
                    NOW()
                );
                
                contador_erro := contador_erro + 1;
                COMMIT;
        END;
    END LOOP;
    
    -- Limpar tabela temporária
    EXECUTE format('DROP TABLE %I', temp_table_name);
    
    -- Log final
    INSERT INTO sistema_logs (mensagem, nivel)
    VALUES (
        format('Importação concluída: %s sucessos, %s erros', 
               contador_sucesso, contador_erro),
        'INFO'
    );
    COMMIT;
END;
$$;
```

## Procedures com Notificações

### Sistema de Alertas

```sql
-- Procedure para monitorar sistema e enviar alertas
CREATE OR REPLACE PROCEDURE monitorar_sistema()
LANGUAGE plpgsql
AS $$
DECLARE
    alerta TEXT;
    metrica RECORD;
BEGIN
    -- Verificar espaço em disco das tabelas
    FOR metrica IN
        SELECT 
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as tamanho,
            pg_total_relation_size(schemaname||'.'||tablename) as tamanho_bytes
        FROM pg_tables 
        WHERE schemaname = 'public'
        ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
        LIMIT 10
    LOOP
        -- Alertar se tabela muito grande (> 1GB)
        IF metrica.tamanho_bytes > 1073741824 THEN
            alerta := format('ALERTA: Tabela %s.%s está muito grande: %s',
                           metrica.schemaname, metrica.tablename, metrica.tamanho);
            
            -- Enviar notificação
            PERFORM pg_notify('sistema_alertas', alerta);
            
            -- Log do alerta
            INSERT INTO sistema_alertas (tipo, mensagem, criado_em)
            VALUES ('DISCO', alerta, NOW());
        END IF;
    END LOOP;
    
    -- Verificar conexões ativas
    SELECT COUNT(*) INTO metrica
    FROM pg_stat_activity 
    WHERE state = 'active';
    
    IF metrica.count > 100 THEN
        alerta := format('ALERTA: Muitas conexões ativas: %s', metrica.count);
        PERFORM pg_notify('sistema_alertas', alerta);
        
        INSERT INTO sistema_alertas (tipo, mensagem, criado_em)
        VALUES ('CONEXOES', alerta, NOW());
    END IF;
    
    -- Verificar locks
    SELECT COUNT(*) INTO metrica
    FROM pg_locks 
    WHERE NOT granted;
    
    IF metrica.count > 10 THEN
        alerta := format('ALERTA: Muitos locks não concedidos: %s', metrica.count);
        PERFORM pg_notify('sistema_alertas', alerta);
        
        INSERT INTO sistema_alertas (tipo, mensagem, criado_em)
        VALUES ('LOCKS', alerta, NOW());
    END IF;
    
    COMMIT;
END;
$$;
```

## Procedures Recursivos

### Processamento Hierárquico

```sql
-- Procedure recursivo para processar estrutura organizacional
CREATE OR REPLACE PROCEDURE processar_hierarquia_organizacional(
    departamento_id INTEGER,
    nivel INTEGER DEFAULT 0
)
LANGUAGE plpgsql
AS $$
DECLARE
    dept RECORD;
    funcionario RECORD;
    subdept RECORD;
BEGIN
    -- Obter informações do departamento atual
    SELECT * INTO dept
    FROM departamentos 
    WHERE id = departamento_id;
    
    IF NOT FOUND THEN
        RETURN;
    END IF;
    
    -- Log do processamento
    INSERT INTO log_processamento_hierarquia (
        departamento_id, nome_departamento, nivel, data_processamento
    ) VALUES (
        dept.id, dept.nome, nivel, NOW()
    );
    
    -- Processar funcionários do departamento
    FOR funcionario IN 
        SELECT * FROM funcionarios 
        WHERE departamento_id = dept.id
    LOOP
        -- Calcular benefícios baseados no nível hierárquico
        UPDATE funcionarios 
        SET 
            bonus_hierarquia = salario_base * (0.05 * nivel),
            ultima_atualizacao = NOW()
        WHERE id = funcionario.id;
    END LOOP;
    
    -- Commit do processamento deste nível
    COMMIT;
    
    -- Processar subdepartamentos recursivamente
    FOR subdept IN 
        SELECT id FROM departamentos 
        WHERE departamento_pai_id = dept.id
    LOOP
        -- Chamada recursiva
        CALL processar_hierarquia_organizacional(subdept.id, nivel + 1);
    END LOOP;
END;
$$;
```

## Agendamento de Procedures

### Usando pg_cron (Extensão)

```sql
-- Instalar extensão pg_cron
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Agendar procedure para executar diariamente às 2:00
SELECT cron.schedule(
    'limpeza-diaria',
    '0 2 * * *',
    'CALL limpar_dados_antigos();'
);

-- Agendar sincronização a cada hora
SELECT cron.schedule(
    'sync-estatisticas',
    '0 * * * *',
    'CALL sincronizar_estatisticas_cliente();'
);

-- Agendar monitoramento a cada 5 minutos
SELECT cron.schedule(
    'monitoramento-sistema',
    '*/5 * * * *',
    'CALL monitorar_sistema();'
);

-- Listar jobs agendados
SELECT * FROM cron.job;

-- Remover job
SELECT cron.unschedule('limpeza-diaria');
```

## Monitoramento e Debug

### Logging Avançado em Procedures

```sql
-- Procedure com logging detalhado
CREATE OR REPLACE PROCEDURE procedure_com_logging(
    parametro1 INTEGER,
    parametro2 TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    inicio_execucao TIMESTAMP;
    fim_execucao TIMESTAMP;
    duracao INTERVAL;
    log_id INTEGER;
BEGIN
    inicio_execucao := clock_timestamp();
    
    -- Inserir log de início
    INSERT INTO logs_execucao_procedures (
        nome_procedure, parametros, inicio_execucao, status
    ) VALUES (
        'procedure_com_logging',
        jsonb_build_object('parametro1', parametro1, 'parametro2', parametro2),
        inicio_execucao,
        'INICIADO'
    ) RETURNING id INTO log_id;
    
    COMMIT;
    
    BEGIN
        -- Lógica do procedure aqui
        PERFORM pg_sleep(2); -- Simular processamento
        
        -- Atualizar log de sucesso
        fim_execucao := clock_timestamp();
        duracao := fim_execucao - inicio_execucao;
        
        UPDATE logs_execucao_procedures 
        SET 
            fim_execucao = fim_execucao,
            duracao = duracao,
            status = 'CONCLUIDO'
        WHERE id = log_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Log de erro
            UPDATE logs_execucao_procedures 
            SET 
                fim_execucao = clock_timestamp(),
                duracao = clock_timestamp() - inicio_execucao,
                status = 'ERRO',
                mensagem_erro = SQLERRM
            WHERE id = log_id;
            
            COMMIT;
            RAISE;
    END;
END;
$$;
```

## Gerenciamento de Procedures

### Informações sobre Procedures

```sql
-- Listar todos os procedures
SELECT 
    routine_name as nome,
    routine_type as tipo,
    external_language as linguagem,
    routine_definition as definicao
FROM information_schema.routines
WHERE routine_type = 'PROCEDURE'
    AND routine_schema = 'public'
ORDER BY routine_name;

-- Detalhes específicos de um procedure
SELECT 
    p.proname as nome,
    p.proargnames as parametros,
    p.proargmodes as modos_parametros,
    l.lanname as linguagem,
    p.prosrc as codigo_fonte
FROM pg_proc p
JOIN pg_language l ON p.prolang = l.oid
WHERE p.proname = 'nome_do_procedure'
    AND p.prokind = 'p';  -- 'p' para procedures
```

### Permissões e Segurança

```sql
-- Conceder permissão de execução
GRANT EXECUTE ON PROCEDURE processar_pedidos_lote() TO role_processamento;

-- Revogar permissão
REVOKE EXECUTE ON PROCEDURE processar_pedidos_lote() FROM role_processamento;

-- Procedure com SECURITY DEFINER
CREATE OR REPLACE PROCEDURE procedure_admin()
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Executado com privilégios do criador
    TRUNCATE TABLE dados_temporarios;
    COMMIT;
END;
$$;
```

### Remoção de Procedures

```sql
-- Remover procedure
DROP PROCEDURE IF EXISTS limpar_dados_antigos();

-- Remover procedure com parâmetros específicos
DROP PROCEDURE transferir_valores_complexo(INTEGER, INTEGER, DECIMAL);
```

## Boas Práticas

### 1. Sempre usar controle de transação explícito
### 2. Implementar logging adequado para auditoria
### 3. Tratar exceções de forma granular
### 4. Usar savepoints para operações complexas
### 5. Validar parâmetros de entrada
### 6. Documentar procedures adequadamente
### 7. Monitorar performance e uso de recursos
### 8. Implementar retry logic quando apropriado

Os Stored Procedures no PostgreSQL oferecem controle granular sobre transações e são ideais para operações complexas que envolvem múltiplas etapas, processamento em lote e manutenção de dados. Com o gerenciamento adequado de transações e tratamento de exceções, eles se tornam uma ferramenta poderosa para implementar lógica de negócio robusta diretamente no banco de dados.