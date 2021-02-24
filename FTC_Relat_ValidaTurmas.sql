USE LYCEUM
GO



--EXEC [FTC_Relat_ValidaTurmas] '04',2018,1
--(CONVERT(VARCHAR(15), 

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_Relat_ValidaTurmas'))
   exec('CREATE PROCEDURE [dbo].[FTC_Relat_ValidaTurmas] AS BEGIN SET NOCOUNT OFF; END')
GO 

 
ALTER PROCEDURE [dbo].[FTC_Relat_ValidaTurmas]  
(  
	@p_unidade VARCHAR(15),
    @p_ano VARCHAR(4),  
    @p_semestre VARCHAR(2)  
)    


AS            
-- [INÍCIO]                    
BEGIN            
        
SET NOCOUNT ON 

/*

DECLARE @p_unidade VARCHAR(15),
		@p_ano VARCHAR(4),
		@p_semestre VARCHAR(2)

SET @p_unidade = NULL
SET @p_ano = '2017'
SET @p_semestre = '2'

*/



--##
-- Turmas sem num_alunos
--##
SELECT distinct 'Turmas sem número de alunos (vagas)' as TIPO, t.ano, t.SEMESTRE, t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE, isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS FROM LY_TURMA t
join LY_DISCIPLINA d on d.DISCIPLINA = t.DISCIPLINA
left join ly_docente do on do.NUM_FUNC = t.NUM_FUNC
LEFT JOIN ly_curso c ON c.CURSO = t.CURSO
WHERE t.ANO = @p_ano AND t.SEMESTRE = @p_semestre 
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL OR @p_unidade = '')   
AND t.NUM_ALUNOS IS NULL AND t.SIT_TURMA = 'Aberta'


UNION

--##
-- Turmas com nivel e disciplinas sem nivel
--##
SELECT distinct  'Turmas com nivel e disciplinas sem nivel' as TIPO,t.ano, t.SEMESTRE,t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS FROM LY_TURMA t
join LY_DISCIPLINA d on d.DISCIPLINA = t.DISCIPLINA
 join ly_docente do on do.NUM_FUNC = t.NUM_FUNC
 left join LY_CURSO c on c.CURSO = t.CURSO
WHERE t.ANO = @p_ano AND t.SEMESTRE = @p_semestre
AND t.nivel is not null AND t.SIT_TURMA = 'Aberta'
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL OR @p_unidade = '')   
and exists (select top 1 1 from LY_DISCIPLINA d
				where d.disciplina = t.disciplina
				and tipo is null)


UNION
--##
-- Turmas sem nivel e disciplinas com nivel
--##
SELECT distinct 'Turmas sem nivel e disciplinas com nivel' as TIPO, t.ano, t.SEMESTRE, t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS FROM LY_TURMA t
join LY_DISCIPLINA d on d.DISCIPLINA = t.DISCIPLINA
join ly_docente do on do.NUM_FUNC = t.NUM_FUNC
left join LY_CURSO c on c.CURSO = t.CURSO
WHERE t.ANO = @p_ano AND t.SEMESTRE = @p_semestre
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL OR @p_unidade = '')   
AND t.nivel is null AND t.SIT_TURMA = 'Aberta'
and exists (select top 1 1 from LY_DISCIPLINA
				where disciplina = t.disciplina
				and tipo is not null)


UNION

--##
--## Disciplinas com nivel e não tem os niveis nas turmas
--##
select distinct 'Turmas com nivel a mais em disciplinas teoricas' as TIPO, t.ano, t.SEMESTRE, t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE, isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO,isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS FROM LY_TURMA t
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
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL OR @p_unidade = '')   
and t.SIT_TURMA = 'Aberta'
AND d.TIPO = 'TEORICA'

UNION


--##
--## Disciplinas com docente = 1
--##
select distinct 'Turmas com docente genérico (1, 388 ou 825)' AS TIPO, t.ano, t.SEMESTRE, t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS
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
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL)   
and t.SIT_TURMA = 'Aberta'
AND t.NUM_FUNC in (1,388,825)
AND EXISTS (SELECT 1 FROM VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE)
UNION



--##
--## Disciplinas sem curso associado
--##
select distinct 'Turmas sem curso associado' AS TIPO, t.ano, t.SEMESTRE, t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS
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
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL OR @p_unidade = '')   
AND EXISTS (SELECT 1 FROM VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE)
AND T.CURSO IS NULL

UNION



--##
--## Disciplinas sem curso associado
--##
select distinct 'Turmas sem horário/agenda' AS TIPO, t.ano, t.SEMESTRE, t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS
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
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL OR @p_unidade = '')   
AND EXISTS (SELECT 1 FROM VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE)
AND NOT EXISTS (SELECT TOP 1 1 FROM LY_AULA_DOCENTE WHERE ANO = t.ANO AND SEMESTRE = t.SEMESTRE AND DISCIPLINA = t.DISCIPLINA and TURMA = t.TURMA) 

UNION

--##
--## Disciplinas sem frequencia
--##
select distinct 'Turmas sem frequencia online' AS TIPO, t.ano, t.SEMESTRE, t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS
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
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL OR @p_unidade = '')   
AND EXISTS (SELECT 1 FROM VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE)
AND NOT EXISTS (SELECT TOP 1 1 FROM LY_FREQ WHERE ANO = t.ANO AND PERIODO = t.SEMESTRE AND DISCIPLINA = t.DISCIPLINA and TURMA = t.TURMA and ON_LINE = 'S') 


UNION

--##
--## Disciplinas sem formula lançada
--##
select distinct 'Turmas sem formula ou conceito mínimo lançado' AS TIPO, t.ano, t.SEMESTRE, t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS
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
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL OR @p_unidade = '')   
AND EXISTS (SELECT 1 FROM VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE)
AND (ISNULL(t.FORMULA_MF1,'') = '' OR ISNULL(t.FORMULA_MF2,'') = '' OR ISNULL(t.FORMULA_CA1,'') = '' OR ISNULL(t.FORMULA_CA2,'') = '' or ISNULL(t.CONCEITO_MIN_1,'') = '' OR ISNULL(t.CONCEITO_MIN_2,'') = '' OR ISNULL(t.CONCEITO_MIN_EX,'') = '')


UNION

--##
--## Disciplinas sem prova lançada
--##
select distinct 'Turmas sem prova cadastrada' AS TIPO, t.ano, t.SEMESTRE, t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS
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
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL OR @p_unidade = '')   
AND EXISTS (SELECT 1 FROM VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE)
AND NOT EXISTS (SELECT TOP 1 1 FROM LY_PROVA P WHERE P.ANO = t.ANO AND P.SEMESTRE = t.SEMESTRE AND P.DISCIPLINA = t.DISCIPLINA and P.TURMA = t.TURMA AND P.E_OFICIAL = 'S' AND P.ON_LINE = 'S')

UNION

--##
--## Turma em Unidades Associadas erradas
--##
select distinct 'Turma com Unidade Associada Errada' AS TIPO, t.ano, t.SEMESTRE, t.TURMA, t.DISCIPLINA, d.NOME, t.UNIDADE_RESPONSAVEL, t.FACULDADE,isnull(t.curso,'') as CURSO, ISNULL(c.nome,'') as NOME_CURSO, isnull(t.NUM_FUNC,0) AS NUM_FUNC, isnull(do.NOME_COMPL,'') as NOME_DOCENTE, ISNULL(T.NIVEL,'') AS NIVEL, ISNULL(T.NUM_ALUNOS,0) AS NUM_ALUNOS
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
AND ((@p_unidade IS NOT NULL AND t.unidade_responsavel = @p_unidade) OR @p_unidade IS NULL OR @p_unidade = '')   
AND EXISTS (SELECT 1 FROM VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE)
AND NOT EXISTS (SELECT TOP 1 1 FROM LY_UNIDADES_ASSOCIADAS WHERE UNIDADE_ENS = t.UNIDADE_RESPONSAVEL AND UNIDADE_FIS = t.FACULDADE )
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

SET NOCOUNT OFF

END

-- [FIM]  


DELETE FROM LY_CUSTOM_CLIENTE    
where NOME = 'FTC_Relat_ValidaTurmas'    
and IDENTIFICACAO_CODIGO = '0002' 
GO

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_Relat_ValidaTurmas' NOME
, '0002' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2018-04-26' DATA_CRIACAO
, 'Relatório - Validação de Turmas - Acréscimo de Validações de Frequencia, Agenda, Fórmula e Prova.' OBJETIVO
, 'Liane Soares, André Britto' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO 