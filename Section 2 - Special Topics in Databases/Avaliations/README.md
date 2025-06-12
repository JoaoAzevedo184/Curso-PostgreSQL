# Questionário PostgreSQL

## Exercícios funções
1. Crie uma função que receba como parâmetro o ID do pedido e retorne o valor total deste pedido
2. Crie uma função chamada “maior”, que quando executada retorne o pedido com o maior valor

## Exercícios procedures
1. Crie uma stored procedure que receba como parâmetro o ID do produto e o percentual de aumento, e reajuste o preço somente deste produto de acordo com
o valor passado como parâmetro
2. Crie uma stored procedure que receba como parâmetro o ID do produto e exclua da base de dados somente o produto com o ID correspondente

## Exercícios triggers
1. Crie uma tabela chamada PEDIDOS_APAGADOS
2. Faça uma trigger que quando um pedido for apagado, todos os seus dados devem ser copiados para a tabela PEDIDOS_APAGADOS

## Exercícios usuários e permissões
1. Crie um novo papel chamado “atendente”
2. Defina somente permissões para o novo papel poder selecionar e incluir novos pedidos (tabelas pedido e pedido_produto). O restante do acesso deve estar
bloqueado
3. Crie um novo usuário associado ao novo papel
4. Realize testes para verificar se as permissões foram aplicadas corretamente