USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_Relat_BolsasAlunoPeriodoLetivo'))
   exec('CREATE PROCEDURE [dbo].[FTC_Relat_BolsasAlunoPeriodoLetivo] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE dbo.FTC_Relat_BolsasAlunoPeriodoLetivo
(      
	@p_ano VARCHAR(4)
	, @p_semestre  VARCHAR(2)  
	, @p_faculdade VARCHAR(MAX)
	, @p_tipo VARCHAR(MAX)  
	, @p_curso  VARCHAR(20)
	, @p_ano_ingresso VARCHAR(4)
	, @p_sem_ingresso VARCHAR(2) 

)      
AS      
-- [IN�CIO]  

--EXEC FTC_Relat_BolsasAlunoPeriodoLetivo '2018', '2', '03,04,30', 'GRADUACAO-EAD,GRADUACAO-SP,TECNOLOGO,GRADUACAO', NULL, NULL, NULL
BEGIN      

 DECLARE @v_todas_faculdades VARCHAR(1)    
 DECLARE @v_todos_tipo_curso VARCHAR(1)
    
 IF NOT EXISTS ( SELECT 1    
     FROM LY_UNIDADE_ENSINO    
     WHERE NOT EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @v_todas_faculdades, ',') WHERE LY_UNIDADE_ENSINO.UNIDADE_ENS = ValorIni ) )    
 BEGIN    
   SET @v_todas_faculdades = 'S'    
 END    
 ELSE    
 BEGIN    
   SET @v_todas_faculdades = 'N'    
 END    
 
  IF NOT EXISTS ( SELECT 1    
     FROM LY_TIPO_CURSO    
     WHERE NOT EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @v_todos_tipo_curso, ',') WHERE LY_TIPO_CURSO.TIPO = ValorIni ) )    
	BEGIN    
	SET @v_todos_tipo_curso = 'S'    
	END    
	ELSE    
	BEGIN    
	SET @v_todos_tipo_curso = 'N'    
	END

  
SET NOCOUNT ON    
    
  SELECT
	C.TIPO AS [TIPO_CURSO],
     C.CURSO                AS [CURSO],    
     C.NOME                 AS [NOME_CURSO],   
     A.CURRICULO              AS [CURRICULO],   
     A.TURNO                 AS [TURNO],  
     A.SERIE                 AS [SERIE_ALUNO],   
     C.FACULDADE                AS [UNIDADE_ENSINO_ALUNO],   
     UE.NOME_COMP                AS [NOME_UNIDADE_ENSINO_ALUNO],   
     A.ANO_INGRESSO               AS [ANO_INGRESSO],  
     A.SEM_INGRESSO               AS [SEM_INGRESSO],  
     A.TIPO_INGRESSO               AS [TIPO_INGRESSO],   
     A.ALUNO                 AS [ALUNO],   
     PES.NOME_COMPL               AS [NOME_ALUNO],  
     PES.CPF                 AS [CPF],  
     PES.RG_NUM                AS [RG],   
     A.ANOCONCL_2G                AS [ANO_CONCLUSAO_2G],   
     PES.E_MAIL                AS [E_MAIL],  
     PES.ENDERECO                AS [ENDERECO],  
	PES.END_NUM                AS [NUMERO],  
    PES.END_COMPL                AS [COMPLEMENTO],  
    PES.CEP                 AS [CEP],  
    HM.NOME                 AS [CIDADE],  
    HM.UF                  AS [ESTADO],   
    PES.FONE                 AS [FONE],   
     PES.CELULAR                AS [CELULAR],   
     B.TIPO_BOLSA                AS [TIPO_BOLSA],   
     TB.DESCRICAO                AS [NOME_BOLSA],   
     B.PERC_VALOR                AS [PERC_VALOR],   
     B.VALOR                 AS [VALOR_BOLSA],   
     B.ANOINI                 AS [ANOINI_BOLSA],   
     B.MESINI                 AS [MESINI_BOLSA],   
     B.ANOFIM                 AS [ANOFIM_BOLSA],   
     B.MESFIM                 AS [MESFIM_BOLSA],   
     B.DATA_BOLSA                AS [DATA_BOLSA]   
FROM LY_ALUNO A         
JOIN LY_PESSOA PES  
    ON PES.PESSOA = A.PESSOA  
JOIN LY_CURSO C       
 ON A.CURSO = C.CURSO  
JOIN LY_UNIDADE_ENSINO UE    
 ON C.FACULDADE = UE.UNIDADE_ENS  
JOIN LY_BOLSA B  
 ON A.ALUNO = B.ALUNO  
JOIN LY_TIPO_BOLSA TB  
 ON B.TIPO_BOLSA = TB.TIPO_BOLSA  
JOIN HD_MUNICIPIO HM  
 ON HM.MUNICIPIO = PES.END_MUNICIPIO  
WHERE 1=1
AND B.DATA_CANCEL IS NULL
AND ((@p_curso IS NOT NULL AND C.CURSO = @p_curso) OR @p_curso IS NULL)  
AND ((@p_ano_ingresso IS NOT NULL AND @p_ano_ingresso = A.ANO_INGRESSO) OR @p_ano_ingresso IS NULL )
AND ((@p_ano IS NOT NULL AND @p_ano = B.ANOINI) OR @p_ano IS NULL)
AND ((@p_semestre IS NOT NULL AND B.MESINI BETWEEN (CASE WHEN @p_semestre IN ('1','11') THEN 1 WHEN @p_semestre IN ('2','22') THEN 7 ELSE 1 END) AND (CASE WHEN @p_semestre IN ('1','11') THEN 6 ELSE 12 END)) OR @p_semestre IS NULL)
AND ( @p_faculdade IS NULL OR @v_todas_faculdades = 'S' OR EXISTS ( SELECT 1    
        FROM LY_UNIDADE_ENSINO UE    
        WHERE 1=1
        AND UE.UNIDADE_ENS = C.FACULDADE
        AND EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @p_faculdade, ',') WHERE ValorIni = UE.UNIDADE_ENS )   
		) )

AND ( @p_tipo IS NULL OR @v_todos_tipo_curso = 'S' OR EXISTS ( SELECT 1    
        FROM LY_TIPO_CURSO TP    
        WHERE 1=1  
        AND TP.TIPO = C.TIPO
        AND EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @p_tipo, ',') WHERE ValorIni = TP.TIPO )  
		) ) 
ORDER BY C.FACULDADE, UE.NOME_COMP, C.CURSO, C.NOME  
 
    
SET NOCOUNT OFF 
  
END              
GO

delete from LY_CUSTOM_CLIENTE
where NOME = 'FTC_Relat_BolsasAlunoPeriodoLetivo'
and IDENTIFICACAO_CODIGO = '0002'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_Relat_BolsasAlunoPeriodoLetivo' NOME
, '0002' IDENTIFICAO_CODIGO
, 'Ediley' AUTOR
, '2018-09-28' DATA_CRIACAO
, 'Relatorio de Bolsas - Ajuste de Regras Bolsa Cancelada' OBJETIVO
, 'Nelson' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO 