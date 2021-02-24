USE LYCEUM
GO

--EXEC FTC_SP_csvListaTurmas '2017','2','FCS',NULL,NULL,NULL,NULL
ALTER PROCEDURE dbo.FTC_SP_csvListaTurmas  
(        
  @P_ANO VARCHAR(4)  
, @P_SEMESTRE VARCHAR(1)  
, @P_FACULDADE VARCHAR(20)  
, @P_TIPO_CURSO VARCHAR(20)    
, @P_CURSO  VARCHAR(20)    
, @P_TURNO  VARCHAR(20)    
, @P_CURRICULO VARCHAR(20)    
)        
AS        
-- [IN�CIO]                
BEGIN        
    
SET NOCOUNT ON    
    
  SELECT T.UNIDADE_RESPONSAVEL    AS [UNIDADE_ENSINO],  
  UE.NOME_COMP       AS [NOME_UNIDADE_ENS],  
  T.FACULDADE        AS [UNIDADE_FISICA],  
  UF.NOME_COMP       AS [NOME_UNIDADE_FIS],  
  T.ANO         AS [ANO],  
  T.SEMESTRE        AS [SEMESTRE],  
  T.SIT_TURMA        AS [SIT_TURMA],  
  T.TURMA         AS [TURMA],  
  T.DISCIPLINA       AS [DISCIPLINA],  
  isnull(T.NIVEL,'')      AS [NIVEL],  
  D.NOME         AS [NOME_DISCIPLINA],  
  ISNULL(T.CURSO,'')         AS [CURSO],  
  ISNULL(C.NOME,'')         AS [NOME_CURSO],
  ISNULL((	SELECT COUNT(DISTINCT M.ALUNO) FROM VW_MATRICULA_E_PRE_MATRICULA M 
			LEFT JOIN LY_MATRICULA MAT ON MAT.TURMA = M.TURMA AND MAT.DISCIPLINA = M.DISCIPLINA AND MAT.ANO = M.ANO AND MAT.SEMESTRE = M.SEMESTRE
			WHERE M.DISCIPLINA = T.DISCIPLINA AND (MAT.SUBTURMA1 = T.TURMA OR M.TURMA = T.TURMA) AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE AND M.SIT_MATRICULA NOT IN ('Cancelado','Trancado')),0) AS QTD_ALUNOS      
FROM LY_TURMA T  
JOIN LY_DISCIPLINA D ON D.DISCIPLINA = T.DISCIPLINA  
JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = T.UNIDADE_RESPONSAVEL  
JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = T.FACULDADE  
LEFT JOIN LY_CURSO C ON C.CURSO = T.CURSO  
WHERE  ((@P_ANO IS NOT NULL AND T.ANO = @P_ANO) OR @P_ANO IS NULL)  
AND ((@P_SEMESTRE IS NOT NULL AND T.SEMESTRE = @P_SEMESTRE) OR @P_SEMESTRE IS NULL)  
AND ((@P_FACULDADE IS NOT NULL AND T.FACULDADE = @P_FACULDADE) OR @P_FACULDADE IS NULL)   
AND ((@P_TIPO_CURSO IS NOT NULL AND C.TIPO = @P_TIPO_CURSO) OR @P_TIPO_CURSO IS NULL)    
AND ((@P_CURSO IS NOT NULL AND T.CURSO = @P_CURSO) OR @P_CURSO IS NULL)  
AND ((@P_TURNO IS NOT NULL AND T.TURNO = @P_TURNO) OR @P_TURNO IS NULL)    
AND ((@P_CURRICULO IS NOT NULL AND T.CURRICULO = @P_CURRICULO) OR @P_CURRICULO IS NULL)     
ORDER BY 1,3,8    
    
SET NOCOUNT OFF    
    
END                