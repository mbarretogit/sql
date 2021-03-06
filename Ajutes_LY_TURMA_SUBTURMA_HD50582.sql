USE LYCEUM
GO

--DISCIPLINAS TEOPRAEAD

--SELECT TIPO, * FROM LY_DISCIPLINA WHERE DISCIPLINA IN ('SPR449','EPR527')

SELECT DISTINCT M.* FROM LY_PRE_MATRICULA M
WHERE M.ANO = 2018 AND M.SEMESTRE = 2
AND M.DISCIPLINA IN ('SPR449','EPR527')
AND M.SUBTURMA2 IS NULL

EXCEPT

SELECT DISTINCT M.* FROM LY_PRE_MATRICULA M
JOIN LY_ASSOC_TURMA_SUBTURMA ATS ON ATS.DISCIPLINA = M.DISCIPLINA AND ATS.TURMA = M.TURMA AND ATS.ANO = M.ANO AND ATS.PERIODO = M.SEMESTRE
WHERE M.ANO = 2018 AND M.SEMESTRE = 2
AND M.DISCIPLINA IN ('SPR449','EPR527')
AND M.SUBTURMA2 IS NULL

UPDATE M SET M.SUBTURMA2 = ATS.SUBTURMA2
FROM LY_PRE_MATRICULA M
JOIN LY_ASSOC_TURMA_SUBTURMA ATS ON ATS.DISCIPLINA = M.DISCIPLINA AND ATS.TURMA = M.TURMA AND ATS.ANO = M.ANO AND ATS.PERIODO = M.SEMESTRE
WHERE M.ANO = 2018 AND M.SEMESTRE = 2
AND M.DISCIPLINA IN ('SPR449','EPR527')
AND M.SUBTURMA2 IS NULL

GO

--DISICPLINAS TEOEAD

--SELECT TIPO, * FROM LY_DISCIPLINA WHERE DISCIPLINA IN ('SPR407','143897')

SELECT DISTINCT M.* FROM LY_PRE_MATRICULA M
WHERE M.ANO = 2018 AND M.SEMESTRE = 2
AND M.DISCIPLINA IN ('SPR407','143897')
AND M.SUBTURMA1 IS NULL


EXCEPT

SELECT M.* FROM LY_PRE_MATRICULA M
JOIN LY_ASSOC_TURMA_SUBTURMA ATS ON ATS.DISCIPLINA = M.DISCIPLINA AND ATS.TURMA = M.TURMA AND ATS.ANO = M.ANO AND ATS.PERIODO = M.SEMESTRE
WHERE M.ANO = 2018 AND M.SEMESTRE = 2
AND M.DISCIPLINA IN ('SPR407','143897')
AND M.SUBTURMA1 IS NULL

UPDATE M SET M.SUBTURMA1 = ATS.SUBTURMA1
FROM LY_PRE_MATRICULA M
JOIN LY_ASSOC_TURMA_SUBTURMA ATS ON ATS.DISCIPLINA = M.DISCIPLINA AND ATS.TURMA = M.TURMA AND ATS.ANO = M.ANO AND ATS.PERIODO = M.SEMESTRE
WHERE M.ANO = 2018 AND M.SEMESTRE = 2
AND M.DISCIPLINA IN ('SPR407','143897')
AND M.SUBTURMA1 IS NULL

GO

