USE LYCEUM
GO

DELETE HD FROM LY_HISTORICO_DOCENTE HD
WHERE HD.NUM_FUNC IN ('1','825','388')
AND EXISTS (SELECT TOP 1 1 FROM LY_HISTORICO_DOCENTE WHERE ALUNO = HD.ALUNO AND DISCIPLINA = HD.DISCIPLINA AND ANO = HD.ANO AND PERIODO = HD.PERIODO AND NUM_FUNC NOT IN ('1','825','388'))
GO