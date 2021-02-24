USE FTC_DATAMART
GO

--EXEC BI_ACOMP_MATR_POS_JOB

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.BI_ACOMP_MATR_POS_JOB'))
   exec('CREATE PROCEDURE [dbo].[BI_ACOMP_MATR_POS_JOB] AS BEGIN SET NOCOUNT OFF; END')
GO 
 
ALTER PROCEDURE dbo.BI_ACOMP_MATR_POS_JOB       
         
AS            
-- [IN�CIO]                    
BEGIN            
        
--CRIANDO TABELA PARA O BI
IF EXISTS (SELECT * FROM sys.tables WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.BI_ACOMP_MATR_POS'))   
BEGIN
	DROP TABLE BI_ACOMP_MATR_POS
END

CREATE TABLE BI_ACOMP_MATR_POS 
(
	[UNIDADE_ENSINO_ALUNO]	VARCHAR(20),
	[NOME_UNIDADE_ENSINO_ALUNO] VARCHAR(100),
	[TIPO_CURSO] VARCHAR(50),
	[CURSO] VARCHAR(20),
	[NOME_CURSO] VARCHAR(100),
	[TURMA_PREFERENCIAL] VARCHAR(20),
	[TURNO] VARCHAR(20),
	[PERIODO_INGRESSO] VARCHAR(10),
	[TIPO_ALUNO] VARCHAR(50),
	[PAGO] NUMERIC(10),
	[NAO_PAGO] NUMERIC(10),
	[ALUNO] VARCHAR(20),
	[CPF] VARCHAR(20),
	[NOME_ALUNO] VARCHAR(100),
	[CURRICULO] VARCHAR(20),
	[SIT_ALUNO] VARCHAR(30),
	[DT_INGRESSO] DATETIME,
	[DT_INSERCAO] DATETIME,
	[SIT_MATRICULA] VARCHAR(20),
	[RG] VARCHAR(20),
	[E_MAIL] VARCHAR(100),
	[ENDERECO] VARCHAR(50),
	[NUMERO] VARCHAR(20),
	[COMPLEMENTO] VARCHAR(50),
	[CEP] VARCHAR(9),
	[BAIRRO] VARCHAR(50),
	[CIDADE] VARCHAR(100),
	[ESTADO] VARCHAR(2),
	[DDD_FONE] VARCHAR(3),
	[FONE] VARCHAR(30),
	[DDD_CELULAR] VARCHAR(3),
	[CELULAR] VARCHAR(30)
	

)  

--ALIMENTANDO TEMPORARIA COM TODOS OS ALUNOS
	INSERT INTO BI_ACOMP_MATR_POS
    SELECT   DISTINCT     
				C.FACULDADE						AS [UNIDADE_ENSINO_ALUNO],       
				A.UNIDADE_FISICA				AS [NOME_UNIDADE_ENSINO_ALUNO],
				C.TIPO							AS [TIPO_CURSO]      ,
				C.CURSO							AS [CURSO],        
				C.NOME							AS [NOME_CURSO], 
				ISNULL(A.TURMA_PREF,'')			AS [TURMA_PREFERENCIAL],      
				A.TURNO							AS [TURNO], 
				CONCAT(A.ANO_INGRESSO,A.SEM_INGRESSO)	AS PERIODO_INGRESSO,
				CASE WHEN A.ANO_INGRESSO < '2019' THEN 'VETERANO' ELSE 'CALOURO' END AS TIPO_ALUNO,
				1								AS [PAGO],
				0								AS [NAO_PAGO],
				A.ALUNO,
				P.CPF,
				A.NOME_COMPL					AS NOME_ALUNO,
				A.CURRICULO,
				A.SIT_ALUNO				AS SIT_ALUNO,
				ISNULL(CONVERT(DATETIME,A.DT_INGRESSO,103),'')	AS DT_INGRESSO,
				ISNULL(CONVERT(DATETIME,PM.DT_INSERCAO,103),'')	AS DT_INSERCAO,
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
				 ISNULL(P.DDD_FONE,'')				AS [DDD_FONE],
				 ISNULL(P.FONE,'')                 AS [FONE], 
				 ISNULL(P.DDD_FONE_CELULAR,'')		AS [DDD_CELULAR],    
				 ISNULL(P.CELULAR,'')                AS [CELULAR]
	FROM LYCEUM..LY_ALUNO A 
	JOIN LYCEUM..LY_PESSOA P ON P.PESSOA = A.PESSOA            
	JOIN LYCEUM..LY_CURSO C ON A.CURSO = C.CURSO
	JOIN LYCEUM..LY_UNIDADE_ENSINO UE ON C.FACULDADE = UE.UNIDADE_ENS
	JOIN HADES..HD_MUNICIPIO HM ON HM.MUNICIPIO = P.END_MUNICIPIO 
	LEFT JOIN (SELECT DISTINCT ALUNO,SIT_MATRICULA, DT_INSERCAO FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA WHERE SIT_MATRICULA IN ('Matriculado','Pre-Matriculado')) PM ON PM.ALUNO = A.ALUNO 
	WHERE 1=1 
	AND (EXISTS (SELECT TOP 1 1 FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA WHERE ALUNO = A.ALUNO) 
	 OR EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_HISTMATRICULA WHERE ALUNO = A.ALUNO) )
	AND A.SIT_ALUNO NOT IN ('Cancelado','Evadido','Concluido','Jubilado') 
	AND C.TIPO IN ('POS-GRADUACAO','EXTENSAO')
		AND (EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_ITEM_CRED IC
				JOIN LYCEUM..LY_ITEM_LANC IL ON IL.COBRANCA = IC.COBRANCA
				JOIN LYCEUM..LY_LANC_DEBITO LD ON LD.LANC_DEB = IL.LANC_DEB
				WHERE TIPO_ENCARGO IS NULL AND TIPODESCONTO IS NULL
				AND LD.ALUNO = A.ALUNO 
				AND LD.CODIGO_LANC IN ('MS','MS_EB','ACORDO'))
					
		OR EXISTS (SELECT TOP 1 1 FROM LYCEUM..VW_COBRANCA VW
					JOIN LYCEUM..LY_ITEM_LANC IL ON IL.COBRANCA = VW.COBRANCA
					JOIN LYCEUM..LY_COBRANCA C ON C.COBRANCA = VW.COBRANCA
					WHERE VW.ALUNO = A.ALUNO AND VW.VALOR <= 0
					AND IL.PARCELA = 1
					AND IL.CODIGO_LANC IN ('MS','MS_EB','ACORDO')
					AND C.DT_ESTORNO IS NULL))
    
UNION

    SELECT   DISTINCT     
     C.FACULDADE							AS [UNIDADE_ENSINO_ALUNO],       
     A.UNIDADE_FISICA						AS [NOME_UNIDADE_ENSINO_ALUNO], 
	 C.TIPO									AS [TIPO_CURSO]     ,
     C.CURSO								AS [CURSO],        
     C.NOME									AS [NOME_CURSO],       
	 ISNULL(A.TURMA_PREF,'')				AS [TURMA_PREFERENCIAL],
     A.TURNO								AS [TURNO], 
	 CONCAT(A.ANO_INGRESSO,A.SEM_INGRESSO)	AS PERIODO_INGRESSO, 
	 CASE WHEN A.ANO_INGRESSO < '2019' THEN 'VETERANO' ELSE 'CALOURO' END AS TIPO_ALUNO,    
	 0						AS [PAGO],
	 1						AS [NAO_PAGO],
	 A.ALUNO,
	 P.CPF,
	 A.NOME_COMPL			AS NOME_ALUNO,
	 A.CURRICULO,
	 A.SIT_ALUNO				AS SIT_ALUNO,
	ISNULL(CONVERT(DATETIME,A.DT_INGRESSO,103),'')	AS DT_INGRESSO,
	ISNULL(CONVERT(DATETIME,PM.DT_INSERCAO,103),'')	AS DT_INSERCAO,
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
	ISNULL(P.DDD_FONE,'')				AS [DDD_FONE],
	ISNULL(P.FONE,'')                 AS [FONE], 
	ISNULL(P.DDD_FONE_CELULAR,'')		AS [DDD_CELULAR],    
	ISNULL(P.CELULAR,'')                AS [CELULAR]
FROM LYCEUM..LY_ALUNO A
JOIN LYCEUM..LY_PESSOA P ON P.PESSOA = A.PESSOA             
JOIN LYCEUM..LY_CURSO C ON A.CURSO = C.CURSO
JOIN LYCEUM..LY_UNIDADE_ENSINO UE ON C.FACULDADE = UE.UNIDADE_ENS
JOIN LYCEUM..HD_MUNICIPIO HM ON HM.MUNICIPIO = P.END_MUNICIPIO
LEFT JOIN (SELECT DISTINCT ALUNO,SIT_MATRICULA, DT_INSERCAO FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA WHERE SIT_MATRICULA IN ('Matriculado','Pre-Matriculado')) PM ON PM.ALUNO = A.ALUNO 
WHERE 1=1 
AND A.SIT_ALUNO NOT IN ('Cancelado','Evadido','Concluido','Jubilado') 
AND C.TIPO IN ('POS-GRADUACAO','EXTENSAO') 
	AND (EXISTS (SELECT TOP 1 1 FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA WHERE ALUNO = A.ALUNO) 
	 OR EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_HISTMATRICULA WHERE ALUNO = A.ALUNO) )
AND (NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..LY_ITEM_CRED IC
				JOIN LYCEUM..LY_ITEM_LANC IL ON IL.COBRANCA = IC.COBRANCA
				JOIN LYCEUM..LY_LANC_DEBITO LD ON LD.LANC_DEB = IL.LANC_DEB
				WHERE TIPO_ENCARGO IS NULL AND TIPODESCONTO IS NULL
				AND LD.ALUNO = A.ALUNO 
				AND LD.CODIGO_LANC IN ('MS','MS_EB','ACORDO'))
		AND NOT EXISTS (SELECT TOP 1 1 FROM LYCEUM..VW_COBRANCA VW
					JOIN LYCEUM..LY_ITEM_LANC IL ON IL.COBRANCA = VW.COBRANCA
					JOIN LYCEUM..LY_COBRANCA C ON C.COBRANCA = VW.COBRANCA
					WHERE VW.ALUNO = A.ALUNO AND VW.VALOR <= 0
					AND IL.PARCELA = 1
					AND IL.CODIGO_LANC IN ('MS','MS_EB','ACORDO')
					AND C.DT_ESTORNO IS NULL))
ORDER BY C.FACULDADE, C.CURSO 

        
END                  
    
-- [FIM]          
    
GO