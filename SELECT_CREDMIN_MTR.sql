use lyceum
go

SELECT DISTINCT A.ALUNO
FROM LY_ALUNO A
WHERE	((SELECT SUM(D.CREDITOS) FROM LY_PRE_MATRICULA PM JOIN LY_DISCIPLINA D ON D.DISCIPLINA = PM.DISCIPLINA AND PM.ALUNO = A.ALUNO) < 
		(SELECT CREDMIN_MATR FROM LY_CURRICULO WHERE CURSO = A.CURSO AND CURRICULO = A.CURRICULO AND TURNO = A.TURNO)
		OR (SELECT SUM(D.CREDITOS) FROM LY_PRE_MATRICULA PM JOIN LY_DISCIPLINA D ON D.DISCIPLINA = PM.DISCIPLINA AND PM.ALUNO = A.ALUNO) > 
		(SELECT CREDMAX_MATR FROM LY_CURRICULO WHERE CURSO = A.CURSO AND CURRICULO = A.CURRICULO AND TURNO = A.TURNO))
AND EXISTS (SELECT TOP 1 1 FROM LY_PRE_MATRICULA WHERE ALUNO = A.ALUNO AND CONFIRMADA = 'N' AND ANO = 2018 AND SEMESTRE = 2)
AND NOT EXISTS (SELECT TOP 1 1 FROM LY_CONTRATO_ALUNO WHERE ALUNO = A.ALUNO AND ANO = 2018 AND PERIODO = 2 AND CONTRATO_ACEITO = 'S')


SELECT DISTINCT A.UNIDADE_FISICA, A.CURSO,A.TURNO, A.CURRICULO,A.NOME_COMPL,ISNULL(P.DDD_FONE,'')DDD_FONE, ISNULL(P.FONE,'')FONE, ISNULL(P.DDD_FONE_CELULAR,'')DDD_FONE_CELULAR,ISNULL(P.CELULAR,'')CELULAR,ISNULL(P.E_MAIL,'')E_MAIL
FROM LY_ALUNO A
JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA
WHERE	((SELECT SUM(D.CREDITOS) FROM LY_PRE_MATRICULA PM JOIN LY_DISCIPLINA D ON D.DISCIPLINA = PM.DISCIPLINA AND PM.ALUNO = A.ALUNO) < 
		(SELECT CREDMIN_MATR FROM LY_CURRICULO WHERE CURSO = A.CURSO AND CURRICULO = A.CURRICULO AND TURNO = A.TURNO)
		OR (SELECT SUM(D.CREDITOS) FROM LY_PRE_MATRICULA PM JOIN LY_DISCIPLINA D ON D.DISCIPLINA = PM.DISCIPLINA AND PM.ALUNO = A.ALUNO) > 
		(SELECT CREDMAX_MATR FROM LY_CURRICULO WHERE CURSO = A.CURSO AND CURRICULO = A.CURRICULO AND TURNO = A.TURNO))
AND EXISTS (SELECT TOP 1 1 FROM LY_PRE_MATRICULA WHERE ALUNO = A.ALUNO AND CONFIRMADA = 'N'  AND ANO = 2018 AND SEMESTRE = 2)
AND NOT EXISTS (SELECT TOP 1 1 FROM LY_CONTRATO_ALUNO WHERE ALUNO = A.ALUNO AND ANO = 2018 AND PERIODO = 2 AND CONTRATO_ACEITO = 'S')
ORDER BY 1,2


/*
select * FROM LY_PRE_MATRICULA WHERE ALUNO = '021041866'
select * FROM LY_ALUNO WHERE ALUNO = '021041866'
SELECT SUM(D.CREDITOS) FROM LY_PRE_MATRICULA PM JOIN LY_DISCIPLINA D ON D.DISCIPLINA = PM.DISCIPLINA AND PM.ALUNO = '021041866'
SELECT CREDMIN_MATR FROM LY_CURRICULO WHERE CURSO = '354' AND CURRICULO = '20162' AND TURNO = 'I'
*/