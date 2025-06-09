# Comandos Adicionais SQL - PostgreSQL

Este documento aborda comandos avançados e funções úteis no PostgreSQL para manipulação de dados, tratamento de valores nulos e operações condicionais.

## Extract de Data

A função `EXTRACT` permite extrair componentes específicos de valores de data e hora no PostgreSQL.

### Sintaxe Básica
```sql
EXTRACT(campo FROM fonte)
```

### Componentes Disponíveis
- `YEAR` - Ano
- `MONTH` - Mês (1-12)
- `DAY` - Dia do mês
- `HOUR` - Hora (0-23)
- `MINUTE` - Minuto (0-59)
- `SECOND` - Segundo (0-59)
- `DOW` - Dia da semana (0=Domingo, 6=Sábado)
- `DOY` - Dia do ano (1-366)
- `WEEK` - Número da semana no ano

### Exemplos Práticos

```sql
-- Extrair o ano de uma data
SELECT EXTRACT(YEAR FROM '2024-03-15'::DATE);
-- Resultado: 2024

-- Extrair mês e dia
SELECT 
    EXTRACT(MONTH FROM CURRENT_DATE) as mes_atual,
    EXTRACT(DAY FROM CURRENT_DATE) as dia_atual;

-- Filtrar registros por ano específico
SELECT * FROM pedidos 
WHERE EXTRACT(YEAR FROM data_pedido) = 2024;

-- Agrupar vendas por mês
SELECT 
    EXTRACT(MONTH FROM data_venda) as mes,
    SUM(valor_total) as total_vendas
FROM vendas 
GROUP BY EXTRACT(MONTH FROM data_venda)
ORDER BY mes;
```

## Substring

A função `SUBSTRING` extrai uma parte de uma string baseada em posição e comprimento.

### Sintaxe
```sql
SUBSTRING(string FROM posição FOR comprimento)
-- ou
SUBSTRING(string, posição, comprimento)
```

### Parâmetros
- `string` - Texto original
- `posição` - Posição inicial (começa em 1)
- `comprimento` - Número de caracteres a extrair

### Exemplos Práticos

```sql
-- Extrair os primeiros 3 caracteres
SELECT SUBSTRING('PostgreSQL' FROM 1 FOR 3);
-- Resultado: 'Pos'

-- Extrair código do produto (primeiros 4 caracteres)
SELECT 
    produto,
    SUBSTRING(codigo_produto FROM 1 FOR 4) as categoria
FROM produtos;

-- Extrair ano de um código no formato YYYYMMDD
SELECT 
    codigo,
    SUBSTRING(codigo FROM 1 FOR 4) as ano,
    SUBSTRING(codigo FROM 5 FOR 2) as mes,
    SUBSTRING(codigo FROM 7 FOR 2) as dia
FROM registros;

-- Usar com expressões regulares
SELECT SUBSTRING('ABC-123-XYZ' FROM '[0-9]+');
-- Resultado: '123'
```

## Coalesce

A função `COALESCE` retorna o primeiro valor não nulo de uma lista de expressões.

### Sintaxe
```sql
COALESCE(valor1, valor2, valor3, ...)
```

### Características
- Avalia os argumentos da esquerda para a direita
- Retorna o primeiro valor que não seja NULL
- Se todos os valores forem NULL, retorna NULL

### Exemplos Práticos

```sql
-- Substituir valores nulos por um padrão
SELECT 
    nome,
    COALESCE(telefone, 'Não informado') as telefone_contato
FROM clientes;

-- Usar múltiplos campos como fallback
SELECT 
    nome,
    COALESCE(email_principal, email_secundario, 'sem_email@empresa.com') as email
FROM usuarios;

-- Calcular com tratamento de nulos
SELECT 
    produto,
    preco_original,
    preco_promocional,
    COALESCE(preco_promocional, preco_original) as preco_final
FROM produtos;

-- Concatenar com tratamento de nulos
SELECT 
    COALESCE(nome, '') || ' - ' || COALESCE(sobrenome, '') as nome_completo
FROM pessoas;
```

## Case

A estrutura `CASE` permite criar lógica condicional nas consultas SQL, similar ao if-else em linguagens de programação.

### Sintaxe Simples
```sql
CASE coluna
    WHEN valor1 THEN resultado1
    WHEN valor2 THEN resultado2
    ELSE resultado_padrao
END
```

### Sintaxe com Condições
```sql
CASE 
    WHEN condição1 THEN resultado1
    WHEN condição2 THEN resultado2
    ELSE resultado_padrao
END
```

### Exemplos Práticos

#### CASE Simples
```sql
-- Categorizar produtos por tipo
SELECT 
    nome_produto,
    categoria,
    CASE categoria
        WHEN 'ELE' THEN 'Eletrônicos'
        WHEN 'ROU' THEN 'Roupas'
        WHEN 'LIV' THEN 'Livros'
        ELSE 'Outros'
    END as categoria_descricao
FROM produtos;
```

#### CASE com Condições
```sql
-- Classificar clientes por valor de compras
SELECT 
    nome_cliente,
    total_compras,
    CASE 
        WHEN total_compras >= 10000 THEN 'VIP'
        WHEN total_compras >= 5000 THEN 'Premium'
        WHEN total_compras >= 1000 THEN 'Regular'
        ELSE 'Novo'
    END as categoria_cliente
FROM (
    SELECT 
        c.nome as nome_cliente,
        COALESCE(SUM(p.valor_total), 0) as total_compras
    FROM clientes c
    LEFT JOIN pedidos p ON c.id = p.cliente_id
    GROUP BY c.id, c.nome
) as resumo_clientes;

-- Aplicar desconto baseado em quantidade
SELECT 
    produto,
    quantidade,
    preco_unitario,
    CASE 
        WHEN quantidade >= 100 THEN preco_unitario * 0.9  -- 10% desconto
        WHEN quantidade >= 50 THEN preco_unitario * 0.95   -- 5% desconto
        ELSE preco_unitario
    END as preco_com_desconto
FROM itens_pedido;
```

#### CASE em Agregações
```sql
-- Contar registros por categoria
SELECT 
    COUNT(CASE WHEN status = 'ativo' THEN 1 END) as ativos,
    COUNT(CASE WHEN status = 'inativo' THEN 1 END) as inativos,
    COUNT(CASE WHEN status = 'pendente' THEN 1 END) as pendentes
FROM usuarios;

-- Somar valores condicionalmente
SELECT 
    SUM(CASE WHEN tipo = 'entrada' THEN valor ELSE 0 END) as total_entradas,
    SUM(CASE WHEN tipo = 'saida' THEN valor ELSE 0 END) as total_saidas
FROM movimentacoes;
```

## Combinando Funções

Estas funções podem ser combinadas para criar consultas mais poderosas:

```sql
-- Exemplo complexo combinando todas as funções
SELECT 
    cliente_id,
    nome_cliente,
    EXTRACT(YEAR FROM data_pedido) as ano_pedido,
    SUBSTRING(codigo_produto FROM 1 FOR 3) as categoria_produto,
    COALESCE(desconto, 0) as desconto_aplicado,
    CASE 
        WHEN EXTRACT(MONTH FROM data_pedido) IN (12, 1, 2) THEN 'Verão'
        WHEN EXTRACT(MONTH FROM data_pedido) IN (3, 4, 5) THEN 'Outono'
        WHEN EXTRACT(MONTH FROM data_pedido) IN (6, 7, 8) THEN 'Inverno'
        ELSE 'Primavera'
    END as estacao_compra,
    valor_total * COALESCE(1 - desconto/100, 1) as valor_final
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
WHERE EXTRACT(YEAR FROM data_pedido) = 2024;
```

## Dicas e Boas Práticas

1. **EXTRACT**: Útil para relatórios temporais e filtros por período
2. **SUBSTRING**: Ideal para parsing de códigos e formatação de dados
3. **COALESCE**: Essencial para tratamento de valores NULL
4. **CASE**: Poderoso para lógica condicional e categorização de dados

Estas funções são fundamentais para manipulação avançada de dados no PostgreSQL e podem ser combinadas para resolver problemas complexos de consulta e formatação de resultados.