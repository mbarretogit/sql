USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_SP_StatusMatricula'))
   exec('CREATE PROCEDURE [dbo].[FTC_SP_StatusMatricula] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE dbo.FTC_SP_StatusMatricula     
(      
  @P_ANO VARCHAR(4)
, @P_SEMESTRE VARCHAR(2)
, @P_FACULDADE VARCHAR(20)
, @P_TIPO_CURSO VARCHAR(20)  
, @P_CURSO  VARCHAR(20)  
, @P_TURNO  VARCHAR(20)  
, @P_CURRICULO VARCHAR(20)
, @P_ANO_INGRESSO VARCHAR(4)
, @P_SEM_INGRESSO VARCHAR(2)
, @P_TIPO_EMISSAO T_CODIGO  
)      
AS      
-- [IN�CIO]              
BEGIN      

SET NOCOUNT ON

 IF @P_TIPO_EMISSAO = 'ANALITICO'  
 BEGIN    
    SELECT	 DISTINCT
			  C.FACULDADE																AS [UNIDADE_ENSINO_ALUNO], 
              UE.NOME_COMP																AS [NOME_UNIDADE_ENSINO_ALUNO],
			  C.CURSO																	AS [CURSO],  
			  C.NOME																	AS [NOME_CURSO], 
			  A.CURRICULO																AS [CURRICULO], 
			  A.TURNO																	AS [TURNO],
			  A.SERIE																	AS [SERIE_ALUNO], 
			  A.ANO_INGRESSO															AS [ANO_INGRESSO],
			  A.SEM_INGRESSO															AS [SEM_INGRESSO],
			  A.TIPO_INGRESSO															AS [TIPO_INGRESSO],
			  ISNULL(CONVERT(VARCHAR(10),A.DT_INGRESSO,103),'')							AS [DATA_INGRESSO],
			  ISNULL(A.TURMA_PREF,'')													AS [TURMA_PREF], 
			  A.ALUNO																	AS [ALUNO], 
			  PES.NOME_COMPL															AS [NOME_ALUNO],
              PES.CPF																	AS [CPF],
			  PES.RG_NUM																AS [RG], 
			  PES.E_MAIL																AS [E_MAIL],
			  PES.ENDERECO																AS [ENDERECO],
              PES.END_NUM																AS [NUMERO],
              PES.END_COMPL																AS [COMPLEMENTO],
              PES.CEP																	AS [CEP],
              HM.NOME																	AS [CIDADE],
              HM.UF																		AS [ESTADO],	
              PES.FONE																	AS [FONE], 
			  PES.CELULAR																AS [CELULAR],
			  ISNULL(PM.SIT_MATRICULA,'Ingressado')										AS [SIT_MATRICULA], 
              ISNULL((SELECT TOP 1 'S' 
					FROM LY_ITEM_LANC IL
					JOIN LY_LANC_DEBITO LD
						ON IL.LANC_DEB = LD.LANC_DEB 
					JOIN VW_COBRANCA C
						ON IL.COBRANCA = C.COBRANCA
					LEFT JOIN LY_ITEM_CRED IC 
						ON IC.COBRANCA = C.COBRANCA
				WHERE LD.ALUNO = PM.ALUNO
				AND LD.ANO_REF = PM.ANO
				AND LD.PERIODO_REF = PM.SEMESTRE
				AND C.VALOR <= 1
				AND LD.LANC_DEB = PM.LANC_DEB
				AND LD.CODIGO_LANC IN ('MS','MS_EB')
				GROUP BY IL.COBRANCA
				HAVING MAX(IL.PARCELA) = 1
				),'N')														AS [PAGO],
			   ISNULL((SELECT TOP 1 CONVERT(VARCHAR(10),IC.DATA,103)
					FROM LY_ITEM_LANC IL
					JOIN LY_LANC_DEBITO LD
						ON IL.LANC_DEB = LD.LANC_DEB 
					JOIN VW_COBRANCA C
						ON IL.COBRANCA = C.COBRANCA
					JOIN LY_ITEM_CRED IC 
						ON IC.COBRANCA = C.COBRANCA
				WHERE LD.ALUNO = PM.ALUNO
				AND LD.ANO_REF = PM.ANO
				AND LD.PERIODO_REF = PM.SEMESTRE
				AND C.VALOR <= 1
				AND LD.LANC_DEB = PM.LANC_DEB
				AND LD.CODIGO_LANC IN ('MS','MS_EB')
				GROUP BY IC.DATA
				HAVING MAX(IL.PARCELA) = 1
				),'')													AS [DATA_PAGAMENTO],
				ISNULL(CA.CONTRATO_ACEITO,'X')							AS [CONTRATO_ACEITO]
FROM LY_ALUNO A							
LEFT JOIN ( SELECT ANO, SEMESTRE, DISCIPLINA, TURMA, ALUNO, 'Matriculado' AS SIT_MATRICULA, DT_ULTALT , SERIE_CALCULO, LANC_DEB, COBRANCA_SEP, SIT_DETALHE, GRUPO_ELETIVA , DT_INSERCAO, 'S' AS CONFIRMADA
            FROM LY_MATRICULA X WHERE SIT_MATRICULA NOT IN ('Dispensado','Cancelado','Trancado')
            UNION
		    SELECT ANO, SEMESTRE, DISCIPLINA, TURMA, ALUNO, 'Pre-Matriculado' AS SIT_MATRICULA, DT_ULTALT , SERIE_CALCULO, LANC_DEB, COBRANCA_SEP, SIT_DETALHE, GRUPO_ELETIVA , DT_INSERCAO, CONFIRMADA
            FROM LY_PRE_MATRICULA X WHERE NOT EXISTS (SELECT 1 FROM LY_MATRICULA WHERE ALUNO = X.ALUNO) AND X.DISPENSADA = 'N'
            UNION           
		    SELECT ANO, SEMESTRE, DISCIPLINA, TURMA, ALUNO, 'Matriculado' AS SIT_MATRICULA,  DT_ULTALT, SERIE AS SERIE_CALCULO, LANC_DEB, COBRANCA_SEP, SIT_DETALHE, GRUPO_ELETIVA, DT_MATRICULA AS DT_INSERCAO, 'S' CONFIRMADA
		    FROM LY_HISTMATRICULA WHERE SITUACAO_HIST NOT IN ('Cancelado','Dispensado')
		  ) PM ON PM.ALUNO = A.ALUNO
JOIN LY_PESSOA PES
    ON PES.PESSOA = A.PESSOA
JOIN LY_CURSO C							-- PARA SABER NOME DO CURSO E JOIN COM UNIDADE ENSINO
	ON A.CURSO = C.CURSO
JOIN LY_UNIDADE_ENSINO UE				-- PARA SABER NOME UNIDADE ENSINO
	ON C.FACULDADE = UE.UNIDADE_ENS
JOIN HD_MUNICIPIO HM
	ON HM.MUNICIPIO = PES.END_MUNICIPIO
LEFT JOIN LY_LANC_DEBITO LD
	ON LD.LANC_DEB = PM.LANC_DEB
LEFT JOIN LY_CONTRATO_ALUNO CA ON CA.ALUNO = PM.ALUNO AND CA.ANO = PM.ANO AND CA.PERIODO = PM.SEMESTRE
WHERE 1=1
AND (@P_ANO IS NOT NULL AND ISNULL(PM.ANO,@P_ANO) = @P_ANO)
AND (@P_SEMESTRE IS NOT NULL AND ISNULL(PM.SEMESTRE,@P_SEMESTRE) = @P_SEMESTRE)
AND ((@P_FACULDADE IS NOT NULL AND C.FACULDADE = @P_FACULDADE) OR @P_FACULDADE IS NULL) 
AND (@P_TIPO_CURSO IS NOT NULL AND C.TIPO = @P_TIPO_CURSO)  
AND ((@P_CURSO IS NOT NULL AND C.CURSO = @P_CURSO) OR @P_CURSO IS NULL)
AND ((@P_TURNO IS NOT NULL AND A.TURNO = @P_TURNO) OR @P_TURNO IS NULL)  
AND ((@P_CURRICULO IS NOT NULL AND A.CURRICULO = @P_CURRICULO) OR @P_CURRICULO IS NULL)
AND ((@P_ANO_INGRESSO IS NOT NULL AND A.ANO_INGRESSO = @P_ANO_INGRESSO) OR @P_ANO_INGRESSO IS NULL)
AND ((@P_SEM_INGRESSO IS NOT NULL AND A.SEM_INGRESSO = @P_SEM_INGRESSO) OR @P_SEM_INGRESSO IS NULL)
 

ORDER BY C.FACULDADE, UE.NOME_COMP, C.CURSO, C.NOME
 END

IF @P_TIPO_EMISSAO = 'SINTETICO'  
BEGIN  
 	SELECT	  DISTINCT C.FACULDADE												AS [UNIDADE_ENSINO_ALUNO], 
              UE.NOME_COMP																AS [NOME_UNIDADE_ENSINO_ALUNO],
			  C.CURSO																	AS [CURSO],  
			  C.NOME																	AS [NOME_CURSO], 
			  ISNULL(PM.SIT_MATRICULA,'Ingressado')										AS [SIT_MATRICULA], 
    --          ISNULL((SELECT TOP 1 'S' 
				--	FROM LY_ITEM_LANC IL
				--	JOIN LY_LANC_DEBITO LD
				--		ON IL.LANC_DEB = LD.LANC_DEB 
				--	JOIN VW_COBRANCA C
				--		ON IL.COBRANCA = C.COBRANCA
				--	LEFT JOIN LY_ITEM_CRED IC 
				--		ON IC.COBRANCA = C.COBRANCA
				--WHERE LD.ANO_REF = PM.ANO
				--AND LD.PERIODO_REF = PM.SEMESTRE
				--AND C.VALOR <= 1
				--AND LD.CODIGO_LANC IN ('MS','MS_EB')
				--GROUP BY IL.COBRANCA
				--HAVING MAX(IL.PARCELA) = 1
				--),'N')																	AS [PAGO],
				COUNT(DISTINCT PM.ALUNO)													AS [QTD_ALUNOS]
FROM LY_ALUNO A							
LEFT JOIN ( SELECT ANO, SEMESTRE, DISCIPLINA, TURMA, ALUNO, 'Matriculado' AS SIT_MATRICULA, DT_ULTALT , SERIE_CALCULO, COBRANCA_SEP, SIT_DETALHE, GRUPO_ELETIVA , DT_INSERCAO, 'S' AS CONFIRMADA
            FROM LY_MATRICULA X WHERE SIT_MATRICULA NOT IN ('Dispensado','Cancelado','Trancado')
            UNION
		    SELECT ANO, SEMESTRE, DISCIPLINA, TURMA, ALUNO, 'Pre-Matriculado' AS SIT_MATRICULA, DT_ULTALT , SERIE_CALCULO, COBRANCA_SEP, SIT_DETALHE, GRUPO_ELETIVA , DT_INSERCAO, CONFIRMADA
            FROM LY_PRE_MATRICULA X WHERE NOT EXISTS (SELECT 1 FROM LY_MATRICULA WHERE ALUNO = X.ALUNO) AND X.DISPENSADA = 'N'
            UNION           
		    SELECT ANO, SEMESTRE, DISCIPLINA, TURMA, ALUNO, 'Matriculado' AS SIT_MATRICULA,  DT_ULTALT, SERIE AS SERIE_CALCULO, COBRANCA_SEP, SIT_DETALHE, GRUPO_ELETIVA, DT_MATRICULA AS DT_INSERCAO, 'S' CONFIRMADA
		    FROM LY_HISTMATRICULA WHERE SITUACAO_HIST NOT IN ('Cancelado','Dispensado')
		  ) PM ON PM.ALUNO = A.ALUNO
JOIN LY_CURSO C							
	ON A.CURSO = C.CURSO
JOIN LY_UNIDADE_ENSINO UE				
	ON C.FACULDADE = UE.UNIDADE_ENS
WHERE 1=1 AND PM.ANO = 2017 AND PM.SEMESTRE = 1 AND C.FACULDADE = '07'
AND EXISTS (SELECT 1 FROM LY_HISTMATRICULA H WHERE H.ALUNO = PM.ALUNO AND H.ANO = 2016 AND H.SEMESTRE = 2)
--AND (@P_ANO IS NOT NULL AND ISNULL(PM.ANO,@P_ANO) = @P_ANO)
--AND (@P_SEMESTRE IS NOT NULL AND ISNULL(PM.SEMESTRE,@P_SEMESTRE) = @P_SEMESTRE)
--AND ((@P_FACULDADE IS NOT NULL AND C.FACULDADE = @P_FACULDADE) OR @P_FACULDADE IS NULL) 
--AND (@P_TIPO_CURSO IS NOT NULL AND C.TIPO = @P_TIPO_CURSO)  
--AND ((@P_CURSO IS NOT NULL AND C.CURSO = @P_CURSO) OR @P_CURSO IS NULL)
--AND ((@P_TURNO IS NOT NULL AND A.TURNO = @P_TURNO) OR @P_TURNO IS NULL)  
--AND ((@P_CURRICULO IS NOT NULL AND A.CURRICULO = @P_CURRICULO) OR @P_CURRICULO IS NULL)
--AND ((@P_ANO_INGRESSO IS NOT NULL AND A.ANO_INGRESSO = @P_ANO_INGRESSO) OR @P_ANO_INGRESSO IS NULL)
--AND ((@P_SEM_INGRESSO IS NOT NULL AND A.SEM_INGRESSO = @P_SEM_INGRESSO) OR @P_SEM_INGRESSO IS NULL)
 	GROUP BY C.FACULDADE, UE.NOME_COMP,C.CURSO,C.NOME,PM.SIT_MATRICULA,PM.ANO,PM.SEMESTRE
 	ORDER BY 1,2,3,4,5



END 


SET NOCOUNT OFF
  
END              
GO