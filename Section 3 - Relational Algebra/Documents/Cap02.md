# Operação Project (Projeção)

A operação **Project** (π - pi) é uma das operações fundamentais da álgebra relacional que permite selecionar colunas específicas de uma relação, criando uma nova relação com apenas os atributos desejados.

## Definição Formal

A operação de projeção é definida como:

**π<sub>A₁, A₂, ..., Aₖ</sub>(R)**

Onde:
- π (pi) é o símbolo da operação de projeção
- A₁, A₂, ..., Aₖ são os atributos (colunas) a serem selecionados
- R é a relação (tabela) de origem

## Características Principais

### Seleção de Colunas
A projeção permite escolher quais atributos devem aparecer no resultado, eliminando colunas desnecessárias e focando apenas nos dados relevantes para a consulta.

### Eliminação de Duplicatas
Por definição matemática, o resultado de uma projeção é um conjunto, portanto elimina automaticamente tuplas duplicadas. Isso garante que cada combinação de valores dos atributos selecionados apareça apenas uma vez.

### Preservação da Ordem Lógica
Embora a álgebra relacional não defina ordem, na prática, a projeção mantém a sequência lógica dos dados quando possível.

### Redução de Dados
A projeção pode reduzir significativamente o volume de dados ao eliminar colunas desnecessárias e duplicatas.

## Sintaxe em SQL

A operação de projeção em SQL é implementada através da cláusula **SELECT**:

```sql
SELECT coluna1, coluna2, coluna3
FROM tabela;
```

## Exemplos Práticos

### Exemplo 1: Projeção Simples

**Tabela Funcionarios:**
| id | nome | cargo | salario | departamento |
|----|------|-------|---------|--------------|
| 1 | Ana | Analista | 5000 | TI |
| 2 | Bruno | Gerente | 8000 | Vendas |
| 3 | Carlos | Analista | 4800 | TI |
| 4 | Diana | Desenvolvedora | 6500 | TI |

**Operação:** π<sub>nome, cargo</sub>(Funcionarios)

```sql
SELECT nome, cargo 
FROM funcionarios;
```

**Resultado:**
| nome | cargo |
|------|-------|
| Ana | Analista |
| Bruno | Gerente |
| Carlos | Analista |
| Diana | Desenvolvedora |

### Exemplo 2: Projeção com Eliminação de Duplicatas

**Operação:** π<sub>cargo</sub>(Funcionarios)

```sql
SELECT DISTINCT cargo 
FROM funcionarios;
```

**Resultado:**
| cargo |
|-------|
| Analista |
| Gerente |
| Desenvolvedora |

Note que "Analista" aparece apenas uma vez, mesmo existindo dois funcionários com esse cargo.

### Exemplo 3: Projeção com Expressões

```sql
-- Álgebra: π nome, salario*12 AS salario_anual (Funcionarios)
SELECT nome, salario * 12 AS salario_anual 
FROM funcionarios;
```

**Resultado:**
| nome | salario_anual |
|------|---------------|
| Ana | 60000 |
| Bruno | 96000 |
| Carlos | 57600 |
| Diana | 78000 |

## Aplicações no PostgreSQL

### Projeção Básica
```sql
-- Selecionar apenas nome e email dos clientes
SELECT nome, email 
FROM clientes;
```

### Projeção com Funções
```sql
-- Projeção com transformação de dados
SELECT 
    nome,
    UPPER(email) AS email_maiusculo,
    DATE_PART('year', data_nascimento) AS ano_nascimento
FROM clientes;
```

### Projeção com Agregações
```sql
-- Combinar projeção com funções de agregação
SELECT 
    departamento,
    COUNT(*) AS total_funcionarios,
    AVG(salario) AS salario_medio
FROM funcionarios
GROUP BY departamento;
```

### Projeção com DISTINCT
```sql
-- Eliminar duplicatas explicitamente
SELECT DISTINCT cidade, estado 
FROM enderecos;
```

## Propriedades Importantes

### Comutatividade com Seleção
A projeção é comutativa com a seleção quando os atributos da condição de seleção estão incluídos na projeção:

```
π A₁,A₂ (σ condição (R)) = σ condição (π A₁,A₂ (R))
```

### Idempotência
Aplicar a mesma projeção múltiplas vezes produz o mesmo resultado:

```
π A₁,A₂ (π A₁,A₂ (R)) = π A₁,A₂ (R)
```

### Composição de Projeções
Uma projeção pode ser composta com outra, resultando na projeção dos atributos comuns:

```
π A₁ (π A₁,A₂ (R)) = π A₁ (R)
```

## Otimizações no PostgreSQL

### Índices Cobrindo
```sql
-- Criar índice que cobre a projeção
CREATE INDEX idx_funcionarios_nome_cargo 
ON funcionarios (nome, cargo);

-- Esta consulta pode usar apenas o índice
SELECT nome, cargo 
FROM funcionarios 
WHERE departamento = 'TI';
```

### Materialized Views
```sql
-- Criar uma view materializada para projeções frequentes
CREATE MATERIALIZED VIEW funcionarios_resumo AS
SELECT nome, cargo, departamento
FROM funcionarios;

-- Atualizar quando necessário
REFRESH MATERIALIZED VIEW funcionarios_resumo;
```

## Casos de Uso Comuns

### Relatórios Específicos
```sql
-- Relatório de vendas simplificado
SELECT 
    data_venda,
    produto,
    quantidade,
    valor_total
FROM vendas
WHERE EXTRACT(MONTH FROM data_venda) = EXTRACT(MONTH FROM CURRENT_DATE);
```

### APIs e Interfaces
```sql
-- Dados para interface de usuário
SELECT 
    id,
    nome,
    foto_perfil,
    status_online
FROM usuarios
WHERE ativo = true;
```

### Data Warehousing
```sql
-- Projeção para análise dimensional
SELECT 
    ano,
    mes,
    categoria_produto,
    SUM(receita) as receita_total
FROM fatos_vendas
GROUP BY ano, mes, categoria_produto;
```

## Considerações de Performance

### Índices Apropriados
Criar índices que incluam as colunas frequentemente projetadas pode melhorar significativamente a performance:

```sql
-- Índice para projeções frequentes
CREATE INDEX idx_clientes_contato 
ON clientes (nome, email, telefone);
```

### Ordem das Colunas
A ordem das colunas na projeção pode afetar a performance, especialmente em consultas que utilizam índices compostos.

### Tamanho dos Dados
Projeções que reduzem significativamente o número de colunas podem melhorar a performance ao diminuir a quantidade de dados transferidos e processados.

A operação Project é fundamental na álgebra relacional e essencial para a construção de consultas eficientes em SQL, permitindo trabalhar apenas com os dados necessários e otimizando tanto a performance quanto a clareza das consultas.