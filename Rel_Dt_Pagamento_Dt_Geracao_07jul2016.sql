--SELECT * FROM ly_cheques WHERE NUMERO= '35'

--SELECT * FROM LY_PLANO_PGTO_PERIODO WHERE resp = '01947786571'

--SELECT * FROM HD_USUARIO hu WHERE hu.USUARIO = '01947786571'

--SELECT * FROM ly_aluno WHERE aluno IN ('160520052','160520171','160520234')
--SELECT * FROM ly_item_cred WHERE LANC_CRED = '21472'
--SELECT * FROM LY_LANC_CREDITO WHERE LANC_CRED = '21472'

SELECT	IC.LANC_CRED PAGAMENTO, 
		IC.COBRANCA, 
		IC.VALOR, 
		CONVERT(CHAR(10),IC.DATA,103) DATA_GERACAO, 
		CONVERT(CHAR(10),LC.DT_CREDITO,103) DATA_PAGAMENTO, 
		A.ALUNO, 
		A.NOME_COMPL,
		IC.USUARIO,
		U.NOME NOME_USUARIO
FROM LY_LANC_CREDITO LC
JOIN LY_ITEM_CRED IC ON IC.LANC_CRED = LC.LANC_CRED
JOIN LY_PLANO_PGTO_PERIODO PPP ON PPP.RESP = LC.RESP
JOIN LY_ALUNO A ON A.ALUNO = PPP.ALUNO
JOIN HD_USUARIO U ON U.USUARIO = IC.USUARIO
WHERE LC.DT_CREDITO > IC.DATA AND IC.VALOR < -1
