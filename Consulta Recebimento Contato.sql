
SELECT	DISTINCT
		A.UNIDADE_FISICA AS COD_UNIDADE,
		UF.NOME_COMP AS NOME_UNIDADE,
		CUR.TIPO,
		LC.LANC_CRED,
		C.COBRANCA,
		C.ESTORNO AS COBRANCA_ESTORNADA,
		C.DT_ESTORNO AS DATA_ESTORNO,
		ISNULL(LC.TIPO_PAGAMENTO,'') AS TIPO_PAGAMENTO,
		ISNULL(LC.TIPO_CRED,'') AS TIPO_CREDITO,
		CUR.TIPO AS TIPO_CURSO,
		C.CURSO AS COD_CURSO,
		CUR.NOME AS NOME_CURSO,
		C.ALUNO, 
		A.NOME_COMPL AS NOME_ALUNO,
		C.RESP AS RESPONSAVEL,
		CASE WHEN RF.CPF_TITULAR IS NULL    
			THEN dbo.fn_FormataNumeroCNPJ(rf.CGC_TITULAR)    
			ELSE dbo.fn_FormataNumeroCPF(rf.CPF_TITULAR) 
		END AS DOCUMENTO_TITULAR, 
		CONVERT(DATETIME, '01-' + STR(C.mes)  + '-' + STR(CASE WHEN C.ANO < 1901 THEN 1900 ELSE C.ANO END), 105) AS DATAREF,
		CONVERT(DATETIME,C.DATA_DE_VENCIMENTO,105) AS DATA_VENCIMENTO,
		CONVERT(DATETIME,LC.DT_CREDITO,105) AS DATA_PAGAMENTO,
		CONVERT(DATETIME,LC.DATA,105) AS DATA_RECEBIMENTO,
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = C.COBRANCA AND IL.ITEM_ESTORNADO IS NULL AND IL.NUM_BOLSA IS NULL) AS VALOR_BRUTO,
		(SELECT ISNULL(SUM(VALOR),0)*-1 FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = C.COBRANCA AND IL.ITEM_ESTORNADO IS NULL AND IL.NUM_BOLSA IS NOT NULL) AS BOLSA,
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC1 WHERE IC1.COBRANCA = C.COBRANCA AND IC1.TIPO_ENCARGO = 'MULTA') AS MULTA,
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC4 WHERE IC4.COBRANCA = C.COBRANCA AND IC4.TIPO_ENCARGO = 'PERDEBOLSA') AS PERDEBOLSA,
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC2 WHERE IC2.COBRANCA = C.COBRANCA AND IC2.TIPO_ENCARGO = 'JUROS') AS JUROS,
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC3 WHERE IC3.COBRANCA = C.COBRANCA AND IC3.TIPODESCONTO IN ('Acr�scimo','Concedido','DescBanco','PagtoAntecipado')) AS DESCONTO,
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC3 WHERE IC3.COBRANCA = C.COBRANCA AND IC3.TIPODESCONTO IS NULL AND IC3.TIPO_ENCARGO IS NULL)*-1 AS VALOR_PAGO,
		P.DDD_FONE,
		P.FONE,
		P.DDD_FONE_CELULAR,
		P.CELULAR,
		P.E_MAIL
FROM LY_COBRANCA C
JOIN LY_ALUNO A ON A.ALUNO = C.ALUNO
JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA
JOIN LY_RESP_FINAN RF ON RF.RESP = C.RESP
JOIN LY_CURSO CUR ON CUR.CURSO = C.CURSO
JOIN LY_ITEM_CRED IC ON IC.COBRANCA = C.COBRANCA
JOIN LY_LANC_CREDITO LC ON LC.LANC_CRED = IC.LANC_CRED
JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = C.UNID_FISICA
JOIN VW_LANCAMENTOS_PAGAMENTOS LP ON LP.COBRANCA = C.COBRANCA
WHERE  C.ESTORNO = 'N' AND C.DT_ESTORNO IS NULL AND CUR.TIPO IN ('GRADUACAO','TECNOLOGO') AND C.NUM_COBRANCA IN (1,2,4,5) AND LC.DT_CREDITO BETWEEN '2018-07-01' AND GETDATE()
AND C.ANO = 2018 AND C.MES > 6
ORDER BY 1,11,13