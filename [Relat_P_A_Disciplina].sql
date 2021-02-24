USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.Relat_P_A_Disciplina'))
   exec('CREATE PROCEDURE [dbo].[Relat_P_A_Disciplina] AS BEGIN SET NOCOUNT OFF; END')
GO 
    
ALTER PROCEDURE [dbo].[Relat_P_A_Disciplina]    
(    
   @p_unidade VARCHAR(20)
   ,@p_avaliacaoq VARCHAR(30)
   ,@p_aplicacao VARCHAR(30)    
)   

    
AS    
BEGIN    
  /*  
  DECLARE @p_unidade VARCHAR(20)
   DECLARE @p_avaliacaoq VARCHAR(30)
   DECLARE @p_aplicacao VARCHAR(30) 

   SET @p_unidade = '03'
   SET @p_avaliacaoq = 'Avaliação DocenteII'
   SET @p_aplicacao = 'AVALDOCENTE2_20171'
*/

SELECT	CASE WHEN @p_avaliacaoq NOT IN ('Avaliação Docente I','Avaliação DocenteIII') THEN NULL ELSE d.DISCIPLINA END AS CODIGO
		,CASE WHEN @p_avaliacaoq NOT IN ('Avaliação Docente I','Avaliação DocenteIII') THEN NULL ELSE (d.DISCIPLINA + ' - ' + d.NOME) END AS DESCR    
FROM LY_DISCIPLINA d     
JOIN LY_RESPOSTA R ON CONVERT(VARCHAR(15),R.AVA_CODIGO2) = CONVERT(VARCHAR(15),d.DISCIPLINA)
JOIN LY_TURMA T ON T.DISCIPLINA = d.DISCIPLINA AND CONVERT(VARCHAR(4),T.ANO)= CONVERT(VARCHAR(4),R.CODIGO) AND CONVERT(VARCHAR(2),T.SEMESTRE) = CONVERT(VARCHAR(2),R.AVA_CODIGO1)
WHERE T.UNIDADE_RESPONSAVEL = ISNULL(@p_unidade,T.UNIDADE_RESPONSAVEL) AND R.TIPO_QUESTIONARIO = @p_avaliacaoq AND R.APLICACAO = @p_aplicacao
UNION    
SELECT NULL AS CODIGO, 'TODAS' AS DESCR      
ORDER BY 2
    
END    