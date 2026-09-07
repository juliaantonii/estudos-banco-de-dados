/*
====================================================================
  SIMULADO PL/pgSQL — GESTÃO DE LOJA DE CELULARES
====================================================================
*/

/*
1. Function Básica: Crie uma função fn_calcula_desconto(p_valor DECIMAL, p_porcentagem DECIMAL) que receba
um valor e uma porcentagem de desconto e retorne o valor final com o desconto aplicado.
*/
CREATE OR REPLACE FUNCTION fn_calcula_desconto(p_valor DECIMAL, p_porcentagem DECIMAL)
RETURNS DECIMAL(10,2)
AS $$
DECLARE 
    valor_final DECIMAL(10,2);
BEGIN
    valor_final := p_valor - (p_valor / 100) * p_porcentagem;
    RETURN valor_final;
END;
$$ LANGUAGE 'plpgsql';

SELECT fn_calcula_desconto(100, 20);


/*
2. SELECT INTO + IF: Crie uma função fn_verifica_estoque(p_id_produto INT) que consulte a quantidade em estoque
do produto informado. Se o estoque for menor que 10, retorne a mensagem 'Estoque Baixo'; caso contrário, retorne
'Estoque Suficiente'.
*/
CREATE OR REPLACE FUNCTION fn_verifica_estoque(p_id_produto INT)
RETURNS TEXT
AS $$
DECLARE 
    qtd_estoque INT;
BEGIN
    SELECT estoque INTO qtd_estoque
    FROM produto
    WHERE id_produto = p_id_produto;

    IF qtd_estoque < 10 THEN
        RETURN 'Estoque Baixo';
    ELSE
        RETURN 'Estoque Suficiente';
    END IF;
END;
$$ LANGUAGE 'plpgsql';

SELECT fn_verifica_estoque(102);


/*
3. Uso de RAISE NOTICE e Sub-blocos: Crie uma procedure sp_alerta_cliente(p_id_cliente INT) que recupere o nome e a
categoria do cliente. Se a categoria for 'VIP' ou 'PREMIUM', exiba no console a mensagem: "Cliente [nome] possui
atendimento prioritário!".
*/
CREATE OR REPLACE PROCEDURE sp_alerta_cliente(p_id_cliente INT)
AS $$
DECLARE 
    p_nome VARCHAR(100); 
    p_categoria VARCHAR(20);
BEGIN
    SELECT nome, categoria INTO p_nome, p_categoria
    FROM cliente
    WHERE id_cliente = p_id_cliente;

    IF p_categoria = 'VIP' OR p_categoria = 'PREMIUM' THEN
        RAISE NOTICE 'Cliente % possui atendimento prioritário!', p_nome;
    END IF;
END;
$$ LANGUAGE 'plpgsql';

CALL sp_alerta_cliente(2);


/*
4. Procedure de Atualização: Crie uma procedure sp_atualiza_total_venda(p_id_venda INT) que calcule o valor total dos
itens da venda informada (Soma de quantidade x preco_aplicado) e atualize o campo total_venda na tabela venda.
*/
CREATE OR REPLACE PROCEDURE sp_atualiza_total_venda(p_id_venda INT)
AS $$
DECLARE 
    p_total_venda DECIMAL(10,2) := 0;
BEGIN
    SELECT COALESCE(SUM(quantidade * preco_aplicado), 0) INTO p_total_venda
    FROM item_venda
    WHERE id_venda = p_id_venda;
        
    UPDATE venda
    SET total_venda = p_total_venda
    WHERE id_venda = p_id_venda;
END;
$$ LANGUAGE 'plpgsql';

CALL sp_atualiza_total_venda(1);


/*
5. Uso de %ROWTYPE ou RECORD: Crie uma função fn_dados_produto(p_id_produto INT) que busque um produto e retorne uma
variável do tipo RECORD (ou %ROWTYPE) contendo o modelo e o preço unitário do produto.
*/
CREATE OR REPLACE FUNCTION fn_dados_produto(p_id_produto INT)
RETURNS RECORD
AS $$
DECLARE 
    reg_modelo_preco RECORD;
BEGIN
    SELECT modelo, preco_unitario INTO reg_modelo_preco
    FROM produto
    WHERE id_produto = p_id_produto;

    RETURN reg_modelo_preco;
END;
$$ LANGUAGE 'plpgsql';

SELECT * FROM fn_dados_produto(101) AS (modelo VARCHAR, preco DECIMAL);


/*
6. Lógica de Negócio com IF Encadeado: Crie uma função fn_calcula_frete(p_id_cliente INT, p_valor_compra DECIMAL) que
determine o valor do frete com base na categoria do cliente:
- 'PREMIUM': Frete grátis (0.00).
- 'VIP': Frete fixo de 15.00.
- 'PADRAO': Se a compra for superior a 3000.00, frete de 20.00; caso contrário, frete de 50.00.
*/
CREATE OR REPLACE FUNCTION fn_calcula_frete(p_id_cliente INT, p_valor_compra DECIMAL)
RETURNS DECIMAL(10,2)
AS $$
DECLARE 
    valor_frete DECIMAL(10,2) := 0;
    p_categoria VARCHAR(20);
BEGIN
    SELECT categoria INTO p_categoria
    FROM cliente
    WHERE id_cliente = p_id_cliente;

    IF p_categoria = 'PADRAO' AND p_valor_compra <= 3000 THEN
        valor_frete := 50.00;
    ELSIF p_categoria = 'PADRAO' AND p_valor_compra > 3000 THEN
        valor_frete := 20.00;
    ELSIF p_categoria = 'VIP' THEN
        valor_frete := 15.00;
    ELSE
        valor_frete := 0.00;
    END IF;

    RETURN valor_frete;
END;
$$ LANGUAGE 'plpgsql';

SELECT fn_calcula_frete(1, 3001);


/*
7. FOR RECORD IN SELECT: Crie uma procedure sp_processa_totais_vendas() que utilize um laço FOR para percorrer todas as
vendas cadastradas na tabela venda e execute o cálculo/atualização do campo total_venda para cada uma delas.
*/
CREATE OR REPLACE PROCEDURE sp_processa_totais_vendas()
AS $$
DECLARE 
    reg_venda RECORD;
BEGIN
    FOR reg_venda IN SELECT id_venda FROM venda LOOP
        CALL sp_atualiza_total_venda(reg_venda.id_venda);
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';

CALL sp_processa_totais_vendas();

/*
8. Validação de Transação e Manipulação de Estoque:
Crie uma procedure sp_registrar_item_venda(p_id_venda INT, p_id_produto INT, p_quantidade INT) que:
  - Consulte o estoque atual do produto e seu preço unitário.
  - Se o estoque for SUFICIENTE (estoque >= p_quantidade):
      * Insira o item na tabela 'item_venda' usando o preço unitário consultado.
      * Subtraia a quantidade inserida do estoque na tabela 'produto'.
      * Exiba com RAISE NOTICE: 'Item registrado com sucesso!'.
  - Se NÃO for suficiente:
      * Exiba com RAISE NOTICE: 'Estoque insuficiente para o produto %'.
*/

-- Escreva seu código da questão 8 aqui:

CREATE OR REPLACE PROCEDURE sp_registrar_item_venda(p_id_venda INT, p_id_produto INT, p_quantidade INT)
AS $$
DECLARE p_modelo VARCHAR(100);
		p_estoque INT;
		p_preco_unitario DECIMAL(10,2);
		p_qtd_prod INT;
BEGIN
	SELECT modelo, estoque, preco_unitario INTO p_modelo, p_estoque, p_preco_unitario
	FROM produto
	WHERE id_produto = p_id_produto;

	SELECT quantidade INTO p_qtd_prod
	FROM item_venda
	WHERE id_venda = p_id_venda;

	IF p_estoque >= p_quantidade THEN
		INSERT INTO item_venda VALUES(p_id_venda, p_id_produto, p_quantidade, (p_preco_unitario * p_quantidade));

		UPDATE produto
		SET estoque = p_estoque - p_quantidade
		WHERE id_produto = p_id_produto;

		RAISE NOTICE 'Item registrado com sucesso!';
	ELSE
		RAISE NOTICE 'Estoque insuficiente para o produto %', p_modelo;
	END IF;

END;
$$ LANGUAGE 'plpgsql';

CALL sp_registrar_item_venda(2, 104, 2);

SELECT * FROM cliente;
SELECT * FROM produto;
SELECT * FROM venda;
SELECT * FROM item_venda;


/*
9. Retorno de Múltiplos Registros com SETOF RECORD:
Crie uma função fn_relatorio_compras_cliente(p_id_cliente INT)
RETURNS SETOF RECORD que percorra todas as vendas do cliente informado e
retorne as colunas: (id_venda INT, dt_venda DATE, total_venda DECIMAL).
Dica: Utilize FOR reg IN SELECT ... LOOP e RETURN NEXT reg;
*/

-- Escreva seu código da questão 9 aqui:



/*
10. Desafio Completo (Integração de Conceitos):
Crie a procedure sp_fechar_mes_vendas(p_mes INT, p_ano INT) que:
  - Percorra todas as vendas realizadas no mês (EXTRACT(MONTH FROM dt_venda)) e ano (EXTRACT(YEAR FROM dt_venda)) informados.
  - Para cada venda, recupere a categoria do cliente e aplique um desconto no total_venda atual:
      * VIP: 5% de desconto
      * PREMIUM: 10% de desconto
      * PADRAO: 0% de desconto
  - Atualize a coluna total_venda na tabela com esse novo valor descontado.
  - Mantenha variáveis contadoras para exibir ao final via RAISE NOTICE:
      * A quantidade total de vendas processadas.
      * O valor total faturado no mês (soma dos totais de todas as vendas processadas).
*/

-- Escreva seu código da questão 10 aqui: