/*
 * CRIAÇÃO DAS TABELAS BASE
 */

create table vendedor (
    idvendedor integer not null,
    nome varchar(50) not null,
    constraint pk_idvendedor primary key (idvendedor),
    constraint un_nome unique (nome)
 );

create table cliente (
    idcliente integer not null,
    nome varchar(100) not null,
    CGC int not null,
    logradouro varchar(100) not null,
    endereco varchar(10) not null,
    constraint pk_idcliente primary key (idcliente),
    constraint un_cgc unique (CGC)
 );

create table pedido (
    idpedido integer not null,
    idcliente integer not null,
    idvendedor integer not null,
    constraint pk_idpedido primary key (idpedido),
    constraint fk_idcliente foreign key (idcliente) references cliente(idcliente),
    constraint fk_idvendedor foreign key (idvendedor) references vendedor(idvendedor)
 );

create table produto (
    idproduto integer not null,
    nome varchar(100) not null,
    constraint pk_idproduto primary key (idproduto),
    constraint un_nome unique (nome)
 );

create table pedido_produto (
    idpedido integer not null,
    idproduto integer not null,
    quantidade integer not null,
    valor_total float not null,
    constraint pk_idpedido_produto primary key (idpedido, idproduto),
    constraint fk_idpedido foreign key (idpedido) references pedido(idpedido),
    constraint fk_idproduto foreign key (idproduto) references produto(idproduto)
 );