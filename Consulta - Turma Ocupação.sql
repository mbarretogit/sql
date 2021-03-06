USE FTC_DATAMART
GO

SELECT	TOP 50
		BI.ANO,
		BI.SEMESTRE,
		BI.UNIDADE_ENSINO_ALUNO,
		BI.NOME_UNIDADE_ENSINO_ALUNO,
		BI.UNIDADE_FISICA_ALUNO,
		BI.TIPO_CURSO,
		BI.CURSO,
		BI.TURNO,
		BI.CURRICULO,
		BI.NOME_CURSO,
		TIPO_ALUNO,
		TIPO_FINAN,
		FINAN,
		STATUS_FTC,
		BI.CPF,
		BI.ALUNO,
		BI.NOME_ALUNO,
		VW.TURMA,
		VW.DISCIPLINA,
		D.NOME,
		VW.SIT_MATRICULA AS SIT_MATRICULA_DISC,
		T.SIT_TURMA,
		T.DT_INICIO,
		T.DT_FIM,
		T.NUM_FUNC,
		DO.NOME_COMPL,
		DO.CPF,
		T.NIVEL,
		T.AULAS_PREVISTAS
FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA VW
RIGHT JOIN BI_REMATRICULA BI ON BI.ALUNO = VW.ALUNO AND BI.ANO = VW.ANO AND BI.SEMESTRE = VW.SEMESTRE
RIGHT JOIN LYCEUM..LY_DISCIPLINA D ON D.DISCIPLINA = VW.DISCIPLINA
JOIN LYCEUM..LY_TURMA T ON T.TURMA = VW.TURMA AND T.DISCIPLINA = VW.DISCIPLINA AND T.ANO = VW.ANO AND T.SEMESTRE = VW.SEMESTRE
JOIN LYCEUM..LY_DOCENTE DO ON DO.NUM_FUNC = T.NUM_FUNC
WHERE BI.ANO = 2020
AND BI.SEMESTRE = 1
--AND T.DISCIPLINA = 'EPR532'
--AND BI.ALUNO = '131030063'
ORDER BY 3,5,7,15