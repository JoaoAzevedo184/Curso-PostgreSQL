/*
 * CRIAÇÃO DAS TABELAS BASE
 */

-- Tabela de Clientes
create table cliente(
    idcliente integer not null,
    nome varchar(40) not null,
    cpf char(11) not null,
    rg varchar(15),
    data_nascimento date,
    genero char(1),
    profissao varchar(30),
    nacionalidade varchar(30),
    logradouro varchar(30), 
    complemento varchar(10),
    bairro varchar(30),
    municipio varchar(30),
    estado varchar(30),
    observacoes text,
    constraint pk_idcliente primary key(idcliente)
);

-- Tabela de Profissões
create table profissao(
    idprofissao integer not null,
    nome varchar(30) not null,
    constraint pk_idprofissao primary key(idprofissao),
    constraint un_nome unique (nome)
);

-- Tabela de Nacionalidades
create table nacionalidade(
    idnacionalidade integer not null,
    nome varchar(30) not null,
    constraint pk_ncn_idnacionalidade primary key(idnacionalidade),
    constraint un_ncn_nome unique (nome)
);

-- Tabela de Complementos
create table complemento(
    idcomplemento integer not null,
    nome varchar(30) not null,
    constraint pk_cpl_idcomplemento primary key (idcomplemento),
    constraint un_cpl_nome unique (nome)
);

-- Tabela de Bairros
create table bairro(
    idbairro integer not null,
    nome varchar(30) not null,
    constraint pk_brr_idbairro primary key (idbairro),
    constraint un_brr_nome unique (nome)
);

-- Tabela de UF
create table uf(
    iduf integer not null,
    nome varchar(30) not null,
    sigla char(2) not null,
    constraint pk_ufd_idunidade_federecao primary key (iduf),
    constraint un_ufd_nome unique (nome),
    constraint un_ufd_sigla unique (sigla)
);

-- Tabela de Municípios
create table municipio(
    idmunicipio integer not null,
    nome varchar(30) not null,
    iduf integer not null,
    constraint pk_mnc_idmunicipio primary key (idmunicipio),
    constraint un_mnc_nome unique (nome),
    constraint fk_mnc_iduf foreign key (iduf) references uf (iduf)
);

/*
 * TABELAS DE NEGÓCIO
 */

-- Tabela de Fornecedores
create table fornecedor(
    idfornecedor integer not null,
    nome varchar(50) not null,
    constraint pk_frn_idfornecedor primary key (idfornecedor),
    constraint un_frn_nome unique (nome)
);

-- Tabela de Vendedores
create table vendedor(
    idvendedor integer not null,
    nome varchar(50) not null,
    constraint pk_vnd_idvendedor primary key (idvendedor),
    constraint un_vnd_nome unique (nome)
);

-- Tabela de Transportadoras
create table transportadora(
    idtransportadora integer not null,
    idmunicipio integer,
    nome varchar(50) not null,
    logradouro varchar(50),
    numero varchar(10),
    constraint pk_trn_idtransportadora primary key (idtransportadora),
    constraint fk_trn_idmunicipio foreign key (idmunicipio) references municipio (idmunicipio),
    constraint un_trn_nome unique (nome)
);

-- Tabela de Produtos
create table produto(
    idproduto integer not null,
    idfornecedor integer not null,
    nome varchar(50) not null,
    valor float not null,
    constraint pk_prd_idproduto primary key (idproduto),
    constraint fk_prd_idfornecedor foreign key (idfornecedor) references fornecedor (idfornecedor)
);

-- Tabela de Pedidos
create table pedido(
    idpedido integer not null,
    idcliente integer not null,
    idtransportadora integer,
    idvendedor integer not null,
    data_pedido date not null,
    valor float not null,
    constraint pk_pdd_idpedido primary key (idpedido),
    constraint fk_pdd_idcliente foreign key (idcliente) references cliente (idcliente),
    constraint fk_pdd_idtransportadora foreign key (idtransportadora) references transportadora (idtransportadora),
    constraint fk_pdd_idvendedor foreign key (idvendedor) references vendedor (idvendedor)
);

-- Tabela de Itens do Pedido
create table pedido_produto(
    idpedido integer not null,
    idproduto integer not null,
    quantidade integer not null,
    valor_unitario float not null,
    constraint pk_pdp_idpedidoproduto primary key (idpedido, idproduto),
    constraint fk_pdp_idpedido foreign key (idpedido) references pedido (idpedido),
    constraint fk_pdp_idproduto foreign key (idproduto) references produto (idproduto)
);

/*
 * INSERÇÃO DE DADOS
 */

-- [AQUI VÃO OS COMANDOS INSERT]

/*
 * CONSULTAS
 */

-- [AQUI VÃO OS COMANDOS SELECT]

/*
 * ALTERAÇÕES DE ESTRUTURA
 */

-- [AQUI VÃO OS COMANDOS ALTER TABLE]