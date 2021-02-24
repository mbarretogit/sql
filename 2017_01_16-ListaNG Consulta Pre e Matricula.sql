DECLARE
	@p_ano				T_ANO,
	@p_semestre			T_Semestre2,
	@p_unidade_ensino	T_codigo,
	@p_tipo_curso		T_codigo,
	@p_curso			T_codigo,
	@p_turno			T_codigo,
	@p_curriculo		T_codigo,	
	@p_sit_matricula	T_codigo,
	@p_tem_turma		varchar(1)

SET @p_ano	= '2017'
SET	@p_semestre	= '1'
SET	@p_unidade_ensino = NULL
SET	@p_tipo_curso = NULL
SET @p_curso = NULL
SET	@p_turno = NULL
SET	@p_curriculo = NULL	
SET	@p_sit_matricula = NULL
SET	@p_tem_turma = NULL


			SELECT 
				'PRÉ-MATRÍCULA' AS TIPO,
				P.CPF,
				A.ALUNO,
				A.NOME_COMPL	AS NOME_ALUNO,
				A.CURSO,
				C.NOME			AS NOME_CURSO,
				C.TIPO			AS TIPO_CURSO,
				C.FACULDADE,
				ue.NOME_COMP	as NOME_UNIDADE_ENSINO,
				A.TURNO,
				A.CURRICULO,
				A.SERIE,
				PM.DISCIPLINA,
				D.NOME			AS NOME_DISCIPLINA,
				PM.ANO,
				PM.SEMESTRE,
				PM.TURMA,
				PM.SUBTURMA1,
				PM.SUBTURMA2,
				PM.SIT_DETALHE,
				'Pré-Matriculado'		AS SIT_MATRICULA,
				PM.SERIE_IDEAL,
				PM.CONFIRMADA,
				PM.DISPENSADA,
				PM.DT_INSERCAO,
				PM.DT_ULTALT,
				PM.DT_CONFIRMACAO,
				null AS dt_matricula,
				PM.GRUPO_ELETIVA,
				PM.LANC_DEB,
				PM.MANUAL,
				PM.OBS,
				PM.MENS_ERRO 
			from LY_PRE_MATRICULA PM
			JOIN LY_ALUNO A
				on pm.aluno = a.aluno
			JOIN LY_CURSO c
				on a.CURSO = c.curso
			join LY_DISCIPLINA d
				on pm.DISCIPLINA = d.DISCIPLINA
			LEFT JOIN LY_UNIDADE_ENSINO ue 
				ON c.FACULDADE = ue.UNIDADE_ENS
			JOIN LY_PESSOA P 
				ON P.PESSOA = A.PESSOA
			WHERE 1 = 1
			and pm.ano		= @p_ano
			and pm.SEMESTRE	= isnull(@p_semestre,semestre)
			AND C.FACULDADE = ISNULL(@P_UNIDADE_ENSINO,C.FACULDADE)
			AND C.TIPO		= ISNULL(@P_TIPO_CURSO, C.TIPO)
			AND A.CURSO		= ISNULL(@P_CURSO,A.CURSO)
			AND A.TURNO		= ISNULL(@P_TURNO,A.TURNO)
			AND A.CURRICULO = ISNULL(@p_curriculo,A.CURRICULO)

			union ALL
			
			SELECT 
				'MATRÍCULA' AS TIPO,
				P.CPF,
				A.ALUNO,
				A.NOME_COMPL	AS NOME_ALUNO,
				A.CURSO,
				C.NOME			AS NOME_CURSO,
				C.TIPO			AS TIPO_CURSO,
				C.FACULDADE,
				ue.NOME_COMP	as NOME_UNIDADE_ENSINO,
				A.TURNO,
				A.CURRICULO,
				A.SERIE,
				M.DISCIPLINA,
				D.NOME			AS NOME_DISCIPLINA,
				M.ANO,
				M.SEMESTRE,
				M.TURMA,
				M.SUBTURMA1,
				M.SUBTURMA2,
				M.SIT_DETALHE,
				m.SIT_MATRICULA,
				NULL				AS SERIE_IDEAL,
				NULL				AS CONFIRMADA,
				NULL				AS DISPENSADA,
				M.DT_INSERCAO,
				M.DT_ULTALT,
				NULL				AS DT_CONFIRMACAO,
				M.DT_MATRICULA,
				M.GRUPO_ELETIVA,
				M.LANC_DEB,
				NULL				AS MANUAL,
				M.OBS,
				NULL				AS MENS_ERRO 
			from LY_MATRICULA M
			JOIN LY_ALUNO A
				on m.aluno = a.aluno
			JOIN LY_CURSO c
				on a.CURSO = c.curso
			join LY_DISCIPLINA d
				on m.DISCIPLINA = d.DISCIPLINA
			LEFT JOIN LY_UNIDADE_ENSINO ue 
				ON c.FACULDADE = ue.UNIDADE_ENS
			JOIN LY_PESSOA P 
				ON P.PESSOA = A.PESSOA
			WHERE 1 = 1
			and m.ano		= @p_ano
			and m.SEMESTRE	= isnull(@p_semestre,semestre)
			AND C.FACULDADE = ISNULL(@P_UNIDADE_ENSINO,C.FACULDADE)
			AND C.TIPO		= ISNULL(@P_TIPO_CURSO, C.TIPO)
			AND A.CURSO		= ISNULL(@P_CURSO,A.CURSO)
			AND A.TURNO		= ISNULL(@P_TURNO,A.TURNO)
			AND A.CURRICULO = ISNULL(@p_curriculo,A.CURRICULO)