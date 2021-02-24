USE LYCEUM
GO

IF (NOT EXISTS (SELECT * 
                 FROM LYCEUMINTEGRACAO.INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'BI_FATURAMENTO'))
	BEGIN

	--DROP TABLE LYCEUMINTEGRACAO..BI_FATURAMENTO
	--AY_VW_FATURAMENTO
	CREATE TABLE LYCEUMINTEGRACAO..BI_FATURAMENTO
	(
		COD_UNIDADE T_CODIGO,
		NOME_UNIDADE T_ALFALARGE,
		ALUNO T_CODIGO,
		RESP T_CODIGO,
		TIPO_CURSO T_CODIGO,
		COD_CURSO T_CODIGO,
		NOME_CURSO T_ALFALARGE,
		COBRANCA T_NUMERO,
		TIPO_COBRANCA VARCHAR(20),
		DATA_DE_VENCIMENTO T_DATA,
		ANO_REF T_ANO,
		MES_REF T_MES,
		VALOR_FATURADO DECIMAL(10,2)
	)


	END

ELSE

	BEGIN 

		DELETE FROM LYCEUMINTEGRACAO..BI_FATURAMENTO

END

	INSERT INTO LYCEUMINTEGRACAO..BI_FATURAMENTO
	SELECT
		F.UNIDADE_FISICA AS COD_UNIDADE,
		UF.NOME_COMP AS NOME_UNIDADE,
		F.ALUNO,
		F.RESP,
		C.TIPO AS TIPO_CURSO,
		F.CURSO AS COD_CURSO,
		C.NOME AS NOME_CURSO,
		F.COBRANCA,
		CASE CO.NUM_COBRANCA  
			WHEN 1 THEN 'MENSALIDADE'  
            WHEN 2 THEN 'SERVICO'  
            WHEN 3 THEN 'ACORDO'  
            WHEN 4 THEN 'OUTROS'  
            WHEN 5 THEN 'CHEQUE DEVOLVIDO'  
			ELSE NULL END AS TIPO_COBRANCA,
		F.DT_VENC AS DATA_DE_VENCIMENTO,
		F.ANO_REF,
		F.MES_REF,
		SUM(VALOR_BRUTO) AS VALOR_FATURADO
	FROM AY_VW_FATURAMENTO F
	JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = F.UNIDADE_FISICA
	JOIN LY_CURSO C ON C.CURSO = F.CURSO
	JOIN LY_COBRANCA CO ON CO.COBRANCA = F.COBRANCA
	JOIN LY_ITEM_LANC 
	JOIN LY_LANC_DEBITO LD ON LD
	WHERE not exists (select top 1 1 from  AY_VW_FATURAMENTO where COBRANCA = f.COBRANCA and EVENTO_NUM IN (1001))
	GROUP BY
		F.UNIDADE_FISICA, UF.NOME_COMP, F.ALUNO, F.RESP, C.TIPO, F.CURSO, C.NOME,F.COBRANCA, CO.NUM_COBRANCA,F.DT_VENC, F.ANO_REF, F.MES_REF