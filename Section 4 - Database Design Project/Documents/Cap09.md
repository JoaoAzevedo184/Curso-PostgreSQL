# Formas Normais Avançadas - BCNF, 4FN e 5FN

## Forma Normal de Boyce-Codd (BCNF)

### Definição
Uma relação está na **BCNF** se:
1. Está na 3FN
2. Para toda dependência funcional X → Y, X deve ser uma super-chave

### Diferença entre 3FN e BCNF
- **3FN**: Permite dependências funcionais onde o determinante não é super-chave, desde que o dependente seja atributo primo (parte de alguma chave candidata)
- **BCNF**: Exige que TODO determinante seja super-chave

### Quando 3FN ≠ BCNF
Quando existem múltiplas chaves candidatas sobrepostas (compartilham atributos comuns).

### Exemplo - Tabela em 3FN mas NÃO em BCNF

```sql
PROFESSOR_DISCIPLINA_CURSO
+----------+------------+--------+
| Professor| Disciplina | Curso  |
+----------+------------+--------+
| Silva    | BD         | SI     |
| Silva    | Java       | CC     |
| Santos   | BD         | CC     |
| Santos   | Java       | SI     |
| Lima     | Python     | SI     |
+----------+------------+--------+
```

**Restrições do Negócio:**
- Cada professor ensina apenas uma disciplina por curso
- Cada disciplina é ensinada por apenas um professor por curso
- Um professor pode ensinar a mesma disciplina em cursos diferentes

**Chaves Candidatas:**
- {Professor, Curso}
- {Disciplina, Curso}

**Dependências Funcionais:**
```
(Professor, Curso) → Disciplina     ✓ Determinante é chave candidata
(Disciplina, Curso) → Professor     ✓ Determinante é chave candidata
Professor → Disciplina              ✗ Determinante NÃO é super-chave
```

**Problema:** A dependência `Professor → Disciplina` viola BCNF pois `Professor` não é super-chave.

### Solução - Normalização para BCNF

```sql
PROFESSOR_DISCIPLINA
+----------+------------+
| Professor| Disciplina |
+----------+------------+
| Silva    | BD         |
| Santos   | Java       |
| Lima     | Python     |
+----------+------------+

DISCIPLINA_CURSO
+------------+--------+
| Disciplina | Curso  |
+------------+--------+
| BD         | SI     |
| BD         | CC     |
| Java       | CC     |
| Java       | SI     |
| Python     | SI     |
+------------+--------+
```

### Problema da Decomposição BCNF
**Perda de informação**: Não conseguimos mais determinar qual professor ensina qual disciplina em qual curso específico.

**Solução Alternativa - Manter 3FN:**
Em alguns casos, é preferível manter a relação em 3FN para preservar certas dependências funcionais importantes.

### Exemplo Prático - Sistema Acadêmico

```sql
-- Problema: Professor pode ensinar mesma disciplina em múltiplas turmas
AULA_VIOLACAO_BCNF
+----------+------------+-------+----------+
| Professor| Disciplina | Turma | Horario  |
+----------+------------+-------+----------+
| Silva    | BD         | A     | 08:00    |
| Silva    | BD         | B     | 10:00    |
| Santos   | Java       | A     | 14:00    |
+----------+------------+-------+----------+

-- Chaves candidatas: {Professor, Turma}, {Disciplina, Turma}
-- Dependência problemática: Professor → Disciplina (não é super-chave)

-- Solução BCNF
PROFESSOR_DISCIPLINA
+----------+------------+
| Professor| Disciplina |
+----------+------------+
| Silva    | BD         |
| Santos   | Java       |
+----------+------------+

TURMA_HORARIO
+------------+-------+----------+
| Disciplina | Turma | Horario  |
+------------+-------+----------+
| BD         | A     | 08:00    |
| BD         | B     | 10:00    |
| Java       | A     | 14:00    |
+------------+-------+----------+
```

---

## Quarta Forma Normal (4FN)

### Definição
Uma relação está na **4FN** se:
1. Está na BCNF
2. **Não possui dependências multivaloradas não triviais**

### Dependência Multivalorada (DMV)
Uma dependência multivalorada X →→ Y existe quando, para cada valor de X, existe um conjunto bem definido de valores de Y, independentemente dos valores de outros atributos.

### Notação
- **X →→ Y**: X multidetermina Y
- Lê-se: "X multidetermina Y"

### Exemplo - Tabela NÃO está em 4FN

```sql
FUNCIONARIO_HABILIDADE_PROJETO
+-------------+------------+----------+
| Funcionario | Habilidade | Projeto  |
+-------------+------------+----------+
| Silva       | Java       | SistemaA |
| Silva       | Java       | SistemaB |
| Silva       | Python     | SistemaA |
| Silva       | Python     | SistemaB |
| Santos      | PHP        | SistemaC |
| Santos      | MySQL      | SistemaC |
+-------------+------------+----------+
```

**Dependências Multivaloradas:**
```
Funcionario →→ Habilidade
Funcionario →→ Projeto
```

**Problemas:**
- Redundância: Combinações cartesianas desnecessárias
- Anomalias de inserção: Para adicionar uma habilidade, preciso adicionar para todos os projetos
- Anomalias de atualização: Mudanças em cascata

### Solução - Normalização para 4FN

```sql
FUNCIONARIO_HABILIDADE
+-------------+------------+
| Funcionario | Habilidade |
+-------------+------------+
| Silva       | Java       |
| Silva       | Python     |
| Santos      | PHP        |
| Santos      | MySQL      |
+-------------+------------+

FUNCIONARIO_PROJETO
+-------------+----------+
| Funcionario | Projeto  |
+-------------+----------+
| Silva       | SistemaA |
| Silva       | SistemaB |
| Santos      | SistemaC |
+-------------+----------+
```

### Exemplo Prático - Sistema de Cursos

```sql
-- Violação 4FN
PROFESSOR_DISCIPLINA_LIVRO
+----------+------------+------------------+
| Professor| Disciplina | Livro_Texto      |
+----------+------------+------------------+
| Silva    | BD         | Elmasri          |
| Silva    | BD         | Date             |
| Silva    | Java       | Deitel           |
| Silva    | Java       | Oracle_Press     |
| Santos   | Python     | Lutz             |
+----------+------------+------------------+

-- Dependências multivaloradas:
-- Professor →→ Disciplina
-- Professor →→ Livro_Texto

-- Solução 4FN
PROFESSOR_DISCIPLINA
+----------+------------+
| Professor| Disciplina |
+----------+------------+
| Silva    | BD         |
| Silva    | Java       |
| Santos   | Python     |
+----------+------------+

PROFESSOR_LIVRO
+----------+------------------+
| Professor| Livro_Texto      |
+----------+------------------+
| Silva    | Elmasri          |
| Silva    | Date             |
| Silva    | Deitel           |
| Silva    | Oracle_Press     |
| Santos   | Lutz             |
+----------+------------------+
```

### Identificando Dependências Multivaloradas

**Teste prático:**
1. Para um valor fixo de X, os valores de Y são independentes dos valores de Z?
2. Se sim, então X →→ Y

**Exemplo:**
- Um funcionário tem habilidades independentemente dos projetos
- Um funcionário participa de projetos independentemente das habilidades
- Logo: Funcionario →→ Habilidade e Funcionario →→ Projeto

---

## Quinta Forma Normal (5FN)

### Definição
Uma relação está na **5FN** (também chamada PJNF - Project-Join Normal Form) se:
1. Está na 4FN
2. **Não pode ser decomposta em projeções menores sem perda de informação**

### Dependência de Junção
Uma dependência de junção existe quando uma relação pode ser reconstruída pela junção natural de suas projeções, mas não pode ser decomposta sem perda de informação essencial.

### Exemplo - Tabela NÃO está em 5FN

```sql
FORNECEDOR_PRODUTO_PROJETO
+------------+----------+---------+
| Fornecedor | Produto  | Projeto |
+------------+----------+---------+
| F1         | P1       | Proj1   |
| F1         | P2       | Proj1   |
| F1         | P1       | Proj2   |
| F2         | P1       | Proj1   |
| F2         | P2       | Proj2   |
+------------+----------+---------+
```

**Restrições do Negócio:**
- Se um fornecedor fornece um produto E um projeto usa esse produto E o fornecedor participa do projeto, então existe uma tupla na relação
- Dependência de junção ternária

### Teste para 5FN
Decompor em projeções binárias:

```sql
FORNECEDOR_PRODUTO
+------------+----------+
| Fornecedor | Produto  |
+------------+----------+
| F1         | P1       |
| F1         | P2       |
| F2         | P1       |
| F2         | P2       |
+------------+----------+

PRODUTO_PROJETO
+----------+---------+
| Produto  | Projeto |
+----------+---------+
| P1       | Proj1   |
| P1       | Proj2   |
| P2       | Proj1   |
| P2       | Proj2   |
+----------+---------+

FORNECEDOR_PROJETO
+------------+---------+
| Fornecedor | Projeto |
+------------+---------+
| F1         | Proj1   |
| F1         | Proj2   |
| F2         | Proj1   |
| F2         | Proj2   |
+------------+---------+
```

**Resultado da Junção Natural:**
```sql
-- Produto cartesiano das três tabelas geraria tuplas espúrias:
F2, P1, Proj2  -- ✗ Não existe na tabela original
F2, P2, Proj1  -- ✗ Não existe na tabela original
```

### Solução para 5FN
Manter a relação ternária original, pois a decomposição gera informação espúria.

### Exemplo Prático - Sistema de Agentes

```sql
-- Situação: Agente pode representar Cliente para Produto específico
AGENTE_CLIENTE_PRODUTO
+--------+---------+----------+
| Agente | Cliente | Produto  |
+--------+---------+----------+
| A1     | C1      | P1       |
| A1     | C1      | P2       |
| A1     | C2      | P1       |
| A2     | C1      | P2       |
+--------+---------+----------+

-- Tentativa de decomposição:
AGENTE_CLIENTE      CLIENTE_PRODUTO      AGENTE_PRODUTO
+--------+---------+ +---------+--------+ +--------+----------+
| A1     | C1      | | C1      | P1     | | A1     | P1       |
| A1     | C2      | | C1      | P2     | | A1     | P2       |
| A2     | C1      | | C2      | P1     | | A2     | P2       |
+--------+---------+ +---------+--------+ +--------+----------+

-- Junção natural geraria:
-- (A1, C2, P2) -- ✗ Tupla espúria
-- (A2, C1, P1) -- ✗ Tupla espúria
```

### Quando Aplicar 5FN
5FN é aplicável quando:
1. Existem relacionamentos ternários ou n-ários complexos
2. A decomposição em relacionamentos binários gera informação espúria
3. As restrições do negócio exigem a manutenção da relação completa

---

## Resumo Comparativo das Formas Normais

| Forma Normal | Elimina | Critério Principal | Exemplo de Violação |
|--------------|---------|--------------------|--------------------|
| **1FN** | Atributos multivalorados | Valores atômicos | Telefones: "11999,11888" |
| **2FN** | Dependências parciais | Dependência total da chave | Cod_Produto → Nome |
| **3FN** | Dependências transitivas | Sem dependência entre não-chaves | CPF → Dept → Nome_Dept |
| **BCNF** | Dependências de não-super-chaves | Determinante é super-chave | Professor → Disciplina |
| **4FN** | Dependências multivaloradas | Sem DMV não triviais | Func →→ Habilidade, Projeto |
| **5FN** | Dependências de junção | Sem decomposição sem perda | Relacionamento ternário |

## Processo de Normalização Completo

### Exemplo Integrado

#### Tabela Original
```sql
PROJETO_ORIGINAL
+----------+----------+----------+----------+----------+----------+
| Projeto  | Gerente  | Depto    | Nome_Dept| Tecnologia| Funcao   |
+----------+----------+----------+----------+----------+----------+
| P1       | Silva    | D1       | TI       | Java,Python| Dev,Test |
| P2       | Santos   | D2       | RH       | PHP      | Dev      |
+----------+----------+----------+----------+----------+----------+
```

#### Aplicação Sequencial das Formas Normais

**1FN - Eliminar multivalorados:**
```sql
PROJETO_1FN
+----------+----------+----------+----------+----------+----------+
| Projeto  | Gerente  | Depto    | Nome_Dept| Tecnologia| Funcao   |
+----------+----------+----------+----------+----------+----------+
| P1       | Silva    | D1       | TI       | Java     | Dev      |
| P1       | Silva    | D1       | TI       | Java     | Test     |
| P1       | Silva    | D1       | TI       | Python   | Dev      |
| P1       | Silva    | D1       | TI       | Python   | Test     |
| P2       | Santos   | D2       | RH       | PHP      | Dev      |
+----------+----------+----------+----------+----------+----------+
```

**2FN - Eliminar dependências parciais:**
```sql
PROJETO
+----------+----------+----------+
| Projeto  | Gerente  | Depto    |
+----------+----------+----------+
| P1       | Silva    | D1       |
| P2       | Santos   | D2       |
+----------+----------+----------+

PROJETO_TECNOLOGIA_FUNCAO
+----------+----------+----------+
| Projeto  | Tecnologia| Funcao  |
+----------+----------+----------+
| P1       | Java     | Dev      |
| P1       | Java     | Test     |
| P1       | Python   | Dev      |
| P1       | Python   | Test     |
| P2       | PHP      | Dev      |
+----------+----------+----------+

DEPARTAMENTO
+----------+----------+
| Depto    | Nome_Dept|
+----------+----------+
| D1       | TI       |
| D2       | RH       |
+----------+----------+
```

**4FN - Eliminar dependências multivaloradas:**
```sql
PROJETO_TECNOLOGIA
+----------+----------+
| Projeto  | Tecnologia|
+----------+----------+
| P1       | Java     |
| P1       | Python   |
| P2       | PHP      |
+----------+----------+

PROJETO_FUNCAO
+----------+----------+
| Projeto  | Funcao   |
+----------+----------+
| P1       | Dev      |
| P1       | Test     |
| P2       | Dev      |
+----------+----------+
```

## Considerações Práticas

### Quando Parar a Normalização?
1. **Performance**: Muitas junções podem degradar performance
2. **Complexidade**: Consultas muito complexas
3. **Requisitos específicos**: Alguns relatórios precisam de dados desnormalizados
4. **Frequência de acesso**: Dados frequentemente acessados juntos

### Desnormalização Controlada
Em alguns casos, é aceitável manter redundância controlada para:
- Melhorar performance de consultas críticas
- Simplificar relatórios complexos
- Reduzir número de junções em consultas frequentes

### Ferramentas de Análise
```sql
-- Verificação de dependências funcionais
SELECT coluna1, coluna2, COUNT(DISTINCT coluna3)
FROM tabela
GROUP BY coluna1, coluna2
HAVING COUNT(DISTINCT coluna3) > 1;

-- Identificação de candidatos a chave primária
SELECT colunas, COUNT(*)
FROM tabela
GROUP BY colunas
HAVING COUNT(*) > 1;
```