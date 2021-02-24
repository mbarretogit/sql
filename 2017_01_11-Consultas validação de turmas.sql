USE LYCEUM
GO






DECLARE @p_ano VARCHAR(4),
		@p_semestre VARCHAR(2)

SET @p_ano = '2017'
SET @p_semestre = '2'



--##
-- Turmas sem num_alunos
--##
SELECT distinct 'Turmas sem num_alunos' as TIPO, t.ano, t.SEMESTRE, t.DISCIPLINA, t.TURMA, t.UNIDADE_RESPONSAVEL, t.FACULDADE, isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, T.NIVEL FROM LY_TURMA t
join LY_DISCIPLINA d on d.DISCIPLINA = t.DISCIPLINA
left join ly_docente do on do.NUM_FUNC = t.NUM_FUNC
LEFT JOIN ly_curso c ON c.CURSO = t.CURSO
WHERE ANO = @p_ano AND SEMESTRE = @p_semestre
AND NUM_ALUNOS IS NULL
UNION

--##
-- Turmas com nivel e disciplinas sem nivel
--##
SELECT distinct  'Turmas com nivel e disciplinas sem nivel' as TIPO,t.ano, t.SEMESTRE, t.DISCIPLINA, t.TURMA, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, T.NIVEL FROM LY_TURMA t
join LY_DISCIPLINA d on d.DISCIPLINA = t.DISCIPLINA
 join ly_docente do on do.NUM_FUNC = t.NUM_FUNC
 left join LY_CURSO c on c.CURSO = t.CURSO
WHERE ANO = @p_ano AND SEMESTRE = @p_semestre
AND nivel is not null
and exists (select top 1 1 from LY_DISCIPLINA d
				where d.disciplina = t.disciplina
				and tipo is null)

UNION
--##
-- Turmas sem nivel e disciplinas com nivel
--##
SELECT distinct 'Turmas sem nivel e disciplinas com nivel' as TIPO, t.ano, t.SEMESTRE, t.DISCIPLINA, t.TURMA, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, T.NIVEL FROM LY_TURMA t
join LY_DISCIPLINA d on d.DISCIPLINA = t.DISCIPLINA
join ly_docente do on do.NUM_FUNC = t.NUM_FUNC
left join LY_CURSO c on c.CURSO = t.CURSO
WHERE ANO = @p_ano AND SEMESTRE = @p_semestre
AND nivel is null
and exists (select top 1 1 from LY_DISCIPLINA d
				where d.disciplina = t.disciplina
				and tipo is not null)
UNION

--##
--## Disciplinas com nivel e não tem os niveis nas turmas
--##
select distinct 'Turmas com nivel a mais em disciplinas teoricas' as TIPO, t.ano, t.SEMESTRE, t.DISCIPLINA, t.TURMA, t.UNIDADE_RESPONSAVEL, t.FACULDADE, isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO,isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, T.NIVEL FROM LY_TURMA t
join LY_DISCIPLINA d on d.DISCIPLINA = t.DISCIPLINA
join ly_docente do on do.NUM_FUNC = t.NUM_FUNC
left join LY_CURSO c on c.CURSO = t.CURSO
where 1 = 1
and d.DISCIPLINA in
		(
		SELECT disciplina--, count(distinct NIVEL) as qnt 
		FROM LY_TURMA t
		WHERE ANO = @p_ano AND SEMESTRE = @p_semestre
		and exists (select top 1 1 from LY_DISCIPLINA d
						where d.disciplina = t.disciplina
						and tipo is NOT NULL)
		and NIVEL is NOT NULL
		group by disciplina
		having  count(distinct NIVEL) = 2
		)
and t.ANO = @p_ano AND t.SEMESTRE = @p_semestre
and t.SIT_TURMA = 'Aberta'
AND d.TIPO = 'TEORICA'
UNION


--##
--## Disciplinas com docente = 1
--##
select distinct 'Turmas com docente genérico (1, 388 ou 825)' AS TIPO, t.ano, t.SEMESTRE, t.DISCIPLINA, t.TURMA, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, T.NIVEL
from LY_DISCIPLINA d
join ly_turma t
	on d.DISCIPLINA = t.DISCIPLINA
LEFT JOIN ly_curso c
	ON c.CURSO = t.CURSO
JOIN LY_DOCENTE DO
	ON do.NUM_FUNC = t.NUM_FUNC 
where 1 = 1
and t.SEMESTRE = @p_semestre
and t.ANO = @p_ano
and t.SIT_TURMA = 'Aberta'
AND t.NUM_FUNC in (1,388,825)
AND EXISTS (SELECT 1 FROM VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE)
UNION



--##
--## Disciplinas sem curso associado
--##
select distinct 'Turmas sem curso associado' AS TIPO, t.ano, t.SEMESTRE, t.DISCIPLINA, t.TURMA, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, T.NIVEL
from LY_DISCIPLINA d
join ly_turma t
	on d.DISCIPLINA = t.DISCIPLINA
LEFT JOIN ly_curso c
	ON c.CURSO = t.CURSO
LEFT JOIN LY_DOCENTE DO
	ON do.NUM_FUNC = t.NUM_FUNC 
where 1 = 1
and t.SEMESTRE = @p_semestre
and t.ANO = @p_ano
and t.SIT_TURMA = 'Aberta'
AND EXISTS (SELECT 1 FROM VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE)
AND T.CURSO IS NULL
ORDER BY 1,t.UNIDADE_RESPONSAVEL

/*

--##
--## Lista de Cursos e seus coordenadores
--##
select DISTINCT uf.unidade_fis,uf.nome_comp,C.CURSO, C.NOME, CO.NUM_FUNC, DO.NOME_COMPL, ISNULL(CO.UNID_FISICA,'') AS UNID_FISICA_COORDENADOR 
FROM LY_COORDENACAO CO
JOIN ly_curso c
	ON c.CURSO = co.CURSO
JOIN LY_DOCENTE DO
	ON do.NUM_FUNC = co.NUM_FUNC
JOIN LY_UNIDADE_FISICA uf
	ON uf.FL_FIELD_01 = c.FACULDADE 
where 1 = 1
AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
--AND c.FACULDADE = '07'
AND c.ATIVO = 'S'
ORDER BY  1,3
GO

*/