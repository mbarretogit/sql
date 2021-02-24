USE LYCEUM_TECHNE
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.Relat_AvalDocQtdPartic'))
   exec('CREATE PROCEDURE [dbo].[Relat_AvalDocQtdPartic] AS BEGIN SET NOCOUNT OFF; END')
GO 
  
ALTER PROCEDURE Relat_AvalDocQtdPartic  
  @p_avaliacaoq VARCHAR(30)  
 ,@p_aplicacao VARCHAR(30)  
 ,@p_unidade VARCHAR(15)  
 ,@p_curso VARCHAR(20)  

 AS

 --EXEC Relat_AvalDocQtdPartic 'Avaliação Docente I', 'AVALDOCENTE1_20172', '03', NULL

 BEGIN

select COUNT(DISTINCT A.ALUNO) AS QTD from LY_RESPOSTA_AUX RA
JOIN LY_ALUNO A ON A.ALUNO = RA.AVALIADOR
JOIN LY_CURSO C ON C.CURSO = A.CURSO
WHERE 1=1
AND RA.TIPO_QUESTIONARIO = ISNULL(@p_avaliacaoq,RA.TIPO_QUESTIONARIO) 
AND RA.aplicacao = ISNULL(@p_aplicacao,RA.aplicacao)
AND C.FACULDADE = ISNULL(@p_unidade,C.FACULDADE)
AND C.CURSO = ISNULL(@p_curso,C.CURSO)

END