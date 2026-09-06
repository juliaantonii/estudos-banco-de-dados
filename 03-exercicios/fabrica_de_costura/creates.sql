/*
Universidade Federal de Mato Grosso do Sul
Curso de Bacharelado em Sistemas de Informação
Disciplina: Banco de Dados e Laboratório de Banco de Dados
Professora: Ivone Matsuno

Estudo de caso: Fábrica de Costura
Criação das Tabelas


*/

-- create database fabrica_costura;
--
-- funcionario
create table funcionario(
matricula integer not null,
nome varchar(255) not null,
endereco varchar(255) not null default 'não informado',
primary key (matricula)
);


-- funcionario meio
create table meio(
matricula integer not null,
setor varchar(255),
salario_fixo decimal(10,2),
gratificacao decimal(10,2),
primary key (matricula),
foreign key (matricula) references funcionario(matricula),
check(setor IN('ADM', 'TI', 'FINANCEIRO', 'RH', 'INFRA')),
check (gratificacao >= 0 and gratificacao <= 5000)
);

-- funcionario costureira
create table costureira(
matricula integer not null,
aliquota_fixa decimal(10,2),
salario decimal(10,2),
valor_minimo decimal(10,2),
costureira_supervisora integer,
primary key (matricula),
foreign key (matricula) references funcionario(matricula)
);


-- tipo de costura
create table tipo_costura(
id_tipo_costura integer not null,
descricao varchar(255),
primary key (id_tipo_costura)
);

-- maquina
create table maquina(
id_maquina integer not null,
fabricante varchar(255),
situacao varchar(255),
primary key (id_maquina)
);
--
-- fornecedores de maquina
create table fornecedores_maquina(
id_maquina integer not null,
fornecedor varchar(60),
primary key (id_maquina, fornecedor),
foreign key (id_maquina) references maquina (id_maquina)
);

-- manutencao
create table manutencao(
id_manutencao integer not null,
dt_inicio date,
dt_fim date check (dt_fim >=dt_inicio),
id_maquina integer,
id_monitora integer,
primary key (id_manutencao)
);

-- peça
create table peca(
id_peca integer not null,
modelo varchar(255),
preco_venda decimal(10,2),
descricao_modelo varchar(255),
primary key (id_peca)
);

-- producao
create table producao(
id_producao serial,
matricula integer,
id_maquina integer,
id_peca integer,
dt_ini date,
dt_fim date check (dt_fim >=dt_ini),
hr_ini time,
hr_fim time check (hr_fim >=hr_ini),
primary key(id_producao)

);

-- habilitacao
create table habilitacao(
matricula integer not null,
id_tipo_costura integer,
primary key(matricula, id_tipo_costura)
);

create table maquina_tipo_costura(
id_maquina integer not null,
id_tipo_costura integer,
primary key(id_maquina, id_tipo_costura)
);

-- ----------------------------------------
-- Adionando chaves estrangeiras

--costureira
alter table costureira
add constraint fk_costureira foreign key(costureira_supervisora) references costureira(matricula);

-- manutencao
alter table manutencao
add constraint fk_manutencao_supervisora foreign key (id_monitora) references costureira(matricula),
add constraint fk_manutencao_maquina foreign key (id_maquina) references maquina(id_maquina);

-- producao
alter table producao
add constraint fk_prod1 foreign key (matricula) references costureira(matricula),
add constraint fk_prod2 foreign key (id_maquina) references maquina(id_maquina),
add constraint fk_prod3 foreign key (id_peca) references peca(id_peca);

-- habilitacao
alter table habilitacao
add constraint fk_hab1 foreign key (matricula) references costureira(matricula),
add constraint fk_hab2 foreign key (id_tipo_costura) references tipo_costura(id_tipo_costura);

-- maquina_tipo_costura
alter table maquina_tipo_costura
add constraint fk_maq_cost1 foreign key (id_maquina) references maquina(id_maquina),
add constraint fk_maq_cost2 foreign key (id_tipo_costura) references tipo_costura(id_tipo_costura);