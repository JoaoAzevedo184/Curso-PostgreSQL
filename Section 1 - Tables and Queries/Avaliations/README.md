# Questionário PostgreSQL

## 1. Consultas Simples
1. Liste nome, gênero e profissão de todos os clientes (ordem decrescente por nome)
2. Encontre clientes com letra "R" no nome
3. Encontre clientes com nome iniciando com "C"
4. Encontre clientes com nome terminando em "A"
5. Liste clientes do bairro "Centro"
6. Liste clientes com complementos iniciando com "A"
7. Liste apenas clientes do sexo feminino
8. Liste clientes sem CPF informado
9. Liste nome e profissão (ordem crescente por profissão)
10. Liste clientes de nacionalidade "Brasileira"
11. Liste clientes com número de residência informado
12. Liste clientes de Santa Catarina
13. Liste clientes nascidos entre 01/01/2000 e 01/01/2002
14. Liste dados concatenados dos clientes (nome do cliente e o logradouro, número, complemento, bairro, município e UF)

## 2. Comandos Update e Delete

### 2.1 Inserção de Dados

#### Cliente 1:
- IdCliente: 16
- Nome: Maicon
- CPF: 12349596421
- RG: 1234
- Data_Nascimento: 10/10/1965
- Gênero: F
- Profissão: Empresário
- Nacionalidade: -
- Logradouro: -
- Numero: -
- Complemento: -
- Bairro: -
- Município: Florianópolis
- UF: PR

#### Cliente 2:
- IdCliente: 17
- Nome: Getúlio
- CPF: -
- RG: 4631
- Data_Nascimento: -
- Gênero: F
- Profissão: Estudante
- Nacionalidade: Brasileira
- Logradouro: Rua Central
- Numero: 343
- Complemento: Apartamento
- Bairro: Centro
- Município: Curitiba
- UF: SC

#### Cliente 3:
- IdCliente: 18
- Nome: Sandra
- CPF: -
- RG: -
- Data_Nascimento: -
- Gênero: M
- Profissão: Professor
- Nacionalidade: Italiana
- Logradouro: -
- Numero: 12
- Complemento: Bloco A
- Bairro: -
- Município: -
- UF: -

### 2.2 Atualizações
1. Cliente Maicon:
   - CPF para 45390569432
   - Gênero para M
   - Nacionalidade para Brasileira
   - UF para SC

2. Cliente Getúlio:
   - Data nascimento para 01/04/1978
   - Gênero para M

3. Cliente Sandra:
   - Gênero para F
   - Profissão para Professora
   - Número para 123

### 2.3 Exclusões
1. Apagar cliente Maicon
2. Apagar cliente Sandra

## 3. Consulta Simples 2
1. Somente o nome de todos os vendedores em ordem alfabética.
2. Os produtos que o preço seja maior que R$200,00, em ordem crescente pelo preço.
3. O nome do produto, o preço e o preço reajustado em 10%, ordenado pelo nome do produto.
4. Os municípios do Rio Grande do Sul.
5. Os pedidos feitos entre 10/04/2008 e 25/04/2008 ordenado pelo valor.
6. Os pedidos que o valor esteja entre R$1.000,00 e R$1.500,00.
7. Os pedidos que o valor não esteja entre R$100,00 e R$500,00.
8. Os pedidos do vendedor André ordenado pelo valor em ordem decrescente.
9. Os pedidos do cliente Manoel ordenado pelo valor em ordem crescente.
10. Os pedidos da cliente Jéssica que foram feitos pelo vendedor André.
11. Os pedidos que foram transportados pela transportadora União Transportes.
12. Os pedidos feitos pela vendedora Maria ou pela vendedora Aline.
13. Os clientes que moram em União da Vitória ou Porto União.
14. Os clientes que não moram em União da Vitória e nem em Porto União.
15. Os clientes que não informaram o logradouro.
16. Os clientes que moram em avenidas.
17. Os vendedores que o nome começa com a letra S.
18. Os vendedores que o nome termina com a letra A.
19. Os vendedores que o nome não começa com a letra A.
20. Os municípios que começam com a letra P e são de Santa Catarina.
21. As transportadoras que informaram o endereço.
22. Os itens do pedido 01.
23. Os itens do pedido 06 ou do pedido 10. 

## 3. Funções Agregadas
1. A média dos valores de vendas dos vendedores que venderam mais que R$ 200,00.
2. Os vendedores que venderam mais que R$ 1500,00.
3. O somatório das vendas de cada vendedor.
4. A quantidade de municípios.
5. A quantidade de municípios que são do Paraná ou de Santa Catarina.
6. A quantidade de municípios por estado.
7. A quantidade de clientes que informaram o logradouro.
8. A quantidade de clientes por município.
9. A quantidade de fornecedores.
10. A quantidade de produtos por fornecedor.
11. A média de preços dos produtos do fornecedor Cap. Computadores.
12. O somatório dos preços de todos os produtos.
13. O nome do produto e o preço somente do produto mais caro.
14. O nome do produto e o preço somente do produto mais barato.
15. A média de preço de todos os produtos.
16. A quantidade de transportadoras.
17. A média do valor de todos os pedidos.
18. O somatório do valor do pedido agrupado por cliente.
19. O somatório do valor do pedido agrupado por vendedor.
20. O somatório do valor do pedido agrupado por transportadora.
21. O somatório do valor do pedido agrupado pela data.
22. O somatório do valor do pedido agrupado por cliente, vendedor e transportadora.
23. O somatório do valor do pedido que esteja entre 01/04/2008 e 10/12/2009 e que seja maior que R$ 200,00.
24. A média do valor do pedido do vendedor André.
25. A média do valor do pedido da cliente Jéssica.
26. A quantidade de pedidos transportados pela transportadora BS. Transportes.
27. A quantidade de pedidos agrupados por vendedor.
28. A quantidade de pedidos agrupados por cliente.
29. A quantidade de pedidos entre 15/04/2008 e 25/04/2008.
30. A quantidade de pedidos que o valor seja maior que R$ 1.000,00.
31. A quantidade de microcomputadores vendida.
32. A quantidade de produtos vendida agrupado por produto.
33. O somatório do valor dos produtos dos pedidos, agrupado por pedido.
34. A quantidade de produtos agrupados por pedido.
35. O somatório do valor total de todos os produtos do pedido.
36. A média dos produtos do pedido 6.
37. O valor do maior produto do pedido.
38. O valor do menor produto do pedido.
39. O somatório da quantidade de produtos por pedido.
40. O somatório da quantidade de todos os produtos do pedido.

## 4. Joins
1. O nome do cliente, a profissão, a nacionalidade, o logradouro, o número, o complemento, o bairro, o município e a unidade de federação.
2. O nome do produto, o valor e o nome do fornecedor.
3. O nome da transportadora e o município.
4. A data do pedido, o valor, o nome do cliente, o nome da transportadora e o nome do vendedor.
5. O nome do produto, a quantidade e o valor unitário dos produtos do pedido.
6. O nome dos clientes e a data do pedido dos clientes que fizeram algum pedido (ordenado pelo nome do cliente).
7. O nome dos clientes e a data do pedido de todos os clientes, independente se tenham feito pedido (ordenado pelo nome do cliente).
8. O nome da cidade e a quantidade de clientes que moram naquela cidade.
9. O nome do fornecedor e a quantidade de produtos de cada fornecedor.
10.O nome do cliente e o somatório do valor do pedido (agrupado por cliente).
11.O nome do vendedor e o somatório do valor do pedido (agrupado por vendedor).
12.O nome da transportadora e o somatório do valor do pedido (agrupado por transportadora). 
13.O nome do cliente e a quantidade de pedidos de cada um (agrupado por cliente).
14.O nome do produto e a quantidade vendida (agrupado por produto).
15.A data do pedido e o somatório do valor dos produtos do pedido (agrupado pela data do pedido). 
16.A data do pedido e a quantidade de produtos do pedido (agrupado pela data do pedido).

## 5. Comandos Adicionais
1. O nome do cliente e somente o mês de nascimento. Caso a data de nascimento não esteja preenchida mostrar a mensagem “Não informado”.
2. O nome do cliente e somente o nome do mês de nascimento (Janeiro, Fevereiro etc). Caso a data de nascimento não esteja preenchida mostrar a mensagem “Não informado”.
3. O nome do cliente e somente o ano de nascimento. Caso a data de nascimento não esteja preenchida mostrar a mensagem “Não informado”.
4. O caractere 5 até o caractere 10 de todos os municípios.
5. O nome de todos os municípios em letras maiúsculas.
6. O nome do cliente e o gênero. Caso seja M mostrar “Masculino”, senão mostrar “Feminino”.
7. O nome do produto e o valor. Caso o valor seja maior do que R$ 500,00 mostrar a mensagem “Acima de 500”, caso contrário, mostrar a mensagem “Abaixo de 500”.

## 6. Subconsultas
1. O nome dos clientes que moram na mesma cidade do Manoel. Não deve ser mostrado o Manoel.
2. A data e o valor dos pedidos que o valor do pedido seja menor que a média de todos os pedidos.
3. A data,o valor, o cliente e o vendedor dos pedidos que possuem 2 ou mais produtos.
4. O nome dos clientes que moram na mesma cidade da transportadora BSTransportes.
5. O nome do cliente e o município dos clientes que estão localizados no mesmo município de qualquer uma das transportadoras.
6. Atualizar o valor do pedido em 5% para os pedidos que o somatório do valor total dos produtos daquele pedido seja maior que a média do valor total
de todos os produtos de todos os pedidos.
7. O nome do cliente e a quantidade de pedidos feitos pelo cliente.
8. Para revisar, refaça o exercício anterior (número 07) utilizando group by e mostrando somente os clientes que fizeram pelo menos um pedido.


## 7. Views
1. O nome, a profissão, a nacionalidade, o complemento, o município, a unidade de federação, o bairro, o CPF,o RG, a data de nascimento, o gênero (mostrar “Masculino” ou “Feminino”), o logradouro, o número e as observações dos clientes.
2. O nome do município e o nome e a sigla da unidade da federação.
3. O nome do produto, o valor e o nome do fornecedor dos produtos.
4. O nome da transportadora, o logradouro, o número, o nome da unidade de federação e a sigla da unidade de federação das transportadoras.
5. A data do pedido, o valor, o nome da transportadora, o nome do cliente e o nome do vendedor dos pedidos.
6. O nome do produto, a quantidade, o valor unitário e o valor total dos produtos do pedido.

## 8. Sequences (Auto Incremento)
Criar sequências para:
- Cliente
- Complemento
- Fornecedor
- Município
- Nacionalidade
- Pedido
- Pedido produto
- Profissão
- Transportadora
- UF
- Vendedor

## 9. Valores Default
1. Tabela produtos_pedido:
   - Quantidade = 1
   - Valor unitário = 0

2. Tabela produtos:
   - Valor = 0

## 10. Índices
Criar índices para:
1. Pedido (data_pedido)
2. Produto (nome)

---
**Nota**: Cada exercício deve ser resolvido usando SQL padrão PostgreSQL.