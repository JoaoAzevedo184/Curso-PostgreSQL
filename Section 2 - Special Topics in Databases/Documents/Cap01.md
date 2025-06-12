# Funções no PostgreSQL

## Introdução

As funções no PostgreSQL são blocos de código reutilizáveis que encapsulam lógica de negócio, cálculos complexos e operações repetitivas. Elas podem aceitar parâmetros, executar consultas SQL, manipular dados e retornar valores, proporcionando maior modularidade, performance e manutenibilidade ao sistema.

## Conceitos Fundamentais

### O que são Funções?

Funções são procedimentos armazenados no banco de dados que podem ser chamados de consultas SQL, outras funções ou aplicações. No PostgreSQL, funções podem ser escritas em várias linguagens como PL/pgSQL, SQL puro, Python, JavaScript e outras.

### Vantagens das Funções

- **Reutilização de código**: Evita duplicação de lógica
- **Performance**: Executam no servidor, reduzindo tráfego de rede
- **Segurança**: Controlam acesso aos dados
- **Manutenibilidade**: Centralizam regras de negócio
- **Atomicidade**: Executam dentro de transações

## Sintaxe Básica

### Estrutura Geral

```sql
CREATE [OR REPLACE] FUNCTION nome_funcao(
    parametro1 tipo1,
    parametro2 tipo2 DEFAULT valor_default
) 
RETURNS tipo_retorno
LANGUAGE linguagem
AS $$
    -- corpo da função
$$;
```

### Função Simples em SQL

```sql
-- Função que calcula área do círculo
CREATE OR REPLACE FUNCTION calcular_area_circulo(raio NUMERIC)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT 3.14159 * raio * raio;
$$;

-- Uso da função
SELECT calcular_area_circulo(10);
```

## Linguagens Suportadas

### 1. SQL Puro

Ideal para funções simples com consultas diretas:

```sql
-- Função que retorna total de pedidos de um cliente
CREATE OR REPLACE FUNCTION total_pedidos_cliente(cliente_id INTEGER)
RETURNS INTEGER
LANGUAGE SQL
AS $$
    SELECT COUNT(*) 
    FROM pedidos 
    WHERE cliente_id = $1;
$$;

-- Função que retorna dados agregados
CREATE OR REPLACE FUNCTION vendas_por_mes(ano INTEGER)
RETURNS TABLE(mes INTEGER, total DECIMAL)
LANGUAGE SQL
AS $$
    SELECT 
        EXTRACT(MONTH FROM data_pedido)::INTEGER as mes,
        SUM(valor_total) as total
    FROM pedidos 
    WHERE EXTRACT(YEAR FROM data_pedido) = $1
    GROUP BY EXTRACT(MONTH FROM data_pedido)
    ORDER BY mes;
$$;
```

### 2. PL/pgSQL

A linguagem procedural mais usada no PostgreSQL:

```sql
-- Função com lógica condicional
CREATE OR REPLACE FUNCTION calcular_desconto(
    valor_compra DECIMAL,
    cliente_vip BOOLEAN DEFAULT FALSE
)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
    desconto DECIMAL := 0;
BEGIN
    -- Lógica de desconto
    IF cliente_vip THEN
        desconto := valor_compra * 0.15;  -- 15% para VIP
    ELSIF valor_compra > 1000 THEN
        desconto := valor_compra * 0.10;  -- 10% para compras altas
    ELSIF valor_compra > 500 THEN
        desconto := valor_compra * 0.05;  -- 5% para compras médias
    END IF;
    
    RETURN desconto;
END;
$$;
```

### 3. PL/Python

Para lógicas complexas utilizando Python:

```sql
-- Primeiro, habilitar a extensão
CREATE EXTENSION IF NOT EXISTS plpython3u;

-- Função que processa dados com Python
CREATE OR REPLACE FUNCTION processar_json_python(dados_json TEXT)
RETURNS TEXT
LANGUAGE plpython3u
AS $$
    import json
    import re
    
    # Parse do JSON
    dados = json.loads(dados_json)
    
    # Processamento com Python
    if 'email' in dados:
        # Validar email
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if re.match(email_pattern, dados['email']):
            dados['email_valido'] = True
        else:
            dados['email_valido'] = False
    
    return json.dumps(dados)
$$;
```

## Tipos de Retorno

### Retorno Simples

```sql
-- Retorna um valor único
CREATE OR REPLACE FUNCTION obter_idade(data_nascimento DATE)
RETURNS INTEGER
LANGUAGE SQL
AS $$
    SELECT EXTRACT(YEAR FROM AGE(data_nascimento))::INTEGER;
$$;
```

### Retorno de Tabela

```sql
-- Retorna múltiplas linhas
CREATE OR REPLACE FUNCTION listar_produtos_categoria(nome_categoria TEXT)
RETURNS TABLE(
    id INTEGER,
    nome TEXT,
    preco DECIMAL,
    estoque INTEGER
)
LANGUAGE SQL
AS $$
    SELECT p.id, p.nome, p.preco, p.estoque
    FROM produtos p
    JOIN categorias c ON p.categoria_id = c.id
    WHERE c.nome = nome_categoria;
$$;

-- Uso
SELECT * FROM listar_produtos_categoria('Eletrônicos');
```

### Retorno de Record/Row

```sql
-- Definir tipo personalizado
CREATE TYPE info_cliente AS (
    nome TEXT,
    email TEXT,
    total_pedidos INTEGER,
    valor_total DECIMAL
);

-- Função que retorna tipo personalizado
CREATE OR REPLACE FUNCTION obter_info_cliente(cliente_id INTEGER)
RETURNS info_cliente
LANGUAGE plpgsql
AS $$
DECLARE
    resultado info_cliente;
BEGIN
    SELECT 
        u.nome,
        u.email,
        COUNT(p.id),
        COALESCE(SUM(p.valor_total), 0)
    INTO resultado
    FROM usuarios u
    LEFT JOIN pedidos p ON u.id = p.cliente_id
    WHERE u.id = cliente_id
    GROUP BY u.nome, u.email;
    
    RETURN resultado;
END;
$$;
```

## Parâmetros e Argumentos

### Parâmetros com Nomes

```sql
CREATE OR REPLACE FUNCTION criar_pedido(
    cliente_id INTEGER,
    produto_id INTEGER,
    quantidade INTEGER DEFAULT 1,
    observacoes TEXT DEFAULT ''
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    novo_pedido_id INTEGER;
    preco_unitario DECIMAL;
BEGIN
    -- Obter preço do produto
    SELECT preco INTO preco_unitario
    FROM produtos 
    WHERE id = produto_id;
    
    -- Inserir pedido
    INSERT INTO pedidos (cliente_id, produto_id, quantidade, valor_unitario, valor_total, observacoes)
    VALUES (cliente_id, produto_id, quantidade, preco_unitario, preco_unitario * quantidade, observacoes)
    RETURNING id INTO novo_pedido_id;
    
    RETURN novo_pedido_id;
END;
$$;

-- Chamadas com parâmetros nomeados
SELECT criar_pedido(cliente_id := 1, produto_id := 5, quantidade := 2);
SELECT criar_pedido(1, 5, observacoes := 'Entrega urgente');
```

### Parâmetros Variáveis (VARIADIC)

```sql
-- Função que aceita número variável de argumentos
CREATE OR REPLACE FUNCTION somar_numeros(VARIADIC numeros NUMERIC[])
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    soma NUMERIC := 0;
    numero NUMERIC;
BEGIN
    FOREACH numero IN ARRAY numeros
    LOOP
        soma := soma + numero;
    END LOOP;
    
    RETURN soma;
END;
$$;

-- Chamadas
SELECT somar_numeros(1, 2, 3, 4, 5);
SELECT somar_numeros(10.5, 20.3, 15.7);
```

## Controle de Fluxo

### Estruturas Condicionais

```sql
CREATE OR REPLACE FUNCTION classificar_idade(idade INTEGER)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    IF idade < 13 THEN
        RETURN 'Criança';
    ELSIF idade < 18 THEN
        RETURN 'Adolescente';
    ELSIF idade < 60 THEN
        RETURN 'Adulto';
    ELSE
        RETURN 'Idoso';
    END IF;
END;
$$;

-- Usando CASE
CREATE OR REPLACE FUNCTION obter_descricao_status(status_code INTEGER)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN CASE status_code
        WHEN 1 THEN 'Ativo'
        WHEN 2 THEN 'Inativo'
        WHEN 3 THEN 'Pendente'
        WHEN 4 THEN 'Cancelado'
        ELSE 'Status Desconhecido'
    END;
END;
$$;
```

### Estruturas de Repetição

```sql
-- Loop simples
CREATE OR REPLACE FUNCTION gerar_numeros_pares(limite INTEGER)
RETURNS INTEGER[]
LANGUAGE plpgsql
AS $$
DECLARE
    resultado INTEGER[] := '{}';
    i INTEGER := 2;
BEGIN
    WHILE i <= limite LOOP
        resultado := array_append(resultado, i);
        i := i + 2;
    END LOOP;
    
    RETURN resultado;
END;
$$;

-- FOR loop
CREATE OR REPLACE FUNCTION calcular_fatorial(n INTEGER)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    resultado BIGINT := 1;
    i INTEGER;
BEGIN
    FOR i IN 1..n LOOP
        resultado := resultado * i;
    END LOOP;
    
    RETURN resultado;
END;
$$;

-- FOR loop com query
CREATE OR REPLACE FUNCTION processar_pedidos_pendentes()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    pedido RECORD;
    contador INTEGER := 0;
BEGIN
    FOR pedido IN 
        SELECT id, cliente_id, valor_total 
        FROM pedidos 
        WHERE status = 'pendente'
    LOOP
        -- Processar cada pedido
        UPDATE pedidos 
        SET status = 'processando', 
            data_processamento = NOW()
        WHERE id = pedido.id;
        
        contador := contador + 1;
    END LOOP;
    
    RETURN contador;
END;
$$;
```

## Tratamento de Exceções

```sql
CREATE OR REPLACE FUNCTION dividir_seguro(dividendo NUMERIC, divisor NUMERIC)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    resultado NUMERIC;
BEGIN
    -- Tentativa de divisão
    BEGIN
        IF divisor = 0 THEN
            RAISE EXCEPTION 'Divisão por zero não é permitida';
        END IF;
        
        resultado := dividendo / divisor;
        RETURN resultado;
        
    EXCEPTION
        WHEN division_by_zero THEN
            RAISE NOTICE 'Erro: Divisão por zero detectada';
            RETURN NULL;
        WHEN OTHERS THEN
            RAISE NOTICE 'Erro inesperado: %', SQLERRM;
            RETURN NULL;
    END;
END;
$$;

-- Função com transação controlada
CREATE OR REPLACE FUNCTION transferir_estoque(
    produto_origem INTEGER,
    produto_destino INTEGER,
    quantidade INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    estoque_origem INTEGER;
BEGIN
    -- Verificar estoque origem
    SELECT estoque INTO estoque_origem
    FROM produtos 
    WHERE id = produto_origem;
    
    IF estoque_origem < quantidade THEN
        RAISE EXCEPTION 'Estoque insuficiente. Disponível: %, Solicitado: %', 
                       estoque_origem, quantidade;
    END IF;
    
    BEGIN
        -- Iniciar transação
        UPDATE produtos SET estoque = estoque - quantidade 
        WHERE id = produto_origem;
        
        UPDATE produtos SET estoque = estoque + quantidade 
        WHERE id = produto_destino;
        
        RETURN TRUE;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback automático em caso de erro
            RAISE NOTICE 'Erro na transferência: %', SQLERRM;
            RETURN FALSE;
    END;
END;
$$;
```

## Funções Avançadas

### Funções com Cursores

```sql
CREATE OR REPLACE FUNCTION processar_vendas_cursor()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    cursor_vendas CURSOR FOR 
        SELECT id, cliente_id, valor_total 
        FROM pedidos 
        WHERE data_pedido >= CURRENT_DATE - INTERVAL '30 days';
    
    venda RECORD;
    total_processado DECIMAL := 0;
    contador INTEGER := 0;
BEGIN
    OPEN cursor_vendas;
    
    LOOP
        FETCH cursor_vendas INTO venda;
        EXIT WHEN NOT FOUND;
        
        -- Processar cada venda
        total_processado := total_processado + venda.valor_total;
        contador := contador + 1;
        
        -- Fazer algo com os dados
        INSERT INTO log_processamento (pedido_id, processado_em)
        VALUES (venda.id, NOW());
    END LOOP;
    
    CLOSE cursor_vendas;
    
    RETURN format('Processados %s pedidos, total: R$ %.2f', 
                  contador, total_processado);
END;
$$;
```

### Funções Trigger

```sql
-- Função para trigger de auditoria
CREATE OR REPLACE FUNCTION auditar_mudancas()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Para INSERT
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (
            tabela, operacao, dados_novos, usuario, data_operacao
        ) VALUES (
            TG_TABLE_NAME, TG_OP, row_to_json(NEW), USER, NOW()
        );
        RETURN NEW;
    END IF;
    
    -- Para UPDATE
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (
            tabela, operacao, dados_antigos, dados_novos, usuario, data_operacao
        ) VALUES (
            TG_TABLE_NAME, TG_OP, row_to_json(OLD), row_to_json(NEW), USER, NOW()
        );
        RETURN NEW;
    END IF;
    
    -- Para DELETE
    IF TG_OP = 'DELETE' THEN
        INSERT INTO auditoria (
            tabela, operacao, dados_antigos, usuario, data_operacao
        ) VALUES (
            TG_TABLE_NAME, TG_OP, row_to_json(OLD), USER, NOW()
        );
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$;

-- Criar trigger
CREATE TRIGGER trigger_auditoria_usuarios
    AFTER INSERT OR UPDATE OR DELETE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION auditar_mudancas();
```

### Funções Recursivas

```sql
-- Função recursiva para calcular Fibonacci
CREATE OR REPLACE FUNCTION fibonacci(n INTEGER)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
BEGIN
    IF n <= 1 THEN
        RETURN n;
    ELSE
        RETURN fibonacci(n-1) + fibonacci(n-2);
    END IF;
END;
$$;

-- Função para navegar hierarquia organizacional
CREATE OR REPLACE FUNCTION obter_subordinados(gerente_id INTEGER)
RETURNS TABLE(
    funcionario_id INTEGER,
    nome TEXT,
    nivel INTEGER
)
LANGUAGE SQL
AS $$
    WITH RECURSIVE hierarquia AS (
        -- Caso base: funcionários diretos do gerente
        SELECT id, nome, 1 as nivel
        FROM funcionarios 
        WHERE supervisor_id = gerente_id
        
        UNION ALL
        
        -- Caso recursivo: subordinados dos subordinados
        SELECT f.id, f.nome, h.nivel + 1
        FROM funcionarios f
        INNER JOIN hierarquia h ON f.supervisor_id = h.funcionario_id
    )
    SELECT funcionario_id, nome, nivel FROM hierarquia;
$$;
```

## Funções com JSON/JSONB

```sql
-- Função para processar dados JSON
CREATE OR REPLACE FUNCTION processar_pedido_json(dados_json JSONB)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    novo_pedido_id INTEGER;
    item JSONB;
BEGIN
    -- Inserir cabeçalho do pedido
    INSERT INTO pedidos (cliente_id, data_pedido, observacoes)
    VALUES (
        (dados_json->>'cliente_id')::INTEGER,
        NOW(),
        dados_json->>'observacoes'
    )
    RETURNING id INTO novo_pedido_id;
    
    -- Inserir itens do pedido
    FOR item IN SELECT * FROM jsonb_array_elements(dados_json->'itens')
    LOOP
        INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco)
        VALUES (
            novo_pedido_id,
            (item->>'produto_id')::INTEGER,
            (item->>'quantidade')::INTEGER,
            (item->>'preco')::DECIMAL
        );
    END LOOP;
    
    RETURN novo_pedido_id;
END;
$$;

-- Uso da função
SELECT processar_pedido_json('{
    "cliente_id": 123,
    "observacoes": "Entrega expressa",
    "itens": [
        {"produto_id": 1, "quantidade": 2, "preco": 25.50},
        {"produto_id": 5, "quantidade": 1, "preco": 15.00}
    ]
}');
```

## Otimização e Performance

### Funções IMMUTABLE, STABLE e VOLATILE

```sql
-- IMMUTABLE: sempre retorna o mesmo resultado para mesmos parâmetros
CREATE OR REPLACE FUNCTION calcular_area_quadrado(lado NUMERIC)
RETURNS NUMERIC
LANGUAGE SQL
IMMUTABLE
AS $$
    SELECT lado * lado;
$$;

-- STABLE: resultado pode mudar entre transações, mas não dentro da mesma
CREATE OR REPLACE FUNCTION obter_configuracao(chave TEXT)
RETURNS TEXT
LANGUAGE SQL
STABLE
AS $$
    SELECT valor FROM configuracoes WHERE nome = chave;
$$;

-- VOLATILE: resultado pode mudar a qualquer momento (padrão)
CREATE OR REPLACE FUNCTION gerar_codigo_unico()
RETURNS TEXT
LANGUAGE SQL
VOLATILE
AS $$
    SELECT 'COD-' || extract(epoch from now())::bigint || '-' || trunc(random() * 10000)::text;
$$;
```

### Funções com Cache

```sql
-- Função com cache simples usando tabela temporária
CREATE OR REPLACE FUNCTION obter_relatorio_vendas_cache(mes INTEGER, ano INTEGER)
RETURNS TABLE(produto TEXT, vendas BIGINT, receita DECIMAL)
LANGUAGE plpgsql
AS $$
DECLARE
    cache_key TEXT;
    cache_exists BOOLEAN;
BEGIN
    cache_key := format('vendas_%s_%s', mes, ano);
    
    -- Verificar se existe cache
    SELECT EXISTS (
        SELECT 1 FROM cache_relatorios 
        WHERE chave = cache_key 
        AND created_at > NOW() - INTERVAL '1 hour'
    ) INTO cache_exists;
    
    IF cache_exists THEN
        -- Retornar dados do cache
        RETURN QUERY 
        SELECT (dados->>'produto')::TEXT,
               (dados->>'vendas')::BIGINT,
               (dados->>'receita')::DECIMAL
        FROM cache_relatorios 
        WHERE chave = cache_key;
    ELSE
        -- Gerar relatório e salvar no cache
        DELETE FROM cache_relatorios WHERE chave = cache_key;
        
        INSERT INTO cache_relatorios (chave, dados, created_at)
        SELECT cache_key, 
               jsonb_build_object(
                   'produto', p.nome,
                   'vendas', COUNT(*),
                   'receita', SUM(ip.quantidade * ip.preco)
               ),
               NOW()
        FROM produtos p
        JOIN itens_pedido ip ON p.id = ip.produto_id
        JOIN pedidos ped ON ip.pedido_id = ped.id
        WHERE EXTRACT(MONTH FROM ped.data_pedido) = mes
          AND EXTRACT(YEAR FROM ped.data_pedido) = ano
        GROUP BY p.id, p.nome;
        
        -- Retornar dados recém-calculados
        RETURN QUERY
        SELECT (dados->>'produto')::TEXT,
               (dados->>'vendas')::BIGINT,
               (dados->>'receita')::DECIMAL
        FROM cache_relatorios 
        WHERE chave = cache_key;
    END IF;
END;
$$;
```

## Gerenciamento de Funções

### Lista e Informações sobre Funções

```sql
-- Listar todas as funções do usuário
SELECT 
    routine_name,
    routine_type,
    data_type,
    routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- Detalhes específicos de uma função
SELECT 
    p.proname as nome,
    p.proargnames as parametros,
    p.prorettype as tipo_retorno,
    l.lanname as linguagem,
    p.prosrc as codigo
FROM pg_proc p
JOIN pg_language l ON p.prolang = l.oid
WHERE p.proname = 'nome_da_funcao';
```

### Modificar e Remover Funções

```sql
-- Alterar função existente
CREATE OR REPLACE FUNCTION minha_funcao(param INTEGER)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    -- nova implementação
    RETURN 'Nova versão: ' || param;
END;
$$;

-- Remover função
DROP FUNCTION IF EXISTS minha_funcao(INTEGER);

-- Remover função com sobrecarga específica
DROP FUNCTION calcular_desconto(DECIMAL, BOOLEAN);
```

### Permissões e Segurança

```sql
-- Conceder permissão de execução
GRANT EXECUTE ON FUNCTION processar_pedido(INTEGER) TO role_usuario;

-- Revogar permissão
REVOKE EXECUTE ON FUNCTION processar_pedido(INTEGER) FROM role_usuario;

-- Função com SECURITY DEFINER (executa com privilégios do criador)
CREATE OR REPLACE FUNCTION funcao_admin()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Esta função executa com privilégios de quem a criou
    RETURN 'Operação administrativa executada';
END;
$$;
```

## Exemplos Práticos

### Sistema de Auditoria Completo

```sql
-- Tabela de auditoria
CREATE TABLE auditoria_sistema (
    id SERIAL PRIMARY KEY,
    tabela_nome VARCHAR(100),
    operacao VARCHAR(10),
    usuario_nome VARCHAR(100),
    data_operacao TIMESTAMP DEFAULT NOW(),
    dados_antigos JSONB,
    dados_novos JSONB,
    ip_address INET
);

-- Função genérica de auditoria
CREATE OR REPLACE FUNCTION fn_auditoria()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    dados_antigos JSONB;
    dados_novos JSONB;
    ip_cliente INET;
BEGIN
    -- Obter IP do cliente (se disponível)
    SELECT inet_client_addr() INTO ip_cliente;
    
    -- Preparar dados baseado na operação
    CASE TG_OP
        WHEN 'INSERT' THEN
            dados_novos := row_to_json(NEW)::JSONB;
        WHEN 'UPDATE' THEN
            dados_antigos := row_to_json(OLD)::JSONB;
            dados_novos := row_to_json(NEW)::JSONB;
        WHEN 'DELETE' THEN
            dados_antigos := row_to_json(OLD)::JSONB;
        ELSE
            -- Operação não suportada
            RETURN NULL;
    END CASE;
    
    -- Inserir registro de auditoria
    INSERT INTO auditoria_sistema (
        tabela_nome, operacao, usuario_nome, 
        dados_antigos, dados_novos, ip_address
    ) VALUES (
        TG_TABLE_NAME, TG_OP, SESSION_USER,
        dados_antigos, dados_novos, ip_cliente
    );
    
    -- Retornar registro apropriado
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;
```

### Sistema de Notificações

```sql
-- Função para enviar notificações
CREATE OR REPLACE FUNCTION enviar_notificacao(
    canal TEXT,
    mensagem TEXT,
    dados_extras JSONB DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    payload JSONB;
BEGIN
    -- Construir payload da notificação
    payload := jsonb_build_object(
        'timestamp', extract(epoch from now()),
        'mensagem', mensagem,
        'dados', dados_extras
    );
    
    -- Enviar notificação
    PERFORM pg_notify(canal, payload::TEXT);
    
    -- Log da notificação
    INSERT INTO log_notificacoes (canal, mensagem, enviado_em)
    VALUES (canal, mensagem, NOW());
END;
$$;

-- Função trigger para notificar mudanças
CREATE OR REPLACE FUNCTION notificar_mudanca_produto()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM enviar_notificacao(
            'produto_novo',
            'Novo produto cadastrado: ' || NEW.nome,
            jsonb_build_object('produto_id', NEW.id, 'nome', NEW.nome)
        );
    ELSIF TG_OP = 'UPDATE' THEN
        -- Verificar se o estoque ficou baixo
        IF NEW.estoque <= 5 AND OLD.estoque > 5 THEN
            PERFORM enviar_notificacao(
                'estoque_baixo',
                'Estoque baixo para produto: ' || NEW.nome,
                jsonb_build_object('produto_id', NEW.id, 'estoque', NEW.estoque)
            );
        END IF;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$;
```

As funções no PostgreSQL são uma ferramenta poderosa para implementar lógica de negócio diretamente no banco de dados, melhorando performance, segurança e maintibilidade das aplicações. Com o domínio dessas técnicas, é possível criar sistemas mais robustos e eficientes.