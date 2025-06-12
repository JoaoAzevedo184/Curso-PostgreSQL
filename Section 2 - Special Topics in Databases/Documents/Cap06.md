# Transações no PostgreSQL

## Introdução

Transações são uma das características mais importantes dos sistemas de banco de dados relacionais. Elas garantem que um conjunto de operações seja executado de forma atômica, consistente, isolada e durável (propriedades ACID).

## O que é uma Transação?

Uma transação é uma unidade lógica de trabalho que consiste em uma ou mais operações SQL que devem ser executadas como um bloco único. Todas as operações dentro de uma transação são executadas com sucesso ou todas são desfeitas.

### Propriedades ACID

- **Atomicidade**: Todas as operações são executadas ou nenhuma é
- **Consistência**: O banco mantém suas regras de integridade
- **Isolamento**: Transações não interferem umas nas outras
- **Durabilidade**: Dados confirmados são permanentemente armazenados

## Estados de uma Transação

1. **Ativa**: Transação está sendo executada
2. **Parcialmente Confirmada**: Todas as operações foram executadas, mas ainda não confirmadas
3. **Confirmada**: Transação foi confirmada com sucesso
4. **Falhada**: Transação falhou e deve ser desfeita
5. **Abortada**: Transação foi desfeita e o banco retornou ao estado anterior

## Comandos de Controle de Transação

### BEGIN

O comando `BEGIN` inicia uma nova transação. Todas as operações subsequentes farão parte dessa transação até que seja confirmada ou desfeita.

#### Sintaxe

```sql
BEGIN;
-- ou
BEGIN TRANSACTION;
-- ou
START TRANSACTION;
```

#### Exemplos

```sql
-- Iniciar uma transação simples
BEGIN;

-- Iniciar transação com nível de isolamento específico
BEGIN ISOLATION LEVEL READ COMMITTED;

-- Iniciar transação read-only
BEGIN READ ONLY;

-- Iniciar transação com características específicas
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE READ WRITE;
```

#### Opções do BEGIN

| Opção | Descrição |
|-------|-----------|
| `ISOLATION LEVEL` | Define o nível de isolamento da transação |
| `READ WRITE` | Permite operações de leitura e escrita (padrão) |
| `READ ONLY` | Permite apenas operações de leitura |
| `DEFERRABLE` | Permite que a transação seja adiada |

### COMMIT

O comando `COMMIT` confirma todas as alterações feitas durante a transação, tornando-as permanentes no banco de dados.

#### Sintaxe

```sql
COMMIT;
-- ou
COMMIT TRANSACTION;
-- ou
COMMIT WORK;
```

#### Exemplos

```sql
-- Exemplo básico de transação com commit
BEGIN;
INSERT INTO produtos (nome, preco) VALUES ('Notebook', 2500.00);
UPDATE estoque SET quantidade = quantidade - 1 WHERE produto_id = 1;
COMMIT;
```

### ROLLBACK

O comando `ROLLBACK` desfaz todas as alterações feitas durante a transação, retornando o banco ao estado anterior ao início da transação.

#### Sintaxe

```sql
ROLLBACK;
-- ou
ROLLBACK TRANSACTION;
-- ou
ROLLBACK WORK;
```

#### Exemplos

```sql
-- Exemplo de rollback em caso de erro
BEGIN;
INSERT INTO produtos (nome, preco) VALUES ('Tablet', 800.00);
-- Simular um erro ou condição que requer rollback
ROLLBACK;
```

## Controle de Transações Avançado

### Savepoints

Savepoints permitem criar pontos de salvamento dentro de uma transação, possibilitando rollback parcial.

```sql
BEGIN;
INSERT INTO clientes (nome) VALUES ('João');
SAVEPOINT sp1;

INSERT INTO produtos (nome, preco) VALUES ('Mouse', 50.00);
SAVEPOINT sp2;

-- Erro ocorre aqui
INSERT INTO produtos (nome, preco) VALUES ('Teclado', NULL); -- Erro!

-- Rollback apenas até o savepoint sp2
ROLLBACK TO SAVEPOINT sp2;

-- Continuar a transação
INSERT INTO produtos (nome, preco) VALUES ('Teclado', 150.00);
COMMIT;
```

### Comandos de Savepoint

```sql
-- Criar savepoint
SAVEPOINT nome_savepoint;

-- Rollback para savepoint
ROLLBACK TO SAVEPOINT nome_savepoint;
-- ou
ROLLBACK TO nome_savepoint;

-- Liberar savepoint (remove o savepoint)
RELEASE SAVEPOINT nome_savepoint;
```

## Níveis de Isolamento

O PostgreSQL suporta quatro níveis de isolamento de transação:

### 1. READ UNCOMMITTED
- Permite leitura de dados não confirmados
- Menor isolamento, maior performance

```sql
BEGIN ISOLATION LEVEL READ UNCOMMITTED;
-- operações da transação
COMMIT;
```

### 2. READ COMMITTED (Padrão)
- Só permite leitura de dados confirmados
- Evita leitura suja (dirty read)

```sql
BEGIN ISOLATION LEVEL READ COMMITTED;
-- operações da transação
COMMIT;
```

### 3. REPEATABLE READ
- Garante que leituras repetidas retornem os mesmos dados
- Evita leitura não repetível (non-repeatable read)

```sql
BEGIN ISOLATION LEVEL REPEATABLE READ;
-- operações da transação
COMMIT;
```

### 4. SERIALIZABLE
- Maior nível de isolamento
- Transações são executadas como se fossem seriais

```sql
BEGIN ISOLATION LEVEL SERIALIZABLE;
-- operações da transação
COMMIT;
```

## Exemplos Práticos

### Transferência Bancária

```sql
-- Exemplo clássico: transferência entre contas
BEGIN;

-- Verificar saldo suficiente
SELECT saldo FROM contas WHERE id = 1;

-- Se saldo suficiente, prosseguir
UPDATE contas SET saldo = saldo - 500.00 WHERE id = 1;
UPDATE contas SET saldo = saldo + 500.00 WHERE id = 2;

-- Registrar a transação
INSERT INTO historico_transacoes (conta_origem, conta_destino, valor, data_transacao) 
VALUES (1, 2, 500.00, NOW());

COMMIT;
```

### Controle de Estoque

```sql
-- Venda de produto com controle de estoque
BEGIN;

-- Verificar disponibilidade
SELECT quantidade FROM estoque WHERE produto_id = 1;

-- Se disponível, processar venda
INSERT INTO vendas (produto_id, quantidade, valor_total) 
VALUES (1, 2, 100.00);

UPDATE estoque SET quantidade = quantidade - 2 WHERE produto_id = 1;

-- Verificar se estoque não ficou negativo
SELECT quantidade FROM estoque WHERE produto_id = 1;

-- Se tudo OK, confirmar
COMMIT;

-- Se algo deu errado, desfazer
-- ROLLBACK;
```

### Tratamento de Erros

```sql
-- Usando blocos de exceção (em funções)
DO $$
BEGIN
    BEGIN
        INSERT INTO produtos (nome, preco) VALUES ('Produto Teste', 100.00);
        -- Simular erro
        INSERT INTO produtos (nome, preco) VALUES ('Produto Teste', 'ERRO');
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Erro ocorreu: %', SQLERRM;
            ROLLBACK;
    END;
END $$;
```

## Transações Automáticas vs Manuais

### Modo Autocommit (Padrão)
```sql
-- Cada comando é automaticamente confirmado
INSERT INTO produtos (nome, preco) VALUES ('Produto A', 50.00);
-- Automaticamente confirmado
```

### Modo Manual
```sql
-- Controle manual das transações
BEGIN;
INSERT INTO produtos (nome, preco) VALUES ('Produto B', 60.00);
INSERT INTO produtos (nome, preco) VALUES ('Produto C', 70.00);
COMMIT; -- Confirma ambas as inserções
```

## Monitoramento de Transações

### Verificar Transações Ativas

```sql
-- Ver transações ativas
SELECT 
    pid,
    state,
    query_start,
    query
FROM pg_stat_activity 
WHERE state IN ('active', 'idle in transaction');
```

### Verificar Locks

```sql
-- Ver locks ativos
SELECT 
    l.pid,
    l.mode,
    l.granted,
    c.relname
FROM pg_locks l
JOIN pg_class c ON l.relation = c.oid
WHERE NOT l.granted;
```

## Boas Práticas

### 1. Transações Curtas
```sql
-- BOM: Transação curta e específica
BEGIN;
UPDATE estoque SET quantidade = quantidade - 1 WHERE produto_id = 1;
COMMIT;
```

### 2. Tratamento de Erros
```sql
-- Sempre considere o tratamento de erros
BEGIN;
-- operações críticas
IF (erro_ocorreu) THEN
    ROLLBACK;
ELSE
    COMMIT;
END IF;
```

### 3. Evitar Transações Longas
```sql
-- EVITAR: Transações muito longas
-- BEGIN;
-- -- muitas operações
-- -- processamento longo
-- COMMIT;
```

### 4. Uso Adequado de Savepoints
```sql
-- Para operações complexas com pontos de recuperação
BEGIN;
INSERT INTO tabela1 VALUES (...);
SAVEPOINT sp1;

-- Operação que pode falhar
INSERT INTO tabela2 VALUES (...);

-- Se falhar, volta ao savepoint
-- ROLLBACK TO sp1;
COMMIT;
```

## Comandos de Referência Rápida

```sql
-- Iniciar transação
BEGIN;

-- Confirmar transação
COMMIT;

-- Desfazer transação
ROLLBACK;

-- Criar savepoint
SAVEPOINT nome_sp;

-- Rollback para savepoint
ROLLBACK TO nome_sp;

-- Liberar savepoint
RELEASE SAVEPOINT nome_sp;

-- Transação com isolamento específico
BEGIN ISOLATION LEVEL SERIALIZABLE;
```

## Cenários de Uso Comum

### E-commerce: Processamento de Pedido
```sql
BEGIN;
-- Inserir pedido
INSERT INTO pedidos (cliente_id, total) VALUES (1, 150.00);

-- Inserir itens do pedido
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade) VALUES (1, 1, 2);

-- Atualizar estoque
UPDATE estoque SET quantidade = quantidade - 2 WHERE produto_id = 1;

-- Registrar pagamento
INSERT INTO pagamentos (pedido_id, valor, status) VALUES (1, 150.00, 'aprovado');

COMMIT;
```

### Sistema de Reservas
```sql
BEGIN;
-- Verificar disponibilidade
SELECT disponivel FROM quartos WHERE id = 1 AND data_reserva = '2024-07-15';

-- Criar reserva
INSERT INTO reservas (quarto_id, cliente_id, data_reserva) VALUES (1, 1, '2024-07-15');

-- Marcar quarto como ocupado
UPDATE quartos SET disponivel = false WHERE id = 1;

COMMIT;
```

## Conclusão

O controle de transações é fundamental para manter a integridade dos dados em sistemas PostgreSQL. O uso adequado de `BEGIN`, `COMMIT` e `ROLLBACK`, combinado com o entendimento dos níveis de isolamento e savepoints, permite criar aplicações robustas e confiáveis.