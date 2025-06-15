# Modelo Conceitual - Multiplicidade e Relacionamentos Condicionais

A multiplicidade e os relacionamentos condicionais são conceitos avançados do modelo conceitual que permitem expressar com maior precisão as regras de negócio e restrições do mundo real. Eles complementam as cardinalidades básicas oferecendo maior flexibilidade e expressividade na modelagem.

## Multiplicidade

A multiplicidade especifica com mais precisão quantas instâncias de uma entidade podem participar de um relacionamento, indo além das cardinalidades básicas (1:1, 1:N, N:M).

### Conceito de Multiplicidade

A multiplicidade define o **número mínimo** e **número máximo** de instâncias que podem participar de um relacionamento, expressa na forma `(min, max)`.

### Notação de Multiplicidade

#### Formato Padrão
```
(mínimo, máximo)
```

#### Exemplos de Notação
- `(0,1)` - Zero ou um
- `(1,1)` - Exatamente um (obrigatório)
- `(0,*)` - Zero ou muitos
- `(1,*)` - Um ou muitos (pelo menos um)
- `(2,5)` - Entre dois e cinco
- `(3,3)` - Exatamente três

### Representação Gráfica

```
┌─────────────┐  (1,1)  ┌─────────────┐  (0,*)  ┌─────────────┐
│   CLIENTE   │─────────│   possui    │─────────│   ENDEREÇO  │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Interpretação:**
- Cada cliente possui exatamente um endereço principal
- Um endereço pode não estar associado a cliente ou estar associado a vários clientes

## Exemplos Detalhados de Multiplicidade

### Sistema de E-commerce

#### Cliente e Pedidos
```
┌─────────────┐  (1,1)  ┌─────────────┐  (0,*)  ┌─────────────┐
│   CLIENTE   │─────────│     faz     │─────────│   PEDIDO    │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Regras:**
- Cada pedido deve ter exatamente um cliente `(1,1)`
- Um cliente pode ter zero ou muitos pedidos `(0,*)`

#### Pedido e Produtos
```
┌─────────────┐  (1,*)  ┌─────────────┐  (1,*)  ┌─────────────┐
│   PEDIDO    │─────────│   contém    │─────────│   PRODUTO   │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Regras:**
- Cada pedido deve conter pelo menos um produto `(1,*)`
- Cada produto deve estar em pelo menos um pedido `(1,*)`

### Sistema Acadêmico

#### Professor e Disciplinas
```
┌─────────────┐  (1,1)  ┌─────────────┐  (1,5)  ┌─────────────┐
│ DISCIPLINA  │─────────│   leciona   │─────────│  PROFESSOR  │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Regras:**
- Cada disciplina tem exatamente um professor responsável `(1,1)`
- Cada professor leciona entre 1 e 5 disciplinas `(1,5)`

#### Aluno e Matrícula
```
┌─────────────┐  (1,1)  ┌─────────────┐  (3,8)  ┌─────────────┐
│  MATRÍCULA  │─────────│   pertence  │─────────│    ALUNO    │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Regras:**
- Cada matrícula pertence a exatamente um aluno `(1,1)`
- Cada aluno deve ter entre 3 e 8 matrículas por semestre `(3,8)`

### Sistema Corporativo

#### Funcionário e Projetos
```
┌─────────────┐  (1,3)  ┌─────────────┐  (5,20) ┌─────────────┐
│ FUNCIONÁRIO │─────────│trabalha_em  │─────────│   PROJETO   │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Regras:**
- Cada funcionário trabalha em 1 a 3 projetos `(1,3)`
- Cada projeto tem entre 5 e 20 funcionários `(5,20)`

## Relacionamentos Condicionais

Relacionamentos condicionais são aqueles que existem apenas sob certas condições ou circunstâncias específicas. Eles permitem modelar situações onde a participação em um relacionamento depende de atributos ou estados específicos das entidades.

### Características dos Relacionamentos Condicionais

- **Dependem de condições**: Só existem quando certas condições são atendidas
- **Maior flexibilidade**: Permitem modelar regras de negócio complexas
- **Expressividade**: Capturam nuances do mundo real
- **Restrições específicas**: Incorporam lógica de negócio no modelo

### Notação de Relacionamentos Condicionais

#### Usando Restrições Textuais
```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│ FUNCIONÁRIO │─────────│ supervisiona│─────────│ FUNCIONÁRIO │
└─────────────┘         └─────────────┘         └─────────────┘
                         [se cargo = 'Gerente']
```

#### Usando Símbolos Especiais
```
┌─────────────┐    C    ┌─────────────┐         ┌─────────────┐
│   CLIENTE   │─────────│   possui    │─────────│ CARTÃO_VIP  │
└─────────────┘         └─────────────┘         └─────────────┘
```

### Exemplos de Relacionamentos Condicionais

#### Sistema de Vendas - Cliente VIP

```
┌─────────────┐  (0,1)  ┌─────────────┐  (1,1)  ┌─────────────┐
│   CLIENTE   │─────────│   possui    │─────────│ CARTÃO_VIP  │
└─────────────┘         └─────────────┘         └─────────────┘
                    [se total_compras > 10000]
```

**Condição:** Cliente só possui cartão VIP se total de compras > R$ 10.000

#### Sistema Bancário - Conta Premium

```
┌─────────────┐  (0,1)  ┌─────────────┐  (1,1)  ┌─────────────┐
│   CLIENTE   │─────────│     tem     │─────────│CONTA_PREMIUM│
└─────────────┘         └─────────────┘         └─────────────┘
                      [se saldo > 50000]
```

**Condição:** Conta premium só existe se saldo > R$ 50.000

#### Sistema de RH - Supervisor

```
┌─────────────┐  (0,*)  ┌─────────────┐  (0,1)  ┌─────────────┐
│ FUNCIONÁRIO │─────────│ supervisiona│─────────│ FUNCIONÁRIO │
└─────────────┘         └─────────────┘         └─────────────┘
                    [se cargo in ('Gerente', 'Coordenador')]
```

**Condição:** Só funcionários com cargo de Gerente ou Coordenador podem supervisionar

#### Sistema Educacional - Monitor

```
┌─────────────┐  (0,1)  ┌─────────────┐  (1,1)  ┌─────────────┐
│    ALUNO    │─────────│   monitora  │─────────│ DISCIPLINA  │
└─────────────┘         └─────────────┘         └─────────────┘
                     [se CRA >= 8.0 e já cursou]
```

**Condição:** Aluno só pode ser monitor se CRA ≥ 8.0 e já cursou a disciplina

### Tipos de Condições

#### 1. Condições de Atributo
Baseadas em valores específicos de atributos.

```
FUNCIONÁRIO supervisiona FUNCIONÁRIO
[se salario > 5000]
```

#### 2. Condições de Estado
Baseadas no estado ou situação da entidade.

```
PRODUTO está_em PROMOÇÃO
[se data_validade < CURRENT_DATE + 30]
```

#### 3. Condições Compostas
Combinam múltiplas condições.

```
CLIENTE possui DESCONTO_ESPECIAL
[se (idade > 60 OR total_compras > 5000) AND ativo = TRUE]
```

#### 4. Condições Temporais
Baseadas em períodos ou datas específicas.

```
FUNCIONÁRIO trabalha_em PROJETO_ESPECIAL
[se data_inicio BETWEEN '2024-01-01' AND '2024-12-31']
```

## Relacionamentos Incondicionais

Relacionamentos incondicionais são aqueles que sempre existem, independentemente de condições específicas. Eles representam associações fundamentais e permanentes entre entidades.

### Características dos Relacionamentos Incondicionais

- **Sempre válidos**: Existem independentemente de condições
- **Fundamentais**: Representam associações básicas do domínio
- **Estáveis**: Não mudam com base em estados das entidades
- **Obrigatórios**: Geralmente têm participação total

### Exemplos de Relacionamentos Incondicionais

#### Sistema de Vendas

```
┌─────────────┐  (1,1)  ┌─────────────┐  (0,*)  ┌─────────────┐
│   PEDIDO    │─────────│pertence_a   │─────────│   CLIENTE   │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Sempre válido:** Todo pedido sempre pertence a um cliente

#### Sistema de RH

```
┌─────────────┐  (1,1)  ┌─────────────┐  (1,*)  ┌─────────────┐
│ FUNCIONÁRIO │─────────│trabalha_em  │─────────│DEPARTAMENTO │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Sempre válido:** Todo funcionário sempre trabalha em um departamento

#### Sistema Acadêmico

```
┌─────────────┐  (1,1)  ┌─────────────┐  (1,*)  ┌─────────────┐
│ DISCIPLINA  │─────────│pertence_a   │─────────│    CURSO    │
└─────────────┘         └─────────────┘         └─────────────┘
```

**Sempre válido:** Toda disciplina sempre pertence a um curso

## Comparação: Condicionais vs Incondicionais

### Relacionamentos Condicionais

| Característica | Descrição |
|----------------|-----------|
| **Existência** | Dependem de condições específicas |
| **Estabilidade** | Podem aparecer/desaparecer ao longo do tempo |
| **Complexidade** | Mais complexos de implementar |
| **Flexibilidade** | Alta flexibilidade para regras de negócio |
| **Exemplo** | Cliente possui Cartão VIP (se compras > 10k) |

### Relacionamentos Incondicionais

| Característica | Descrição |
|----------------|-----------|
| **Existência** | Sempre existem |
| **Estabilidade** | Estáveis e permanentes |
| **Complexidade** | Simples de implementar |
| **Flexibilidade** | Menos flexíveis, mais rígidos |
| **Exemplo** | Pedido pertence a Cliente (sempre) |

## Implementação no Modelo Lógico

### Relacionamentos Condicionais

#### Usando Triggers
```sql
-- Tabela principal
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    total_compras DECIMAL(10,2)
);

-- Tabela condicional
CREATE TABLE cartao_vip (
    id_cartao SERIAL PRIMARY KEY,
    id_cliente INTEGER REFERENCES cliente(id_cliente),
    data_emissao DATE,
    beneficios TEXT
);

-- Trigger para garantir condição
CREATE OR REPLACE FUNCTION check_cartao_vip()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT total_compras FROM cliente WHERE id_cliente = NEW.id_cliente) <= 10000 THEN
        RAISE EXCEPTION 'Cliente não elegível para cartão VIP';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_cartao_vip
    BEFORE INSERT OR UPDATE ON cartao_vip
    FOR EACH ROW EXECUTE FUNCTION check_cartao_vip();
```

#### Usando Constraints
```sql
-- Constraint de verificação
ALTER TABLE funcionario 
ADD CONSTRAINT check_supervisor 
CHECK (
    cargo NOT IN ('Gerente', 'Coordenador') OR 
    id_supervisor IS NOT NULL
);
```

### Relacionamentos Incondicionais

#### Implementação Direta
```sql
-- Sempre obrigatório
CREATE TABLE pedido (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL REFERENCES cliente(id_cliente),
    data_pedido DATE NOT NULL
);

-- Constraint de integridade referencial garante a incondicionalidade
```

## Multiplicidade Avançada

### Multiplicidade Condicional

A multiplicidade também pode ser condicional, variando de acordo com circunstâncias específicas.

#### Exemplo: Sistema de Turmas

```
┌─────────────┐  (20,30|15,25)  ┌─────────────┐  (1,1)  ┌─────────────┐
│    ALUNO    │─────────────────│   estuda_em │─────────│    TURMA    │
└─────────────┘                 └─────────────┘         └─────────────┘
```

**Interpretação:**
- Turma regular: 20-30 alunos
- Turma especial: 15-25 alunos
- Condição: Depende do tipo da turma

#### Implementação com Multiplicidade Condicional

```sql
CREATE TABLE turma (
    id_turma SERIAL PRIMARY KEY,
    tipo_turma VARCHAR(20) CHECK (tipo_turma IN ('regular', 'especial')),
    qtd_alunos INTEGER
);

-- Trigger para validar multiplicidade condicional
CREATE OR REPLACE FUNCTION check_multiplicidade_turma()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo_turma = 'regular' AND (NEW.qtd_alunos < 20 OR NEW.qtd_alunos > 30) THEN
        RAISE EXCEPTION 'Turma regular deve ter entre 20 e 30 alunos';
    END IF;
    
    IF NEW.tipo_turma = 'especial' AND (NEW.qtd_alunos < 15 OR NEW.qtd_alunos > 25) THEN
        RAISE EXCEPTION 'Turma especial deve ter entre 15 e 25 alunos';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## Padrões Comuns de Multiplicidade

### Padrão 1: Hierarquia Organizacional
```
┌─────────────┐  (0,1)  ┌─────────────┐  (0,10) ┌─────────────┐
│ FUNCIONÁRIO │─────────│ supervisiona│─────────│ FUNCIONÁRIO │
└─────────────┘         └─────────────┘         └─────────────┘
```

### Padrão 2: Composição com Limites
```
┌─────────────┐  (1,1)  ┌─────────────┐  (1,50) ┌─────────────┐
│   PEDIDO    │─────────│   contém    │─────────│    ITEM     │
└─────────────┘         └─────────────┘         └─────────────┘
```

### Padrão 3: Relacionamento Opcional com Limite
```
┌─────────────┐  (0,3)  ┌─────────────┐  (1,1)  ┌─────────────┐
│   CLIENTE   │─────────│   possui    │─────────│   TELEFONE  │
└─────────────┘         └─────────────┘         └─────────────┘
```

## Validação de Multiplicidade e Condições

### Checklist de Validação

#### Para Multiplicidade
- [ ] Os limites mínimo e máximo fazem sentido no negócio?
- [ ] As restrições são realistas e implementáveis?
- [ ] A multiplicidade reflete corretamente as regras de negócio?
- [ ] Há flexibilidade suficiente para evolução futura?

#### Para Relacionamentos Condicionais
- [ ] A condição é clara e bem definida?
- [ ] A condição é verificável automaticamente?
- [ ] A condição é estável ou pode mudar frequentemente?
- [ ] Há alternativas mais simples para expressar a mesma regra?

#### Para Relacionamentos Incondicionais
- [ ] O relacionamento é realmente sempre válido?
- [ ] Não há exceções possíveis?
- [ ] A obrigatoriedade está correta?
- [ ] Não deveria ser condicional?

## Documentação de Multiplicidade e Condições

### Template de Documentação

```markdown
## Relacionamento: [NOME_DO_RELACIONAMENTO]

**Entidades:** Entidade1 - Entidade2
**Tipo:** Condicional / Incondicional
**Multiplicidade:** (min1, max1) - (min2, max2)

**Condição:** [Se aplicável]
[Descrever a condição em linguagem natural]

**Regras de Negócio:**
1. [Regra 1]
2. [Regra 2]
3. [Regra N]

**Exemplos:**
- Caso válido: [exemplo]
- Caso inválido: [exemplo]

**Implementação:**
[Notas sobre como implementar no modelo lógico]
```

### Exemplo de Documentação

```markdown
## Relacionamento: possui_cartao_vip

**Entidades:** CLIENTE - CARTAO_VIP
**Tipo:** Condicional
**Multiplicidade:** (0,1) - (1,1)

**Condição:** 
Cliente só pode possuir cartão VIP se total_compras > 10000

**Regras de Negócio:**
1. Cliente pode ter no máximo um cartão VIP
2. Cartão VIP deve pertencer a exatamente um cliente
3. Cliente deve ter comprado mais de R$ 10.000 para ser elegível
4. Cartão VIP é automaticamente cancelado se cliente ficar inativo por 12 meses

**Exemplos:**
- Caso válido: Cliente com R$ 15.000 em compras recebe cartão VIP
- Caso inválido: Cliente com R$ 5.000 em compras tenta obter cartão VIP

**Implementação:**
Usar trigger para verificar condição antes de inserir/atualizar cartão VIP
```

## Ferramentas de Modelagem

### Suporte a Multiplicidade Avançada

#### Ferramentas com Suporte Completo
- **Enterprise Architect**: Suporte total a multiplicidade e condições
- **Visual Paradigm**: Notação rica e flexível
- **Lucidchart**: Suporte básico com anotações textuais

#### Ferramentas com Suporte Limitado
- **MySQL Workbench**: Multiplicidade básica
- **dbdiagram.io**: Sem suporte a condições
- **Draw.io**: Apenas com anotações manuais

### Extensões para Multiplicidade

```
-- Notação estendida para multiplicidade condicional
CLIENTE (0,1)[total_compras > 10000] ── possui ── (1,1) CARTAO_VIP

-- Notação para multiplicidade temporal
FUNCIONARIO (1,3)[durante_projeto] ── trabalha_em ── (5,20) PROJETO
```

## Boas Práticas

### Para Multiplicidade

1. **Seja Realista**
   - Use limites baseados em dados reais
   - Considere crescimento e exceções
   - Valide com stakeholders

2. **Documente Justificativas**
   - Explique por que escolheu os limites
   - Registre fonte das informações
   - Mantenha atualizado

3. **Considere Implementação**
   - Verifique se é tecnicamente viável
   - Pense na performance das validações
   - Considere manutenção futura

### Para Relacionamentos Condicionais

1. **Simplifique Quando Possível**
   - Use relacionamentos incondicionais se viável
   - Evite condições muito complexas
   - Considere alternativas de design

2. **Torne Condições Explícitas**
   - Documente claramente as condições
   - Use nomes descritivos
   - Forneça exemplos

3. **Planeje Evolução**
   - Condições podem mudar
   - Mantenha flexibilidade
   - Documente histórico de mudanças

## Conclusão

A multiplicidade e os relacionamentos condicionais são ferramentas poderosas para criar modelos conceituais mais precisos e expressivos. Eles permitem capturar nuances importantes do negócio que não são possíveis com cardinalidades simples.

A escolha entre relacionamentos condicionais e incondicionais deve ser baseada na natureza do negócio e na estabilidade das regras. Multiplicidade detalhada ajuda a definir limites realistas e implementar validações adequadas.

O uso correto desses conceitos resulta em modelos mais fiéis à realidade e sistemas de banco de dados mais robustos e alinhados com as necessidades do negócio.