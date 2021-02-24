      
 ALTER FUNCTION [dbo].[FN_FTC_RET_DADOS_ACOMPANHAMENTO_DOCENTES_RESUMO_SOMA]                                                     
 (                                                 
   @P_ANO    T_ANO                                                    
   ,@P_SEMESTRE  T_SEMESTRE2                                                   
   ,@P_FACULDADE  T_CODIGO                                                   
   ,@P_DOCENTE   T_CODIGO                                                   
   ,@P_CURSO INT = 0                                                   
 )                                   
RETURNS          
    @TABELA TABLE ( FACULDADE VARCHAR(50), NUM_FUNC VARCHAR(50), NOME_COMPL VARCHAR(250), CURSO VARCHAR(50), NOME_CURSO VARCHAR(250), STATUS INT, CH_SALA FLOAT, CH_EXTRA FLOAT, CH_GESTAO FLOAT, TOTAL FLOAT, CH_STATUS FLOAT, TOTAL_CH_SALA FLOAT,           
 REGIME_TRABALHO varchar(2), TURMA_INTEGRACAO VARCHAR(MAX) )                                                       
AS                                                      
BEGIN                                               
                                  
 -- DECLARE                                                            
 -- @P_ANO    T_ANO           = '2021'                                                            
 --,@P_SEMESTRE  T_SEMESTRE2  = '1'                                                              
 --,@P_FACULDADE  T_CODIGO    = 'FCS'                                                             
 --,@P_DOCENTE   T_CODIGO     = '5491'                                                   
 --,@P_CURSO INT              = 0          
           
       
        
----------------------------------------------------------------------------------------------------------------------------------------------------------------------                                                              
DECLARE @TAB AS TABLE (FACULDADE VARCHAR(50), NUM_FUNC VARCHAR(50), NOME_COMPL VARCHAR(250), CURSO VARCHAR(50), NOME_CURSO VARCHAR(250), STATUS INT, CH_SALA FLOAT, CH_EXTRA FLOAT, TOTAL FLOAT, EC_PADRAO_25 FLOAT          
, REGIME_TRABALHO varchar(20), TURMA_INTEGRACAO VARCHAR(MAX))                        
----------------------------------------------------------------------------------------------------------------------------------------------------------------------                                                   
                                                   
  INSERT INTO @TAB ( FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, STATUS, CH_SALA, CH_EXTRA,TOTAL, EC_PADRAO_25, REGIME_TRABALHO, TURMA_INTEGRACAO )                                                    
  SELECT distinct                                    
      FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, STATUS,                                                   
   SUM(CH_SALA) CH_SALA,                                                   
   CH_EXTRA CH_EXTRA,                                                   
   SUM(TOTAL) TOTAL       
   , EC_PADRAO_25,                                     
   REGIME_TRABALHO          
   ,TURMA_INTEGRACAO          
  FROM                                     
  (                                                     
   select                                      
    FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, STATUS,                                                 
    (isnull(QUANTIDADE,0)) CH_SALA,  -- (isnull(QUANTIDADE,0) + isnull(CH_ESTAGIO,0)) CH_SALA, -- RETIRADO CH ESTAGIO SOLICITACAO DE BARBARA - IGOR CAMPOS 10/09/2019                                                
    ( isnull(EC_ADICIONAL,0)) CH_EXTRA,                                                  
    ( isnull(QUANTIDADE,0) + isnull(CH_ESTAGIO,0)) TOTAL,                                                 
    isnull(EC_PADRAO_25,0) as EC_PADRAO_25,                                    
    ISNULL( ( CASE REGIME_TRABALHO WHEN 'Horista' THEN 'H' WHEN 'Tempo Parcial' THEN 'TP' WHEN 'Tempo Integral' THEN 'TI' WHEN 'Coordenador' THEN 'CO' ELSE 'PD' END ), 'PD') as REGIME_TRABALHO          
 , R.TURMA_INTEGRACAO          
   from dbo.FN_FTC_RET_DADOS_ACOMPANHAMENTO_DOCENTES_RESUMO ( @P_ANO, @P_SEMESTRE,@P_FACULDADE,@P_DOCENTE, @P_CURSO) R              
   left join LYCEUMINTEGRACAO..FTC_TABELA_ENQUADRAMENTO_CONFIG_DOCENTE d on d.DOCENTE = R.NUM_FUNC AND r.faculdade = d.unidade                                     
  ) TB                                                     
  GROUP BY FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, STATUS, EC_PADRAO_25, CH_EXTRA, REGIME_TRABALHO ,TURMA_INTEGRACAO                                    
  ORDER BY FACULDADE, NOME_COMPL, NOME_CURSO;      
     
    
 DECLARE @AUX TABLE (  
  QUANTIDADE INT  
  ,NUM_FUNC VARCHAR(50)  
  ,TURMA_INTEGRACAO VARCHAR(MAX)  
  )  
  
 INSERT INTO @AUX  
 SELECT DISTINCT QUANTIDADE,NUM_FUNC, TURMA_INTEGRACAO2  
 FROM DBO.FN_FTC_RET_DADOS_ACOMPANHAMENTO_DOCENTES_RESUMO ( @P_ANO, @P_SEMESTRE,@P_FACULDADE,@P_DOCENTE, @P_CURSO) R  
 WHERE R.TURMA_INTEGRACAO2 IS NOT NULL  
  
 UPDATE T SET T.CH_SALA = (SELECT SUM(QUANTIDADE) FROM @AUX A WHERE A.NUM_FUNC = T.NUM_FUNC)  
 FROM @TAB T  
 WHERE T.TURMA_INTEGRACAO IS NOT NULL  
  
 UPDATE T SET T.TOTAL = T.CH_SALA  
 FROM @TAB T  
 WHERE T.TURMA_INTEGRACAO IS NOT NULL  
    
            
----------------------------------------------------------------------------------------------------------------------------------------------------------------------                                                   
            
 INSERT INTO @TABELA (FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, STATUS, CH_SALA, CH_EXTRA, CH_GESTAO, TOTAL, CH_STATUS, REGIME_TRABALHO, TURMA_INTEGRACAO )                                                      
 SELECT                                             
 FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, STATUS, CH_SALA,                                       
  CASE WHEN REGIME_TRABALHO = 'TP' THEN CASE WHEN CH_STATUS < 9 AND CH_EXTRA = 0 THEN 3 ELSE CH_EXTRA END ELSE 0 END AS CH_EXTRA,                                    
  CH_GESTAO,                                             
  CASE WHEN CH_STATUS < 9 AND CH_EXTRA = 0 AND REGIME_TRABALHO = 'TP' THEN 3 + TOTAL ELSE TOTAL END AS TOTAL,                                             
  CASE WHEN CH_STATUS < 9 AND CH_EXTRA = 0 AND REGIME_TRABALHO = 'TP' THEN 3 + CH_STATUS ELSE TOTAL END AS CH_STATUS,                                     
  REGIME_TRABALHO          
  ,TURMA_INTEGRACAO          
  FROM                                     
  (                                            
   SELECT                                                 
   FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, STATUS, CH_SALA, CH_EXTRA, CH_GESTAO, TOTAL,                                            
   (          
    SELECT SUM(CH_SALA)           
    FROM @TAB TA           
    WHERE TA.NUM_FUNC = A.NUM_FUNC AND TA.FACULDADE = A.FACULDADE           
  ) CH_STATUS          
 , REGIME_TRABALHO          
 , TURMA_INTEGRACAO                                                 
    FROM                                     
    (                                                
     SELECT                                     
     FACULDADE, NUM_FUNC, NOME_COMPL, CURSO, NOME_CURSO, STATUS,                                              
     CH_SALA,                                        
     -- HORA EXTRA, CASO REGIME DE TRABALHO = TP ENTÃO OS 25% DA TABELA EMQUADRAMENTO ELSE 0                                    
     CASE WHEN REGIME_TRABALHO = 'TP'                                     
     THEN                                    
     ISNULL(                                                    
     (SELECT TOP 1 CH FROM LYCEUMINTEGRACAO..FTC_ENQUADRAMENTO_DOCENTE_CH_EXTRA WHERE DOCENTE = NUM_FUNC AND ANO = @P_ANO AND SEMESTRE = @P_SEMESTRE AND TIPO = 'EC25' AND UNIDADE = FACULDADE)                                                    
     ,                                                    
     ISNULL(                                            
 ( SELECT TOP 1 MAX(HORA_OUTRAS_ATIVIDADES) FROM FTC_TABELA_ENQUADRAMENTO_DOCENTE WHERE                                            
     ( SELECT SUM(CH_SALA) FROM @TAB TTT WHERE TTT.FACULDADE = TT.FACULDADE AND TTT.NUM_FUNC = TT.NUM_FUNC  )                                        
     = HORA_SALA_AULA -- BETWEEN HORA_SALA_AULA AND(HORA_SALA_AULA + 1)                                                             
     AND DATA_EXCLUSAO IS NULL                                                            
     ),0)                                                    
     )                                     
     ELSE 0 END                                     
     AS CH_EXTRA,                                             
                                          
     ISNULL(                                                    
     (SELECT SUM(ISNULL(CH,0)) FROM LYCEUMINTEGRACAO..FTC_ENQUADRAMENTO_DOCENTE_DISTRIBUCAO_EXTRA WHERE DOCENTE = NUM_FUNC AND ANO = @P_ANO AND SEMESTRE = @P_SEMESTRE AND TIPO_EXTRA = 'ECAD' AND UNIDADE = FACULDADE )                                       
 
     
     
                
     , 0 ) + ISNULL(( select SUM(CH_EXTRA) from @TAB T WHERE T.FACULDADE =  TT.FACULDADE AND T.NUM_FUNC = TT.NUM_FUNC ),0)                     
                      
     AS CH_GESTAO,                             
                                                
     --(ISNULL(CH_EXTRA,0) + ISNULL((SELECT TOP 1 EC_PADRAO_25 FROM @TAB T WHERE T.FACULDADE = TT.FACULDADE AND T.NUM_FUNC = TT.NUM_FUNC ),0) ) CH_EXTRA,                                                   
     --                                                    
     (                                                  
     ISNULL((SELECT TOP 1 SUM(TOTAL) FROM @TAB T WHERE T.FACULDADE = TT.FACULDADE AND T.NUM_FUNC = TT.NUM_FUNC ),0)                                                   
     +                                           
     CASE WHEN REGIME_TRABALHO = 'TP'                                     
     THEN                                    
     ISNULL(                                                    
     (SELECT TOP 1 CH FROM LYCEUMINTEGRACAO..FTC_ENQUADRAMENTO_DOCENTE_CH_EXTRA WHERE DOCENTE = NUM_FUNC AND ANO = @P_ANO AND SEMESTRE = @P_SEMESTRE AND TIPO = 'EC25' AND UNIDADE = FACULDADE)                                              
     ,                                                    
     ISNULL(                                            
     ( SELECT TOP 1 MAX(HORA_OUTRAS_ATIVIDADES) FROM FTC_TABELA_ENQUADRAMENTO_DOCENTE WHERE                                            
     ( SELECT SUM(CH_SALA) FROM @TAB TTT WHERE TTT.FACULDADE = TT.FACULDADE AND TTT.NUM_FUNC = TT.NUM_FUNC  )                                                
     BETWEEN HORA_SALA_AULA AND(HORA_SALA_AULA + 1)                                                             
     AND DATA_EXCLUSAO IS NULL                                                            
     ),0)                                                 
     )                                     
     ELSE 0 END                                                
     +                                                  
     ISNULL(                                                    
     (SELECT SUM(ISNULL(CH,0)) FROM LYCEUMINTEGRACAO..FTC_ENQUADRAMENTO_DOCENTE_DISTRIBUCAO_EXTRA WHERE DOCENTE = NUM_FUNC AND ANO = @P_ANO AND SEMESTRE = @P_SEMESTRE AND TIPO_EXTRA = 'ECAD' AND UNIDADE = FACULDADE)                                        
  
    
      
       
             
     ,0 )                                        
     --ISNULL((SELECT TOP 1 CH_EXTRA FROM @TAB T WHERE T.FACULDADE = TT.FACULDADE AND T.NUM_FUNC = TT.NUM_FUNC ),0)                                                  
     )                                                  
     TOTAL,                                   
     REGIME_TRABALHO          
     ,TURMA_INTEGRACAO               
     FROM @TAB TT                                              
    ) A                                               ) B                                                
ORDER BY FACULDADE , NOME_COMPL , NOME_CURSO                                      
----------------------------------------------------------------------------------------------------------------------------------------------------------------------       
            
  update T set T.TOTAL_CH_SALA =  ( SELECT SUM(CH_SALA) FROM @TABELA TT WHERE TT.FACULDADE = T.FACULDADE AND TT.NUM_FUNC = T.NUM_FUNC )                                     
  FROM @TABELA T                               
                              
  update T set T.CH_GESTAO =  ISNULL( (SELECT SUM( DISTINCT CH_GESTAO) FROM (( SELECT DISTINCT CH_GESTAO FROM @TABELA TT WHERE TT.FACULDADE = T.FACULDADE AND TT.NUM_FUNC = T.NUM_FUNC )) A), 0)                          
  FROM @TABELA T                             
                                    
  update t set STATUS =                                    
   case when (SELECT TOP 1 count(HORA_REGIME_TRABALHO) qtd FROM FTC_TABELA_ENQUADRAMENTO_DOCENTE WHERE HORA_REGIME_TRABALHO = ISNULL(( select distinct TOTAL_CH_SALA + CH_EXTRA from @TABELA TT WHERE TT.FACULDADE = T.FACULDADE AND TT.NUM_FUNC = T.NUM_FUNC  
 
     
      
           
 )                  
 , 0) ) = 0 and status = 1 then 3 else status end                                       
  FROM @TABELA T                                     
                       
  update T set T.TOTAL =  T.TOTAL_CH_SALA + T.CH_GESTAO + CH_EXTRA                            
  FROM @TABELA T                 
                
   update T set T.TOTAL = case when ch_sala = 0 AND ch_gestao = 0 then 0 else T.TOTAL end              
   , T.ch_extra = case when ch_sala = 0 then 0 else T.ch_extra end              
     , T.ch_status = case when ch_sala = 0 AND ch_gestao = 0 then 0 else T.ch_status end              
   , T.status = case when ch_sala = 0 AND ch_gestao = 0 then 0 else T.status end              
   , T.REGIME_TRABALHO = CASE WHEN CH_SALA = 0 AND CH_EXTRA = 0 AND REGIME_TRABALHO = 'PD' THEN 'TP' ELSE REGIME_TRABALHO END            
            
  FROM @TABELA T               
        
----------------------------------------------------------------------------------------------------------------------------------------------------------------------                                     
           
 --UPDATE T           
 --SET TURMA_INTEGRACAO = ( CASE WHEN TURMA_INTEGRACAO = '' THEN 'N' ELSE 'S' END )          
 --FROM @TABELA T          
                                      
----------------------------------------------------------------------------------------------------------------------------------------------------------------------                                     
   -- SELECT * FROM @TABELA          
RETURN               
      
----------------------------------------------------------------------------------------------------------------------------------------------------------------------                                                   
                      
END 