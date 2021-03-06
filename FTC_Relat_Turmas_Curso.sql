USE LYCEUM
GO

--EXEC FTC_Relat_Turmas_Curso 2018,2,'04',NULL,NULL

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_Relat_Turmas_Curso'))
   exec('CREATE PROCEDURE [dbo].[FTC_Relat_Turmas_Curso] AS BEGIN SET NOCOUNT OFF; END')
GO 
      
ALTER PROCEDURE dbo.FTC_Relat_Turmas_Curso       
( 
	  @p_ano VARCHAR(4)      
	, @p_semestre VARCHAR(2)      
	, @p_unidade VARCHAR(20)      
	, @p_tipo VARCHAR(20)        
	, @p_curso  VARCHAR(20)        
	
)
AS            
-- [IN�CIO]                    
BEGIN            
        
SET NOCOUNT ON   

	SELECT DISTINCT T.UNIDADE_RESPONSAVEL AS COD_UNIDADE
		,UE.NOME_COMP AS NOME_UNIDADE
		,ISNULL(C.TIPO,'') AS TIPO_CURSO
		,ISNULL(C.CURSO,'') AS COD_CURSO
		,ISNULL(C.NOME,'') AS NOME_CURSO
		,CO.NUM_FUNC AS COD_COORDENADOR
		,(SELECT NOME_COMPL FROM LY_DOCENTE WHERE NUM_FUNC = CO.NUM_FUNC) AS NOME_COORDENADOR
		,T.ANO
		,T.SEMESTRE
		,T.SIT_TURMA
		,T.TURMA
		,T.DISCIPLINA AS COD_DISCIPLINA
		,D.NOME AS NOME_DISCIPLINA
		,D.CREDITOS
		,DO.NUM_FUNC AS COD_PROFESSOR
		,DO.NOME_COMPL AS NOME_PROFESSOR
	FROM LY_TURMA T
	JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = T.UNIDADE_RESPONSAVEL
	JOIN LY_DISCIPLINA D ON D.DISCIPLINA = T.DISCIPLINA
	LEFT JOIN LY_DOCENTE DO ON DO.NUM_FUNC = T.NUM_FUNC
	LEFT JOIN LY_CURSO C ON C.CURSO = T.CURSO
	LEFT JOIN LY_COORDENACAO CO ON CO.CURSO = T.CURSO
	WHERE 1=1 
	AND ((@p_ano IS NOT NULL AND T.ANO = @p_ano) OR @p_ano IS NULL)        
	AND ((@p_semestre IS NOT NULL AND T.SEMESTRE = @p_semestre)  OR @p_semestre IS NULL)       
	AND ((@p_unidade IS NOT NULL AND T.UNIDADE_RESPONSAVEL = @p_unidade) OR @p_unidade IS NULL)       
	AND ((@p_tipo IS NOT NULL AND C.TIPO = @p_tipo) OR @p_tipo IS NULL)        
	AND ((@p_curso IS NOT NULL AND T.CURSO = @p_curso) OR @p_curso IS NULL)
	ORDER BY 1,4,11


SET NOCOUNT OFF

END
GO

DELETE FROM LY_CUSTOM_CLIENTE    
where NOME = 'FTC_Relat_Turmas_Curso'    
and IDENTIFICACAO_CODIGO = '0001' 
GO

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_Relat_Turmas_Curso' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2018-10-01' DATA_CRIACAO
, 'Relat�rio - Turmas Cadastradas por Curso e Unidade e Informa��es de Coordenador' OBJETIVO
, 'Dayse Ackerman' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO 