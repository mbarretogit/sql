            
ALTER FUNCTION [dbo].[FN_FTC_RET_DADOS_ACOMPANHAMENTO_DOCENTES_RESUMO]                                                     
(                                                      
  @P_ANO   VARCHAR(20)-- T_ANO                                          
 ,@P_SEMESTRE  VARCHAR(20) --T_SEMESTRE2                                       
 ,@P_FACULDADE  VARCHAR(20) --T_CODIGO                                         
 ,@P_DOCENTE   VARCHAR(20) --T_CODIGO                                      
 ,@P_CURSO INT = 0                                         
)                                                    
RETURNS                 
   
  @TABELA TABLE (                                                      
 FACULDADE VARCHAR(50), NUM_FUNC VARCHAR(50), NOME_COMPL VARCHAR(250), CURSO VARCHAR(50), NOME_CURSO VARCHAR(250) , TURNO VARCHAR(5), DISCIPLINA VARCHAR(250),                                     
 DISCIPLINA_NOME VARCHAR(250), CH_SEMANAL FLOAT, QTD_ALUNOS FLOAT, QUANTIDADE FLOAT, CH_ESTAGIO FLOAT, EC_PADRAO_25 FLOAT, EC_ADICIONAL FLOAT , STATUS INT,                
 TURMA_INTEGRACAO VARCHAR(MAX), TURMA_INTEGRACAO2 VARCHAR(MAX)                
)  
                                                    
AS                                      
                                                       
 -- DECLARE                                                        
 -- @P_ANO    T_ANO           = '2021'                                                        
 --,@P_SEMESTRE  T_SEMESTRE2  = '1'                                                          
 --,@P_FACULDADE  T_CODIGO    = 'FCS'                                                         
 --,@P_DOCENTE   T_CODIGO     = '5491'                                               
 --,@P_CURSO INT              = 0                        
 
 
 

BEGIN                                                      
                                                
DECLARE @TAB AS TABLE ( FACULDADE VARCHAR(50), NUM_FUNC VARCHAR(50), NOME_COMPL VARCHAR(250), CURSO VARCHAR(50), NOME_CURSO VARCHAR(250) ,                                     
TURNO VARCHAR(5), DISCIPLINA VARCHAR(250), DISCIPLINA_NOME VARCHAR(250), CH_SEMANAL FLOAT, QTD_ALUNOS FLOAT, QUANTIDADE FLOAT, TURMA_INTEGRACAO VARCHAR(MAX), TURMA_INTEGRACAO2 VARCHAR(MAX)   )                                                    
                                        
IF @P_CURSO = 0 BEGIN                  
                
 INSERT INTO @TAB ( FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, QUANTIDADE, TURMA_INTEGRACAO, TURMA_INTEGRACAO2  )               
 SELECT                                             
 FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, SUM(QUANTIDADE), TURMA_INTEGRACAO, TURMA_INTEGRACAO2                                      
 FROM (           
 SELECT DISTINCT                                                    
  --ISNULL (T.FACULDADE,'') AS FACULDADE            
  ISNULL (D.FL_FIELD_09,'') AS FACULDADE           
    ,ISNULL (AD.NUM_FUNC,0) AS NUM_FUNC                                             
    ,ISNULL (D.NOME_COMPL,'') AS NOME_COMPL                                                               
    ,ISNULL (T.CURSO,'') AS CURSO                                                
    ,ISNULL (C.NOME,'') AS NOME_CURSO                                                  
    ,ISNULL (T.TURNO,'') AS TURNO                                                 
    ,ISNULL (T.DISCIPLINA,'') AS DISCIPLINA                                                
    ,ISNULL ( DI.NOME_COMPL,'') AS DISCIPLINA_NOME                                                
    ,ISNULL(DI.AULAS_SEMANAIS,0) AS CH_SEMANAL                                                 
    ,ISNULL((SELECT COUNT(*) FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE AND M.SIT_MATRICULA NOT IN ('Cancelado','Trancado')),0) AS QTD_ALUNOS           
  
    ,HA.DIA_SEMANA                       
    ,ISNULL(HA.QTDE_AULA,0) AS QUANTIDADE          
    ,ISNULL (T.TURMA,'')     AS TURMA                                                    
    ,CONVERT(VARCHAR(05),HA.HORAINI_AULA,108) AS HORARIO_AULA                   
    , HA.AULA                 
    ,UPPER(T.TURMA_INTEGRACAO) AS TURMA_INTEGRACAO
	,UPPER(T.TURMA_INTEGRACAO) AS TURMA_INTEGRACAO2
 FROM LYCEUM..LY_AULA_DOCENTE AD                                    
   INNER JOIN LYCEUM..LY_TURMA T ON AD.TURMA = T.TURMA AND AD.TURNO = T.TURNO AND AD.DISCIPLINA = T.DISCIPLINA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE                                                             
    INNER JOIN LYCEUM..LY_DISCIPLINA DI ON DI.DISCIPLINA = AD.DISCIPLINA                                                  
    INNER JOIN LYCEUM..LY_CURSO C ON T.CURSO = C.CURSO                                                           
    ----LEFT JOIN LYCEUM..LY_AULA_DOCENTE AD ON AD.TURMA = T.TURMA AND AD.TURNO = T.TURNO AND AD.DISCIPLINA = T.DISCIPLINA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE                                                        
    INNER JOIN LYCEUM..LY_HOR_AULA HA ON HA.AULA = AD.AULA AND HA.DIA_SEMANA = AD.DIA_SEMANA AND HA.TURNO = AD.TURNO AND HA.FACULDADE = AD.FACULDADE AND HA.DISCIPLINA = AD.DISCIPLINA AND HA.TURMA = AD.TURMA                 
    AND HA.ANO = AD.ANO AND HA.SEMESTRE = AD.SEMESTRE                                        
    INNER JOIN LYCEUM..LY_DOCENTE D  ON D.NUM_FUNC  = AD.NUM_FUNC                                       
    LEFT JOIN LYCEUM..LY_TURMA_DOCENTE TD ON TD.NUM_FUNC = AD.NUM_FUNC AND TD.DISCIPLINA = T.DISCIPLINA AND TD.TURMA = T.TURMA AND TD.ANO = T.ANO AND TD.PERIODO = T.SEMESTRE                                                          
  WHERE 1 = 1                                                        
  AND AD.ANO = CAST(ISNULL(@P_ANO, AD.ANO) AS VARCHAR(20))                                                       
  AND AD.SEMESTRE = CAST(ISNULL(@P_SEMESTRE,AD.SEMESTRE) AS VARCHAR(20))             
  ---- ALTERA플O 08/12/2020 - Barbara e Diniz           
   --AND AD.FACULDADE = CAST(ISNULL(@P_FACULDADE,AD.FACULDADE) AS VARCHAR(20))              
  AND AD.NUM_FUNC in ( select           
       NUM_FUNC          
       from LYCEUM..LY_DOCENTE           
       where FL_FIELD_09 is not null           
       and ATIVO = 'S'           
       AND DT_DEMISSAO IS NULL           
       AND FL_FIELD_09 <> ''          
       AND FL_FIELD_09 = CAST(ISNULL(@P_FACULDADE,AD.FACULDADE) AS VARCHAR(20))          
     )           
          
  AND AD.NUM_FUNC = CAST(ISNULL(@P_DOCENTE,AD.NUM_FUNC) AS VARCHAR(20))                                                    
  AND AD.FACULDADE not in ('DOM-FSA','DOM-VIC','DOM-JEQ','DOM-PET','DOM-SSA','THINK-SSA','OTE-CAM','OTE-CAR','POLO-CEN','POLO-FSA','POLO-ITA','POLO-JEQ','POLO-JUA','POLO-PAR','POLO-PET','POLO-SP','POLO-VIC','THINK-JEQ','THINK-VIC','THINK-FCS','THINK-FSA','THINK-ITA','THINK-JUA','THINK-PET')             
  AND T.TURMA_INTEGRACAO IS NULL          
  ) TB                                       
 WHERE CURSO NOT IN ( '722' )                                      
 GROUP BY FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS,TURMA_INTEGRACAO,TURMA_INTEGRACAO2               
           
 union all          
           
     
SELECT     
 DISTINCT     
 FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, QUANTIDADE, TURMA_INTEGRACAO , TURMA_INTEGRACAO2         
FROM (    
 SELECT                                             
 --FACULDADE,     
 ( select top 1 ISNULL (D.FL_FIELD_09,'') from lyceum..ly_docente d where d.NUM_FUNC = tb.NUM_FUNC ) as FACULDADE,    
 NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, SUM(QUANTIDADE) as QUANTIDADE, TURMA_INTEGRACAO  , TURMA, TURMA_INTEGRACAO AS TURMA_INTEGRACAO2                                 
 FROM (           
 SELECT DISTINCT                                                    
        
 ISNULL (T.FACULDADE,'') AS FACULDADE            
     --ISNULL (D.FL_FIELD_09,'') AS FACULDADE           
    ,ISNULL (AD.NUM_FUNC,0) AS NUM_FUNC                                               ,ISNULL (D.NOME_COMPL,'') AS NOME_COMPL                                                               
    --,ISNULL (T.CURSO,'') AS CURSO                  
 ,(           
  select top 1 curso from LYCEUM..LY_TURMA TT where AD.ANO = @P_ANO AND AD.SEMESTRE = @P_SEMESTRE and faculdade = @P_FACULDADE AND TURMA_INTEGRACAO IS NOT NULL AND AD.NUM_FUNC = TT.NUM_FUNC     
 ) AS CURSO          
          
    --,ISNULL (C.NOME,'') AS NOME_CURSO      
 ,(           
  select top 1 ISNULL (CC.NOME,'') from LYCEUM..LY_TURMA TT INNER JOIN LYCEUM..LY_CURSO CC ON CC.CURSO = TT.CURSO  where AD.ANO = @P_ANO AND AD.SEMESTRE = @P_SEMESTRE and TT.faculdade = @P_FACULDADE AND TURMA_INTEGRACAO IS NOT NULL AND AD.NUM_FUNC = TT.NUM_FUNC     
 ) AS NOME_CURSO     
    ,ISNULL (T.TURNO,'') AS TURNO                                                 
    ,ISNULL (T.DISCIPLINA,'') AS DISCIPLINA                                                
    ,ISNULL ( DI.NOME_COMPL,'') AS DISCIPLINA_NOME                                                
    ,ISNULL(DI.AULAS_SEMANAIS,0) AS CH_SEMANAL                                                 
    ,ISNULL((SELECT COUNT(*) FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE AND M.SIT_MATRICULA NOT IN ('Cancelado','Trancado')),0) AS QTD_ALUNOS           
  
    ,HA.DIA_SEMANA                                        
    ,ISNULL(HA.QTDE_AULA,0) AS QUANTIDADE                                            
    ,ISNULL (T.TURMA,'')     AS TURMA                                                    
    ,CONVERT(VARCHAR(05),HA.HORAINI_AULA,108) AS HORARIO_AULA                   
    , HA.AULA                 
    ,UPPER(T.TURMA_INTEGRACAO) AS TURMA_INTEGRACAO
	,UPPER(T.TURMA_INTEGRACAO) AS TURMA_INTEGRACAO2
 FROM LYCEUM..LY_AULA_DOCENTE AD                                    
    INNER JOIN LYCEUM..LY_TURMA T ON AD.TURMA = T.TURMA AND AD.TURNO = T.TURNO AND AD.DISCIPLINA = T.DISCIPLINA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE                                                             
    INNER JOIN LYCEUM..LY_DISCIPLINA DI ON DI.DISCIPLINA = AD.DISCIPLINA                                                  
    INNER JOIN LYCEUM..LY_CURSO C ON T.CURSO = C.CURSO                                                           
    ----LEFT JOIN LYCEUM..LY_AULA_DOCENTE AD ON AD.TURMA = T.TURMA AND AD.TURNO = T.TURNO AND AD.DISCIPLINA = T.DISCIPLINA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE                                                        
    INNER JOIN LYCEUM..LY_HOR_AULA HA ON HA.AULA = AD.AULA AND HA.DIA_SEMANA = AD.DIA_SEMANA AND HA.TURNO = AD.TURNO AND HA.FACULDADE = AD.FACULDADE AND HA.DISCIPLINA = AD.DISCIPLINA AND HA.TURMA = AD.TURMA                 
    AND HA.ANO = AD.ANO AND HA.SEMESTRE = AD.SEMESTRE                                        
    INNER JOIN LYCEUM..LY_DOCENTE D  ON D.NUM_FUNC  = AD.NUM_FUNC                                       
    LEFT JOIN LYCEUM..LY_TURMA_DOCENTE TD ON TD.NUM_FUNC = AD.NUM_FUNC AND TD.DISCIPLINA = T.DISCIPLINA AND TD.TURMA = T.TURMA AND TD.ANO = T.ANO AND TD.PERIODO = T.SEMESTRE                                                          
  WHERE 1 = 1                                                        
  AND AD.ANO = CAST(ISNULL(@P_ANO, AD.ANO) AS VARCHAR(20))                                                       
  AND AD.SEMESTRE = CAST(ISNULL(@P_SEMESTRE,AD.SEMESTRE) AS VARCHAR(20))             
  ---- ALTERA플O 08/12/2020 - Barbara e Diniz           
   --AND AD.FACULDADE = CAST(ISNULL(@P_FACULDADE,AD.FACULDADE) AS VARCHAR(20))              
  AND AD.NUM_FUNC in ( select           
       NUM_FUNC          
       from LYCEUM..LY_DOCENTE           
       where FL_FIELD_09 is not null           
       and ATIVO = 'S'           
       AND DT_DEMISSAO IS NULL           
       AND FL_FIELD_09 <> ''          
       AND FL_FIELD_09 = CAST(ISNULL(@P_FACULDADE,AD.FACULDADE) AS VARCHAR(20))          
     )           
          
  AND AD.NUM_FUNC = CAST(ISNULL(@P_DOCENTE,AD.NUM_FUNC) AS VARCHAR(20))                                                    
  AND AD.FACULDADE not in ('DOM-FSA','DOM-VIC','DOM-JEQ','DOM-PET','DOM-SSA','THINK-SSA','OTE-CAM','OTE-CAR','POLO-CEN','POLO-FSA','POLO-ITA','POLO-JEQ','POLO-JUA','POLO-PAR','POLO-PET','POLO-SP','POLO-VIC','THINK-JEQ','THINK-VIC','THINK-FCS','THINK-FSA',
'THINK-ITA','THINK-JUA','THINK-PET')             
  AND T.TURMA_INTEGRACAO IS NOT NULL          
  ) TB                                       
 WHERE CURSO NOT IN ( '722' )           
 and CURSO IS NOT NULL          
 GROUP BY FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QUANTIDADE, QTD_ALUNOS,TURMA_INTEGRACAO  , TURMA, TURMA_INTEGRACAO2                                   
) tf    
GROUP BY FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QUANTIDADE, QTD_ALUNOS,TURMA_INTEGRACAO   , TURMA, TURMA_INTEGRACAO2         
                               
    
 -----------------------------------------------------                
                  
-- INSERT INTO @TAB ( FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, QUANTIDADE, TURMA_INTEGRACAO )                                  
-- SELECT                                           
--  FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, SUM(QUANTIDADE),TURMA_INTEGRACAO                                 
-- FROM (                 
--  SELECT DISTINCT                                                  
--  ISNULL (T.FACULDADE,'') AS FACULDADE              
--  --ISNULL (D.FL_FIELD_09,'') AS FACULDADE           
--    ,ISNULL (T.NUM_FUNC,0) AS NUM_FUNC                                                            
--    ,ISNULL (D.NOME_COMPL,'') AS NOME_COMPL                                                          
--    ,ISNULL (T.CURSO,'') AS CURSO                                                
--    ,ISNULL (C.NOME,'') AS NOME_CURSO                                         
--    ,ISNULL (T.TURNO,'') AS TURNO                                                 
--    ,ISNULL (T.DISCIPLINA,'') AS DISCIPLINA                                                
--    ,ISNULL ( DI.NOME_COMPL,'') AS DISCIPLINA_NOME                                                
--    ,ISNULL(DI.AULAS_SEMANAIS,0) AS CH_SEMANAL                                                 
--    ,ISNULL((SELECT COUNT(*) FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE AND M.SIT_MATRICULA NOT IN ('Cancelado','Trancado')),0) AS QTD_ALUNOS         
  
    
     
        
             
--    , HA.DIA_SEMANA                                        
--    ,ISNULL(HA.QTDE_AULA,0) AS QUANTIDADE                                            
--    ,ISNULL (T.TURMA,'')     AS TURMA                                                 
--   ,CONVERT(VARCHAR(05),HA.HORAINI_AULA,108) AS HORARIO_AULA                     
--   , HA.AULA                  
--   ,UPPER(T.TURMA_INTEGRACAO) AS TURMA_INTEGRACAO                
--  FROM LYCEUM..LY_TURMA T                                            
--    INNER JOIN LYCEUM..LY_DOCENTE D  ON D.NUM_FUNC  = T.NUM_FUNC                                            
--    INNER JOIN LYCEUM..LY_TURMA_DOCENTE TD ON TD.NUM_FUNC = D.NUM_FUNC AND TD.DISCIPLINA = T.DISCIPLINA AND TD.TURMA = T.TURMA AND TD.ANO = T.ANO AND TD.PERIODO = T.SEMESTRE                                                      
--    INNER JOIN LYCEUM..LY_DISCIPLINA DI ON DI.DISCIPLINA = T.DISCIPLINA                                              
--    LEFT JOIN LYCEUM..LY_CURSO C ON T.CURSO = C.CURSO                                                       
--    LEFT JOIN LYCEUM..LY_AULA_DOCENTE AD ON AD.TURMA = T.TURMA AND AD.TURNO = T.TURNO AND AD.DISCIPLINA = T.DISCIPLINA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE                                                    
--    LEFT JOIN LYCEUM..LY_HOR_AULA HA ON HA.AULA = AD.AULA AND HA.DIA_SEMANA = AD.DIA_SEMANA AND HA.TURNO = AD.TURNO AND HA.FACULDADE = AD.FACULDADE AND HA.DISCIPLINA = T.DISCIPLINA AND HA.TURMA = T.TURMA AND HA.ANO = T.ANO AND HA.SEMESTRE = T.SEMESTRE  
  
    
      
        
         
--WHERE 1 = 1                                                      
--  AND T.ANO = ISNULL(@P_ANO, T.ANO)                                                          
--  AND T.SEMESTRE = ISNULL(@P_SEMESTRE,T.SEMESTRE)                                                  
--  AND T.FACULDADE = ISNULL(@P_FACULDADE,T.FACULDADE)            
--  ---- ALTERA플O 08/12/2020 - Barbara e Diniz            
--  --AND T.NUM_FUNC in ( select           
--  --     NUM_FUNC           
--  --     from LYCEUM..LY_DOCENTE           
--  --     where FL_FIELD_09 is not null           
--  --     and ATIVO = 'S'           
--  --     AND DT_DEMISSAO IS NULL           
--  --     AND FL_FIELD_09 <> ''          
--  --     AND FL_FIELD_09 = CAST(ISNULL(@P_FACULDADE,AD.FACULDADE) AS VARCHAR(20))          
--  --   )           
--  AND T.NUM_FUNC = ISNULL(@P_DOCENTE,T.NUM_FUNC)                                             
--  AND T.FACULDADE not in ('DOM-FSA','DOM-VIC','DOM-JEQ','DOM-PET','DOM-SSA','THINK-SSA','OTE-CAM','OTE-CAR','POLO-CEN','POLO-FSA','POLO-ITA','POLO-JEQ','POLO-JUA','POLO-PAR','POLO-PET','POLO-SP','POLO-VIC','THINK-JEQ','THINK-VIC','THINK-FCS','THINK-FSA','        
--  THINK-ITA','THINK-JUA','THINK-PET')                                                        
-- ) TB                                          
-- where CURSO not in( '722' )                                     
-- and not exists ( select top 1 1 from @TAB t where t.FACULDADE = t.FACULDADE and t.NUM_FUNC = tb.NUM_FUNC and t.CURSO = tb.CURSO )           
-- GROUP BY FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, TURMA_INTEGRACAO                                    
                
-------------------------------------------------------------------------------------------                
-- Concatena grupos integradoras                
-------------------------------------------------------------------------------------------                
             
 --SELECT * FROM @TAB            
            
UPDATE t                 
set TURMA_INTEGRACAO =                
(                      
 SELECT TOP 1                 
 COALESCE(                
 (                
  SELECT CAST(convert(VARCHAR(MAX),TURMA_INTEGRACAO,103 ) AS VARCHAR(MAX)) + ';' AS [text()]                       
  FROM @TAB AS O                 
  WHERE O.NUM_FUNC = C.NUM_FUNC AND O.CURSO = C.CURSO                
  GROUP BY TURMA_INTEGRACAO FOR XML PATH(''), TYPE                
  ).value('.[1]', 'VARCHAR(MAX)'), '')                             
 FROM @TAB AS C                 
 WHERE C.NUM_FUNC = t.NUM_FUNC AND t.CURSO = C.CURSO    
 AND ISNULL(T.TURMA_INTEGRACAO,'') <> ''  
)                           
FROM @TAB t                 
                
------------------------------------------------------------------------------------------------------------------------------                
                
INSERT INTO @TABELA (FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA,DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, QUANTIDADE, CH_ESTAGIO, EC_PADRAO_25, EC_ADICIONAL, STATUS)                                                     
SELECT                                 
 EE.UNIDADE, DOCENTE, D.NOME_COMPL, EE.CURSO, C.NOME NOME_CURSO, '' TURNO, '' DISCIPLINA, '' DISCIPLINA_NOME, 0 CH_SEMANAL, 0 QTD_ALUNOS, 0 QUANTIDADE, 0 CH_ESTAGIO, EE.EC_PADRAO_25 , EE.EC_ADICIONAL                                       
    ,ISNULL( (SELECT TOP 1 STATUS FROM LYCEUMINTEGRACAO..FTC_ENQUADRAMENTO_DOCENTE_CH_APROVADO ET WHERE ET.DOCENTE = EE.DOCENTE AND ET.ANO = @P_ANO AND ET.SEMESTRE = @P_SEMESTRE) ,1) AS STATUS                                  
FROM FTC_ENQUADRAMENTO_DOCENTE_NOVO_DISTRIBUCAO_EXTRA EE                                 
INNER JOIN LYCEUM..LY_CURSO C ON C.CURSO = EE.CURSO                                
INNER JOIN LYCEUM..LY_DOCENTE D ON D.NUM_FUNC = EE.DOCENTE                                
WHERE 1 = 1               
  AND EE.ANO = CAST(ISNULL(@P_ANO, EE.ANO) AS VARCHAR(20))                                                     
AND EE.SEMESTRE = CAST(ISNULL(@P_SEMESTRE,EE.SEMESTRE) AS VARCHAR(20))                                                     
  AND EE.UNIDADE = CAST(ISNULL(@P_FACULDADE,EE.UNIDADE) AS VARCHAR(20))                                       
  AND EE.DOCENTE = CAST(ISNULL(@P_DOCENTE,EE.DOCENTE) AS VARCHAR(20))                                 
  AND EE.CURSO <> '722'                              
             
END                                        
                                      
IF @P_CURSO = 1 BEGIN                                     
                                    
 INSERT INTO @TAB ( FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, QUANTIDADE, TURMA_INTEGRACAO , TURMA_INTEGRACAO2 )                                                    
          
 SELECT                                             
 FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, SUM(QUANTIDADE), TURMA_INTEGRACAO, TURMA_INTEGRACAO2                                  
 FROM (           
 SELECT DISTINCT                                                    
  --ISNULL (T.FACULDADE,'') AS FACULDADE            
  ISNULL (D.FL_FIELD_09,'') AS FACULDADE           
    ,ISNULL (AD.NUM_FUNC,0) AS NUM_FUNC                                             
    ,ISNULL (D.NOME_COMPL,'') AS NOME_COMPL                                                             
    ,ISNULL (T.CURSO,'') AS CURSO                                                
    ,ISNULL (C.NOME,'') AS NOME_CURSO                                                  
    ,ISNULL (T.TURNO,'') AS TURNO                                                 
    ,ISNULL (T.DISCIPLINA,'') AS DISCIPLINA                                                
    ,ISNULL ( DI.NOME_COMPL,'') AS DISCIPLINA_NOME          
    ,ISNULL(DI.AULAS_SEMANAIS,0) AS CH_SEMANAL                                                 
    ,ISNULL((SELECT COUNT(*) FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE AND M.SIT_MATRICULA NOT IN ('Cancelado','Trancado')),0) AS QTD_ALUNOS           
    ,HA.DIA_SEMANA                                        
    ,ISNULL(HA.QTDE_AULA,0) AS QUANTIDADE                                            
 ,ISNULL (T.TURMA,'')     AS TURMA                                                    
    ,CONVERT(VARCHAR(05),HA.HORAINI_AULA,108) AS HORARIO_AULA                   
    , HA.AULA                 
    ,UPPER(T.TURMA_INTEGRACAO) AS TURMA_INTEGRACAO
	,UPPER(T.TURMA_INTEGRACAO) AS TURMA_INTEGRACAO2
 FROM LYCEUM..LY_AULA_DOCENTE AD                                    
    INNER JOIN LYCEUM..LY_TURMA T ON AD.TURMA = T.TURMA AND AD.TURNO = T.TURNO AND AD.DISCIPLINA = T.DISCIPLINA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE                                                             
    INNER JOIN LYCEUM..LY_DISCIPLINA DI ON DI.DISCIPLINA = AD.DISCIPLINA                                                  
    INNER JOIN LYCEUM..LY_CURSO C ON T.CURSO = C.CURSO                                                           
    ----LEFT JOIN LYCEUM..LY_AULA_DOCENTE AD ON AD.TURMA = T.TURMA AND AD.TURNO = T.TURNO AND AD.DISCIPLINA = T.DISCIPLINA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE                                                        
    INNER JOIN LYCEUM..LY_HOR_AULA HA ON HA.AULA = AD.AULA AND HA.DIA_SEMANA = AD.DIA_SEMANA AND HA.TURNO = AD.TURNO AND HA.FACULDADE = AD.FACULDADE AND HA.DISCIPLINA = AD.DISCIPLINA AND HA.TURMA = AD.TURMA                 
    AND HA.ANO = AD.ANO AND HA.SEMESTRE = AD.SEMESTRE                                        
    INNER JOIN LYCEUM..LY_DOCENTE D  ON D.NUM_FUNC  = AD.NUM_FUNC                                       
    LEFT JOIN LYCEUM..LY_TURMA_DOCENTE TD ON TD.NUM_FUNC = AD.NUM_FUNC AND TD.DISCIPLINA = T.DISCIPLINA AND TD.TURMA = T.TURMA AND TD.ANO = T.ANO AND TD.PERIODO = T.SEMESTRE                                                          
  WHERE 1 = 1                                                        
  AND AD.ANO = CAST(ISNULL(@P_ANO, AD.ANO) AS VARCHAR(20))                                                       
  AND AD.SEMESTRE = CAST(ISNULL(@P_SEMESTRE,AD.SEMESTRE) AS VARCHAR(20))             
  ---- ALTERA플O 08/12/2020 - Barbara e Diniz           
   --AND AD.FACULDADE = CAST(ISNULL(@P_FACULDADE,AD.FACULDADE) AS VARCHAR(20))              
  AND AD.NUM_FUNC in ( select           
       NUM_FUNC          
       from LYCEUM..LY_DOCENTE           
       where FL_FIELD_09 is not null           
       and ATIVO = 'S'           
       AND DT_DEMISSAO IS NULL           
       AND FL_FIELD_09 <> ''          
       AND FL_FIELD_09 = CAST(ISNULL(@P_FACULDADE,AD.FACULDADE) AS VARCHAR(20))          
     )           
          
  AND AD.NUM_FUNC = CAST(ISNULL(@P_DOCENTE,AD.NUM_FUNC) AS VARCHAR(20))                                                    
  AND AD.FACULDADE not in ('DOM-FSA','DOM-VIC','DOM-JEQ','DOM-PET','DOM-SSA','THINK-SSA','OTE-CAM','OTE-CAR','POLO-CEN','POLO-FSA','POLO-ITA','POLO-JEQ','POLO-JUA','POLO-PAR','POLO-PET','POLO-SP','POLO-VIC','THINK-JEQ','THINK-VIC','THINK-FCS','THINK-FSA','THINK-ITA','THINK-JUA','THINK-PET')             
  AND T.TURMA_INTEGRACAO IS NULL          
  ) TB                                       
 WHERE CURSO IN ( '722' )                                      
 GROUP BY FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS,TURMA_INTEGRACAO,TURMA_INTEGRACAO2                
           
 union all          
          
        
--SELECT      
-- FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QUANTIDADE, QTD_ALUNOS,TURMA_INTEGRACAO           
--FROM (    
 SELECT                                             
 --FACULDADE,     
 ( select top 1 ISNULL (D.FL_FIELD_09,'') from lyceum..ly_docente d where d.NUM_FUNC = tb.NUM_FUNC ) as FACULDADE,    
 NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, SUM(QUANTIDADE) as QUANTIDADE, TURMA_INTEGRACAO ,TURMA_INTEGRACAO2                                  
 FROM (           
 SELECT DISTINCT                                                    
        
 ISNULL (T.FACULDADE,'') AS FACULDADE            
     --ISNULL (D.FL_FIELD_09,'') AS FACULDADE           
    ,ISNULL (AD.NUM_FUNC,0) AS NUM_FUNC                                             
    ,ISNULL (D.NOME_COMPL,'') AS NOME_COMPL                                                               
    --,ISNULL (T.CURSO,'') AS CURSO                  
 ,(           
  select top 1 curso from LYCEUM..LY_TURMA TT where AD.ANO = @P_ANO AND AD.SEMESTRE = @P_SEMESTRE and faculdade = @P_FACULDADE AND TURMA_INTEGRACAO IS NOT NULL AND AD.NUM_FUNC = TT.NUM_FUNC     
 ) AS CURSO          
          
    ,ISNULL (C.NOME,'') AS NOME_CURSO                                                  
    ,ISNULL (T.TURNO,'') AS TURNO                                                 
    ,ISNULL (T.DISCIPLINA,'') AS DISCIPLINA                                                
    ,ISNULL ( DI.NOME_COMPL,'') AS DISCIPLINA_NOME                                                
    ,ISNULL(DI.AULAS_SEMANAIS,0) AS CH_SEMANAL                                                 
    ,ISNULL((SELECT COUNT(*) FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE AND M.SIT_MATRICULA NOT IN ('Cancelado','Trancado')),0) AS QTD_ALUNOS           
  
    ,HA.DIA_SEMANA                                        
    ,ISNULL(HA.QTDE_AULA,0) AS QUANTIDADE                                            
    ,ISNULL (T.TURMA,'')     AS TURMA                                                    
    ,CONVERT(VARCHAR(05),HA.HORAINI_AULA,108) AS HORARIO_AULA                   
    , HA.AULA                 
    ,UPPER(T.TURMA_INTEGRACAO) AS TURMA_INTEGRACAO
	,UPPER(T.TURMA_INTEGRACAO) AS TURMA_INTEGRACAO2
 FROM LYCEUM..LY_AULA_DOCENTE AD                                    
    INNER JOIN LYCEUM..LY_TURMA T ON AD.TURMA = T.TURMA AND AD.TURNO = T.TURNO AND AD.DISCIPLINA = T.DISCIPLINA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE                                                             
    INNER JOIN LYCEUM..LY_DISCIPLINA DI ON DI.DISCIPLINA = AD.DISCIPLINA                                                  
    INNER JOIN LYCEUM..LY_CURSO C ON T.CURSO = C.CURSO                                                           
    ----LEFT JOIN LYCEUM..LY_AULA_DOCENTE AD ON AD.TURMA = T.TURMA AND AD.TURNO = T.TURNO AND AD.DISCIPLINA = T.DISCIPLINA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE                                                        
    INNER JOIN LYCEUM..LY_HOR_AULA HA ON HA.AULA = AD.AULA AND HA.DIA_SEMANA = AD.DIA_SEMANA AND HA.TURNO = AD.TURNO AND HA.FACULDADE = AD.FACULDADE AND HA.DISCIPLINA = AD.DISCIPLINA AND HA.TURMA = AD.TURMA                 
    AND HA.ANO = AD.ANO AND HA.SEMESTRE = AD.SEMESTRE                                        
    INNER JOIN LYCEUM..LY_DOCENTE D  ON D.NUM_FUNC  = AD.NUM_FUNC                                       
    LEFT JOIN LYCEUM..LY_TURMA_DOCENTE TD ON TD.NUM_FUNC = AD.NUM_FUNC AND TD.DISCIPLINA = T.DISCIPLINA AND TD.TURMA = T.TURMA AND TD.ANO = T.ANO AND TD.PERIODO = T.SEMESTRE                                                          
  WHERE 1 = 1                                                        
  AND AD.ANO = CAST(ISNULL(@P_ANO, AD.ANO) AS VARCHAR(20))                                                       
  AND AD.SEMESTRE = CAST(ISNULL(@P_SEMESTRE,AD.SEMESTRE) AS VARCHAR(20))             
  ---- ALTERA플O 08/12/2020 - Barbara e Diniz           
   --AND AD.FACULDADE = CAST(ISNULL(@P_FACULDADE,AD.FACULDADE) AS VARCHAR(20))              
  AND AD.NUM_FUNC in ( select           
       NUM_FUNC          
       from LYCEUM..LY_DOCENTE           
       where FL_FIELD_09 is not null           
       and ATIVO = 'S'           
       AND DT_DEMISSAO IS NULL           
       AND FL_FIELD_09 <> ''          
       AND FL_FIELD_09 = CAST(ISNULL(@P_FACULDADE,AD.FACULDADE) AS VARCHAR(20))          
     )           
          
  AND AD.NUM_FUNC = CAST(ISNULL(@P_DOCENTE,AD.NUM_FUNC) AS VARCHAR(20))                                                    
  AND AD.FACULDADE not in ('DOM-FSA','DOM-VIC','DOM-JEQ','DOM-PET','DOM-SSA','THINK-SSA','OTE-CAM','OTE-CAR','POLO-CEN','POLO-FSA','POLO-ITA','POLO-JEQ','POLO-JUA','POLO-PAR','POLO-PET','POLO-SP','POLO-VIC','THINK-JEQ','THINK-VIC','THINK-FCS','THINK-FSA','THINK-ITA','THINK-JUA','THINK-PET')             
  AND T.TURMA_INTEGRACAO IS NOT NULL          
  ) TB                                       
 WHERE CURSO not IN ( '722' )           
 and CURSO IS NOT NULL          
 GROUP BY FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QUANTIDADE, QTD_ALUNOS,TURMA_INTEGRACAO,TURMA_INTEGRACAO2                                     
--) tf    
--GROUP BY FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QUANTIDADE, QTD_ALUNOS,TURMA_INTEGRACAO          
    
----------------------------------------                
                
 --INSERT INTO @TAB ( FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, QUANTIDADE, TURMA_INTEGRACAO )                                      
 --SELECT                                           
 -- FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, SUM(QUANTIDADE), TURMA_INTEGRACAO                                           
 --FROM (                                        
 -- SELECT DISTINCT                                                  
 --    ISNULL (T.FACULDADE,'') AS FACULDADE          
 -- --ISNULL (D.FL_FIELD_09,'') AS FACULDADE           
 --   ,ISNULL (T.NUM_FUNC,0) AS NUM_FUNC                                                       
 --   ,ISNULL (D.NOME_COMPL,'') AS NOME_COMPL                                                               
 --   ,ISNULL (T.CURSO,'') AS CURSO                                                
 --   ,ISNULL (C.NOME,'') AS NOME_CURSO                                               
 --   ,ISNULL (T.TURNO,'') AS TURNO                                                 
 --   ,ISNULL (T.DISCIPLINA,'') AS DISCIPLINA                                                
 --   ,ISNULL ( DI.NOME_COMPL,'') AS DISCIPLINA_NOME                                                
 --   ,ISNULL(DI.AULAS_SEMANAIS,0) AS CH_SEMANAL                                                 
 --   ,ISNULL((SELECT COUNT(*) FROM LYCEUM..VW_MATRICULA_E_PRE_MATRICULA M WHERE M.DISCIPLINA = T.DISCIPLINA AND M.TURMA = T.TURMA AND M.ANO = T.ANO AND M.SEMESTRE = T.SEMESTRE AND M.SIT_MATRICULA NOT IN ('Cancelado','Trancado')),0) AS QTD_ALUNOS         
  
   
      
        
             
 --   ,HA.DIA_SEMANA                                        
 --   ,ISNULL(HA.QTDE_AULA,0) AS QUANTIDADE                                            
 --   ,ISNULL (T.TURMA,'')     AS TURMA                                                    
 --   ,CONVERT(VARCHAR(05),HA.HORAINI_AULA,108) AS HORARIO_AULA                   
 --   ,HA.AULA                  
 --,UPPER(T.TURMA_INTEGRACAO) AS TURMA_INTEGRACAO                
 -- FROM LYCEUM..LY_TURMA T                                            
 --   INNER JOIN LYCEUM..LY_DOCENTE D  ON D.NUM_FUNC  = T.NUM_FUNC                                            
 --   INNER JOIN LYCEUM..LY_TURMA_DOCENTE TD ON TD.NUM_FUNC = D.NUM_FUNC AND TD.DISCIPLINA = T.DISCIPLINA AND TD.TURMA = T.TURMA AND TD.ANO = T.ANO AND TD.PERIODO = T.SEMESTRE                                                      
 --   INNER JOIN LYCEUM..LY_DISCIPLINA DI ON DI.DISCIPLINA = T.DISCIPLINA                                              
 --   LEFT JOIN LYCEUM..LY_CURSO C ON T.CURSO = C.CURSO                                                       
 --   LEFT JOIN LYCEUM..LY_AULA_DOCENTE AD ON AD.TURMA = T.TURMA AND AD.TURNO = T.TURNO AND AD.DISCIPLINA = T.DISCIPLINA AND AD.ANO = T.ANO AND AD.SEMESTRE = T.SEMESTRE                                                    
 --   LEFT JOIN LYCEUM..LY_HOR_AULA HA ON HA.AULA = AD.AULA AND HA.DIA_SEMANA = AD.DIA_SEMANA AND HA.TURNO = AD.TURNO AND HA.FACULDADE = AD.FACULDADE AND HA.DISCIPLINA = T.DISCIPLINA AND HA.TURMA = T.TURMA AND HA.ANO = T.ANO AND HA.SEMESTRE = T.SEMESTRE  
  
    
      
        
            
 --WHERE 1 = 1                                                      
 -- AND T.ANO = CAST(ISNULL(@P_ANO, T.ANO) AS VARCHAR(20))                                                         
 -- AND T.SEMESTRE = CAST(ISNULL(@P_SEMESTRE,T.SEMESTRE) AS VARCHAR(20))               
            
 -- ---- ALTERA플O 08/12/2020 - Barbara e Diniz           
 -- AND T.FACULDADE = CAST(ISNULL(@P_FACULDADE,T.FACULDADE) AS VARCHAR(20))                                                         
 --   --AND AD.NUM_FUNC in ( select           
 --   --   NUM_FUNC           
 --   --   from LYCEUM..LY_DOCENTE           
 --   --   where FL_FIELD_09 is not null           
 --   --   and ATIVO = 'S'           
 --   --   AND DT_DEMISSAO IS NULL           
 --   --   AND FL_FIELD_09 <> ''          
 --   --   AND FL_FIELD_09 = CAST(ISNULL(@P_FACULDADE,AD.FACULDADE) AS VARCHAR(20))          
 -- -- )           
 -- AND T.NUM_FUNC = CAST(ISNULL(@P_DOCENTE,T.NUM_FUNC) AS VARCHAR(20))                                                   
 -- AND T.FACULDADE not in ('DOM-FSA','DOM-VIC','DOM-JEQ','DOM-PET','DOM-SSA','THINK-SSA','OTE-CAM','OTE-CAR','POLO-CEN','POLO-FSA','POLO-ITA','POLO-JEQ','POLO-JUA','POLO-PAR','POLO-PET','POLO-SP','POLO-VIC','THINK-JEQ','THINK-VIC','THINK-FCS','THINK-FSA','          
 -- THINK-ITA','THINK-JUA','THINK-PET')                                                      
 --) TB                                          
 --where CURSO = '722'                                     
 --and not exists ( select top 1 1 from @TAB t where t.FACULDADE = t.FACULDADE and t.NUM_FUNC = tb.NUM_FUNC and t.CURSO = tb.CURSO )                                    
 --GROUP BY FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA, DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, TURMA_INTEGRACAO                                    
                      
-------------------------------------------------------------------------------------------                
-- Concatena grupos integradoras     
-------------------------------------------------------------------------------------------                
                
          
UPDATE t                 
set TURMA_INTEGRACAO =                
(                      
 SELECT TOP 1                 
 COALESCE(                
 (                
  SELECT CAST(convert(VARCHAR(MAX),TURMA_INTEGRACAO,103 ) AS VARCHAR(MAX)) + ';' AS [text()]                       
  FROM @TAB AS O                 
  WHERE O.NUM_FUNC = C.NUM_FUNC AND O.CURSO = C.CURSO                
  GROUP BY TURMA_INTEGRACAO FOR XML PATH(''), TYPE                
  ).value('.[1]', 'VARCHAR(MAX)'), '')                             
 FROM @TAB AS C                 
 WHERE C.NUM_FUNC = t.NUM_FUNC AND t.CURSO = C.CURSO   
 AND ISNULL(T.TURMA_INTEGRACAO,'') <> ''  
)                           
FROM @TAB t                  
                
--------------------------------------------------------                
                
INSERT INTO @TABELA (FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA,DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, QUANTIDADE, CH_ESTAGIO, EC_PADRAO_25, EC_ADICIONAL, STATUS)                                                     
SELECT                                 
 EE.UNIDADE, DOCENTE, D.NOME_COMPL, EE.CURSO, C.NOME NOME_CURSO, '' TURNO, '' DISCIPLINA, '' DISCIPLINA_NOME, 0 CH_SEMANAL, 0 QTD_ALUNOS, 0 QUANTIDADE, 0 CH_ESTAGIO, EE.EC_PADRAO_25 , EE.EC_ADICIONAL                                       
    ,ISNULL( (SELECT TOP 1 STATUS FROM LYCEUMINTEGRACAO..FTC_ENQUADRAMENTO_DOCENTE_CH_APROVADO ET WHERE ET.DOCENTE = EE.DOCENTE AND ET.ANO = @P_ANO AND ET.SEMESTRE = @P_SEMESTRE) ,1) AS STATUS                                  
FROM FTC_ENQUADRAMENTO_DOCENTE_NOVO_DISTRIBUCAO_EXTRA EE                                 
INNER JOIN LYCEUM..LY_CURSO C ON C.CURSO = EE.CURSO                                
INNER JOIN LYCEUM..LY_DOCENTE D ON D.NUM_FUNC = EE.DOCENTE                                
WHERE 1 = 1                                
  AND EE.ANO = CAST(ISNULL(@P_ANO, EE.ANO) AS VARCHAR(20))                                                     
  AND EE.SEMESTRE = CAST(ISNULL(@P_SEMESTRE,EE.SEMESTRE) AS VARCHAR(20))                                                     
  AND EE.UNIDADE = CAST(ISNULL(@P_FACULDADE,EE.UNIDADE) AS VARCHAR(20))        
  AND EE.DOCENTE = CAST(ISNULL(@P_DOCENTE,EE.DOCENTE) AS VARCHAR(20))                                 
  AND EE.CURSO = '722'                              
                              
END                                        
                
----------------------------------------------------------------                                                      
                
declare @TABELAAUX TABLE (                                                      
 FACULDADE VARCHAR(50), NUM_FUNC VARCHAR(50), NOME_COMPL VARCHAR(250), CURSO VARCHAR(150), NOME_CURSO VARCHAR(250) , TURNO VARCHAR(5), DISCIPLINA VARCHAR(250),                                     
 DISCIPLINA_NOME VARCHAR(250), CH_SEMANAL FLOAT, QTD_ALUNOS FLOAT, QUANTIDADE FLOAT, CH_ESTAGIO FLOAT, EC_PADRAO_25 FLOAT, EC_ADICIONAL FLOAT , STATUS INT,                
 TURMA_INTEGRACAO VARCHAR(MAX),TURMA_INTEGRACAO2 VARCHAR(MAX)                 
)                       
                            
INSERT INTO @TABELAAUX (FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA,DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, QUANTIDADE, CH_ESTAGIO, EC_PADRAO_25, EC_ADICIONAL, STATUS, TURMA_INTEGRACAO,TURMA_INTEGRACAO2  )                 
SELECT                                             
  TB.FACULDADE, TB.NUM_FUNC, TB.NOME_COMPL, TB.CURSO, TB.NOME_CURSO, TB.TURNO, TB.DISCIPLINA, TB.DISCIPLINA_NOME,                                 
  TB.CH_SEMANAL,                                           
  TB.QTD_ALUNOS,                  
  CASE (SELECT COUNT(*) FROM lyceum..LY_HOR_AULA WHERE FREQUENCIA LIKE 'QUIN%' AND ANO = @P_ANO AND SEMESTRE =  @P_SEMESTRE and DISCIPLINA = TB.DISCIPLINA AND FACULDADE = TB.FACULDADE )                                  
         WHEN 0 THEN TB.QUANTIDADE             
         ELSE CASE WHEN TB.QUANTIDADE > 1 THEN CAST( ( TB.QUANTIDADE / 2 ) AS INT) ELSE TB.QUANTIDADE END                
      END AS QUANTIDADE,                  
  --TB.QUANTIDADE AS QUANTIDADE,                                            
  --SUM(TB.QTD_ALUNOS) AS QTD_ALUNOS,                                             
  --SUM(TB.QUANTIDADE) QUANTIDADE,                                             
  CH_ESTAGIO,                             
  EC_PADRAO_25,                     
  EC_ADICIONAL, STATUS                
  ,TURMA_INTEGRACAO 
  ,TURMA_INTEGRACAO2
FROM (                                            
 SELECT                                                      
  T.FACULDADE, T.NUM_FUNC, T.NOME_COMPL, T.CURSO, T.NOME_CURSO, T.TURNO, T.DISCIPLINA, T.DISCIPLINA_NOME,                                   
  T.CH_SEMANAL                                             
  ,T.QTD_ALUNOS                                            
  ,T.QUANTIDADE                                                        
  ,ISNULL((SELECT TOP 1 CH FROM FTC_ENQUADRAMENTO_DOCENTE_CH_ESTAGIO E WHERE E.DOCENTE = T.NUM_FUNC AND E.CURSO = T.CURSO AND E.DISCIPLINA = T.DISCIPLINA ),0) AS CH_ESTAGIO                                                    
  ,R.EC_PADRAO_25                                  
  ,R.EC_ADICIONAL                                                
  ,ISNULL( (SELECT TOP 1 STATUS FROM LYCEUMINTEGRACAO..FTC_ENQUADRAMENTO_DOCENTE_CH_APROVADO ET WHERE ET.DOCENTE = T.NUM_FUNC AND ET.ANO = @P_ANO AND ET.SEMESTRE = @P_SEMESTRE AND UNIDADE IS NOT NULL ) ,1) AS STATUS                 
  , T.TURMA_INTEGRACAO
  ,T.TURMA_INTEGRACAO2
 FROM @TAB T                                                 
 LEFT OUTER JOIN dbo.FN_FTC_RET_DADOS_ACOMPANHAMENTO_DOCENTES( @P_ANO,@P_SEMESTRE,@P_FACULDADE,@P_DOCENTE, @P_CURSO ) R  ON R.NUM_FUNC = T.NUM_FUNC AND R.CURSO = T.CURSO AND R.FACULDADE = T.FACULDADE                                                
) TB                                            
--GROUP BY TB.FACULDADE, TB.NUM_FUNC, TB.NOME_COMPL, TB.CURSO, TB.NOME_CURSO, TB.TURNO, TB.DISCIPLINA, TB.DISCIPLINA_NOME, TB.CH_SEMANAL,                                             
--  CH_ESTAGIO, EC_PADRAO_25, EC_ADICIONAL, STATUS                                      
                        
-------------------------------------------------------------------------------------------                
-- Concatena grupos integradoras AUX                
-------------------------------------------------------------------------------------------                
                
INSERT INTO @TABELA (FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, TURNO, DISCIPLINA,DISCIPLINA_NOME, CH_SEMANAL, QTD_ALUNOS, QUANTIDADE, CH_ESTAGIO, EC_PADRAO_25, EC_ADICIONAL, STATUS, TURMA_INTEGRACAO, TURMA_INTEGRACAO2 )                                             
 
    
      
        
SELECT TB.FACULDADE, TB.NUM_FUNC, TB.NOME_COMPL, TB.CURSO, TB.NOME_CURSO, TB.TURNO, TB.DISCIPLINA, TB.DISCIPLINA_NOME,                                 
  TB.CH_SEMANAL,                                           
  TB.QTD_ALUNOS,                               
  TB.QUANTIDADE,               
  TB.CH_ESTAGIO,                             
  ISNULL(                                
 (SELECT TOP 1 CH FROM LYCEUMINTEGRACAO..FTC_ENQUADRAMENTO_DOCENTE_CH_EXTRA WHERE DOCENTE = NUM_FUNC AND ANO = @P_ANO AND SEMESTRE = @P_SEMESTRE AND TIPO = 'EC25')                                
 ,         
 ISNULL(( SELECT TOP 1 MAX(HORA_OUTRAS_ATIVIDADES)                                         
 FROM FTC_TABELA_ENQUADRAMENTO_DOCENTE                                         
 WHERE                             
 ( SELECT SUM(QUANTIDADE) FROM @TABELAAUX TTT WHERE TTT.FACULDADE = TB.FACULDADE AND TTT.NUM_FUNC = TB.NUM_FUNC  )                            
 BETWEEN HORA_SALA_AULA AND(HORA_SALA_AULA + 1)                                         
 AND DATA_EXCLUSAO IS NULL                                        
 ),0)                                
 ) EC_PADRAO_25 ,                                 
  TB.EC_ADICIONAL,                             
  TB.STATUS                
  ,TURMA_INTEGRACAO
  ,TURMA_INTEGRACAO2
FROM @TABELAAUX TB                            
                                  
------------------------------------------------------------------                                                     
                
UPDATE @TABELA SET TURMA_INTEGRACAO = '' WHERE TURMA_INTEGRACAO = ';'                
                 
--UPDATE T                 
--SET TURMA_INTEGRACAO = ( CASE WHEN TURMA_INTEGRACAO <> '' THEN 'N' ELSE 'S' END )                
--FROM @TABELA T                
                
------------------------------------------------------------------                                                     
                             
RETURN                     
          
--SELECT * FROM @TABELA          
                                                  
END 