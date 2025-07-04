# Exercício Projeto 2 - Sistema Loja de Locação de Trajes

## Descrição do Sistema

O banco de dados a ser desenvolvido tem o objetivo de controlar os principais processos de uma loja de locação de trajes/roupas.

Por primeiro, é necessário existir um controle dos trajes que existem na loja. Para este processo, deverá existir o controle pelo código do traje, a classe que o traje pertence, a descrição, tamanho, cor, tecido, marca, localização, valor para locação e valor para venda. Segue em anexo o relatório dos trajes.

O próximo processo é a locação de trajes para os clientes. Abaixo segue a descrição deste processo (Contrato):
+ O cliente escolhe o(s) traje(s) que deseja locar
+ Antes de efetivar o contrato, é necessário verificar se o(s) traje(s) estão disponíveis para o período que o cliente deseja locar (uma consulta SQL realizada no banco de dados)
+ É necessário controlar as datas de retirada, data de devolução e data do evento para o qual o traje será utilizado
+ O pagamento poderá ser feito em uma ou mais parcelas
+ O cliente poderá alugar um ou mais trajes

Por último, é preciso controlar os ajustes e provas que são realizados nos trajes, ou seja, caso seja necessário fazer alguma alteração na roupa, esta deverá ser registrada no sistema. Para isso, deverá ser informado o local do ajuste e o que será feito, bem como a data e hora em que o cliente irá provar a roupa após a alteração (Ajustes.pdf).

## Análise do Sistema

### 1. Entidades Identificadas

- **TRAJE**
- **CLASSE**
- **TAMANHO**
- **COR**
- **TECIDO**
- **MARCA**
- **LOCAÇÃO**
- **CLIENTE**
- **ENDEREÇO**
- **CIDADE**
- **ESTADO**
- **FUNCIONÁRIO**
- **PARCELA**
- **FORMA PAGAMENTO**
- **CONTATO**
- **AJUSTE**
- **LOCAL AJUSTE**

### 2. Atributos das Entidades

**TRAJE**:
* Idtraje
* código
* descrição
* localização
* valor locação
* valor venda
* valor indenização

**CLASSE**:
* Idclasse
* nome

**TAMANHO**:
* Idtamanho
* nome

**COR**:
* Idcor
* nome

**TECIDO**:
* Idtecido
* nome

**MARCA**:
* Idmarca
* nome

**LOCAÇÃO**:
* Idlocação
* numero\_contrato
* data retirada
* hora retirada
* valor total
* data devolução
* valor desconto
* valor entrada
* data evento
* saldo pagar
* evento
* valor indenização
* quantidade
* data assinatura
* data reserva

**CLIENTE**:
* Idcliente
* nome
* RG
* CPF

**ENDEREÇO**:
* Idendereço
* logradouro
* numero
* CEP

**CIDADE**:
* Idcidade
* nome

**ESTADO**:
* Idestado
* nome

**FUNCIONÁRIO**:
* Idfuncionário
* nome

**PARCELA**:
* Idparcela
* data vencimento
* valor
* paga

**FORMA PAGAMENTO**:
* Idforma\_pagamento
* nome

**CONTATO**:
* Idcontato
* tipo
* conteúdo

**AJUSTE**:
* Idajuste
* descrição
* data prova
* hora prova

**LOCAL AJUSTE**:
* Idlocal\_ajuste
* nome

### 3. Relacionamentos Identificados

- Traje tem Classe
- Traje tem Tamanho
- Traje tem Cor
- Traje tem Tecido
- Traje tem Marca
- Locação possui Traje
- Ajuste possui Traje
- Locação possui Cliente
- Locação possui Funcionário
- Locação possui Parcela
- Locação possui Ajuste
- Cliente possui Endereço
- Cliente possui Contato
- Endereço está Cidade
- Cidade está Estado
- Parcela possui Forma pagamento
- Ajuste possui Local ajuste
