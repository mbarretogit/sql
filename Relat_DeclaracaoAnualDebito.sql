USE LYCEUM
GO

--EXEC [Relat_DeclaracaoAnualDebito] '50','ENS BASICO','50EI','2017','160500043'
--(CONVERT(VARCHAR(15), 

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.Relat_DeclaracaoAnualDebito'))
   exec('CREATE PROCEDURE [dbo].[Relat_DeclaracaoAnualDebito] AS BEGIN SET NOCOUNT OFF; END')
GO 

 
ALTER PROCEDURE [dbo].[Relat_DeclaracaoAnualDebito]  
(  
    @p_uniresp AS VARCHAR(15),  
    @p_nivelcurso AS VARCHAR(25),  
    @p_curso AS VARCHAR(15),  
    @p_ano AS T_ANO,  
    @p_aluno AS VARCHAR(11)
)  
  
AS  
BEGIN  
  -- ATUALIZA O N�MERO DE VIAS EM TODOS OS REGISTROS DO ALUNO E ANO  
  UPDATE LY_COBRANCA_QUITADA   
  SET  
    LY_COBRANCA_QUITADA.NUM_VIAS = NUM_VIAS + 1  
  FROM  
    LY_COBRANCA_QUITADA  
  INNER JOIN  
    LY_ALUNO  
  ON  
    LY_COBRANCA_QUITADA.ALUNO = LY_ALUNO.ALUNO  
  WHERE   
    YEAR(DATA_DE_VENCIMENTO) = @p_ano  
  AND   
    ((@p_aluno IS NOT NULL AND LY_ALUNO.ALUNO = @p_aluno) OR @p_aluno IS NULL)  
      
  -- OBTEM ALUNOS COM QUIATA��O  
  SELECT DISTINCT   
    LY_CURSO.NOME,   
    LY_ALUNO.NOME_COMPL,   
    LY_ALUNO.ALUNO,   
    LY_CURSO.CURSO,   
    MUNICIPIO.NOME AS MUNICIPIO  
   
  FROM   
    LY_COBRANCA_QUITADA  
  INNER JOIN  
    LY_ALUNO  
  ON   
    LY_COBRANCA_QUITADA.ALUNO = LY_ALUNO.ALUNO  
  INNER JOIN   
    LY_CURSO  
  ON  
    LY_ALUNO.CURSO = LY_CURSO.CURSO  
  INNER JOIN  
    LY_FACULDADE  
  ON  
    LY_CURSO.FACULDADE = LY_FACULDADE.FACULDADE   
  INNER JOIN  
    MUNICIPIO  
  ON  
    LY_FACULDADE.MUNICIPIO = MUNICIPIO.CODIGO  
  
  WHERE   
    YEAR(DATA_DE_VENCIMENTO) = @p_ano  
  AND   
    ((@p_uniresp IS NOT NULL AND (CONVERT(VARCHAR(15), LY_CURSO.FACULDADE)) = @p_uniresp) OR @p_uniresp IS NULL)          
  AND   
    ((@p_nivelcurso IS NOT NULL AND (CONVERT(VARCHAR(25), LY_CURSO.TIPO)) = @p_nivelcurso) OR @p_nivelcurso IS NULL)          
  AND   
    ((@p_curso IS NOT NULL AND (CONVERT(VARCHAR(15), LY_CURSO.CURSO)) = @p_curso) OR @p_curso IS NULL)          
  AND   
    ((@p_aluno IS NOT NULL AND (CONVERT(VARCHAR(11), LY_ALUNO.ALUNO)) = @p_aluno) OR @p_aluno IS NULL)          
  
 ORDER BY LY_CURSO.NOME, LY_ALUNO.NOME_COMPL  
    
END;

delete from LY_CUSTOM_CLIENTE
where NOME = 'Relat_DeclaracaoAnualDebito'
and IDENTIFICACAO_CODIGO = '0001'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'Relat_DeclaracaoAnualDebito' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2017-09-05' DATA_CRIACAO
, 'Ajuste - Relat_DeclaracaoAnualDebito' OBJETIVO
, 'Girlane Amorim' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO 