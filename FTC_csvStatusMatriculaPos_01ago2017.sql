USE LYCEUM
GO

--EXEC FTC_Relat_StatusMatriculaPos '03',NULL,'2738',NULL,NULL,NULL,NULL,NULL,1

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_Relat_StatusMatriculaPos'))
   exec('CREATE PROCEDURE [dbo].[FTC_Relat_StatusMatriculaPos] AS BEGIN SET NOCOUNT OFF; END')
GO 
 
ALTER PROCEDURE dbo.FTC_Relat_StatusMatriculaPos       
(            
  
 @p_unidade VARCHAR(20)      
, @p_tipo VARCHAR(20)        
, @p_curso  VARCHAR(20)
, @p_turma_preferencial VARCHAR(30)        
, @p_dt_ingresso_ini  DATETIME
, @p_dt_ingresso_fim  DATETIME
, @p_ano_ingresso numeric(4)
, @p_sem_ingresso numeric(2)
, @p_sit_aluno VARCHAR(20)        
, @p_tipo_relatorio VARCHAR(1)
)            
AS            
-- [INÍCIO]                    
BEGIN            
        
SET NOCOUNT ON   

--ALIMENTANDO TEMPORARIA COM TODOS OS ALUNOS DO FILTRO

    SELECT   DISTINCT     
				C.FACULDADE							AS [UNIDADE_ENSINO_ALUNO],       
				A.UNIDADE_FISICA						AS [NOME_UNIDADE_ENSINO_ALUNO],      
				C.CURSO								AS [CURSO],        
				C.NOME									AS [NOME_CURSO], 
				ISNULL(A.TURMA_PREF,'')							AS [TURMA_PREFERENCIAL],      
				A.TURNO								AS [TURNO], 
				CONCAT(A.ANO_INGRESSO,A.SEM_INGRESSO)	AS PERIODO_INGRESSO,     
				1						AS [PAGO],
				0						AS [NAO_PAGO],
				A.ALUNO,
				P.CPF,
				A.NOME_COMPL			AS NOME_ALUNO,
				A.CURRICULO,
				A.SIT_ALUNO				AS SIT_ALUNO,
				ISNULL(CONVERT(VARCHAR(10),A.DT_INGRESSO,103),'')	AS DT_INGRESSO,
				ISNULL(CONVERT(VARCHAR(10),PM.DT_INSERCAO,103),'')	AS DT_INSERCAO,
				ISNULL(PM.SIT_MATRICULA,'') AS [SIT_MATRICULA],
				P.RG_NUM               AS [RG],     
				P.E_MAIL               AS [E_MAIL],    
				P.ENDERECO             AS [ENDERECO],    
				P.END_NUM              AS [NUMERO],    
				P.END_COMPL            AS [COMPLEMENTO],    
				P.CEP					AS [CEP],    
				P.BAIRRO				AS [BAIRRO],  
				HM.NOME                AS [CIDADE],    
				HM.UF                  AS [ESTADO],     
				P.FONE                 AS [FONE],     
				P.CELULAR              AS [CELULAR]
		 INTO #TEMP_ALUNOS
	FROM LY_ALUNO A 
	JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA            
	JOIN LY_CURSO C ON A.CURSO = C.CURSO
	JOIN LY_UNIDADE_ENSINO UE ON C.FACULDADE = UE.UNIDADE_ENS
	JOIN HD_MUNICIPIO HM ON HM.MUNICIPIO = P.END_MUNICIPIO 
	LEFT JOIN (SELECT DISTINCT ALUNO,SIT_MATRICULA, DT_INSERCAO FROM VW_MATRICULA_E_PRE_MATRICULA WHERE SIT_MATRICULA IN ('Matriculado','Pre-Matriculado')) PM ON PM.ALUNO = A.ALUNO 
	WHERE 1=1 
	--AND A.SIT_ALUNO NOT IN ('Cancelado','Evadido','Concluido','Jubilado') 
	AND C.TIPO IN ('POS-GRADUACAO','EXTENSAO')
		AND (EXISTS (SELECT TOP 1 1 FROM LY_ITEM_CRED IC
				JOIN LY_ITEM_LANC IL ON IL.COBRANCA = IC.COBRANCA
				JOIN LY_LANC_DEBITO LD ON LD.LANC_DEB = IL.LANC_DEB
				WHERE TIPO_ENCARGO IS NULL AND TIPODESCONTO IS NULL
				AND LD.ALUNO = A.ALUNO 
				AND LD.CODIGO_LANC IN ('MS','MS_EB','ACORDO'))
					
		OR EXISTS (SELECT TOP 1 1 FROM VW_COBRANCA VW
					JOIN LY_ITEM_LANC IL ON IL.COBRANCA = VW.COBRANCA
					JOIN LY_COBRANCA C ON C.COBRANCA = VW.COBRANCA
					WHERE VW.ALUNO = A.ALUNO AND VW.VALOR <= 0
					AND IL.PARCELA = 1
					AND IL.CODIGO_LANC IN ('MS','MS_EB','ACORDO')
					AND C.DT_ESTORNO IS NULL))
	AND ((@p_unidade IS NOT NULL AND C.FACULDADE = @p_unidade) OR @p_unidade IS NULL)   
AND ((@p_tipo IS NOT NULL AND C.TIPO = @p_tipo) OR @p_tipo IS NULL)        
AND ((@p_curso IS NOT NULL AND C.CURSO = @p_curso) OR @p_curso IS NULL)    
AND ((@p_turma_preferencial IS NOT NULL AND A.TURMA_PREF = @p_turma_preferencial) OR @p_turma_preferencial IS NULL)   
	AND ((@p_ano_ingresso IS NOT NULL AND A.ANO_INGRESSO = @p_ano_ingresso) OR @p_ano_ingresso IS NULL)      
	AND ((@p_sem_ingresso IS NOT NULL AND A.SEM_INGRESSO = @p_sem_ingresso) OR @p_sem_ingresso IS NULL)  
	AND ( @p_dt_ingresso_ini IS NULL OR (@p_dt_ingresso_ini IS NOT NULL AND A.DT_INGRESSO  >= @p_dt_ingresso_ini) )    
	AND ( @p_dt_ingresso_fim IS NULL OR (@p_dt_ingresso_fim IS NOT NULL AND A.DT_INGRESSO  <= @p_dt_ingresso_fim) )  
	AND (@p_sit_aluno IS NULL OR (@p_sit_aluno IS NOT NULL AND A.SIT_ALUNO = @p_sit_aluno))      
UNION

    SELECT   DISTINCT     
     C.FACULDADE							AS [UNIDADE_ENSINO_ALUNO],       
     A.UNIDADE_FISICA						AS [NOME_UNIDADE_ENSINO_ALUNO],      
     C.CURSO								AS [CURSO],        
     C.NOME									AS [NOME_CURSO],       
	 ISNULL(A.TURMA_PREF,'')							AS [TURMA_PREFERENCIAL],
     A.TURNO								AS [TURNO], 
	 CONCAT(A.ANO_INGRESSO,A.SEM_INGRESSO)	AS PERIODO_INGRESSO,     
	 0						AS [PAGO],
	 1						AS [NAO_PAGO],
	 A.ALUNO,
	 P.CPF,
	 A.NOME_COMPL			AS NOME_ALUNO,
	 A.CURRICULO,
	 A.SIT_ALUNO				AS SIT_ALUNO,
	ISNULL(CONVERT(VARCHAR(10),A.DT_INGRESSO,103),'')	AS DT_INGRESSO,
	ISNULL(CONVERT(VARCHAR(10),PM.DT_INSERCAO,103),'')	AS DT_INSERCAO,
	 ISNULL(PM.SIT_MATRICULA,'') AS [SIT_MATRICULA],
     P.RG_NUM               AS [RG],     
     P.E_MAIL               AS [E_MAIL],    
     P.ENDERECO             AS [ENDERECO],    
     P.END_NUM              AS [NUMERO],    
     P.END_COMPL            AS [COMPLEMENTO],    
     P.CEP					AS [CEP],    
     P.BAIRRO				AS [BAIRRO],  
     HM.NOME                AS [CIDADE],    
     HM.UF                  AS [ESTADO],     
     P.FONE                 AS [FONE],     
     P.CELULAR              AS [CELULAR]
FROM LY_ALUNO A
JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA             
JOIN LY_CURSO C ON A.CURSO = C.CURSO
JOIN LY_UNIDADE_ENSINO UE ON C.FACULDADE = UE.UNIDADE_ENS
JOIN HD_MUNICIPIO HM ON HM.MUNICIPIO = P.END_MUNICIPIO
LEFT JOIN (SELECT DISTINCT ALUNO,SIT_MATRICULA, DT_INSERCAO FROM VW_MATRICULA_E_PRE_MATRICULA WHERE SIT_MATRICULA IN ('Matriculado','Pre-Matriculado')) PM ON PM.ALUNO = A.ALUNO 
WHERE 1=1 
--AND A.SIT_ALUNO NOT IN ('Cancelado','Evadido','Concluido','Jubilado') 
AND C.TIPO IN ('POS-GRADUACAO','EXTENSAO') 
AND (NOT EXISTS (SELECT TOP 1 1 FROM LY_ITEM_CRED IC
				JOIN LY_ITEM_LANC IL ON IL.COBRANCA = IC.COBRANCA
				JOIN LY_LANC_DEBITO LD ON LD.LANC_DEB = IL.LANC_DEB
				WHERE TIPO_ENCARGO IS NULL AND TIPODESCONTO IS NULL
				AND LD.ALUNO = A.ALUNO 
				AND LD.CODIGO_LANC IN ('MS','MS_EB','ACORDO'))
		AND NOT EXISTS (SELECT TOP 1 1 FROM VW_COBRANCA VW
					JOIN LY_ITEM_LANC IL ON IL.COBRANCA = VW.COBRANCA
					JOIN LY_COBRANCA C ON C.COBRANCA = VW.COBRANCA
					WHERE VW.ALUNO = A.ALUNO AND VW.VALOR <= 0
					AND IL.PARCELA = 1
					AND IL.CODIGO_LANC IN ('MS','MS_EB','ACORDO')
					AND C.DT_ESTORNO IS NULL))
	AND ((@p_unidade IS NOT NULL AND C.FACULDADE = @p_unidade) OR @p_unidade IS NULL)   
AND ((@p_tipo IS NOT NULL AND C.TIPO = @p_tipo) OR @p_tipo IS NULL)        
AND ((@p_curso IS NOT NULL AND C.CURSO = @p_curso) OR @p_curso IS NULL)    
AND ((@p_turma_preferencial IS NOT NULL AND A.TURMA_PREF = @p_turma_preferencial) OR @p_turma_preferencial IS NULL)   
	AND ((@p_ano_ingresso IS NOT NULL AND A.ANO_INGRESSO = @p_ano_ingresso) OR @p_ano_ingresso IS NULL)      
	AND ((@p_sem_ingresso IS NOT NULL AND A.SEM_INGRESSO = @p_sem_ingresso) OR @p_sem_ingresso IS NULL)  
	AND ( @p_dt_ingresso_ini IS NULL OR (@p_dt_ingresso_ini IS NOT NULL AND A.DT_INGRESSO  >= @p_dt_ingresso_ini) )    
	AND ( @p_dt_ingresso_fim IS NULL OR (@p_dt_ingresso_fim IS NOT NULL AND A.DT_INGRESSO  <= @p_dt_ingresso_fim) ) 
	AND (@p_sit_aluno IS NULL OR (@p_sit_aluno IS NOT NULL AND A.SIT_ALUNO = @p_sit_aluno))   
ORDER BY C.FACULDADE, C.CURSO 


--TRAZENDO RESULTADO SINTETICO
IF @p_tipo_relatorio = '0'
	BEGIN
			SELECT        
			 UNIDADE_ENSINO_ALUNO,
			 NOME_UNIDADE_ENSINO_ALUNO,
			 CURSO,
			 NOME_CURSO,
			 TURMA_PREFERENCIAL,
			 SIT_MATRICULA,
			 TURNO,
			 PERIODO_INGRESSO,
			 SUM(PAGO) AS PAGO,
			 SUM(NAO_PAGO) AS NAO_PAGO,				
			 COUNT(ALUNO)			AS [QTD_ALUNOS]
		FROM #TEMP_ALUNOS
		WHERE 1=1  
		GROUP BY UNIDADE_ENSINO_ALUNO,NOME_UNIDADE_ENSINO_ALUNO, CURSO, NOME_CURSO, PERIODO_INGRESSO, TURNO, TURMA_PREFERENCIAL,SIT_MATRICULA
		ORDER BY UNIDADE_ENSINO_ALUNO, CURSO, PERIODO_INGRESSO, TURNO
	END

IF @p_tipo_relatorio = '1' 
	BEGIN

		--UPDATE #TEMP_ALUNOS 
		--SET DT_INSERCAO = '' 
		--WHERE DT_INSERCAO = '1900-01-01 00:00:00.000'
		
									
		SELECT * FROM #TEMP_ALUNOS 
		ORDER BY 1,3

	END       
        
		DROP TABLE #TEMP_ALUNOS

SET NOCOUNT OFF        
        
END                  
    
-- [FIM]          
    
go
    
DELETE FROM LY_CUSTOM_CLIENTE    
where NOME = 'FTC_Relat_StatusMatriculaPos'    
and IDENTIFICACAO_CODIGO = '0002' 
GO

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_Relat_StatusMatriculaPos' NOME
, '0002' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2018-02-22' DATA_CRIACAO
, 'Relatório - Status Matrícula Pós-Graduação - Melhorias' OBJETIVO
, 'Girlane Amorim' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO 