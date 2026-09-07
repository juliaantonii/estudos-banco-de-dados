/*
===============================================================================
UNIVERSIDADE FEDERAL DE MATO GROSSO DO SUL Campus de Três Lagoas
Bacharelado em Sistemas de Informação
Laboratório de Banco de Dados
Atividade Presença - anteposição 17/09/2026
Function, Store Procedure, Triggers
===============================================================================
*/

-- Feito por: Julia Antoni Saab
-- ============================================================================
-- EXERCÍCIO 01
-- ============================================================================
/*
O RH solicitou o cadastro do CPF dos funcionários, ao cadastrar um novo funcionário.
Faça uma função para validar o CPF informado no campo de cadastro novo na tabela
funcionário. Como a restrição CHECK não suporta lógicas complexas de
laços e somatórios, você foi contratado para fazer uma função genérica que recebe o CPF
como uma string de 11 caracteres e devolve verdadeiro quando o dígito verificador
do CPF está correto.
*/

CREATE OR REPLACE FUNCTION fn_valida_cpf(p_cpf VARCHAR)
RETURNS BOOL
AS $$
BEGIN
	IF LENGTH(p_cpf) = 11 AND p_cpf ~ '^[0-9]+$' THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

SELECT fn_valida_cpf('00000000000');

-- ============================================================================
-- EXERCÍCIO 02
-- ============================================================================
/*
O campo 'valor_minimo' na tabela costureira indica o piso daquela funcionária.
Crie uma função que receba a matrícula e retorne TRUE se o salário atual for
maior ou igual ao valor mínimo, e FALSE caso a funcionária esteja recebendo
abaixo do piso estabelecido para ela.
*/

CREATE OR REPLACE FUNCTION fn_verifica_piso(p_matricula INT)
RETURNS BOOL
AS $$
DECLARE p_salario DECIMAL(10,2);
		p_valor_min DECIMAL(10,2);
BEGIN
	SELECT salario, valor_minimo INTO p_salario, p_valor_min
	FROM costureira
	WHERE matricula = p_matricula;

	IF p_salario >= p_valor_min THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

SELECT fn_verifica_piso(6);

-- ============================================================================
-- EXERCÍCIO 03
-- ============================================================================
/*
Faça uma função que receba uma hora (TIME) e retorne uma string indicando o
turno ('Manhã', 'Tarde', 'Noite') para classificar as inserções na tabela produção.
*/

CREATE OR REPLACE FUNCTION fn_verifica_turno(p_hora TIME)
RETURNS TEXT
AS $$
DECLARE
BEGIN
	IF EXTRACT(HOUR FROM p_hora) >= 5 AND EXTRACT(HOUR FROM p_hora) < 12 THEN
		RETURN 'Manhã';
	ELSIF EXTRACT(HOUR FROM p_hora) >= 12 AND EXTRACT(HOUR FROM p_hora) < 18 THEN
		RETURN 'Tarde';
	ELSE
		RETURN 'Noite';
	END IF;
END;
$$ LANGUAGE 'plpgsql';

SELECT fn_verifica_turno('04:59:00');

-- ============================================================================
-- EXERCÍCIO 04
-- ============================================================================
/*
A fábrica começou a exportar e precisa visualizar o preço de venda de cada peça
em outras moedas. Suponha que existe uma tabela TAXA_CAMBIO_BCB com o valor da
taxa de conversão de venda que é sincronizada automaticamente com o Banco Central
diariamente.

a) Faça uma função que receba o número de identificação da peça, a sigla do país e
   a taxa de câmbio e devolve o valor convertido.
*/

CREATE OR REPLACE FUNCTION fn_converte_cambio(p_id_peca INT, p_sigla VARCHAR, p_tx_cambio DECIMAL)
RETURNS DECIMAL
AS $$
DECLARE p_preco_venda DECIMAL(10,2);
		valor_convertido DECIMAL(10,2) := 0;
BEGIN
	SELECT preco_venda INTO p_preco_venda
	FROM peca
	WHERE id_peca = p_id_peca;

	valor_convertido := p_preco_venda / p_tx_cambio;
	RETURN valor_convertido;
END;
$$ LANGUAGE 'plpgsql';

SELECT fn_converte_cambio(1, 'BR', 5.13);

SELECT * FROM peca;
)

/*
b) EXTRA: Faça uma nova função que receba o número de identificação da peça e a
   sigla do país e devolve o valor convertido, para isso considere as informações
   sobre a tabela TAXA_CAMBIO_BCB.

   O Banco Central do Brasil (BCB) disponibiliza diariamente os dados de fechamento
   oficial das taxas de câmbio da moeda brasileira (BRL) para os principais países
   com transações comerciais com o Brasil. Esses dados são armazenados em um
   arquivo texto e podem ser obtidos do site do BCB diariamente. O formato deste
   arquivo usa o caractere ponto-e-vígula (';') como separador entre as colunas
   (data, código, tipo, símbolo, taxaCompra, taxaVenda, paridadeDolarCompra,
   paridadeDolarCompra). Suponha que a tabela taxa_cambio_bcb foi criada pelo SQL:

   CREATE TABLE taxa_cambio_bcb (
       id_taxa SERIAL PRIMARY KEY,
       data_cotacao DATE NOT NULL,
       sigla_moeda_destino VARCHAR(3) NOT NULL,
       taxa_compra DECIMAL (10,4) NOT NULL,
       taxa_venda DECIMAL (10,4) NOT NULL,
       CONSTRAINT unq_ct_dia UNIQUE (data_cotacao, sigla_moeda_destino)
   );
*/


-- ============================================================================
-- EXERCÍCIO 05
-- ============================================================================
/*
O RH definiu que todo o setor 'TI' da tabela meio deve ter uma gratificação
padrão de R$ 1500,00, exceto se a gratificação atual já for maior. Crie uma
procedure para aplicar essa regra.
*/

CREATE OR REPLACE PROCEDURE sp_att_gratificacao()
AS $$
DECLARE reg_meio RECORD;
BEGIN
	FOR reg_meio IN
		SELECT matricula
		FROM meio
		WHERE gratificacao <= 1500
	LOOP
		UPDATE meio
		SET gratificacao = 1500
		WHERE matricula = reg_meio.matricula;
	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CALL sp_att_gratificacao();

select * from meio

-- ============================================================================
-- EXERCÍCIO 06
-- ============================================================================
/*
O custo do tecido aumentou. Crie uma procedure que receba uma palavra-chave do
modelo (ex: 'Camisa') na tabela peca e um percentual de aumento. Todos os
modelos que contenham essa palavra terão seu preco_venda reajustado.
*/

CREATE OR REPLACE PROCEDURE sp_att_custo_tecido(p_wkey VARCHAR, p_perc DECIMAL)
AS $$
DECLARE reg_peca RECORD;
BEGIN
	FOR reg_peca IN
		SELECT id_peca, modelo, preco_venda
		FROM peca
		WHERE modelo LIKE '%' || p_wkey || '%'
	LOOP
		UPDATE peca
		SET preco_venda = reg_peca.preco_venda + (reg_peca.preco_venda * p_perc)
		WHERE id_peca = reg_peca.id_peca;
	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CALL sp_att_custo_tecido('Camisa', 0.5);

select * from peca

-- ============================================================================
-- EXERCÍCIO 07
-- ============================================================================
/*
Quando uma costureira é promovida a supervisora, a alíquota fixa sobre produção
aumenta em 20% e ela deixa de ter um supervisor (coluna costureira_supervisora
fica NULA). Crie uma procedure para executar essa transação.
*/

CREATE OR REPLACE PROCEDURE sp_att_supervisora(p_matricula INT)
AS $$
DECLARE att_aliquota_fixa DECIMAL := 0;
		reg_costureiras RECORD;
BEGIN
	UPDATE costureira
	SET costureira_supervisora = NULL
	WHERE matricula = p_matricula;

	FOR reg_costureiras IN
		SELECT matricula, aliquota_fixa
		FROM costureira
	LOOP
		UPDATE costureira
		SET aliquota_fixa = reg_costureiras.aliquota_fixa * 1.20
		WHERE matricula = reg_costureiras.matricula;
	END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CALL sp_att_supervisora(6);
select * from costureira;

-- ============================================================================
-- EXERCÍCIO 08
-- ============================================================================
/*
A fábrica assinou um contrato e todas as máquinas de um fabricante específico
passarão por revisão sob supervisão de uma costureira. Faça uma procedure que
receba o nome do fabricante e a matrícula da costureira que supervisionará a
manutenção e crie um registro na tabela manutenção para cada máquina dele e mude
a situação dessas máquinas para 'MANUTENÇÃO'.
*/

CREATE OR REPLACE PROCEDURE sp_superv_maq(p_fabricante VARCHAR, p_matricula INT)
AS $$
DECLARE reg_maquina RECORD;
		v_novo_id INT;
BEGIN
	FOR reg_maquina IN
        SELECT id_maquina
        FROM maquina
        WHERE fabricante = p_fabricante
    LOOP
		SELECT COALESCE(MAX(id_manutencao), 0) + 1 INTO v_novo_id FROM manutencao;

        INSERT INTO manutencao(id_manutencao, dt_inicio, id_maquina, id_monitora)
        VALUES (v_novo_id, CURRENT_DATE, reg_maquina.id_maquina, p_matricula);

        UPDATE maquina
        SET situacao = 'MANUTENÇÃO'
        WHERE id_maquina = reg_maquina.id_maquina;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CALL sp_superv_maq('SINGER', 9);

select * from maquina;
select * from costureira;

-- ============================================================================
-- EXERCÍCIO 09
-- ============================================================================
/*
É preciso criar um log sempre que o salário de uma costureira for alterado.
Crie uma tabela de auditoria e um ou mais trigger para registrar as mudanças
no salário dos funcionários.

Tabela de auditoria:
CREATE TABLE log_salario_funcionarios (
    id_log SERIAL PRIMARY KEY,
    matricula INT,
    salario_antigo DECIMAL (10,2),
    salario_novo DECIMAL (10,2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
*/

CREATE TABLE log_salario_funcionarios (
    id_log SERIAL PRIMARY KEY,
    matricula INT,
    salario_antigo DECIMAL (10,2),
    salario_novo DECIMAL (10,2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_log_alteracao_salario()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.salario IS DISTINCT FROM NEW.salario THEN
        INSERT INTO log_salario_funcionarios (matricula, salario_antigo, salario_novo)
        VALUES (OLD.matricula, OLD.salario, NEW.salario);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON funcionario
FOR EACH ROW
EXECUTE FUNCTION fn_log_alteracao_salario();


-- ============================================================================
-- EXERCÍCIO 10
-- ============================================================================
/*
Um erro comum no sistema é cadastrar a própria matrícula da costureira no campo
costureira_supervisora. Implemente um trigger na tabela costureira para impedir
que isso aconteça.
*/

CREATE OR REPLACE FUNCTION fn_verifica_cost_super()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.matricula = NEW.costureira_supervisora THEN
        RAISE EXCEPTION 'Erro: Uma costureira não pode ser supervisora de si mesma!';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trg_impede
BEFORE INSERT OR UPDATE ON costureira
FOR EACH ROW
EXECUTE FUNCTION fn_verifica_cost_super();




-- ============================================================================
-- EXERCÍCIO 11
-- ============================================================================
/*
Para manter o padrão visual, crie um trigger que, antes de inserir ou atualizar
um registro na tabela funcionario converta o nome para letras maiúsculas
automaticamente.
*/

CREATE OR REPLACE FUNCTION fn_converter_nome_maiusculo()
RETURNS TRIGGER AS $$
BEGIN
    NEW.nome = UPPER(NEW.nome);
    
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trg_maiusculo_funcionario
BEFORE INSERT OR UPDATE ON funcionario
FOR EACH ROW
EXECUTE FUNCTION fn_converter_nome_maiusculo();