# Joins no Contexto de Álgebra Relacional

Os **Joins** são operações fundamentais da álgebra relacional que permitem combinar tuplas de duas ou mais relações baseadas em condições específicas. Eles representam uma das operações mais poderosas e utilizadas em bancos de dados relacionais, permitindo a reconstrução de informações distribuídas em múltiplas tabelas.

## Operações Básicas de Join

### 1. Produto Cartesiano (×)

O **Produto Cartesiano** é a operação mais básica de combinação de relações.

#### Definição Formal
**R × S**

Combina cada tupla de R com cada tupla de S, resultando em uma relação com:
- **Atributos**: Todos os atributos de R e S
- **Tuplas**: |R| × |S| tuplas (onde |R| é o número de tuplas em R)

#### Exemplo
**Tabela Funcionarios:**
| id | nome |
|----|------|
| 1 | Ana |
| 2 | Bruno |

**Tabela Departamentos:**
| codigo | nome_dept |
|--------|-----------|
| 10 | TI |
| 20 | Vendas |

**Produto Cartesiano (Funcionarios × Departamentos):**
| id | nome | codigo | nome_dept |
|----|------|--------|-----------|
| 1 | Ana | 10 | TI |
| 1 | Ana | 20 | Vendas |
| 2 | Bruno | 10 | TI |
| 2 | Bruno | 20 | Vendas |

#### SQL Equivalente
```sql
SELECT * 
FROM funcionarios 
CROSS JOIN departamentos;
-- ou
SELECT * 
FROM funcionarios, departamentos;
```

### 2. Join Natural (⋈)

O **Join Natural** combina relações baseado em atributos com nomes idênticos.

#### Definição Formal
**R ⋈ S**

Automaticamente identifica atributos comuns e cria condições de igualdade para eles.

#### Exemplo
**Tabela Funcionarios:**
| id | nome | dept_id |
|----|------|---------|
| 1 | Ana | 10 |
| 2 | Bruno | 20 |
| 3 | Carlos | 10 |

**Tabela Departamentos:**
| dept_id | nome_dept | gerente |
|---------|-----------|---------|
| 10 | TI | João |
| 20 | Vendas | Maria |

**Join Natural (Funcionarios ⋈ Departamentos):**
| id | nome | dept_id | nome_dept | gerente |
|----|------|---------|-----------|---------|
| 1 | Ana | 10 | TI | João |
| 2 | Bruno | 20 | Vendas | Maria |
| 3 | Carlos | 10 | TI | João |

#### SQL Equivalente
```sql
SELECT * 
FROM funcionarios 
NATURAL JOIN departamentos;
```

### 3. Theta Join (⋈θ)

O **Theta Join** é um produto cartesiano seguido de uma seleção baseada em uma condição θ.

#### Definição Formal
**R ⋈<sub>θ</sub> S = σ<sub>θ</sub>(R × S)**

Onde θ é uma condição de join (predicado).

#### Exemplo
**Operação:** Funcionarios ⋈<sub>Funcionarios.dept_id = Departamentos.dept_id</sub> Departamentos

```sql
SELECT * 
FROM funcionarios f
JOIN departamentos d ON f.dept_id = d.dept_id;
```

### 4. Equijoin

O **Equijoin** é um caso especial do Theta Join onde a condição é uma igualdade.

#### Características
- Condição sempre usa o operador de igualdade (=)
- Resulta em colunas duplicadas para os atributos de join
- Mais comum na prática

#### Exemplo
```sql
SELECT f.id, f.nome, f.dept_id, d.dept_id, d.nome_dept
FROM funcionarios f
JOIN departamentos d ON f.dept_id = d.dept_id;
```

## Tipos de Join em SQL

### Inner Join

#### Definição Algébrica
Equivale ao Join Natural ou Equijoin, retornando apenas tuplas que têm correspondência em ambas as relações.

```sql
SELECT f.nome, d.nome_dept
FROM funcionarios f
INNER JOIN departamentos d ON f.dept_id = d.dept_id;
```

#### Exemplo Prático
**Resultado:**
| nome | nome_dept |
|------|-----------|
| Ana | TI |
| Bruno | Vendas |
| Carlos | TI |

### Left Outer Join (⟕)

#### Definição Algébrica
**R ⟕ S**: Inclui todas as tuplas de R, mesmo que não tenham correspondência em S.

```sql
SELECT f.nome, d.nome_dept
FROM funcionarios f
LEFT JOIN departamentos d ON f.dept_id = d.dept_id;
```

#### Exemplo com Dados
**Tabela Funcionarios (com funcionário sem departamento):**
| id | nome | dept_id |
|----|------|---------|
| 1 | Ana | 10 |
| 2 | Bruno | 20 |
| 3 | Carlos | 10 |
| 4 | Diana | NULL |

**Resultado LEFT JOIN:**
| nome | nome_dept |
|------|-----------|
| Ana | TI |
| Bruno | Vendas |
| Carlos | TI |
| Diana | NULL |

### Right Outer Join (⟖)

#### Definição Algébrica
**R ⟖ S**: Inclui todas as tuplas de S, mesmo que não tenham correspondência em R.

```sql
SELECT f.nome, d.nome_dept
FROM funcionarios f
RIGHT JOIN departamentos d ON f.dept_id = d.dept_id;
```

### Full Outer Join (⟗)

#### Definição Algébrica
**R ⟗ S**: Inclui todas as tuplas de ambas as relações, com NULLs onde não há correspondência.

```sql
SELECT f.nome, d.nome_dept
FROM funcionarios f
FULL OUTER JOIN departamentos d ON f.dept_id = d.dept_id;
```

## Propriedades dos Joins

### Comutatividade
```
R ⋈ S = S ⋈ R  (para joins naturais e equijoins)
```

### Associatividade
```
(R ⋈ S) ⋈ T = R ⋈ (S ⋈ T)
```

### Distributividade com Seleção
```
σ<sub>condição</sub>(R ⋈ S) = σ<sub>condição</sub>(R) ⋈ S  (se condição se aplica apenas a R)
```

### Comutatividade com Projeção
```
π<sub>atributos</sub>(R ⋈ S) = π<sub>atributos</sub>(R) ⋈ π<sub>atributos</sub>(S)  (com restrições)
```

## Joins Múltiplos

### Join de Três Tabelas
```sql
-- Álgebra: Funcionarios ⋈ Departamentos ⋈ Projetos
SELECT f.nome, d.nome_dept, p.nome_projeto
FROM funcionarios f
JOIN departamentos d ON f.dept_id = d.dept_id
JOIN projetos p ON d.dept_id = p.dept_responsavel;
```

### Join em Cadeia
```sql
-- Relacionamentos hierárquicos
SELECT f.nome as funcionario, g.nome as gerente
FROM funcionarios f
JOIN funcionarios g ON f.gerente_id = g.id;
```

## Aplicações Práticas no PostgreSQL

### Self Join
```sql
-- Encontrar funcionários e seus gerentes
SELECT 
    f.nome as funcionario,
    g.nome as gerente
FROM funcionarios f
LEFT JOIN funcionarios g ON f.gerente_id = g.id;
```

### Join com Agregação
```sql
-- Departamentos com contagem de funcionários
SELECT 
    d.nome_dept,
    COUNT(f.id) as total_funcionarios
FROM departamentos d
LEFT JOIN funcionarios f ON d.dept_id = f.dept_id
GROUP BY d.dept_id, d.nome_dept;
```

### Join com Subconsulta
```sql
-- Funcionários em departamentos com mais de 5 pessoas
SELECT f.nome, d.nome_dept
FROM funcionarios f
JOIN departamentos d ON f.dept_id = d.dept_id
WHERE d.dept_id IN (
    SELECT dept_id 
    FROM funcionarios 
    GROUP BY dept_id 
    HAVING COUNT(*) > 5
);
```

### Join com Múltiplas Condições
```sql
-- Join com condições complexas
SELECT f.nome, p.nome_projeto
FROM funcionarios f
JOIN projetos p ON f.dept_id = p.dept_responsavel
    AND f.nivel_acesso >= p.nivel_minimo
    AND f.ativo = true;
```

## Otimização de Joins

### Índices para Joins
```sql
-- Índices nas colunas de join
CREATE INDEX idx_funcionarios_dept_id ON funcionarios (dept_id);
CREATE INDEX idx_departamentos_dept_id ON departamentos (dept_id);

-- Índice composto para joins complexos
CREATE INDEX idx_funcionarios_dept_nivel ON funcionarios (dept_id, nivel_acesso);
```

### Ordem de Joins
O PostgreSQL automaticamente otimiza a ordem dos joins, mas podemos influenciar:

```sql
-- Forçar ordem específica (raramente necessário)
SET join_collapse_limit = 1;
SELECT /* ... */;
SET join_collapse_limit = 8; -- valor padrão
```

### Análise de Performance
```sql
-- Verificar plano de execução
EXPLAIN ANALYZE
SELECT f.nome, d.nome_dept
FROM funcionarios f
JOIN departamentos d ON f.dept_id = d.dept_id;
```

## Transformações Algébricas

### Join Push-Down
```sql
-- Menos eficiente
SELECT * FROM (
    SELECT * FROM funcionarios WHERE salario > 5000
) f
JOIN departamentos d ON f.dept_id = d.dept_id;

-- Mais eficiente (otimizador faz automaticamente)
SELECT f.*, d.*
FROM funcionarios f
JOIN departamentos d ON f.dept_id = d.dept_id
WHERE f.salario > 5000;
```

### Projeção Push-Down
```sql
-- O otimizador projeta apenas colunas necessárias
SELECT f.nome, d.nome_dept  -- Apenas estas colunas são processadas
FROM funcionarios f
JOIN departamentos d ON f.dept_id = d.dept_id;
```

## Casos de Uso Avançados

### Window Functions com Joins
```sql
-- Ranking de funcionários por departamento
SELECT 
    f.nome,
    d.nome_dept,
    f.salario,
    ROW_NUMBER() OVER (PARTITION BY d.dept_id ORDER BY f.salario DESC) as ranking
FROM funcionarios f
JOIN departamentos d ON f.dept_id = d.dept_id;
```

### Joins Laterais (PostgreSQL)
```sql
-- Join lateral para top N por grupo
SELECT d.nome_dept, top_func.nome, top_func.salario
FROM departamentos d
JOIN LATERAL (
    SELECT nome, salario
    FROM funcionarios f
    WHERE f.dept_id = d.dept_id
    ORDER BY salario DESC
    LIMIT 2
) top_func ON true;
```

### CTE com Joins
```sql
-- Using Common Table Expressions
WITH funcionarios_senior AS (
    SELECT * FROM funcionarios WHERE anos_experiencia > 5
)
SELECT fs.nome, d.nome_dept
FROM funcionarios_senior fs
JOIN departamentos d ON fs.dept_id = d.dept_id;
```

## Considerações de Design

### Normalização e Joins
- Joins são consequência da normalização
- Balanceamento entre performance e normalização
- Desnormalização controlada quando necessário

### Foreign Keys
```sql
-- Garantir integridade referencial
ALTER TABLE funcionarios
ADD CONSTRAINT fk_funcionarios_departamento
FOREIGN KEY (dept_id) REFERENCES departamentos(dept_id);
```

### Performance vs. Legibilidade
```sql
-- Mais legível
SELECT f.nome, d.nome_dept, p.nome_projeto
FROM funcionarios f
JOIN departamentos d ON f.dept_id = d.dept_id
JOIN projetos p ON f.projeto_atual = p.id;

-- Possível otimização com EXISTS
SELECT f.nome, d.nome_dept
FROM funcionarios f
JOIN departamentos d ON f.dept_id = d.dept_id
WHERE EXISTS (
    SELECT 1 FROM projetos p WHERE p.id = f.projeto_atual
);
```

Os Joins são fundamentais na álgebra relacional e permitem a reconstrução eficiente de informações relacionadas distribuídas em múltiplas tabelas, sendo essenciais para o desenvolvimento de sistemas de banco de dados robustos e eficientes.