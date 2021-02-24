USE LYCEUM 
GO

--ATUALIZANDO AS FREQUENCIAS PARA APARECER NO PORTAL DO DOCENTE
UPDATE LY_FREQ SET ON_LINE = 'S'
WHERE ANO = 2018
AND PERIODO = 2
AND ON_LINE = 'N'
GO

--INSERINDO AS FREQUENCIAS PARA AS TURMAS QUE N�O FORAM CADASTRADAS

INSERT INTO LY_FREQ
SELECT T.DISCIPLINA, T.TURMA, T.ANO, T.SEMESTRE, 'FT','Frequ�ncia Total',1,NULL,NULL,NULL,'S',NULL,T.NUM_FUNC,NULL,NULL FROM LY_TURMA T
WHERE NOT EXISTS (SELECT TOP 1 1 FROM LY_FREQ WHERE TURMA = T.TURMA AND DISCIPLINA = T.DISCIPLINA AND ANO = T.ANO AND T.SEMESTRE = PERIODO)
AND T.ANO = 2018 AND T.SEMESTRE = 2