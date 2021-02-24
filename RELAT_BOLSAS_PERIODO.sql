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
AND B.ANOINI >= 2017
--AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
AND C.FACULDADE = '30'