/*
====================================================================
  UNIVERSIDADE FEDERAL DE MATO GROSSO DO SUL (UFMS)
  REVISÃO PRÁTICA DE BANCO DE DADOS 2
  Profª. Ivone | Modelo: Fábrica de Costura
====================================================================

INSTRUÇÕES:
Considere os modelos conceitual e lógico (ER e DER) da Fábrica de Costura 
disponibilizados em aula para responder às questões a seguir.

--------------------------------------------------------------------
1. FUNÇÃO: Total Produzido por Costureira (fn_total_produzido)
--------------------------------------------------------------------
Para mensurar rapidamente o volume de trabalho individual de cada costureira, crie uma 
função que receba como parâmetros:
  - Matrícula da costureira
  - Mês de referência (1-12)
  - Ano de referência (YYYY)

Retorno: Quantidade total de registros de produção da costureira no 
período especificado.
*/

-- Digite sua solução aqui:

CREATE OR REPLACE FUNCTION fn_total_produzido(matricula_input INT, mes INT, ano INT)
RETURNS INT
AS $$
DECLARE qtd_prod INT;
BEGIN
	SELECT COUNT(p.matricula) INTO qtd_prod
	FROM producao as P
	WHERE matricula_input = p.matricula 
		AND EXTRACT(MONTH FROM dt_fim) = mes
		AND EXTRACT(YEAR FROM dt_fim) = ano
	GROUP BY p.matricula;

	RETURN qtd_prod;
END;
$$ LANGUAGE 'plpgsql';

SELECT fn_total_produzido(6, 8, 2023);

DROP FUNCTION fn_total_produzido;

SELECT *
FROM producao
WHERE matricula = 6;

/*
--------------------------------------------------------------------
2. STORED PROCEDURE: Iniciar Manutenção de Máquina (sp_inicia_manutencao)
--------------------------------------------------------------------
Para garantir a integridade do fluxo operacional quando um equipamento 
apresenta defeito, crie uma Stored Procedure que receba o identificador 
da máquina e atualize seu status no sistema para 'manutenção'.
*/

-- Digite sua solução aqui:

CREATE OR REPLACE PROCEDURE sp_inicia_manutencao(id_maquina_input INT)
AS $$
BEGIN
	UPDATE maquina
	SET situacao = 'manutenção'
	WHERE id_maquina = id_maquina_input;
END;
$$ LANGUAGE 'plpgsql';

CALL sp_inicia_manutencao(4);

SELECT *
FROM maquina
/*
--------------------------------------------------------------------
3. TRIGGER: Validação de Máquina na Produção (trg_valida_maq_producao)
--------------------------------------------------------------------
Para prevenir inconsistências operacionais, uma costureira não deve 
iniciar produção em um equipamento indisponível. Crie um Trigger que, 
ANTES (BEFORE) da inserção de um registro na tabela PRODUCAO, verifique 
a situação da máquina apontada:
  - Se a situação da máquina NÃO for 'ativa', lance uma exceção 
    interrompendo a inserção e exiba uma mensagem explicativa ao usuário.
*/

-- Digite sua solução aqui:



/*
--------------------------------------------------------------------
4. PROCEDIMENTO/ROTINA: Cálculo da Folha de Pagamento
--------------------------------------------------------------------
A renda dos colaboradores é calculada com base em duas regras de negócio:

a) Funcionário da Área Meio:
   - Renda Total = Salário Fixo + Gratificação

b) Costureiras:
   - Renda Total = Valor Mínimo + Produtividade
   - Produtividade = (Qtd. Peças Produzidas no Mês * Preço de Venda da Peça * Alíquota)

TAREFAS:
1. Crie a tabela "PAGAMENTO" contendo os atributos:
   - ano_pgto (INT)
   - mes_pgto (INT)
   - matricula (FK do funcionário)
   - valor (base/mínimo)
   - gratificacao (Valor para área meio | 0.00 para costureiras)
   - produtividade (Valor calculado | 0.00 para área meio)
   - salario_bruto (Renda total calculada)
*/

CREATE TABLE PAGAMENTO (
	ano_pgto INT NOT NULL,
	mes_pgto INT NOT NULL,
	matricula INT NOT NULL,
	valor DECIMAL NOT NULL, -- meio = salario_fixo | costureira = salario
	gratificacao DECIMAL, -- meio = gratificacao | costureira = 0
	produtividade DECIMAL, -- meio = 0 | costureira = Valor a ser calculado
	salario_bruto DECIMAL NOT NULL, -- meio = valor + gratificacao | costureira = valor + produtividade(qt_vend * preco_pec * aliquota_fixa)
	PRIMARY KEY (ano_pgto, mes_pgto, matricula),
	FOREIGN KEY (matricula) REFERENCES funcionario (matricula)
);

/*
2. Desenvolva uma rotina/script que receba o mês e ano desejados, 
   calcule a renda total de TODOS os funcionários da fábrica e persista 
   os resultados na tabela PAGAMENTO.
*/

CREATE OR REPLACE PROCEDURE sp_calcula_pgto(mes INT, ano INT)
AS $$
BEGIN
	SELECT id_matricula as 
	IF 
	INSERT INTO PAGAMENTO VALUES (ano, mes, )
	VALUES (id_pgto, )
END;
$$ LANGUAGE 'plpgsql';

/*
REFLEXÃO TÉCNICA:
- Quais colunas devem compor a Chave Primária (PK) da tabela PAGAMENTO?
- O que acontece se a rotina for executada duas vezes para o mesmo mês/ano?
- Como garantir que registros anteriores não sejam sobrescritos acidentalmente?
*/

-- Digite sua solução aqui: