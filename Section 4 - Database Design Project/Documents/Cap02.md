# Modelo Conceitual - Entidades

As entidades são os elementos fundamentais do modelo conceitual de banco de dados. Elas representam objetos, pessoas, lugares ou conceitos do mundo real que possuem relevância para o sistema e sobre os quais desejamos armazenar informações.

## O que são Entidades?

Uma entidade é qualquer objeto distinguível do mundo real sobre o qual queremos manter informações no banco de dados. Ela deve ter:

- **Existência independente**: Pode existir por si só
- **Identidade única**: Pode ser distinguida de outras entidades
- **Relevância para o negócio**: Tem importância para o sistema
- **Conjunto de propriedades**: Possui características que a descrevem

### Exemplos de Entidades
- **CLIENTE**: Pessoa que compra produtos
- **PRODUTO**: Item vendido pela empresa
- **PEDIDO**: Solicitação de compra feita por um cliente
- **FUNCIONÁRIO**: Pessoa que trabalha na empresa
- **FORNECEDOR**: Empresa que fornece produtos

## Tipos de Entidades

### 1. Entidades Fortes (Regulares)

Entidades que possuem existência independente e podem ser identificadas por seus próprios atributos.

**Características:**
- Possuem chave primária própria
- Não dependem de outras entidades para existir
- Representadas por retângulos simples no DER

**Exemplos:**
```
CLIENTE
- Possui CPF (chave primária)
- Existe independentemente

PRODUTO  
- Possui código do produto (chave primária)
- Existe independentemente
```

### 2. Entidades Fracas (Dependentes)

Entidades que não possuem atributos suficientes para formar uma chave primária própria e dependem de outras entidades para sua identificação.

**Características:**
- Não possuem chave primária independente
- Dependem de entidade forte (proprietária)
- Identificadas pela combinação de seus atributos + chave da entidade forte
- Representadas por retângulos duplos no DER

**Exemplos:**
```
DEPENDENTE (entidade fraca)
- Depende de FUNCIONÁRIO (entidade forte)
- Identificado por: nome_dependente + cpf_funcionario

ITEM_PEDIDO (entidade fraca)
- Depende de PEDIDO (entidade forte)  
- Identificado por: numero_item + numero_pedido
```

### 3. Entidades Associativas

Surgem quando um relacionamento muitos-para-muitos (N:M) precisa ter atributos próprios.

**Características:**
- Originam-se de relacionamentos N:M
- Possuem atributos próprios além das chaves estrangeiras
- Podem se relacionar com outras entidades

**Exemplos:**
```
MATRÍCULA (entidade associativa)
- Surge do relacionamento ALUNO-DISCIPLINA
- Atributos próprios: data_matricula, nota, frequencia

ITEM_PEDIDO (entidade associativa)
- Surge do relacionamento PEDIDO-PRODUTO
- Atributos próprios: quantidade, preco_unitario, desconto
```

## Identificação de Entidades

### Critérios para Identificar Entidades

1. **Substantivos importantes** no domínio do problema
2. **Objetos sobre os quais precisamos manter informações**
3. **Elementos que possuem ciclo de vida próprio**
4. **Conceitos que podem ser contados ou enumerados**

### Processo de Identificação

1. **Análise dos Requisitos**
   - Leia os requisitos do sistema
   - Identifique substantivos importantes
   - Verifique se são relevantes para o negócio

2. **Aplicação de Critérios**
   - É algo sobre o qual queremos manter dados?
   - Possui identidade própria?
   - É relevante para o sistema?
   - Pode ser distinguido de outros objetos?

3. **Validação**
   - Confirme com stakeholders
   - Verifique se faz sentido no contexto
   - Elimine redundâncias

### Exemplo Prático - Sistema de Biblioteca

**Requisitos:**
"A biblioteca empresta livros para usuários. Cada livro tem título, autor e ISBN. Os usuários têm nome, CPF e endereço. Cada empréstimo registra data de empréstimo e data de devolução."

**Identificação de Entidades:**

1. **USUÁRIO**
   - Substantivo importante: ✓
   - Mantemos informações: ✓ (nome, CPF, endereço)
   - Identidade própria: ✓ (CPF)
   - Relevante: ✓

2. **LIVRO**
   - Substantivo importante: ✓
   - Mantemos informações: ✓ (título, autor, ISBN)
   - Identidade própria: ✓ (ISBN)
   - Relevante: ✓

3. **EMPRÉSTIMO**
   - Substantivo importante: ✓
   - Mantemos informações: ✓ (datas)
   - Identidade própria: ✓ (usuário + livro + data)
   - Relevante: ✓

## Representação Gráfica

### Notação Padrão do Modelo ER

```
┌─────────────┐
│   CLIENTE   │  ← Entidade Forte
└─────────────┘

╔═════════════╗
║ DEPENDENTE  ║  ← Entidade Fraca
╚═════════════╝

┌─────────────┐
│  MATRÍCULA  │  ← Entidade Associativa
└─────────────┘
```

### Exemplo Visual Completo

```
Sistema de E-commerce:

┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   CLIENTE   │      │   PEDIDO    │      │   PRODUTO   │
└─────────────┘      └─────────────┘      └─────────────┘

╔═════════════╗      ┌─────────────┐
║  ENDEREÇO   ║      │ ITEM_PEDIDO │
╚═════════════╝      └─────────────┘
```

## Atributos das Entidades

### Classificação dos Atributos

1. **Atributos Simples**
   - Não podem ser subdivididos
   - Exemplo: CPF, data_nascimento

2. **Atributos Compostos**
   - Podem ser subdivididos em partes menores
   - Exemplo: endereço (rua, cidade, CEP)

3. **Atributos Multivalorados**
   - Podem ter múltiplos valores
   - Exemplo: telefones, emails

4. **Atributos Derivados**
   - Calculados a partir de outros atributos
   - Exemplo: idade (calculada a partir da data_nascimento)

### Exemplo de Entidade com Atributos

```
FUNCIONÁRIO
├── cpf (simples, chave)
├── nome (simples)
├── endereco (composto)
│   ├── rua
│   ├── cidade
│   ├── cep
│   └── estado
├── telefones (multivalorado)
├── data_nascimento (simples)
└── idade (derivado)
```

## Regras de Negócio e Entidades

### Restrições de Integridade

1. **Integridade de Entidade**
   - Cada entidade deve ter um identificador único
   - Não pode haver valores nulos na chave primária

2. **Integridade de Domínio**
   - Valores dos atributos devem estar dentro do domínio permitido
   - Exemplo: idade deve ser um número positivo

3. **Regras Específicas do Negócio**
   - Idade mínima para ser cliente
   - Limite de produtos por categoria
   - Validações específicas do domínio

### Exemplo de Regras

```
CLIENTE
- CPF deve ser único e válido
- Idade mínima: 18 anos
- Email deve ser único no sistema

PRODUTO
- Código deve ser único
- Preço deve ser maior que zero
- Categoria deve existir no sistema
```

## Validação de Entidades

### Checklist de Validação

1. **Necessidade**
   - [ ] A entidade é realmente necessária?
   - [ ] Representa algo importante para o negócio?
   - [ ] Não é apenas um atributo de outra entidade?

2. **Identificação**
   - [ ] Possui identificador único?
   - [ ] Pode ser distinguida de outras entidades?
   - [ ] Tem existência independente (se for forte)?

3. **Atributos**
   - [ ] Possui atributos suficientes?
   - [ ] Os atributos são relevantes?
   - [ ] Não há atributos que deveriam ser entidades?

4. **Relacionamentos**
   - [ ] Se relaciona com outras entidades?
   - [ ] Os relacionamentos fazem sentido?
   - [ ] Não está isolada do modelo?

## Exemplos Práticos por Domínio

### Sistema Acadêmico
```
ALUNO, PROFESSOR, DISCIPLINA, TURMA, MATRÍCULA, CURSO, DEPARTAMENTO
```

### Sistema Hospitalar
```
PACIENTE, MÉDICO, CONSULTA, EXAME, MEDICAMENTO, PRESCRIÇÃO, INTERNAÇÃO
```

### Sistema Bancário
```
CLIENTE, CONTA, TRANSAÇÃO, AGÊNCIA, CARTÃO, EMPRÉSTIMO, INVESTIMENTO
```

### Sistema de RH
```
FUNCIONÁRIO, CARGO, DEPARTAMENTO, PROJETO, ALOCAÇÃO, BENEFÍCIO, FOLHA_PAGAMENTO
```

## Evolução das Entidades

### Refinamento do Modelo

1. **Primeira Versão**
   - Identifique entidades principais
   - Foque no essencial

2. **Refinamento**
   - Adicione detalhes
   - Considere casos especiais
   - Valide com stakeholders

3. **Versão Final**
   - Modelo completo e validado
   - Pronto para conversão para modelo lógico

### Exemplo de Evolução

**Versão 1:**
```
CLIENTE, PRODUTO, PEDIDO
```

**Versão 2:**
```
CLIENTE, PRODUTO, PEDIDO, CATEGORIA, FORNECEDOR
```

**Versão 3:**
```
CLIENTE, PRODUTO, PEDIDO, CATEGORIA, FORNECEDOR, 
ENDEREÇO, ITEM_PEDIDO, PAGAMENTO
```

## Ferramentas de Modelagem

### Ferramentas Recomendadas

1. **MySQL Workbench**
   - Gratuita e completa
   - Suporte a engenharia reversa
   - Geração de código SQL

2. **Lucidchart**
   - Colaborativa
   - Interface intuitiva
   - Compartilhamento fácil

3. **Draw.io / Diagrams.net**
   - Gratuita
   - Baseada na web
   - Muitos templates

4. **dbdiagram.io**
   - Especializada em banco de dados
   - Sintaxe simples
   - Compartilhamento online

## Boas Práticas

1. **Nomenclatura**
   - Use nomes descritivos e significativos
   - Mantenha consistência (singular/plural)
   - Evite abreviações obscuras

2. **Granularidade**
   - Não seja muito genérico nem muito específico
   - Encontre o nível adequado de detalhamento
   - Considere a evolução futura

3. **Validação**
   - Valide com stakeholders regularmente
   - Documente decisões importantes
   - Mantenha rastreabilidade com requisitos

4. **Simplicidade**
   - Comece simples e evolua
   - Evite complexidade desnecessária
   - Foque no que é realmente importante

## Conclusão

As entidades são a base do modelo conceitual e representam os objetos centrais do sistema de informação. Sua identificação correta é fundamental para o sucesso do projeto de banco de dados. A análise cuidadosa dos requisitos, aplicação de critérios sistemáticos e validação contínua com stakeholders são essenciais para criar um modelo conceitual robusto e que atenda às necessidades do negócio.