USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.Relat_P_A_Turma'))
   exec('CREATE PROCEDURE [dbo].[Relat_P_A_Turma] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE [dbo].[Relat_P_A_Turma]  
(  
   @p_avaliacaoq VARCHAR(30),  
   @p_aplicacao VARCHAR(30),
   @p_unidade VARCHAR(20),
   @p_disciplina VARCHAR(20)  
   
)  
  
AS  
BEGIN  
  
SELECT DISTINCT 
			CASE WHEN @p_avaliacaoq NOT IN ('Avalia��o Docente I','Avalia��o DocenteIII') THEN NULL ELSE AVA_CODIGO3 END AS CODIGO
			,CASE WHEN @p_avaliacaoq NOT IN ('Avalia��o Docente I','Avalia��o DocenteIII') THEN NULL ELSE AVA_CODIGO3 END AS DESCR  
FROM LY_RESPOSTA R
JOIN LY_TURMA T ON	CONVERT(VARCHAR(20),T.TURMA) = CONVERT(VARCHAR(20),R.AVA_CODIGO3) 
					AND CONVERT(VARCHAR(20),T.DISCIPLINA) = CONVERT(VARCHAR(20),AVA_CODIGO2) 
					AND CONVERT(VARCHAR(4),T.ANO) = CONVERT(VARCHAR(4),R.CODIGO) 
					AND CONVERT(VARCHAR(2),T.SEMESTRE) = CONVERT(VARCHAR(2),R.AVA_CODIGO1)
WHERE	TIPO_QUESTIONARIO = @p_avaliacaoq 
		AND APLICACAO = @p_aplicacao 
		AND T.UNIDADE_RESPONSAVEL = ISNULL(@p_unidade, T.UNIDADE_RESPONSAVEL)
		AND T.DISCIPLINA = ISNULL(@p_disciplina, T.DISCIPLINA)
UNION  
SELECT NULL AS CODIGO, 'TODAS' AS DESCR  
ORDER BY 1
  
END  