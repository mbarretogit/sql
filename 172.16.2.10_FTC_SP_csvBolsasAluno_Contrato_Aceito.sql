ALTER PROCEDURE dbo.FTC_SP_csvBolsasAluno     
(      
  @P_FACULDADE VARCHAR(20)
, @P_TIPO_CURSO VARCHAR(20)  
, @P_CURSO  VARCHAR(20)  
, @P_TURNO  VARCHAR(20)  
, @P_CURRICULO VARCHAR(20)  
)      
AS      
-- [IN�CIO]              
BEGIN      
  
SET NOCOUNT ON  
  
  SELECT   
			  C.CURSO																	AS [CURSO],  
			  C.NOME																	AS [NOME_CURSO], 
			  A.CURRICULO																AS [CURRICULO], 
			  A.TURNO																	AS [TURNO],
			  A.SERIE																	AS [SERIE_ALUNO], 
			  C.FACULDADE																AS [UNIDADE_ENSINO_ALUNO], 
              UE.NOME_COMP																AS [NOME_UNIDADE_ENSINO_ALUNO], 
			  A.ANO_INGRESSO															AS [ANO_INGRESSO],
			  A.SEM_INGRESSO															AS [SEM_INGRESSO],
			  A.TIPO_INGRESSO															AS [TIPO_INGRESSO], 
			  A.ALUNO																	AS [ALUNO], 
			  PES.NOME_COMPL															AS [NOME_ALUNO],
              PES.CPF																	AS [CPF],
			  PES.RG_NUM																AS [RG], 
			  A.ANOCONCL_2G																AS [ANO_CONCLUSAO_2G], 
			  PES.E_MAIL																AS [E_MAIL],
			  PES.ENDERECO																AS [ENDERECO],
              PES.END_NUM																AS [NUMERO],
              PES.END_COMPL																AS [COMPLEMENTO],
              PES.CEP																	AS [CEP],
              HM.NOME																	AS [CIDADE],
              HM.UF																		AS [ESTADO],	
              PES.FONE																	AS [FONE], 
			  PES.CELULAR																AS [CELULAR], 
			  B.TIPO_BOLSA																AS [TIPO_BOLSA], 
			  TB.DESCRICAO																AS [NOME_BOLSA], 
			  B.PERC_VALOR																AS [PERC_VALOR], 
			  B.VALOR																	AS [VALOR_BOLSA], 
			  B.ANOINI																	AS [ANOINI_BOLSA], 
			  B.MESINI																	AS [MESINI_BOLSA], 
			  B.ANOFIM																	AS [ANOFIM_BOLSA], 
			  B.MESFIM																	AS [MESFIM_BOLSA], 
			  B.DATA_BOLSA																AS [DATA_BOLSA], 
			  --B.DATA_CANCEL															AS [DATA_CANCELAMENTO_BOLSA],
              --A.SIT_ALUNO																AS [SIT_ALUNO],
              ISNULL(CA.CONTRATO_ACEITO,'SEM CONTRATO')									AS [CONTRATO_ACEITO]
FROM LY_ALUNO A							
JOIN LY_PESSOA PES
    ON PES.PESSOA = A.PESSOA
JOIN LY_CURSO C							-- PARA SABER NOME DO CURSO E JOIN COM UNIDADE ENSINO
	ON A.CURSO = C.CURSO
JOIN LY_UNIDADE_ENSINO UE				-- PARA SABER NOME UNIDADE ENSINO
	ON C.FACULDADE = UE.UNIDADE_ENS
JOIN LY_BOLSA B
	ON A.ALUNO = B.ALUNO
JOIN LY_TIPO_BOLSA TB
	ON B.TIPO_BOLSA = TB.TIPO_BOLSA
JOIN HD_MUNICIPIO HM
	ON HM.MUNICIPIO = PES.END_MUNICIPIO
LEFT JOIN LY_CONTRATO_ALUNO CA 
	ON CA.ALUNO = B.ALUNO AND CA.ANO = B.ANOINI AND CA.PERIODO = (CASE WHEN B.MESINI BETWEEN 1 AND 6 THEN 1 ELSE 2 END)
WHERE C.ATIVO  = 'S' AND A.SIT_ALUNO = 'Ativo' AND B.DATA_CANCEL IS NULL AND (B.ANOFIM >= YEAR(GETDATE()) OR B.ANOFIM IS NULL) AND (B.MESFIM >= MONTH(GETDATE()) OR B.MESFIM IS NULL)
AND (@P_FACULDADE IS NOT NULL AND C.FACULDADE = @P_FACULDADE) 
AND (@P_TIPO_CURSO IS NOT NULL AND C.TIPO = @P_TIPO_CURSO)  
AND ((@P_CURSO IS NOT NULL AND C.CURSO = @P_CURSO) OR @P_CURSO IS NULL)
AND ((@P_TURNO IS NOT NULL AND A.TURNO = @P_TURNO) OR @P_TURNO IS NULL)  
AND ((@P_CURRICULO IS NOT NULL AND A.CURRICULO = @P_CURRICULO) OR @P_CURRICULO IS NULL)   
 
  
ORDER BY C.FACULDADE, UE.NOME_COMP, C.CURSO, C.NOME
  
  
SET NOCOUNT OFF  
  
END              
GO