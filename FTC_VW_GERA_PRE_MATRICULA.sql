USE LYCEUM
GO

IF OBJECT_ID('dbo.FTC_VW_GERA_PRE_MATRICULA', 'U') IS NOT NULL
  DROP VIEW dbo.FTC_VW_GERA_PRE_MATRICULA
GO

CREATE VIEW FTC_VW_GERA_PRE_MATRICULA        
AS   
  

--MONTA TABELA TEMP PARA GUARDAR ALUNOS COM HISTORICO E MATRICULA
-- HISTORICO
SELECT	DISTINCT
		'GERA_PRE_MATRICULA' CONJ_ALUNO,
		A.ALUNO
FROM LY_ALUNO A
-- VETERANO (MATRICULADO NO SEMESTRE ANTERIOR)
INNER JOIN LY_HISTMATRICULA HM ON HM.ALUNO = A.ALUNO
WHERE A.SIT_ALUNO = 'ATIVO'
AND HM.ANO = '2016'
AND HM.SEMESTRE = '1'
AND HM.SITUACAO_HIST IN ('APROVADO', 'REP NOTA', 'REP FREQ', 'TRANCADO')
AND NOT EXISTS (SELECT 1 FROM LY_TRANCAMENTO T WHERE T.ALUNO = HM.ALUNO AND T.ANO_TRANC = HM.ANO AND T.SEM_TRANC = HM.SEMESTRE)

UNION

-- MATRICULA
SELECT	DISTINCT
		'GERA_PRE_MATRICULA' CONJ_ALUNO,
		A.ALUNO
FROM LY_ALUNO A
-- VETERANO (MATRICULADO NO SEMESTRE ANTERIOR)
INNER JOIN LY_MATRICULA M ON M.ALUNO = A.ALUNO
WHERE A.SIT_ALUNO = 'ATIVO'
AND M.ANO = '2016'
AND M.SEMESTRE = '1'
AND M.SIT_MATRICULA IN ('MATRICULADO', 'APROVADO', 'REP NOTA', 'REP FREQ', 'TRANCADO')
AND NOT EXISTS (SELECT 1 FROM LY_TRANCAMENTO T WHERE T.ALUNO = M.ALUNO AND T.ANO_TRANC = M.ANO AND T.SEM_TRANC = M.SEMESTRE)
GO