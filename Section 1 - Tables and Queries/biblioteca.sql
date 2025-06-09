/*
 * CRIAÇÃO DAS TABELAS
 */
create table editora (
    idEditora serial not null,
    nome varchar(50) not null unique,
    constraint pk_edt_editora primary key (idEditora),
    constraint un_edt_nome unique (nome)
);
create table categoria (
    idCategoria serial not null,
    nome varchar(50) not null unique,
    constraint pk_cat_idCategoria primary key (idCategoria),
    constraint un_cat_nome unique (nome)
);
create table autor (
    idAutor serial not null,
    nome varchar(50) not null,
    constraint pk_atr_idAutor primary key (idAutor),
    constraint un_atr_nome unique (nome)
);
create table livro (
    idLivro serial not null,
    idEditora integer not null,
    idCategoria integer not null,
    titulo varchar(80) not null unique,
    constraint pk_lvr_idlivro primary key (idLivro),
	constraint fk_lvr_ideditora foreign key (idEditora) references editora (idEditora),
	constraint fk_lvr_idcategoria foreign key (idCategoria) references categoria (idCategoria),
	constraint un_lvr_titulo unique (titulo)
);
create table livro_autor (
    idLivro integer not null,
    idAutor integer not null,
    constraint pk_lva_autor primary key (idLivro, idAutor),
    constraint fk_lva_autor_livro foreign key (idLivro) references livro(idLivro),
    constraint fk_lva_autor_autor foreign key (idAutor) references autor(idAutor)
);
create table aluno(
    idAluno serial not null,
    nome varchar(50) not null,
    constraint pk_aln_idaluno primary key (idAluno),
	constraint un_aln_nome unique (nome)
);
create table emprestimo (
    idEmprestimo serial not null,
    idAluno integer not null,
    dataEmprestimo date not null DEFAULT current_date,
    dataDevolucao date not null,
    devolvido char(1) not null,
    valor decimal(10,2) not null,
    constraint pk_emp_idEmprestimo primary key (idEmprestimo),
    constraint fk_emp_idAluno foreign key (idAluno) references aluno(idAluno)
);
create table emprestimo_livro (
    idEmprestimo integer not null,
    idLivro integer not null,
    constraint pk_eml_idEmprestimoLivro primary key (idEmprestimo, idLivro),
    constraint fk_eml_emprestimo foreign key (idEmprestimo) references emprestimo(idEmprestimo),
    constraint fk_eml_livro foreign key (idLivro) references livro(idLivro)
);
/*
 * INSERÇÃO DE DADOS
 */
-- 1,2,3,4
insert into editora (nome) values 
('Bookman'),
('Edgard Blusher'),
('Nova Terra'),
('Brasport');

-- 1,2,3,4
insert into categoria (nome) values 
('Banco de Dados'),
('HTML'),
('Java'),
('PHP');

-- 1,2,3,4,5,6,7,8,9,10
insert into autor (nome) values 
('Waldemar Setzer'),
('Flávio Soares'),
('John Watson'),
('Rui Rossi dos Santos'),
('Antonio Pereira de Resende'),
('Claudiney Calixto Lima'),
('Evandro Carlos Teruel'),
('Ian Graham'),
('Fabrício Xavier'),
('Pablo Dalloglio');

insert into livro (idEditora, idCategoria, titulo) values 
(2, 1, 'Banco de Dados - 1 Edição'),
(1, 1, 'Oracle Database 11G Administração'),
(3, 3, 'Programação de Computadores em Java'),
(4, 3, 'Programação Orientada a Aspectos em Java'),
(4, 2, 'HTML5 – Guia Prático'),
(3, 2, 'XHTML: Guia de Referência para Desenvolvimento na Web'),
(1, 4, 'PHP para Desenvolvimento Profissional'),
(2, 4, 'PHP com Programação Orientada a Objetos');

insert into livro_autor (idLivro, idAutor) values 
(1, 1),
(1, 2),
(2, 3),
(3, 4),
(4, 5),
(4, 6),
(5, 7),
(6, 8),
(7, 9),
(8, 10);

insert into aluno (nome) values 
('Mario'),
('João'),
('Paulo'),
('Pedro'),
('Maria');

insert into emprestimo (idAluno, dataEmprestimo, dataDevolucao, devolvido, valor) values 
(1, '2012-05-02', '2012-05-12', 'S', 10.00),
(1, '2012-04-23', '2012-05-03', 'N', 5.00),
(2, '2012-05-10', '2012-05-20', 'N', 12.00),
(3, '2012-05-10', '2012-05-20', 'S', 8.00),
(4, '2012-05-05', '2012-05-15', 'N', 15.00),
(4, '2012-05-07', '2012-05-17', 'S', 20.00),
(4, '2012-05-08', '2012-05-18', 'S', 5.00);

insert into emprestimo_livro (idEmprestimo, idLivro) values 
(1, 1),
(2, 4),
(2, 3),
(3, 2),
(3, 7),
(4, 5),
(5, 4),
(6, 6),
(6, 1),
(7, 8);

/*
 * CRIANDO O INDEX
 */

create index idx_emp_data_emprestimo on emprestimo (dataEmprestimo);
create index idx_emp_data_devolucao on emprestimo (dataDevolucao);

/*
 * CONSULTAS SIMPLES
 */

-- O nome dos autores em ordem alfabética.
select nome from autor order by nome asc;

-- O nome dos alunos que começam com a letra P.
select nome from aluno where nome like 'P%';

-- O nome dos livros da categoria Banco de Dados ou Java.
select * from categoria;
select * from categoria where idCategoria in (1,3); 

-- O nome dos livros da editora Bookman.
select * from editora;
select * from livro where idEditora = 1;

-- Os empréstimos realizados entre 05/05/2012 e 10/05/2012.
select * from emprestimo where dataEmprestimo between '2012-05-05' and '2012-05-10';

-- Os empréstimos que não foram feitos entre 05/05/2012 e 10/05/2012
select * from emprestimo where dataEmprestimo not between '2012-05-05' and '2012-05-10';

-- Os empréstimos que os livros já foram devolvidos.
select * from emprestimo where devolvido = 'S';

/*
 * CONSULTAS COM AGRUPAMENTO SIMPLES
 */

-- A quantidade de livros.
select count(idlivro) from livro;

-- O somatório do valor dos empréstimos.
select sum(valor) from emprestimo;

-- A média do valor dos empréstimos.
select avg(valor) from emprestimo;

-- O maior valor dos empréstimos.
select max(valor) from emprestimo;

-- O menor valor dos empréstimos.
select min(valor) from emprestimo;

-- O somatório do valor do empréstimo que estão entre 05/05/2012 e 10/05/2012.
select sum(valor) from emprestimo where dataEmprestimo between '2012-05-05' and '2012-05-10';

-- A quantidade de empréstimos que estão entre 01/05/2012 e 05/05/2012.
select count(idEmprestimo) from emprestimo where dataEmprestimo between '2012-05-01' and '2012-05-05';

/*
 * CONSULTAS COM JOIN
 */

-- O nome do livro, a categoria e a editora (LIVRO) – fazer uma view
create view livro_dados as
select 
	lvr.titulo,
	ctg.nome as categoria,
	edt.nome as editora
from
	livro lvr
left outer join
	categoria ctg on lvr.idCategoria = ctg.idCategoria
left outer join
	editora edt on lvr.idEditora = edt.idEditora;
	
-- O nome do livro e o nome do autor (LIVRO_AUTOR) – fazer uma view.
create view livro_autor_view as
select 
	lvr.titulo,
	atr.nome as autor
from
	livro_autor lvt
left outer join
	livro lvr on lvt.idLivro = lvr.idLivro
left outer join
	autor atr on lvt.idAutor = atr.idAutor;
	
-- O nome dos livros do autor Ian Graham (LIVRO_AUTOR).
select * from autor;
select 
	lvr.titulo,
	atr.nome as autor
from
	livro_autor lvt
left outer join
	livro lvr on lvt.idLivro = lvr.idLivro
left outer join
	autor atr on lvt.idAutor = atr.idAutor
where
	lvt.idautor = 8;
	
-- O nome do aluno, a data do empréstimo e a data de devolução (EMPRESTIMO).
select
	aln.nome as aluno,
	emp.dataEmprestimo as data_do_emprestimo,
	emp.dataDevolucao as data_da_devolucao
from
	emprestimo emp
left outer join
	aluno aln on emp.idaluno = aln.idaluno;

-- O nome de todos os livros que foram emprestados (EMPRESTIMO_LIVRO).
select
	distinct(lvr.titulo) as titulo
from
	emprestimo_livro eml
left outer join
	livro lvr on eml.idLivro = lvr.idLivro;

/*
 * CONSULTAS COM AGRUPAMENTO + JOIN
 */

-- O nome da editora e a quantidade de livros de cada editora (LIVRO).
select
	edt.nome as editora,
	count(lvr.idlivro) as quantidade
from
	livro lvr
left outer join
	editora edt on lvr.ideditora = edt.ideditora
group by
	edt.nome;
-- O nome da categoria e a quantidade de livros de cada categoria (LIVRO).
select
	ctg.nome as categoria,
	count(lvr.idlivro) as quantidade
from
	livro lvr
left outer join
	categoria ctg on lvr.idcategoria = ctg.idcategoria
group by
	ctg.nome;
	
-- O nome do autor e a quantidade de livros de cada autor (LIVRO_AUTOR).
select
	atr.nome as autor,
	count(lva.idlivro) as quantidade
from
	livro_autor lva
left outer join
	autor atr on lva.idautor = atr.idautor
group by
	atr.nome;

-- O nome do aluno e a quantidade de empréstimo de cada aluno (EMPRESTIMO_LIVRO).
select
	aln.nome as aluno,
	count(emp.idemprestimo) as quantidade
from
	emprestimo emp
left outer join
	aluno aln on emp.idaluno = aln.idaluno
group by
	aln.nome;

-- O nome do aluno e o somatório do valor total dos empréstimos de cada aluno (EMPRESTIMO).
select
	aln.nome as aluno,
	sum(emp.valor) as valor
from
	emprestimo emp
left outer join
	aluno aln on emp.idaluno = aln.idaluno
group by
	aln.nome;
	
-- O nome do aluno e o somatório do valor total dos empréstimos de cada aluno somente daqueles que o somatório for maior do que 12,00 (EMPRESTIMO).
select
	aln.nome as aluno,
	sum(emp.valor) as valor
from
	emprestimo emp
left outer join
	aluno aln on emp.idaluno = aln.idaluno
group by
	aln.nome
having
	sum(emp.valor) > 12;
	
/*
 * CONSULTAS COMANDOS DIVERSOS
 */
-- O nome de todos os alunos em ordem decrescente e em letra maiúscula.
select upper(nome) from aluno order by nome desc;

-- Os empréstimos que foram feitos no mês 04 de 2012.
select * from emprestimo 
where extract(year from dataEmprestimo) = 2012 and extract(month from dataEmprestimo) = 4;

-- Todos os campos do empréstimo. Caso já tenha sido devolvido, mostrar a mensagem “Devolução completa”, senão “Em atraso”.
select 
	*,
	case devolvido
		when 'S' then 'Devolução completa'
		when 'N' then 'Em atraso'
	end as status 
from emprestimo;

-- Somente o caractere 5 até o caractere 10 do nome dos autores.
select substring(nome from 5 for 10) from autor;

-- O valor do empréstimo e somente o mês da data de empréstimo. Escreva “Janeiro”, “Fevereiro”, etc
select 
	valor,
	case extract(month from dataEmprestimo)
		when 1 then 'Janeiro'
		when 2 then 'Fevereiro'
		when 3 then 'Março'
		when 4 then 'Abril'
		when 5 then 'Maio'
		when 6 then 'Junho'
		when 7 then 'Julho'
		when 8 then 'Agosto'
		when 9 then 'Setembro'
		when 10 then 'Outubro'
		when 11 then 'Novembro'
		when 12 then 'Dezembro'
	else
		'Não informado'
	end as mes 
from emprestimo;

/*
 * SUBCONSULTAS
 */
-- A data do empréstimo e o valor dos empréstimos que o valor seja maior que a média de todos os empréstimos.
select
	dataEmprestimo,
	valor
from
	emprestimo
where
	valor > (select avg(valor) from emprestimo);
	
-- A data do empréstimo e o valor dos empréstimos que possuem mais de um livro.
select
	emp.dataEmprestimo,
	emp.valor,
	(select count(elv.idemprestimo) from emprestimo_livro elv where elv.idemprestimo = emp.idemprestimo)
from
	emprestimo emp
where
	(select 
	 	count(elv.idemprestimo) 
	 from 
	 	emprestimo_livro elv 
	  where elv.idemprestimo = emp.idemprestimo) > 1;
	  
-- A data do empréstimo e o valor dos empréstimos que o valor seja menor que a soma de todos os empréstimos.
select
	dataEmprestimo,
	valor
from
	emprestimo
where
	valor < (select sum(valor) from emprestimo);