USE LYCEUM
GO

SELECT DISTINCT HM.ANO, HM.SEMESTRE,A.UNIDADE_FISICA, UF.NOME_COMP, A.CURSO, C.NOME, A.ALUNO, A.NOME_COMPL, A.SERIE, A.SIT_ALUNO
FROM LY_ALUNO A
JOIN LY_HISTMATRICULA HM ON HM.ALUNO = A.ALUNO
JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = A.UNIDADE_FISICA
JOIN LY_CURSO C ON C.CURSO = A.CURSO
WHERE 1=1
AND HM.ANO BETWEEN 2013 AND 2017
AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
AND HM.SITUACAO_HIST <> 'Cancelado'
ORDER BY HM.ANO, HM.SEMESTRE,A.UNIDADE_FISICA, A.CURSO, A.ALUNO