USE LYCEUM
GO

DROP TABLE #TEMP

SELECT DISTINCT UF.UNIDADE_FIS, 
				UF.NOME_COMP,
				C.TIPO, 
				C.CURSO, 
				C.NOME,
				A.ALUNO,
				P.CPF,
				A.NOME_COMPL,
				CONCAT(A.ANO_INGRESSO,'/',A.SEM_INGRESSO) AS PERIODO_INGRESSO,
				CAST('' AS VARCHAR(7)) AS ULTIMA_MATRICULA,
				A.SIT_ALUNO, 
				CAST('' AS VARCHAR(10)) AS DT_ENCERRAMENTO,
				CAST('' AS VARCHAR(30)) AS MOTIVO_ENCERRAMENTO
INTO #TEMP
FROM LY_ALUNO A
JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA
JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = A.UNIDADE_FISICA
JOIN LY_CURSO C ON C.CURSO = A.CURSO
WHERE C.TIPO IN ('GRADUACAO','GRADUACAO-EAD','GRADUACAO-SP','POS-GRADUACAO','TECNOLOGO')
AND (	EXISTS (SELECT TOP 1 1 FROM LY_HISTMATRICULA HM WHERE HM.ALUNO = A.ALUNO AND HM.SITUACAO_HIST NOT IN ('Cancelado','Dispensado'))
		OR EXISTS(SELECT TOP 1 1 FROM VW_MATRICULA_E_PRE_MATRICULA VW WHERE VW.ALUNO = A.ALUNO AND VW.SIT_MATRICULA NOT IN ('Cancelado','Dispensado'))
	)

UPDATE T SET ULTIMA_MATRICULA = (SELECT MAX(CONCAT(HM.ANO,'/',HM.SEMESTRE)) FROM LY_HISTMATRICULA HM WHERE HM.ALUNO = T.ALUNO AND HM.SITUACAO_HIST NOT IN ('Cancelado','Dispensado'))
FROM #TEMP T
WHERE ULTIMA_MATRICULA = ''

UPDATE T SET ULTIMA_MATRICULA = (SELECT MAX(CONCAT(HM.ANO,'/',HM.SEMESTRE)) FROM VW_MATRICULA_E_PRE_MATRICULA HM WHERE HM.ALUNO = T.ALUNO AND HM.SIT_MATRICULA NOT IN ('Cancelado','Dispensado'))
FROM #TEMP T
WHERE ULTIMA_MATRICULA IS NULL

UPDATE T SET T.DT_ENCERRAMENTO = CONVERT(VARCHAR(10),HCC.DT_ENCERRAMENTO,103),  T.MOTIVO_ENCERRAMENTO = HCC.MOTIVO 
FROM #TEMP T
JOIN LY_H_CURSOS_CONCL HCC ON HCC.ALUNO = T.ALUNO
WHERE T.DT_ENCERRAMENTO = '' AND T.MOTIVO_ENCERRAMENTO = ''
AND HCC.DT_REABERTURA IS NULL

SELECT * FROM #TEMP ORDER BY 1,4