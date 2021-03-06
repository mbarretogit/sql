USE LYCEUM
GO

SELECT	PPP.RESP,
		A.ALUNO,
		C.FACULDADE UNIDADE,
		UE.NOME_COMP AS NOME_UNIDADE,
		C.TIPO AS TIPO_CURSO,
		C.CURSO,
		C.NOME AS NOME_CURSO,
		A.NOME_COMPL AS NOME_ALUNO,
		A.SIT_ALUNO,
		CONCAT(PPP.ANO, PPP.PERIODO) AS PERIODO,
		CONVERT(DECIMAL(10,2),VSP.CUSTO_UNITARIO*SUM(D.CREDITOS)/6) AS VALOR_MENSALIDADE
FROM LY_ALUNO A
JOIN LY_CURSO C ON C.CURSO = A.CURSO
JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = C.FACULDADE
JOIN LY_GRADE G ON G.CURSO = A.CURSO AND G.TURNO = A.TURNO AND G.CURRICULO = A.CURRICULO AND G.SERIE_IDEAL = A.SERIE
JOIN LY_DISCIPLINA D ON D.DISCIPLINA = G.DISCIPLINA
JOIN LY_SERIE S ON S.CURSO = A.CURSO AND S.TURNO = A.TURNO AND S.CURRICULO = A.CURRICULO AND S.SERIE = A.SERIE
JOIN LY_VALOR_SERV_PERIODO VSP ON VSP.SERVICO = S.SERVICO_CRED
JOIN LY_PLANO_PGTO_PERIODO PPP ON PPP.ALUNO = A.ALUNO AND PPP.ANO = VSP.ANO AND PPP.PERIODO = VSP.PERIODO
WHERE 1=1
--AND A.ALUNO = '162040001'
AND PPP.ANO = '2018'
AND PPP.PERIODO = '1'
AND EXISTS (SELECT TOP 1 1 FROM VW_MATRICULA_E_PRE_MATRICULA WHERE ALUNO = A.ALUNO AND ANO = PPP.ANO AND SEMESTRE = PPP.PERIODO)
GROUP BY PPP.RESP,
		A.ALUNO,
		C.FACULDADE,
		UE.NOME_COMP,
		C.CURSO,
		C.NOME,
		A.NOME_COMPL,
		A.SIT_ALUNO,
		PPP.ANO, 
		PPP.PERIODO,
		VSP.CUSTO_UNITARIO,
		C.TIPO
ORDER BY	C.FACULDADE,
			C.CURSO