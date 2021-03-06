USE LYCEUM
GO

SELECT DISTINCT A.UNIDADE_FISICA, A.CURSO, C.NOME, A.ALUNO, A.NOME_COMPL, A.SIT_ALUNO,HCC.MOTIVO,HCC.ANO_ENCERRAMENTO,HCC.SEM_ENCERRAMENTO
FROM LY_ALUNO A
JOIN LY_CURSO C ON C.CURSO = A.CURSO
LEFT JOIN LY_H_CURSOS_CONCL HCC ON HCC.ALUNO = A.ALUNO AND HCC.DT_REABERTURA IS NULL
WHERE	EXISTS	(
				SELECT TOP 1 1 
				FROM LY_HISTMATRICULA HM
				WHERE HM.ALUNO = A.ALUNO AND HM.ANO = 2019
				AND HM.SITUACAO_HIST NOT IN ('Cancelado','Dispensado')
				)
		AND C.TIPO IN ('ENS INFANTIL','ENS BASICO')
ORDER BY 1,2