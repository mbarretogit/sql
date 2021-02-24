USE LYCEUM
GO

SELECT A.UNIDADE_FISICA, A.ALUNO ,PPP.ANO, PPP.PERIODO, PPP.DIA_VENCIMENTO FROM LY_ALUNO A
JOIN LY_PLANO_PGTO_PERIODO PPP ON PPP.ALUNO = A.ALUNO
JOIN LY_CURSO C ON C.CURSO = A.CURSO
WHERE EXISTS (SELECT TOP 1 1 FROM LY_HISTMATRICULA WHERE ANO= 2018 AND SEMESTRE = 1 AND ALUNO = A.ALUNO)
AND PPP.ANO = 2018 AND PPP.PERIODO IN (1,2)
AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
--GROUP BY A.UNIDADE_FISICA,PPP.ANO, PPP.PERIODO, PPP.DIA_VENCIMENTO
ORDER BY 1,2