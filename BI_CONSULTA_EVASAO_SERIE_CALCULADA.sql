USE FTC_DATAMART
GO

DROP TABLE  #TEMP
 
SELECT	ANO,
		SEMESTRE,
		UNIDADE_ENSINO_ALUNO,
		NOME_UNIDADE_ENSINO_ALUNO,
		UNIDADE_FISICA_ALUNO,
		TIPO_CURSO,
		CURSO,
		NOME_CURSO,
		ALUNO,
		NOME_ALUNO,
		STATUS_FTC,
		TIPO_FINAN,
		'N' AS EVADIDO,
		NULL AS SERIE_CALCULADA
INTO #TEMP
FROM BI_REMATRICULA 
WHERE 1=1
AND TIPO_ALUNO IN ('CALOURO','CALOURO-CONCLUINTE')
AND STATUS_FTC IN ('MATRICULADO PAGO','PRE-MATRICULADO PAGO','CONCLUIDO','INCONCLUIDO')
AND TIPO_INGRESSO IN ('Vestibular','Enem','FIES','ProUni','Outros','Mandado de Seguranša')
AND ANO < 2020


UPDATE T 
SET T.EVADIDO = 'S'
FROM #TEMP T
WHERE EXISTS (SELECT TOP 1 1 
				FROM BI_REMATRICULA BI
				WHERE BI.ALUNO = T.ALUNO 
				AND BI.STATUS_FTC NOT IN ('MATRICULADO PAGO','PRE-MATRICULADO PAGO','CONCLUIDO','INCONCLUIDO')
				AND BI.ANO < 2020
				AND CONCAT(BI.ANO,BI.SEMESTRE) >= CONCAT(T.ANO,T.SEMESTRE))

UPDATE T
SET T.SERIE_CALCULADA = (SELECT MAX(BI.SERIE_CALCULADA)
							FROM BI_REMATRICULA BI
							WHERE BI.ALUNO = T.ALUNO
							AND BI.STATUS_FTC IN ('MATRICULADO PAGO','PRE-MATRICULADO PAGO','CONCLUIDO','INCONCLUIDO')
							AND BI.ANO < 2020)
FROM #TEMP T
WHERE EVADIDO = 'N'

UPDATE T
SET T.SERIE_CALCULADA = (SELECT MAX(BI.SERIE_CALCULADA)
							FROM BI_REMATRICULA BI
							WHERE BI.ALUNO = T.ALUNO
							AND BI.STATUS_FTC NOT IN ('MATRICULADO PAGO','PRE-MATRICULADO PAGO','CONCLUIDO','INCONCLUIDO')
							AND BI.ANO < 2020)
FROM #TEMP T
WHERE EVADIDO = 'S'

SELECT * FROM #TEMP
ORDER BY 1,2


--SELECT * FROM #TEMP WHERE ALUNO = '181030524'