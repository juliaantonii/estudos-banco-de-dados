-- -----------------------------------------------------------------
-- SETUP DO BANCO DE DADOS (Tabelas e Dados de Teste)
-- -----------------------------------------------------------------
DROP TABLE IF EXISTS item_venda CASCADE;
DROP TABLE IF EXISTS venda CASCADE;
DROP TABLE IF EXISTS produto CASCADE;
DROP TABLE IF EXISTS cliente CASCADE;

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(20) DEFAULT 'PADRAO' CHECK (categoria IN ('PADRAO', 'VIP', 'PREMIUM')),
    dt_cadastro DATE NOT NULL
);

CREATE TABLE produto (
    id_produto INT PRIMARY KEY,
    modelo VARCHAR(100) NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL CHECK (estoque >= 0)
);

CREATE TABLE venda (
    id_venda INT PRIMARY KEY,
    id_cliente INT REFERENCES cliente(id_cliente),
    dt_venda DATE NOT NULL,
    total_venda DECIMAL(10,2) DEFAULT 0.00
);

CREATE TABLE item_venda (
    id_venda INT REFERENCES venda(id_venda),
    id_produto INT REFERENCES produto(id_produto),
    quantidade INT NOT NULL,
    preco_aplicado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_venda, id_produto)
);

INSERT INTO cliente VALUES 
(1, 'Carlos Eduardo', 'PADRAO', '2023-01-10'),
(2, 'Mariana Lima', 'VIP', '2022-05-15'),
(3, 'Roberto Alves', 'PREMIUM', '2021-11-20'),
(4, 'Fernanda Costa', 'PADRAO', '2023-06-01');

INSERT INTO produto VALUES 
(101, 'Galaxy S23', 4500.00, 15),
(102, 'iPhone 14', 5500.00, 8),
(103, 'Redmi Note 12', 1500.00, 30),
(104, 'Moto G84', 1800.00, 5);

INSERT INTO venda VALUES 
(1, 1, '2023-08-05', 0.00),
(2, 2, '2023-08-10', 0.00),
(3, 3, '2023-08-12', 0.00),
(4, 1, '2023-09-01', 0.00);

INSERT INTO item_venda VALUES 
(1, 101, 1, 4500.00),
(1, 103, 2, 1500.00),
(2, 102, 1, 5500.00),
(3, 101, 2, 4500.00),
(3, 104, 1, 1800.00),
(4, 103, 1, 1500.00);
