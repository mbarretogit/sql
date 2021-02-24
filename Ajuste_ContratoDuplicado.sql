USE LYCEUM
GO
--select * from LY_ALUNO WHERE ALUNO = '182210017'

DISABLE TRIGGER CRO_LY_CURRICULO_CONTRATO_Delete ON LY_CURRICULO_CONTRATO
GO

DELETE FROM LY_CURRICULO_CONTRATO 
WHERE CHAVE NOT IN (SELECT MAX(CHAVE) 
                 FROM LY_CURRICULO_CONTRATO
				 WHERE EXISTS (SELECT 1 FROM #TEMP T WHERE CURSO = T.CURSO AND CURRICULO = T.CURRICULO AND TURNO = T.TURNO AND SERIE = T.SERIE)
     GROUP BY CURSO, TURNO, CURRICULO,SERIE)
GO

ENABLE TRIGGER CRO_LY_CURRICULO_CONTRATO_Delete ON LY_CURRICULO_CONTRATO
GO

--SELECT DISTINCT CURSO FROM #TEMP

	 /*
SELECT CURSO, TURNO, CURRICULO,SERIE 
INTO #TEMP
FROM LY_CURRICULO_CONTRATO
GROUP BY CURSO, TURNO, CURRICULO,SERIE
HAVING COUNT(chave) > 1
	*/