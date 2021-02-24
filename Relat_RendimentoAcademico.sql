USE LYCEUM
GO

--EXEC Relat_RendimentoAcademico ''

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.Relat_RendimentoAcademico'))
   exec('CREATE PROCEDURE [dbo].[Relat_RendimentoAcademico] AS BEGIN SET NOCOUNT OFF; END')
GO 


ALTER  PROCEDURE dbo.Relat_RendimentoAcademico  
(    
 @p_ano NUMERIC(4,0),  
 @p_semestre NUMERIC(2,0),  
 @p_unidade_ensino VARCHAR(20),      
 @p_unidade_fisica VARCHAR(20),    
 @p_curso VARCHAR(20),  
 @p_turno VARCHAR(20),  
 @p_curriculo VARCHAR(20),  
 @p_serie NUMERIC(3,0),  
 @p_indice VARCHAR(20)  
)  
  
AS    
-- [INICIO]

BEGIN  
  
 SELECT ue.UNIDADE_ENS,  
     ue.NOME_COMP,  
     CASE WHEN ind.CURSO IS NULL OR LTRIM(RTRIM(ind.CURSO)) = '' THEN a.CURSO ELSE ind.CURSO END AS CURSO,  
     c.NOME AS NOME_CURSO,  
     t.TURNO,  
     t.DESCRICAO AS DESCR_TURNO,  
     a.SERIE,  
        ind.ALUNO,  
        a.NOME_COMPL,   
     ind.CLASSIFICACAO,  
     ind.DESCRICAO,  
     ind.DT_DIVULG,  
     ind.INDICE,  
     ind.VALOR,
	 (SELECT TOP 1 VALOR FROM LY_INDICE_ALUNO WHERE ALUNO = a.aluno AND INDICE = 'GLOBAL') AS INDICE_GLOBAL  
 FROM LY_INDICE_ALUNO ind  
 JOIN LY_ALUNO a ON ind.ALUNO = a.ALUNO  
 JOIN LY_CURSO c ON (CASE WHEN ind.CURSO IS NULL OR LTRIM(RTRIM(ind.CURSO)) = '' THEN a.CURSO ELSE ind.CURSO END) = c.CURSO  
 JOIN LY_TURNO t ON a.TURNO = t.TURNO  
 JOIN LY_UNIDADE_ENSINO ue ON c.FACULDADE = ue.UNIDADE_ENS
 WHERE ind.ANO = @p_ano  
   AND ind.PERIODO = @p_semestre  
   AND (@p_unidade_ensino IS NULL OR (@p_unidade_ensino IS NOT NULL AND c.FACULDADE = @p_unidade_ensino))  
   AND (@p_unidade_fisica IS NULL OR (@p_unidade_fisica IS NOT NULL AND (CASE WHEN ind.UNIDADE_FIS IS NULL OR LTRIM(RTRIM(ind.UNIDADE_FIS)) = '' THEN a.UNIDADE_FISICA ELSE ind.UNIDADE_FIS END) = @p_unidade_fisica))  
   AND (@p_curso IS NULL OR (@p_curso IS NOT NULL AND (CASE WHEN ind.CURSO IS NULL OR LTRIM(RTRIM(ind.CURSO)) = '' THEN a.CURSO ELSE ind.CURSO END) = @p_curso))  
   AND (@p_turno IS NULL OR (@p_turno IS NOT NULL AND a.TURNO = @p_turno))  
   AND (@p_curriculo IS NULL OR (@p_curriculo IS NOT NULL AND a.CURRICULO = @p_curriculo))  
   AND (@p_serie IS NULL OR (@p_serie IS NOT NULL AND a.SERIE = @p_serie))  
   AND (@p_indice IS NULL OR (@p_indice IS NOT NULL AND ind.INDICE = @p_indice))  
 ORDER BY ue.NOME_COMP, c.NOME, a.NOME_COMPL, ind.INDICE  
   
END  
-- [FIM]  

  
DELETE FROM LY_CUSTOM_CLIENTE    
where NOME = 'Relat_RendimentoAcademico'    
and IDENTIFICACAO_CODIGO = '0001' 
GO

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'Relat_RendimentoAcademico' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2018-03-20' DATA_CRIACAO
, 'Acréscimo de Campo no Relatório RendimentoAcademico' OBJETIVO
, 'Girlane, Jéssica, Paulo Henrique' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO 