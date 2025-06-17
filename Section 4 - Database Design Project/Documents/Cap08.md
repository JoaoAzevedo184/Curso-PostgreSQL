# Formas Normais em Banco de Dados

## Conceito Geral

As **Formas Normais** são um conjunto de regras utilizadas no processo de normalização de banco de dados para eliminar redundâncias, inconsistências e anomalias de atualização. Cada forma normal possui critérios específicos que uma relação deve atender.

### Objetivos da Normalização
- Eliminar redundâncias desnecessárias
- Prevenir anomalias de inserção, atualização e exclusão
- Garantir integridade dos dados
- Otimizar o armazenamento
- Facilitar a manutenção

---

## Primeira Forma Normal (1FN)

### Definição
Uma relação está na **1FN** se todos os seus atributos contêm apenas valores atômicos (indivisíveis) e não há grupos repetitivos.

### Critérios para 1FN
1. **Valores atômicos**: Cada célula contém um único valor
2. **Sem atributos multivalorados**: Não há conjuntos de valores em um atributo
3. **Sem atributos compostos**: Atributos não são subdivididos
4. **Ordem irrelevante**: A ordem das tuplas não importa

### Exemplo - Tabela NÃO está em 1FN

```sql
FUNCIONARIO_VIOLACAO_1FN
+--------+-------------+-------------------------+
| CPF    | Nome        | Telefones               |
+--------+-------------+-------------------------+
| 123    | João Silva  | 11999999999,1133333333  |
| 456    | Maria Souza | 21888888888             |
| 789    | Pedro Lima  | 31777777777,3144444444  |
+--------+-------------+-------------------------+
```

**Problemas identificados:**
- Atributo `Telefones` é multivalorado (múltiplos valores em uma célula)
- Viola o princípio de atomicidade

### Solução - Normalização para 1FN

#### Opção 1: Repetição de Tuplas
```sql
FUNCIONARIO_1FN_OPCAO1
+--------+-------------+-------------+
| CPF    | Nome        | Telefone    |
+--------+-------------+-------------+
| 123    | João Silva  | 11999999999 |
| 123    | João Silva  | 1133333333  |
| 456    | Maria Souza | 21888888888 |
| 789    | Pedro Lima  | 31777777777 |
| 789    | Pedro Lima  | 3144444444  |
+--------+-------------+-------------+
```

#### Opção 2: Criação de Tabela Separada (Recomendada)
```sql
FUNCIONARIO
+--------+-------------+
| CPF    | Nome        |
+--------+-------------+
| 123    | João Silva  |
| 456    | Maria Souza |
| 789    | Pedro Lima  |
+--------+-------------+

TELEFONE_FUNCIONARIO
+--------+-------------+
| CPF    | Telefone    |
+--------+-------------+
| 123    | 11999999999 |
| 123    | 1133333333  |
| 456    | 21888888888 |
| 789    | 31777777777 |
| 789    | 3144444444  |
+--------+-------------+
```

### Outros Exemplos de Violação da 1FN

```sql
-- Atributo composto (endereço em uma célula)
CLIENTE_VIOLACAO
+------+----------+--------------------------------+
| ID   | Nome     | Endereco                       |
+------+----------+--------------------------------+
| 1    | Ana      | Rua A, 123, Centro, São Paulo  |
+------+----------+--------------------------------+

-- Solução
CLIENTE_1FN
+------+----------+--------+--------+----------+----------+
| ID   | Nome     | Rua    | Numero | Bairro   | Cidade   |
+------+----------+--------+--------+----------+----------+
| 1    | Ana      | Rua A  | 123    | Centro   | São Paulo|
+------+----------+--------+--------+----------+----------+
```

---

## Segunda Forma Normal (2FN)

### Definição
Uma relação está na **2FN** se:
1. Está na 1FN
2. **Não possui dependências funcionais parciais** de atributos não-chave em relação à chave primária

### Dependência Funcional Parcial
Ocorre quando um atributo não-chave depende funcionalmente de apenas **parte** de uma chave primária composta.

### Exemplo - Tabela NÃO está em 2FN

```sql
ITEM_PEDIDO_VIOLACAO_2FN
+------------+------------+---------------+-------------+----------+
| Cod_Pedido | Cod_Produto| Nome_Produto  | Data_Pedido | Qtd      |
+------------+------------+---------------+-------------+----------+
| 001        | P01        | Notebook      | 2024-01-15  | 2        |
| 001        | P02        | Mouse         | 2024-01-15  | 5        |
| 002        | P01        | Notebook      | 2024-01-16  | 1        |
| 002        | P03        | Teclado       | 2024-01-16  | 3        |
+------------+------------+---------------+-------------+----------+

Chave Primária: (Cod_Pedido, Cod_Produto)
```

**Dependências Funcionais Identificadas:**
```
(Cod_Pedido, Cod_Produto) → Qtd                    ✓ Dependência total
Cod_Produto → Nome_Produto                         ✗ Dependência parcial
Cod_Pedido → Data_Pedido                          ✗ Dependência parcial
```

**Problemas:**
- `Nome_Produto` depende apenas de `Cod_Produto`
- `Data_Pedido` depende apenas de `Cod_Pedido`
- Redundância de dados
- Anomalias de inserção, atualização e exclusão

### Solução - Normalização para 2FN

```sql
PEDIDO
+------------+-------------+
| Cod_Pedido | Data_Pedido |
+------------+-------------+
| 001        | 2024-01-15  |
| 002        | 2024-01-16  |
+------------+-------------+

PRODUTO
+------------+---------------+
| Cod_Produto| Nome_Produto  |
+------------+---------------+
| P01        | Notebook      |
| P02        | Mouse         |
| P03        | Teclado       |
+------------+---------------+

ITEM_PEDIDO
+------------+------------+-----+
| Cod_Pedido | Cod_Produto| Qtd |
+------------+------------+-----+
| 001        | P01        | 2   |
| 001        | P02        | 5   |
| 002        | P01        | 1   |
| 002        | P03        | 3   |
+------------+------------+-----+
```

### Vantagens da 2FN
- Eliminação de redundâncias
- Prevenção de anomalias de atualização
- Melhor organização dos dados
- Facilita manutenção

---

## Terceira Forma Normal (3FN)

### Definição
Uma relação está na **3FN** se:
1. Está na 2FN
2. **Não possui dependências funcionais transitivas** de atributos não-chave

### Dependência Funcional Transitiva
Ocorre quando um atributo não-chave depende funcionalmente de outro atributo não-chave.

**Se A → B e B → C, então A → C (transitiva)**

### Exemplo - Tabela NÃO está em 3FN

```sql
FUNCIONARIO_VIOLACAO_3FN
+--------+-------------+----------+---------------+
| CPF    | Nome        | Cod_Dept | Nome_Dept     |
+--------+-------------+----------+---------------+
| 123    | João Silva  | D01      | Vendas        |
| 456    | Maria Souza | D02      | Marketing     |
| 789    | Pedro Lima  | D01      | Vendas        |
| 101    | Ana Costa   | D03      | TI            |
| 102    | Carlos Dias | D02      | Marketing     |
+--------+-------------+----------+---------------+

Chave Primária: CPF
```

**Dependências Funcionais Identificadas:**
```
CPF → Nome, Cod_Dept                    ✓ Dependências diretas
Cod_Dept → Nome_Dept                    ✓ Dependência direta
CPF → Nome_Dept                         ✗ Dependência transitiva
```

**Problemas:**
- `Nome_Dept` depende transitivamente de `CPF` através de `Cod_Dept`
- Redundância: nome do departamento repetido
- Anomalias de atualização e inconsistência

### Solução - Normalização para 3FN

```sql
FUNCIONARIO
+--------+-------------+----------+
| CPF    | Nome        | Cod_Dept |
+--------+-------------+----------+
| 123    | João Silva  | D01      |
| 456    | Maria Souza | D02      |
| 789    | Pedro Lima  | D01      |
| 101    | Ana Costa   | D03      |
| 102    | Carlos Dias | D02      |
+--------+-------------+----------+

DEPARTAMENTO
+----------+---------------+
| Cod_Dept | Nome_Dept     |
+----------+---------------+
| D01      | Vendas        |
| D02      | Marketing     |
| D03      | TI            |
+----------+---------------+
```

### Vantagens da 3FN
- Eliminação de dependências transitivas
- Redução significativa de redundâncias
- Prevenção de anomalias de inserção/atualização/exclusão
- Estrutura mais limpa e organizada

---

## Resumo Comparativo

| Forma Normal | Critério Principal | Problema Eliminado | Exemplo |
|--------------|--------------------|--------------------|---------|
| **1FN** | Valores atômicos | Atributos multivalorados/compostos | Telefones: "11999,11888" |
| **2FN** | Sem dependências parciais | Dependência de parte da chave | Cod_Produto → Nome_Produto |
| **3FN** | Sem dependências transitivas | Dependência entre não-chaves | CPF → Dept → Nome_Dept |

## Processo de Normalização Passo a Passo

### Exemplo Completo

#### Tabela Original (Não Normalizada)
```sql
VENDA_ORIGINAL
+----------+----------+----------+----------+----------+----------+----------+----------+
| Num_Nota | Data     | CPF_Cli  | Nome_Cli | Produtos | Qtd      | Preco    | Total    |
+----------+----------+----------+----------+----------+----------+----------+----------+
| 1001     | 2024-01-15| 111     | João     | P1,P2    | 2,3      | 100,50   | 350      |
| 1002     | 2024-01-16| 222     | Maria    | P1       | 1        | 100      | 100      |
+----------+----------+----------+----------+----------+----------+----------+----------+
```

#### Passo 1: Aplicar 1FN
```sql
VENDA_1FN
+----------+----------+---------+----------+----------+-----+-------+
| Num_Nota | Data     | CPF_Cli | Nome_Cli | Cod_Prod | Qtd | Preco |
+----------+----------+---------+----------+----------+-----+-------+
| 1001     | 2024-01-15| 111    | João     | P1       | 2   | 100   |
| 1001     | 2024-01-15| 111    | João     | P2       | 3   | 50    |
| 1002     | 2024-01-16| 222    | Maria    | P1       | 1   | 100   |
+----------+----------+---------+----------+----------+-----+-------+

Chave Primária: (Num_Nota, Cod_Prod)
```

#### Passo 2: Aplicar 2FN
```sql
NOTA_FISCAL
+----------+----------+---------+----------+
| Num_Nota | Data     | CPF_Cli | Nome_Cli |
+----------+----------+---------+----------+
| 1001     | 2024-01-15| 111    | João     |
| 1002     | 2024-01-16| 222    | Maria    |
+----------+----------+---------+----------+

PRODUTO
+----------+-------+
| Cod_Prod | Preco |
+----------+-------+
| P1       | 100   |
| P2       | 50    |
+----------+-------+

ITEM_NOTA
+----------+----------+-----+
| Num_Nota | Cod_Prod | Qtd |
+----------+----------+-----+
| 1001     | P1       | 2   |
| 1001     | P2       | 3   |
| 1002     | P1       | 1   |
+----------+----------+-----+
```

#### Passo 3: Aplicar 3FN
```sql
NOTA_FISCAL
+----------+----------+---------+
| Num_Nota | Data     | CPF_Cli |
+----------+----------+---------+
| 1001     | 2024-01-15| 111    |
| 1002     | 2024-01-16| 222    |
+----------+----------+---------+

CLIENTE
+---------+----------+
| CPF_Cli | Nome_Cli |
+---------+----------+
| 111     | João     |
| 222     | Maria    |
+---------+----------+

PRODUTO
+----------+-------+
| Cod_Prod | Preco |
+----------+-------+
| P1       | 100   |
| P2       | 50    |
+----------+-------+

ITEM_NOTA
+----------+----------+-----+
| Num_Nota | Cod_Prod | Qtd |
+----------+----------+-----+
| 1001     | P1       | 2   |
| 1001     | P2       | 3   |
| 1002     | P1       | 1   |
+----------+----------+-----+
```

## Benefícios da Normalização até 3FN

1. **Integridade dos Dados**: Redução de inconsistências
2. **Eficiência de Armazenamento**: Eliminação de redundâncias
3. **Facilidade de Manutenção**: Mudanças localizadas
4. **Prevenção de Anomalias**: Inserção, atualização e exclusão
5. **Flexibilidade**: Estrutura adaptável a mudanças