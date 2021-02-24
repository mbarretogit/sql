SELECT	DISTINCT
		VW.LANC_CRED						AS [PAGAMENTO],
		VW.COBRANCA							AS [COBRANCA],
		C.ESTORNO							AS [COBRANCA_ESTORNADA],
		VW.TIPO_PAGAMENTO					AS [TIPO_PAGAMENTO],
		VW.TIPO_CREDITO						AS [TIPO_CREDITO],
		C.UNID_FISICA						AS [UNIDADE_FISICA],
		CU.CURSO							AS [CURSO],
		CU.NOME								AS [NOME_CURSO],
		A.TURNO								AS [TURNO],
		A.CURRICULO							AS [CURRICULO],
		VW.ALUNO							AS [ALUNO], 
		VW.NOME_COMPLETO					AS [NOME_ALUNO],
		VW.RESP								AS [RESPONSAVEL_FINANCEIRO],
		VW.NOME_RESP						AS [NOME_RESPONSAVEL],
		CONVERT(VARCHAR(10),C.DATA_DE_VENCIMENTO,105)		AS [DATA_VENCIMENTO],
		CONVERT(VARCHAR(10),VW.DATA_CREDITO,105)			AS [DATA_PAGAMENTO],
		CONVERT(VARCHAR(10),LC.DATA,105)					AS [DATA_RECEBIMENTO],
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = VW.COBRANCA AND IL.NUM_BOLSA IS NULL)																AS [VALOR_TITULO],
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = VW.COBRANCA)																						AS [VALOR_FATURADO],
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC1 WHERE IC1.COBRANCA = VW.COBRANCA AND IC1.TIPO_ENCARGO = 'MULTA')														AS [MULTA],
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC4 WHERE IC4.COBRANCA = VW.COBRANCA AND IC4.TIPO_ENCARGO = 'PERDEBOLSA')												AS [PERDEBOLSA],
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC2 WHERE IC2.COBRANCA = VW.COBRANCA AND IC2.TIPO_ENCARGO = 'JUROS')														AS [JUROS],
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC3 WHERE IC3.COBRANCA = VW.COBRANCA AND IC3.TIPODESCONTO IN ('Acr�scimo','Concedido','DescBanco','PagtoAntecipado'))	AS [DESCONTO],
		(SELECT ISNULL(SUM(VALOR),0) FROM LY_ITEM_CRED IC3 WHERE IC3.COBRANCA = VW.COBRANCA AND IC3.TIPODESCONTO IS NULL AND IC3.TIPO_ENCARGO IS NULL)*-1						AS [VALOR_PAGO],
		CASE WHEN EXISTS (SELECT 1 FROM LY_MATRICULA M WHERE M.ALUNO = A.ALUNO AND M.SIT_MATRICULA NOT IN ('Cancelado')) THEN 'Matriculado'
			 WHEN EXISTS (SELECT 1 FROM LY_MATRICULA M WHERE M.ALUNO = A.ALUNO AND M.SIT_MATRICULA IN ('Cancelado')) THEN 'Cancelado'
			 WHEN EXISTS (SELECT 1 FROM LY_PRE_MATRICULA M WHERE M.ALUNO = A.ALUNO) THEN 'Pr�-Matriculado' ELSE 'Ingressado' END												AS [SIT_MATRICULA]
FROM VW_FLUXO_CAIXA_REL VW
JOIN LY_ITEM_CRED IC ON IC.LANC_CRED = VW.LANC_CRED
JOIN LY_COBRANCA C ON C.COBRANCA = VW.COBRANCA
JOIN LY_LANC_CREDITO LC ON LC.LANC_CRED = VW.LANC_CRED
JOIN LY_ALUNO A ON A.ALUNO = VW.ALUNO
JOIN LY_CURSO CU ON CU.CURSO = A.CURSO
ORDER BY UNIDADE_FISICA,PAGAMENTO,COBRANCA