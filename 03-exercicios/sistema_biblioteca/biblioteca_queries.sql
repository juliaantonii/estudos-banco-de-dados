/*
====================================================================
  REVISÃO PRÁTICA DE BANCO DE DADOS 1
  CENÁRIO: Sistema de Gerenciamento de Biblioteca
====================================================================

  Esquema Conceitual:
  - Autores (id_autor, nome, nacionalidade)
  - Livros (id_livro, titulo, id_autor, ano_publicacao)
  - Usuarios (id_usuario, nome, email)
  - Emprestimos (id_emprestimo, id_usuario, id_livro, data_emprestimo, data_devolucao)
*/

-- ====================================================================
-- EXERCÍCIO DE MODELAGEM (DER / ERD)
-- ====================================================================

/*
  EXERCÍCIO 0: 
  Com base no cenário acima, elabore o Diagrama de Entidade-Relacionamento (DER/ERD).
  Identifique:
  - As entidades e seus atributos (destacando PK e FK).
  - Os relacionamentos entre as entidades e suas cardinalidades:
    * Autor x Livro (Um autor pode escrever quantos livros? Um livro pertence a quantos autores?)
    * Usuario x Emprestimo (Um usuário pode fazer quantos empréstimos?)
    * Livro x Emprestimo (Um livro pode estar em quantos empréstimos?)
*/


-- ====================================================================
-- BLOCO 1: Criação e Manipulação de Dados (DDL e DML)
-- ====================================================================

-- 1) Escreva o comando SQL para criar a tabela "autores", com chave primária em id_autor.
CREATE TABLE autores (
    id_autor INT PRIMARY KEY,
    nome VARCHAR(100),
    nacionalidade VARCHAR(100)
);

-- 2) Escreva o comando para criar a tabela "livros", definindo a chave primária e a chave estrangeira referenciando "autores".
CREATE TABLE livros (
    id_livro INT PRIMARY KEY,
    titulo VARCHAR(100),
    id_autor INT,
    ano_publicacao INT,
    FOREIGN KEY (id_autor) REFERENCES autores (id_autor)
);

-- 3) Escreva os comandos INSERT para adicionar autores e livros.
INSERT INTO autores VALUES 
    (1, 'Andy Weir', 'EUA'),
    (2, 'Silvana Tavano', 'BR'),
    (3, 'Alice Zhao', 'EUA');

INSERT INTO livros VALUES 
    (1, 'Devoradores de Estrelas', 1, 2022),
    (2, 'Ressuscitar Mamutes', 2, 2024),
    (3, 'SQL Guia Prático', 3, 2023);

-- 4) Escreva um comando UPDATE para alterar o ano_publicacao do livro com id_livro = 1 para 2021.
UPDATE livros
SET ano_publicacao = 2021
WHERE id_livro = 1;

-- 5) Escreva os comandos para criar a tabela "usuarios", inserir registros e deletar um usuário por id_usuario.
CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY,
    nome VARCHAR(100),
    email VARCHAR(100)
);

INSERT INTO usuarios VALUES 
    (1, 'Julia Antoni', 'juliaantoni@email.com'),
    (2, 'Clove', 'clove@email.com'),
    (3, 'Mercy', 'drziegler@email.com'),
    (4, 'Sally', 'sallface@email.com');

DELETE FROM usuarios
WHERE id_usuario = 1;


-- ====================================================================
-- BLOCO 2: Consultas Básicas e Ordenação (DQL)
-- ====================================================================

-- 6) Escreva uma consulta para buscar apenas o titulo e o ano_publicacao de todos os livros.
SELECT titulo, ano_publicacao
FROM livros;

-- 7) Escreva uma consulta para buscar todos os dados dos autores cuja nacionalidade seja 'EUA'.
SELECT *
FROM autores
WHERE nacionalidade = 'EUA';

-- 8) Escreva uma consulta para listar todos os usuários, ordenados pelo nome em ordem alfabética (crescente).
SELECT *
FROM usuarios
ORDER BY nome ASC;

-- 9) Escreva uma consulta para listar os livros ordenados pelo ano_publicacao, do mais recente para o mais antigo (decrescente).
SELECT *
FROM livros
ORDER BY ano_publicacao DESC;

-- 10) Escreva uma consulta que retorne apenas o titulo e o ano_publicacao do livro mais antigo.
SELECT titulo, ano_publicacao
FROM livros
ORDER BY ano_publicacao ASC
LIMIT 1;


-- ====================================================================
-- BLOCO 3: Junções de Tabelas (JOINs)
-- ====================================================================

-- 11) Escreva uma consulta usando INNER JOIN para listar o titulo do livro e o nome do seu autor.
SELECT l.titulo, a.nome AS nome_autor
FROM livros AS l
INNER JOIN autores AS a ON l.id_autor = a.id_autor;

-- 12) Escreva uma consulta usando LEFT JOIN para listar todos os autores e os títulos de seus livros (incluindo autores sem livros).
INSERT INTO autores VALUES (4, 'Autor Sem Livro', 'BR');

SELECT a.nome, l.titulo
FROM autores AS a
LEFT JOIN livros AS l ON a.id_autor = l.id_autor;

-- 13) Crie a tabela "emprestimos", insira dados e liste o nome do usuário e a data_emprestimo realizada.
CREATE TABLE emprestimos (
    id_emprestimo INT PRIMARY KEY,
    id_usuario INT,
    id_livro INT,
    data_emprestimo DATE,
    data_devolucao DATE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios (id_usuario),
    FOREIGN KEY (id_livro) REFERENCES livros (id_livro)
);

INSERT INTO emprestimos VALUES 
    (1, 2, 3, '2026-08-20', '2026-08-31'),
    (2, 2, 2, '2026-09-05', '2026-09-15');

SELECT u.nome, e.data_emprestimo
FROM usuarios AS u
JOIN emprestimos AS e ON u.id_usuario = e.id_usuario;

-- 14) Escreva uma consulta unindo 3 tabelas (Usuarios, Emprestimos e Livros) para listar o nome do usuário, o título do livro e a data_emprestimo.
SELECT u.nome, l.titulo, e.data_emprestimo
FROM livros AS l
JOIN emprestimos AS e ON l.id_livro = e.id_livro
JOIN usuarios AS u ON e.id_usuario = u.id_usuario;

-- 15) Escreva uma consulta usando LEFT JOIN para encontrar quais livros NUNCA foram emprestados.
SELECT l.id_livro, l.titulo
FROM livros AS l
LEFT JOIN emprestimos AS e ON l.id_livro = e.id_livro
WHERE e.data_emprestimo IS NULL;


-- ====================================================================
-- BLOCO 4: Agrupamento e Agregação (GROUP BY, HAVING)
-- ====================================================================

-- 16) Escreva uma consulta para contar o total de livros cadastrados no banco de dados.
SELECT COUNT(*) AS total_livros
FROM livros;

-- 17) Escreva uma consulta para mostrar o id_autor e a quantidade de livros que cada autor possui cadastrados.
SELECT a.id_autor, COUNT(l.id_livro) AS qtd_livros_cadastrados
FROM autores AS a
LEFT JOIN livros AS l ON a.id_autor = l.id_autor
GROUP BY a.id_autor;

-- 18) Escreva uma consulta que retorne o ano do livro mais antigo e o ano do livro mais recente em uma única linha.
SELECT MIN(ano_publicacao) AS mais_antigo, MAX(ano_publicacao) AS mais_recente
FROM livros;

-- 19) Escreva uma consulta para listar apenas os autores (id_autor) que possuem mais de 1 livro cadastrado.
INSERT INTO livros VALUES (4, 'Perdido em Marte', 1, 2014);

SELECT a.id_autor, COUNT(l.id_livro) AS qtd_livros_cadastrados
FROM autores AS a
JOIN livros AS l ON a.id_autor = l.id_autor
GROUP BY a.id_autor
HAVING COUNT(l.id_livro) > 1;

-- 20) Escreva uma consulta combinando JOIN e GROUP BY para mostrar o nome do usuário e a quantidade total de empréstimos que ele realizou.
SELECT u.nome, COUNT(e.id_emprestimo) AS total_emprestimos
FROM usuarios AS u
JOIN emprestimos AS e ON u.id_usuario = e.id_usuario
GROUP BY u.id_usuario, u.nome;