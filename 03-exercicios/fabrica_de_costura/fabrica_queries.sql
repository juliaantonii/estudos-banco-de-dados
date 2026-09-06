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
	valor DECIMAL(10,2) NOT NULL, -- meio = salario_fixo | costureira = salario
	gratificacao DECIMAL(10,2), -- meio = gratificacao | costureira = 0
	produtividade DECIMAL(10,2), -- meio = 0 | costureira = Valor a ser calculado
	salario_bruto DECIMAL(10,2) NOT NULL, -- meio = valor + gratificacao | costureira = valor + produtividade(qt_vend * preco_pec * aliquota_fixa)
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
DECLARE 
    -- Variáveis para os registros das iterações
    reg_meio RECORD;
    reg_cost RECORD;
    
    -- Variáveis de cálculo
    v_salario_bruto DECIMAL(10,2);
    v_produtividade DECIMAL(10,2);
BEGIN

    --------------------------------------------------------------------
    -- 1. PROCESSA FUNCIONÁRIOS DA ÁREA MEIO
    --------------------------------------------------------------------
    -- O FOR ... IN percorre cada linha retornada pela consulta automaticamente
    FOR reg_meio IN 
        SELECT m.matricula, m.salario_fixo, COALESCE(m.gratificacao, 0) AS gratificacao
        FROM meio as m
    LOOP
        -- Acesso aos campos via reg_meio.nome_do_campo
        v_salario_bruto := reg_meio.salario_fixo + reg_meio.gratificacao;
        
        INSERT INTO PAGAMENTO (
            ano_pgto, mes_pgto, matricula, valor, gratificacao, produtividade, salario_bruto
        ) VALUES (
            ano, mes, reg_meio.matricula, reg_meio.salario_fixo, reg_meio.gratificacao, 0.00, v_salario_bruto
        );
    END LOOP;

    --------------------------------------------------------------------
    -- 2. PROCESSA COSTUREIRAS
    --------------------------------------------------------------------
    FOR reg_cost IN 
        SELECT c.matricula, c.valor_minimo, c.aliquota_fixa
        FROM costureira as c
    LOOP
        -- Calcula a produtividade INDIVIDUAL desta costureira específica no mês/ano
        SELECT COALESCE(SUM(1 * pc.preco_venda * reg_cost.aliquota_fixa), 0.00)
        INTO v_produtividade
        FROM producao as p
        JOIN peca as pc ON p.id_peca = pc.id_peca
        WHERE p.matricula = reg_cost.matricula
          AND EXTRACT(MONTH FROM p.dt_ini) = mes
          AND EXTRACT(YEAR FROM p.dt_ini) = ano;

        -- Renda Total = Valor Mínimo + Produtividade
        v_salario_bruto := reg_cost.valor_minimo + v_produtividade;
        
        INSERT INTO PAGAMENTO (
            ano_pgto, mes_pgto, matricula, valor, gratificacao, produtividade, salario_bruto
        ) VALUES (
            ano, mes, reg_cost.matricula, reg_cost.valor_minimo, 0.00, v_produtividade, v_salario_bruto
        );
    END LOOP;

END;
$$ LANGUAGE 'plpgsql';

CALL sp_calcula_pgto(8, 2023);

SELECT * FROM PAGAMENTO ORDER BY matricula;

/*
REFLEXÃO TÉCNICA:
- Quais colunas devem compor a Chave Primária (PK) da tabela PAGAMENTO?
- O que acontece se a rotina for executada duas vezes para o mesmo mês/ano?
- Como garantir que registros anteriores não sejam sobrescritos acidentalmente?
*/

-- Digite sua solução aqui: