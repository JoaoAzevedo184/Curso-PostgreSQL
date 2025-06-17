/*
 * CRIAÇÃO DAS TABELAS BASE
 */

create table livro (
    idlivro integer serial,
    data_lancamento date not null,
    numero_paginas integer not null,
    preco numeric(10, 2) not null,
    resumo text not null,
    isbn varchar(20) not null,
    constraint pk_idlivro primary key (idlivro),
    constraint un_isbn unique (isbn)
);

create table categoria (
    idcategoria integer serial,
    nome varchar(50) not null,
    constraint pk_idcategoria primary key (idcategoria),
    constraint un_nome unique (nome)
);

create table cliente (
    idcliente integer serial,
    nome varchar(50) not null,
    constraint pk_idcliente primary key (idcliente),
    constraint un_email unique (email)
);

create table autor (
    idautor integer serial,
    nome varchar(50) not null,
    constraint pk_idautor primary key (idautor),
    constraint un_nome unique (nome)
);

create table autor(
    idautor integer serial,
    nome varchar(50) not null,
    constraint pk_idautor primary key (idautor),
    constraint un_nome unique (nome)
);

create table venda (
    idvenda integer serial,
    quantidade integer not null,
    frete numeric(10, 2) not null,
    valor numeric(10, 2) not null,
    constraint pk_idvenda primary key (idvenda)
);

create table endereco (
    idendereco integer serial,
    logradouro varchar(50) not null,
    numero varchar(10) not null,
    cep char(8) not null,
    constraint pk_idendereco primary key (idendereco),
    constraint un_cep unique (cep)
);

create table cidade (
    idcidade integer serial,
    nome varchar(50) not null,
    constraint pk_idcidade primary key (idcidade),
    constraint un_nome unique (nome)
);

create table estado (
    idestado integer serial,
    nome varchar(50) not null,
    constraint pk_idestado primary key (idestado),
    constraint un_nome unique (nome)
);

create table livro_autor (
    idlivro integer not null,
    idautor integer not null,
    constraint pk_livro_autor primary key (idlivro, idautor),
    constraint fk_livro foreign key (idlivro) references livro(idlivro),
    constraint fk_autor foreign key (idautor) references autor(idautor)
);

create table venda_livro (
    idvenda integer not null,
    idlivro integer not null,
    constraint pk_venda_livro primary key (idvenda, idlivro),
    constraint fk_venda foreign key (idvenda) references venda(idvenda),
    constraint fk_livro foreign key (idlivro) references livro(idlivro)
);

create table cliente_endereco (
    idcliente integer not null,
    idendereco integer not null,
    constraint pk_cliente_endereco primary key (idcliente, idendereco),
    constraint fk_cliente foreign key (idcliente) references cliente(idcliente),
    constraint fk_endereco foreign key (idendereco) references endereco(idendereco)
);