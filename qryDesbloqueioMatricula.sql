DECLARE @p_ano INT = 2021
DECLARE @p_semestre INT = 1
DECLARE @p_aluno VARCHAR(20) = '122030101'

 SELECT DISTINCT              
  C.FACULDADE          
   , P.ALUNO              
   , P.ANO              
   , P.SEMESTRE              
   , CASE               
    WHEN A.ANO_INGRESSO = P.ANO AND A.SEM_INGRESSO = P.SEMESTRE THEN 'S'              
    ELSE 'N'              
  END AS CALOURO              
   , P.LANC_DEB    
   --VERIFICA PAGAMENTO REGRA DO FINANCEIRO   
   , ISNULL(LYCEUMINTEGRACAO.DBO.FN_FTC_ALUNO_PAGO( P.ALUNO, P.LANC_DEB ),0) AS PAGO -- 0 = N�O PAGO, 1 = PAGO  
   FROM lyceum..LY_PRE_MATRICULA P   
        INNER JOIN LYCEUM..LY_ALUNO A      ON (A.ALUNO = P.ALUNO)              
     INNER JOIN LYCEUM..LY_CURSO C      ON (C.CURSO = A.CURSO)  
     INNER JOIN LYCEUMINTEGRACAO..REMATRICULA RM ON RM.ALUNO = P.ALUNO AND RM.ANO = P.ANO AND RM.SEMESTRE = P.SEMESTRE      
   WHERE 1 = 1  
    AND (  
    p.DISCIPLINA LIKE 'MF_%'    
    OR p.DISCIPLINA LIKE 'AF_%'    
    OR p.DISCIPLINA LIKE 'MFM_%'  
   )  
   AND EXISTS (  
    SELECT TOP 1 1 FROM LYCEUM..LY_ALUNO_BLOQ_MATRWEB B   
    WHERE B.MOTIVO LIKE '%matricula acad�mica%'   
    AND B.ALUNO = P.ALUNO   
   )  
   AND P.ANO = 2021  
  and P.aluno = @p_aluno
   union all  
  
 SELECT DISTINCT              
  C.FACULDADE          
   , P.ALUNO              
   , P.ANO              
   , P.SEMESTRE              
   , CASE               
    WHEN A.ANO_INGRESSO = P.ANO AND A.SEM_INGRESSO = P.SEMESTRE THEN 'S'              
    ELSE 'N'              
  END AS CALOURO              
   , P.LANC_DEB    
   --VERIFICA PAGAMENTO REGRA DO FINANCEIRO   
   , ISNULL(LYCEUMINTEGRACAO.DBO.FN_FTC_ALUNO_PAGO( P.ALUNO, P.LANC_DEB ),0) AS PAGO -- 0 = N�O PAGO, 1 = PAGO  
   FROM lyceum..LY_PRE_MATRICULA P   
        INNER JOIN LYCEUM..LY_ALUNO A      ON (A.ALUNO = P.ALUNO)              
     INNER JOIN LYCEUM..LY_CURSO C      ON (C.CURSO = A.CURSO)  
     INNER JOIN LYCEUMINTEGRACAO..REMATRICULA RM ON RM.ALUNO = P.ALUNO AND RM.ANO = P.ANO AND RM.SEMESTRE = P.SEMESTRE      
   WHERE 1 = 1  
    AND (  
    p.DISCIPLINA LIKE 'MF_%'    
    OR p.DISCIPLINA LIKE 'AF_%'    
    OR p.DISCIPLINA LIKE 'MFM_%'  
   )  
   AND NOT EXISTS (  
    SELECT TOP 1 1 FROM LYCEUM..LY_ALUNO_BLOQ_MATRWEB B   
    WHERE B.MOTIVO LIKE '%matricula acad�mica%'   
    AND B.ALUNO = P.ALUNO   
   )  
   AND P.ANO = 2021  
   and P.aluno = @p_aluno
   ORDER BY C.FACULDADE, P.ALUNO  
   /*


SELECT * FROM LY_PLANO_PGTO_PERIODO WHERE ANO = @p_ano and PERIODO = @p_semestre AND ALUNO = @p_aluno
SELECT * FROM VW_COBRANCA WHERE ALUNO = @p_aluno AND ANO = @p_ano AND MES BETWEEN CASE WHEN @p_semestre = 1 THEN 1 ELSE 7 END AND CASE WHEN @p_semestre = 1 THEN 6 ELSE 12 END 

SELECT * FROM LY_ITEM_LANC WHERE COBRANCA = '30865898'

SELECT * FROM LY_BOLSA WHERE ALUNO = @p_aluno

SELECT * FROM LY_TIPO_BOLSA WHERE TIPO_BOLSA = 'CB UNIFICADA'*/