/*
 * CRIAÇÃO DAS TABELAS BASE
 */

create table classe (
    idclasse integer not null,
    nome varchar(50) not null,
    constraint pk_idclasse primary key (idclasse),
    constraint un_nome unique (nome)
);

create table tamanho (
    idtamanho integer not null,
    nome varchar(20) not null,
    constraint pk_idtamanho primary key (idtamanho),
    constraint un_nome unique (nome)
);

create table cor (
    idcor integer not null,
    nome varchar(20) not null,
    constraint pk_idcor primary key (idcor),
    constraint un_nome unique (nome)
);

create table tecido (
    idtecido integer not null,
    nome varchar(50) not null,
    constraint pk_idtecido primary key (idtecido),
    constraint un_nome unique (nome)
);

create table marca (
    idmarca integer not null,
    nome varchar(50) not null,
    constraint pk_idmarca primary key (idmarca),
    constraint un_nome unique (nome)
);


create table cliente (
    idcliente integer not null,
    nome varchar(100) not null,
    rg varchar(20) not null,
    cpf varchar(14) not null,
    constraint pk_idcliente primary key (idcliente),
    constraint un_cpf unique (cpf)
);

create table endereco (
    idendereco integer not null,
    logradouro varchar(100) not null,
    numero varchar(10) not null,
    cep varchar(10) not null,
    constraint pk_idendereco primary key (idendereco),
    constraint un_cep unique (cep),
    constraint fk_idcidade foreign key (idcidade) references cidade(idcidade)
);

create table cidade (
    idcidade integer not null,
    nome varchar(50) not null,
    constraint pk_idcidade primary key (idcidade),
    constraint un_nome unique (nome),
    constraint fk_idestado foreign key (idestado) references estado(idestado)
);

create table estado (
    idestado integer not null,
    nome varchar(50) not null,
    constraint pk_idestado primary key (idestado),
    constraint un_nome unique (nome)
);
create table funcionario (
    idfuncionario integer not null,
    nome varchar(100) not null,
    constraint pk_idfuncionario primary key (idfuncionario),
    constraint un_nome unique (nome)
);

create table parcela (
    idparcela integer not null,
    data_vencimento date not null,
    valor numeric(10, 2) not null,
    paga boolean not null,
    constraint pk_idparcela primary key (idparcela),
    constraint fk_idlocacao foreign key (idlocacao) references locacao(idlocacao),
    constraint fk_idforma_pagamento foreign key (idforma_pagamento) references forma_pagamento(idforma_pagamento)
);

create table forma_pagamento (
    idforma_pagamento integer not null,
    nome varchar(50) not null,
    constraint pk_idforma_pagamento primary key (idforma_pagamento),
    constraint un_nome unique (nome)
);

create table contato (
    idcontato integer not null,
    tipo varchar(20) not null,
    conteudo varchar(100) not null,
    constraint pk_idcontato primary key (idcontato),
    constraint un_conteudo unique (conteudo),
    constraint fk_idcliente foreign key (idcliente) references cliente(idcliente)
);

create table ajuste (
    idajuste integer not null,
    descricao text not null,
    data_prova date not null,
    hora_prova time not null,
    constraint pk_idajuste primary key (idajuste),
    constraint fk_idlocacao foreign key (idlocacao) references locacao(idlocacao),
    constraint fk_idlocal_ajuste foreign key (idlocal_ajuste) references local_ajuste(idlocal_ajuste)
);

create table traje (
    idtraje integer not null,
    codigo varchar(20) not null,
    descricao text not null,
    localizacao varchar(50) not null,
    valor_locacao numeric(10, 2) not null,
    valor_venda numeric(10, 2) not null,
    valor_indenizacao numeric(10, 2) not null,
    constraint pk_idtraje primary key (idtraje),
    constraint un_codigo unique (codigo),
    constraint fk_idclasse foreign key (idclasse) references classe(idclasse),
    constraint fk_idtamanho foreign key (idtamanho) references tamanho(idtamanho),
    constraint fk_idcor foreign key (idcor) references cor(idcor),
    constraint fk_idtecido foreign key (idtecido) references tecido(idtecido),
    constraint fk_idmarca foreign key (idmarca) references marca(idmarca)
);

create table locacao (
    idlocacao integer not null,
    numero_contrato varchar(20) not null,
    data_retirada date not null,
    hora_retirada time not null,
    valor_total numeric(10, 2) not null,
    data_devolucao date,
    valor_desconto numeric(10, 2),
    valor_entrada numeric(10, 2),
    data_evento date,
    saldo_pagar numeric(10, 2),
    evento varchar(50),
    valor_indenizacao numeric(10, 2),
    quantidade integer not null,
    data_assinatura date not null,
    data_reserva date not null,
    constraint pk_idlocacao primary key (idlocacao),
    constraint fk_idcliente foreign key (idcliente) references cliente(idcliente),
    constraint fk_idfuncionario foreign key (idfuncionario) references funcionario(idfuncionario)
);

create table local_ajuste (
    idlocal_ajuste integer not null,
    nome varchar(50) not null,
    constraint pk_idlocal_ajuste primary key (idlocal_ajuste),
    constraint un_nome unique (nome)
);

create table traje_locacao (
    idtraje integer not null,
    idlocacao integer not null,
    quantidade integer not null,
    constraint pk_traje_locacao primary key (idtraje, idlocacao),
    constraint fk_traje foreign key (idtraje) references traje(idtraje),
    constraint fk_locacao foreign key (idlocacao) references locacao(idlocacao)
);

create table cliente_endereco (
    idcliente integer not null,
    idendereco integer not null,
    constraint pk_cliente_endereco primary key (idcliente, idendereco),
    constraint fk_cliente foreign key (idcliente) references cliente(idcliente),
    constraint fk_endereco foreign key (idendereco) references endereco(idendereco)
);

