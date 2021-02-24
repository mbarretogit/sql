USE LYCEUM
GO

ALTER PROCEDURE [dbo].[Relat_P_DocenteTurma]  
(  
   @p_unidade VARCHAR(20),  
   @p_curso VARCHAR(20),  
   @p_ano NUMERIC(4,0),  
   @p_periodo NUMERIC(2,0),  
   @p_disciplina VARCHAR(20),  
   @p_unidade_fisica VARCHAR(20)  
)  
  
AS  
BEGIN  
  
SELECT DISTINCT d.NUM_FUNC AS CODIGO, (CONVERT(VARCHAR, d.NUM_FUNC) +' - '+ d.NOME_COMPL) AS DESCR  
FROM LY_TURMA t INNER JOIN  
     LY_DOCENTE d ON t.NUM_FUNC = d.NUM_FUNC  
WHERE t.UNIDADE_RESPONSAVEL = CASE WHEN @p_unidade IS NULL THEN t.UNIDADE_RESPONSAVEL ELSE @p_unidade END AND  
      ((t.CURSO = CASE WHEN @p_curso IS NULL THEN t.CURSO ELSE @p_curso END) OR (t.CURSO IS NULL)) AND  
      t.ANO = CASE WHEN @p_ano IS NULL THEN t.ANO ELSE @p_ano END AND  
      t.SEMESTRE = CASE WHEN @p_periodo IS NULL THEN t.SEMESTRE ELSE @p_periodo END AND  
      t.DISCIPLINA = CASE WHEN @p_disciplina IS NULL THEN t.DISCIPLINA ELSE @p_disciplina END AND  
      t.FACULDADE = CASE WHEN @p_unidade_fisica IS NULL THEN t.FACULDADE ELSE @p_unidade_fisica END  
UNION  
SELECT NULL AS CODIGO, 'TODOS' AS DESCR  
  
END