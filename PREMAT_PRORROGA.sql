USE LYCEUM
GO

--select * from LY_DEF_CONJ_ALUNO Where conj_aluno = 'PREMAT_PRORROGA'

IF EXISTS (SELECT TOP 1 1 FROM LY_CONJ_ALUNO where conj_aluno = 'PREMAT_PRORROGA')
	DELETE FROM LY_CONJ_ALUNO WHERE CONJ_ALUNO = 'PREMAT_PRORROGA'

INSERT INTO LY_CONJ_ALUNO
SELECT DISTINCT 'PREMAT_PRORROGA', PM.ALUNO
FROM LY_PRE_MATRICULA PM
JOIN LY_ALUNO A ON A.ALUNO = PM.ALUNO
JOIN LY_CURSO C ON C.CURSO = A.CURSO
WHERE 1=1
AND LYCEUMINTEGRACAO.DBO.FN_FTC_ALUNO_PAGO(PM.ALUNO, PM.LANC_DEB) = 0
AND PM.ANO = 2021
AND PM.SEMESTRE = 1
AND C.TIPO IN ('GRADUACAO','TECNOLOGO')