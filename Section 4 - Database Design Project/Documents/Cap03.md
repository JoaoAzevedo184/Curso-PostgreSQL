# Modelo Conceitual - Relacionamentos e Grau de Relacionamento

Os relacionamentos representam as associações ou conexões entre entidades no modelo conceitual. Eles descrevem como as entidades interagem entre si e são fundamentais para capturar a estrutura e as regras de negócio do sistema.

## O que são Relacionamentos?

Um relacionamento é uma associação entre duas ou mais entidades que representa uma interação significativa no mundo real. Ele descreve como as instâncias de diferentes entidades se conectam ou se relacionam.

### Características dos Relacionamentos

- **Conectam entidades**: Estabelecem ligações entre objetos
- **Têm significado semântico**: Representam associações do mundo real
- **Podem ter atributos**: Propriedades específicas da associação
- **Definem regras de negócio**: Estabelecem restrições e comportamentos

### Exemplos de Relacionamentos
- CLIENTE **faz** PEDIDO
- FUNCIONÁRIO **trabalha em** DEPARTAMENTO  
- ALUNO **cursa** DISCIPLINA
- MÉDICO **atende** PACIENTE
- PRODUTO **pertence a** CATEGORIA

## Representação Gráfica

### Notação Padrão do Modelo ER

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   CLIENTE   │────│     faz     │────│   PEDIDO    │
└─────────────┘    └─────────────┘    └─────────────┘
     Entidade        Relacionamento        Entidade
```

### Elementos Visuais

- **Losango**: Representa o relacionamento
- **Linhas**: Conectam entidades ao relacionamento
- **Cardinalidades**: Números ou símbolos nas linhas

## Grau de Relacionamento

O grau de relacionamento indica quantas entidades participam de um relacionamento específico.

### Tipos por Grau

#### 1. Relacionamento Unário (Grau 1)
Uma entidade se relaciona consigo mesma.

```
┌─────────────┐
│ FUNCIONÁRIO │───┐
└─────────────┘   │    ┌─────────────┐
                  └────│   supervisiona │
                       └─────────────┘
```

**Exemplos:**
- FUNCIONÁRIO supervisiona FUNCIONÁRIO
- CATEGORIA contém CATEGORIA (subcategorias)
- PESSOA é casada com PESSOA

#### 2. Relacionamento Binário (Grau 2)
Relacionamento entre duas entidades diferentes (mais comum).

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   CLIENTE   │────│     faz     │────│   PEDIDO    │
└─────────────┘    └─────────────┘    └─────────────┘
```

**Exemplos:**
- CLIENTE faz PEDIDO
- FUNCIONÁRIO trabalha em DEPARTAMENTO
- ALUNO estuda DISCIPLINA

#### 3. Relacionamento Ternário (Grau 3)
Relacionamento entre três entidades.

```
        ┌─────────────┐
        │   PROJETO   │
        └─────────────┘
                │
      ┌─────────────────────┐
      │     trabalha_em     │
      └─────────────────────┘
             │         │
   ┌─────────────┐  ┌─────────────┐
   │ FUNCIONÁRIO │  │ DEPARTAMENTO│
   └─────────────┘  └─────────────┘
```

**Exemplos:**
- FUNCIONÁRIO trabalha em PROJETO para DEPARTAMENTO
- MÉDICO prescreve MEDICAMENTO para PACIENTE
- PROFESSOR ensina DISCIPLINA em TURMA

## Cardinalidade dos Relacionamentos

A cardinalidade especifica quantas instâncias de uma entidade podem estar associadas a quantas instâncias de outra entidade.

### Notações de Cardinalidade

#### Notação Numérica
- **1:1** - Um para Um
- **1:N** - Um para Muitos  
- **N:M** - Muitos para Muitos

#### Notação com Símbolos
- **|** - Um (exatamente um)
- **<** - Muitos
- **O** - Zero
- **||** - Um ou mais

## Um para Um (1:1)

Uma instância da entidade A está associada a no máximo uma instância da entidade B, e vice-versa.

### Características
- Relacionamento mais restritivo
- Cada registro de uma entidade corresponde a apenas um registro da outra
- Pode indicar candidatos a fusão de entidades
- Raro na prática

### Representação Gráfica

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   PESSOA    │──1─│   possui    │─1──│     CPF     │
└─────────────┘    └─────────────┘    └─────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ FUNCIONÁRIO │──1─│    tem      │─1──│   CARTÃO    │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Exemplos Práticos

**Sistema de RH:**
```
FUNCIONÁRIO (1) ──── tem ──── (1) CARTÃO_ACESSO
- Cada funcionário tem exatamente um cartão
- Cada cartão pertence a exatamente um funcionário
```

**Sistema Governamental:**
```
PESSOA (1) ──── possui ──── (1) CPF
- Cada pessoa tem exatamente um CPF
- Cada CPF pertence a exatamente uma pessoa
```

**Sistema Escolar:**
```
TURMA (1) ──── tem ──── (1) MONITOR
- Cada turma tem no máximo um monitor
- Cada monitor é responsável por apenas uma turma
```

### Implementação Lógica

No modelo lógico, relacionamentos 1:1 podem ser implementados de três formas:

1. **Chave estrangeira na entidade A**
2. **Chave estrangeira na entidade B**  
3. **Fusão das entidades** (se fizer sentido semântico)

## Um para Muitos (1:N)

Uma instância da entidade A pode estar associada a várias instâncias da entidade B, mas uma instância de B está associada a apenas uma instância de A.

### Características
- Tipo mais comum de relacionamento
- Estabelece hierarquia ou dependência
- O lado "1" geralmente representa a entidade principal
- O lado "N" representa entidades dependentes

### Representação Gráfica

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   CLIENTE   │──1─│     faz     │─N──│   PEDIDO    │
└─────────────┘    └─────────────┘    └─────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ DEPARTAMENTO│──1─│   possui    │─N──│ FUNCIONÁRIO │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Exemplos Práticos

**Sistema de E-commerce:**
```
CLIENTE (1) ──── faz ──── (N) PEDIDO
- Um cliente pode fazer vários pedidos
- Cada pedido é feito por apenas um cliente
```

**Sistema Corporativo:**
```
DEPARTAMENTO (1) ──── possui ──── (N) FUNCIONÁRIO
- Um departamento tem vários funcionários
- Cada funcionário pertence a apenas um departamento
```

**Sistema Educacional:**
```
PROFESSOR (1) ──── leciona ──── (N) DISCIPLINA
- Um professor pode lecionar várias disciplinas
- Cada disciplina é lecionada por apenas um professor
```

**Sistema Bibliotecário:**
```
CATEGORIA (1) ──── contém ──── (N) LIVRO
- Uma categoria pode ter vários livros
- Cada livro pertence a apenas uma categoria
```

### Implementação Lógica

No modelo lógico, implementa-se com chave estrangeira na entidade do lado "N":

```sql
-- Tabela do lado "1"
CLIENTE (id_cliente, nome, email)

-- Tabela do lado "N" com chave estrangeira
PEDIDO (id_pedido, data_pedido, id_cliente*)
```

## Muitos para Muitos (N:M)

Uma instância da entidade A pode estar associada a várias instâncias da entidade B, e uma instância de B pode estar associada a várias instâncias de A.

### Características
- Relacionamento mais complexo
- Requer resolução no modelo lógico
- Frequentemente possui atributos próprios
- Gera entidade associativa

### Representação Gráfica

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   ALUNO     │──N─│   cursa     │─M──│ DISCIPLINA  │
└─────────────┘    └─────────────┘    └─────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   PRODUTO   │──N─│   compõe    │─M──│   PEDIDO    │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Exemplos Práticos

**Sistema Acadêmico:**
```
ALUNO (N) ──── cursa ──── (M) DISCIPLINA
- Um aluno pode cursar várias disciplinas
- Uma disciplina pode ser cursada por vários alunos
- Atributos: nota, frequência, data_matrícula
```

**Sistema de E-commerce:**
```
PRODUTO (N) ──── compõe ──── (M) PEDIDO
- Um produto pode estar em vários pedidos
- Um pedido pode conter vários produtos
- Atributos: quantidade, preço_unitário, desconto
```

**Sistema Médico:**
```
MÉDICO (N) ──── atende ──── (M) PACIENTE
- Um médico pode atender vários pacientes
- Um paciente pode ser atendido por vários médicos
- Atributos: data_consulta, diagnóstico, receita
```

**Sistema de Projetos:**
```
FUNCIONÁRIO (N) ──── trabalha_em ──── (M) PROJETO
- Um funcionário pode trabalhar em vários projetos
- Um projeto pode ter vários funcionários
- Atributos: horas_trabalhadas, função, data_início
```

### Resolução no Modelo Lógico

Relacionamentos N:M são decompostos em duas relações 1:N usando uma tabela associativa:

```sql
-- Entidades originais
ALUNO (id_aluno, nome, cpf)
DISCIPLINA (id_disciplina, nome, carga_horaria)

-- Tabela associativa (entidade fraca)
MATRICULA (
    id_aluno*,        -- Chave estrangeira
    id_disciplina*,   -- Chave estrangeira  
    nota,             -- Atributo do relacionamento
    frequencia,       -- Atributo do relacionamento
    data_matricula    -- Atributo do relacionamento
)
```

## Atributos de Relacionamentos

Relacionamentos podem ter atributos próprios que não pertencem a nenhuma das entidades participantes.

### Quando Usar Atributos em Relacionamentos

1. **Informação específica da associação**
2. **Dados que só fazem sentido quando as entidades estão relacionadas**
3. **Propriedades temporais da relação**
4. **Métricas da interação**

### Exemplos por Cardinalidade

#### Relacionamento 1:1 com Atributo
```
FUNCIONÁRIO (1) ──── supervisiona ──── (1) FUNCIONÁRIO
Atributos: data_início_supervisão
```

#### Relacionamento 1:N com Atributo
```
CLIENTE (1) ──── faz ──── (N) PEDIDO
Atributos: data_pedido, forma_pagamento
```

#### Relacionamento N:M com Atributos
```
ATOR (N) ──── atua_em ──── (M) FILME
Atributos: personagem, salário, data_gravação
```

## Participação em Relacionamentos

### Participação Total vs Parcial

#### Participação Total (Obrigatória)
Toda instância da entidade deve participar do relacionamento.

```
┌─────────────┐    ┌═════════════┐    ┌─────────────┐
│   PEDIDO    │────║    contém   ║────│   PRODUTO   │
└─────────────┘    ╚═════════════╝    └─────────────┘
```

**Exemplo:** Todo PEDIDO deve conter pelo menos um PRODUTO.

#### Participação Parcial (Opcional)  
Nem toda instância da entidade precisa participar do relacionamento.

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ FUNCIONÁRIO │────│ supervisiona│────│ FUNCIONÁRIO │
└─────────────┘    └─────────────┘    └─────────────┘
```

**Exemplo:** Nem todo FUNCIONÁRIO supervisiona outro funcionário.

## Relacionamentos Recursivos

Relacionamentos onde uma entidade se relaciona consigo mesma.

### Tipos de Relacionamentos Recursivos

#### 1:1 Recursivo
```
PESSOA (1) ──── é_casada_com ──── (1) PESSOA
```

#### 1:N Recursivo
```
FUNCIONÁRIO (1) ──── supervisiona ──── (N) FUNCIONÁRIO
CATEGORIA (1) ──── contém ──── (N) CATEGORIA
```

#### N:M Recursivo
```
PRODUTO (N) ──── é_compatível_com ──── (M) PRODUTO
PESSOA (N) ──── é_amiga_de ──── (M) PESSOA
```

### Implementação de Relacionamentos Recursivos

```sql
-- 1:N Recursivo - Supervisão
FUNCIONÁRIO (
    id_funcionario,
    nome,
    id_supervisor*  -- Referencia outro funcionário
)

-- N:M Recursivo - Compatibilidade de Produtos
PRODUTO (id_produto, nome, preco)

COMPATIBILIDADE (
    id_produto1*,  -- Referencia produto
    id_produto2*,  -- Referencia produto
    tipo_compatibilidade
)
```

## Relacionamentos Ternários e N-ários

### Relacionamentos Ternários

Envolvem três entidades simultaneamente e não podem ser decompostos em relacionamentos binários sem perda semântica.

```
         PROJETO
            │
    ┌───────┼───────┐
    │   ALOCAÇÃO    │
    │               │
FUNCIONÁRIO ─────── DEPARTAMENTO
```

**Exemplo:** FUNCIONÁRIO trabalha em PROJETO pelo DEPARTAMENTO.

### Quando Usar Relacionamentos Ternários

1. **Semântica não pode ser preservada** com relacionamentos binários
2. **As três entidades são necessárias** para definir a associação
3. **Não há como decompor** sem perda de informação

### Implementação de Relacionamentos Ternários

```sql
ALOCACAO (
    id_funcionario*,  -- FK para FUNCIONÁRIO
    id_projeto*,      -- FK para PROJETO  
    id_departamento*, -- FK para DEPARTAMENTO
    horas_semanais,   -- Atributo do relacionamento
    data_inicio       -- Atributo do relacionamento
)
```

## Validação de Relacionamentos

### Checklist de Validação

1. **Semântica**
   - [ ] O relacionamento faz sentido no mundo real?
   - [ ] O nome do relacionamento é descritivo?
   - [ ] A cardinalidade está correta?

2. **Necessidade**
   - [ ] O relacionamento é realmente necessário?
   - [ ] Não é redundante com outros relacionamentos?
   - [ ] Adiciona valor ao modelo?

3. **Completude**
   - [ ] Todos os relacionamentos importantes foram identificados?
   - [ ] As participações estão corretas (total/parcial)?
   - [ ] Os atributos de relacionamento são adequados?

## Padrões Comuns de Relacionamentos

### Padrões por Domínio

#### Sistema de Vendas
```
CLIENTE (1) ──── faz ──── (N) PEDIDO
PEDIDO (N) ──── contém ──── (M) PRODUTO
PRODUTO (N) ──── pertence_a ──── (1) CATEGORIA
```

#### Sistema Acadêmico
```
ALUNO (N) ──── cursa ──── (M) DISCIPLINA
PROFESSOR (1) ──── leciona ──── (N) DISCIPLINA
DISCIPLINA (N) ──── pertence_a ──── (1) CURSO
```

#### Sistema Hospitalar
```
MÉDICO (N) ──── atende ──── (M) PACIENTE
PACIENTE (1) ──── faz ──── (N) CONSULTA
MÉDICO (1) ──── prescreve ──── (N) RECEITA
```

## Evolução dos Relacionamentos

### Refinamento Durante a Modelagem

1. **Identificação Inicial**
   - Relacionamentos óbvios
   - Cardinalidades básicas

2. **Refinamento**
   - Atributos de relacionamentos
   - Participações (total/parcial)
   - Relacionamentos complexos

3. **Validação Final**
   - Verificação semântica
   - Completude do modelo
   - Consistência com requisitos

## Ferramentas e Notações

### Notações Alternativas

#### Notação de Pé de Galinha (Crow's Foot)
```
CLIENTE ||──o{ PEDIDO
PEDIDO }o──o{ PRODUTO
```

#### Notação UML
```
Cliente [1] ←──→ [*] Pedido
Pedido [*] ←──→ [*] Produto
```

#### Notação de Martin
```
CLIENTE ──────< PEDIDO
PEDIDO >──────< PRODUTO  
```

## Boas Práticas

### Nomenclatura de Relacionamentos

1. **Use verbos descritivos**
   - "possui", "contém", "pertence_a"
   - Evite verbos genéricos como "tem"

2. **Seja consistente**
   - Mantenha padrão de nomenclatura
   - Use mesma linguagem (português/inglês)

3. **Seja específico**
   - "leciona" ao invés de "ensina"
   - "supervisiona" ao invés de "gerencia"

### Modelagem de Relacionamentos

1. **Comece simples**
   - Identifique relacionamentos principais
   - Refine gradualmente

2. **Valide constantemente**
   - Confirme com stakeholders
   - Teste com cenários reais

3. **Documente decisões**
   - Justifique cardinalidades
   - Explique relacionamentos complexos

4. **Considere performance**
   - Relacionamentos N:M são mais custosos
   - Pense na implementação física

## Conclusão

Os relacionamentos são elementos cruciais do modelo conceitual que capturam as interações entre entidades. A compreensão correta das cardinalidades (1:1, 1:N, N:M) e a identificação adequada dos relacionamentos são fundamentais para criar um modelo que reflita fielmente as regras de negócio e sirva como base sólida para a implementação do banco de dados.

A progressão do modelo conceitual com relacionamentos bem definidos facilita enormemente a conversão para o modelo lógico e, posteriormente, para a implementação física no PostgreSQL ou qualquer outro SGBD.
