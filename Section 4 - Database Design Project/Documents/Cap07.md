# Dependências Funcionais e Conceitos de Chaves em Banco de Dados

## Dependência Funcional

### Conceito
Uma **dependência funcional** (DF) é uma restrição entre dois conjuntos de atributos em uma relação. Dizemos que existe uma dependência funcional de X para Y (X → Y) se, para cada valor de X, existe um único valor correspondente de Y.

### Notação
- **X → Y**: X determina funcionalmente Y
- **X**: Determinante
- **Y**: Dependente

### Exemplo
```
CPF → Nome, Data_Nascimento
```
Para cada CPF existe um único nome e data de nascimento correspondentes.

---

## Dependência Funcional Parcial

### Conceito
Uma **dependência funcional parcial** ocorre quando um atributo não-chave depende funcionalmente de apenas parte de uma chave primária composta.

### Características
- Só existe quando há chave primária composta
- Atributo depende de parte da chave, não da chave completa
- Viola a 2ª Forma Normal (2FN)

### Exemplo
```sql
PRODUTO_PEDIDO(Cod_Produto, Cod_Pedido, Nome_Produto, Data_Pedido, Quantidade)

Chave Primária: (Cod_Produto, Cod_Pedido)

Dependências Parciais:
- Cod_Produto → Nome_Produto
- Cod_Pedido → Data_Pedido
```

**Nome_Produto** depende apenas de **Cod_Produto**, não da chave completa.

---

## Dependência Funcional Transitiva

### Conceito
Uma **dependência funcional transitiva** ocorre quando um atributo não-chave depende funcionalmente de outro atributo não-chave.

### Características
- Se A → B e B → C, então A → C (transitiva)
- Viola a 3ª Forma Normal (3FN)
- Causa redundância de dados

### Exemplo
```sql
FUNCIONARIO(CPF, Nome, Cod_Depto, Nome_Depto)

Dependências:
- CPF → Nome, Cod_Depto (diretas)
- Cod_Depto → Nome_Depto (direta)
- CPF → Nome_Depto (transitiva)
```

**Nome_Depto** depende transitivamente de **CPF** através de **Cod_Depto**.

---

## Atributos Multivalorados

### Conceito
**Atributos multivalorados** são atributos que podem ter múltiplos valores para uma única entidade.

### Características
- Representados por chaves duplas: {{atributo}}
- Violam a 1ª Forma Normal (1FN)
- Requerem normalização

### Exemplos
```
PESSOA(CPF, Nome, {{Telefone}}, {{Email}})
FUNCIONARIO(ID, Nome, {{Habilidades}})
LIVRO(ISBN, Titulo, {{Autores}})
```

### Solução - Normalização
```sql
-- Antes (não normalizado)
PESSOA(CPF, Nome, Telefones)

-- Depois (normalizado)
PESSOA(CPF, Nome)
TELEFONE(CPF, Numero_Telefone)
```

---

## Atributos Compostos

### Conceito
**Atributos compostos** são atributos formados por vários sub-atributos relacionados.

### Características
- Podem ser divididos em partes menores com significado próprio
- Representam conceitos hierárquicos
- Podem ser armazenados como um todo ou separadamente

### Exemplos
```
Endereco {Rua, Numero, Bairro, Cidade, CEP, Estado}
Nome_Completo {Primeiro_Nome, Nome_Meio, Ultimo_Nome}
Data_Nascimento {Dia, Mes, Ano}
```

### Implementação
```sql
-- Opção 1: Atributos separados
PESSOA(
    CPF,
    Primeiro_Nome,
    Nome_Meio,
    Ultimo_Nome,
    Rua,
    Numero,
    Bairro,
    Cidade,
    CEP,
    Estado
)

-- Opção 2: Como string única
PESSOA(
    CPF,
    Nome_Completo,
    Endereco_Completo
)
```

---

## Atributos Atômicos

### Conceito
**Atributos atômicos** são atributos que não podem ser divididos em partes menores com significado próprio.

### Características
- Indivisíveis no contexto do sistema
- Respeitam a 1ª Forma Normal (1FN)
- Unidade básica de dados

### Exemplos
```
CPF: "123.456.789-00"
Idade: 25
Salario: 5000.00
Status: "Ativo"
```

### Comparação
```sql
-- Atômico
Nome: "João Silva"

-- Composto
Nome: {
    Primeiro: "João",
    Ultimo: "Silva"
}

-- Multivalorado  
Telefones: {"11999999999", "1133333333"}
```

---

## Dependência Funcional Multivalorada

### Conceito
Uma **dependência funcional multivalorada** (DFM) existe quando um atributo determina um conjunto de valores de outro atributo, independentemente de outros atributos.

### Notação
- **X →→ Y**: X multidetermina Y

### Características
- Mais geral que dependência funcional
- Viola a 4ª Forma Normal (4FN)
- Causa redundância

### Exemplo
```sql
PROFESSOR_DISCIPLINA_PROJETO(
    Professor,
    Disciplina, 
    Projeto
)

Dependências Multivaloradas:
- Professor →→ Disciplina
- Professor →→ Projeto
```

Um professor pode lecionar várias disciplinas e participar de vários projetos independentemente.

---

## Dependência Funcional Cíclica

### Conceito
Uma **dependência funcional cíclica** ocorre quando existe um ciclo de dependências funcionais entre atributos.

### Características
- Forma um ciclo: A → B → C → A
- Indica possível problema de modelagem
- Pode causar inconsistências

### Exemplo
```sql
Funcionario → Departamento
Departamento → Gerente  
Gerente → Funcionario
```

### Problemas
- Dificuldade de manutenção
- Inconsistências potenciais
- Complexidade de validação

---

## Chaves: Candidata, Super-Chave e Primária

### Super-Chave
**Conjunto de atributos que identifica unicamente cada tupla em uma relação.**

#### Características
- Pode ter atributos redundantes
- Qualquer superconjunto de uma super-chave também é super-chave

#### Exemplo
```sql
FUNCIONARIO(CPF, RG, Nome, Email)

Super-chaves:
- {CPF}
- {RG}  
- {Email}
- {CPF, Nome}
- {RG, CPF}
- {CPF, RG, Nome, Email}
```

### Chave Candidata
**Super-chave minimal, ou seja, não contém subconjunto próprio que também seja super-chave.**

#### Características
- Minimal (não pode remover atributos)
- Pode haver várias chaves candidatas
- Identificação única garantida

#### Exemplo
```sql
FUNCIONARIO(CPF, RG, Nome, Email)

Chaves Candidatas:
- {CPF}
- {RG}
- {Email}
```

### Chave Primária
**Chave candidata escolhida pelo designer para identificar unicamente as tuplas.**

#### Características
- Única por relação
- Não pode ser NULL
- Valores únicos
- Preferencialmente imutável

#### Critérios de Escolha
1. **Simplicidade**: Menos atributos
2. **Estabilidade**: Valores não mudam
3. **Familiaridade**: Conhecido pelos usuários
4. **Tamanho**: Menor espaço de armazenamento

### Exemplo Completo
```sql
PRODUTO(
    Codigo_Barras,    -- 13 dígitos
    SKU,              -- String única
    Nome,
    Preco
)

Super-chaves:
- {Codigo_Barras}
- {SKU}
- {Codigo_Barras, Nome}
- {SKU, Preco}
- {Codigo_Barras, SKU, Nome, Preco}

Chaves Candidatas:
- {Codigo_Barras}
- {SKU}

Chave Primária: {Codigo_Barras}
(Escolhida por ser padrão internacional e estável)
```

## Resumo das Relações

| Conceito | Definição | Exemplo |
|----------|-----------|---------|
| **DF** | X → Y | CPF → Nome |
| **DF Parcial** | Parte da chave → atributo | Cod_Produto → Nome_Produto |
| **DF Transitiva** | X → Y, Y → Z | CPF → Depto → Nome_Depto |
| **Multivalorado** | Múltiplos valores | {{Telefones}} |
| **Composto** | Subdivisível | Nome{Primeiro, Último} |
| **Atômico** | Indivisível | CPF |
| **DFM** | X →→ Y | Professor →→ Disciplinas |
| **Super-chave** | Identifica unicamente | {CPF, Nome} |
| **Chave Candidata** | Super-chave minimal | {CPF} |
| **Chave Primária** | Candidata escolhida | CPF |