  
CREATE PROCEDURE [dbo].[FTC_EXECUTA_ARGYROS]      
AS         
set nocount on    
DECLARE @DATA_LIMITE DATETIME      
    
    
--## Deleta da movimento temporal os itens de lançamento duplicados devido a bug no desfaturamento do NG    
/*DELETE MT    
FROM LY_MOVIMENTO_TEMPORAL MT    
JOIN (    
  SELECT  [ENTIDADE], [ID1], [ID2], ID_MOV_TEMP = MIN([ID_MOVIMENTO_TEMPORAL])    
  --, COUNT(*)    
  FROM [LY_MOVIMENTO_TEMPORAL]     
  GROUP BY [ENTIDADE], [ID1], [ID2]    
  HAVING COUNT(*) >1    
  ) T ON T.ENTIDADE  = MT.ENTIDADE    
    AND T.ID1   = MT.ID1    
    AND T.ID2   = MT.ID2    
    AND T.ID_MOV_TEMP <> MT.ID_MOVIMENTO_TEMPORAL    
WHERE MT.ENTIDADE = 'LY_ITEM_LANC'    
    
    
DELETE MT    
FROM LY_MOVIMENTO_TEMPORAL MT    
JOIN (    
  SELECT  [ENTIDADE], [ID1], [ID2], ID_MOV_TEMP = min([ID_MOVIMENTO_TEMPORAL])    
  --, COUNT(*)    
  FROM [LY_MOVIMENTO_TEMPORAL]     
  GROUP BY [ENTIDADE], [ID1], [ID2]    
  HAVING COUNT(*) >1    
  ) T ON T.ENTIDADE  = MT.ENTIDADE    
    AND T.ID1   = MT.ID1    
    AND T.ID2   = MT.ID2    
    AND T.ID_MOV_TEMP <> MT.ID_MOVIMENTO_TEMPORAL    
WHERE MT.ENTIDADE = 'ly_item_cred'    
    
--## Deleta da movimento temporal os itens da erro movimento que vieram com problemas da data 1899-12-30    
 DELETE FROM LY_MOVIMENTO_TEMPORAL     
 WHERE   ENTIDADE    =   'LY_ERRO_MOVIMENTO'    
 AND     DT_CONTABIL =   '1899-12-30 00:00:00.000'     
    
--## Deleta da movimento temporal os itens da erro movimento que não existem na ly_erro_movimento    
 DELETE T    
 FROM LY_MOVIMENTO_TEMPORAL T    
 WHERE ENTIDADE = 'ly_erro_movimento'    
 AND  NOT EXISTS(SELECT 1    
      FROM LY_ERRO_MOVIMENTO    
      WHERE ERRO_MOV = T.ID1) */  
    
--## Limpa as tabelas de erros e log    
 DELETE FROM ZZCRO_ERROS     
 WHERE SPID = @@SPID    
    
 DELETE A    
 FROM LY_PROC_ANDAMENTO_LOG A    
 WHERE exists (SELECT 1     
       FROM LY_PROC_ANDAMENTO     
       WHERE NOME_PROC = 'PROC_CORRIGE_LYCEUM'    
       and ID_PROC = A.ID_PROC)    
     
 DELETE FROM LY_PROC_ANDAMENTO     
 WHERE NOME_PROC = 'PROC_CORRIGE_LYCEUM'    
     
 DELETE A    
 FROM LY_PROC_ANDAMENTO_LOG A    
 WHERE exists (SELECT 1     
       FROM LY_PROC_ANDAMENTO     
       WHERE NOME_PROC = 'PROC_GERA_MOV_CONTAB'    
       and ID_PROC = A.ID_PROC)    
    
 DELETE FROM LY_PROC_ANDAMENTO     
 WHERE NOME_PROC = 'PROC_GERA_MOV_CONTAB'    
  
--########################################################################################################    
--##  Executa o Argyros    
 -- calculo para pegar o ultimo dia do mes atual    
 --alterado em 22/03/2017 por juliano armentano para buscar o processamento D-1(dia anterior)+  
 --SELECT @DATA_LIMITE = DATEADD(MM, 1, (convert(varchar,year(DBO.FN_GETDATADIASEMHORA(GETDATE())))+'-'+convert(varchar,MONTH(DBO.FN_GETDATADIASEMHORA(GETDATE())))+'-01')    )-1                               -- DEFINIR DATA LIMITE PARA O PROCESSAMENTO    
SELECT @DATA_LIMITE = dbo.fn_datadiasemhora(GETDATE()-1)   
   
-- Executa argyros    
EXEC PROC_GERA_MOV_CONTAB 'Temporal', 'N', 'N', @DATA_LIMITE     
  
--########################################################################################################    
  
  
  
--## INICIO - 30/03/2017 - RAUL - Rotina para após o processamento do argyros, copiar o log para as tabelas de backup na base lyceum integracao  
--## Guarda o Log do Argyros na base lyceumintegracao  
  
  
INSERT INTO LYCEUMINTEGRACAO..FTC_ARGYROS_LY_PROC_ANDAMENTO  
(DATA_PROCESSAMENTO  
--, ID_PROCESSAMENTO -- campo identity  
, ID_PROC  
, TIME_INI  
, TIME_ULT  
, PERCENTUAL  
, USER_PROC  
, ESTADO  
, CANCELADO  
, NOME_PROC  
, MSG)  
SELECT DBO.FN_GetDataDiaSemHora(GETDATE()) AS  DATA_PROCESSAMENTO, *  
FROM LY_PROC_ANDAMENTO PA  
WHERE NOME_PROC = 'PROC_GERA_MOV_CONTAB'  
  
  
INSERT INTO LYCEUMINTEGRACAO..FTC_ARGYROS_LY_PROC_ANDAMENTO_LOG   
(DATA_PROCESSAMENTO  
, ID_PROCESSAMENTO   
, ID_PROC  
, MSGID  
, CHAVE1  
, CHAVE2  
, CHAVE3  
, CHAVE4  
, CHAVE5  
, CHAVE6  
, CHAVE7  
, CHAVE8  
, CHAVE9  
, CHAVE10  
, MSG  
, CAMPO)  
SELECT DBO.FN_GetDataDiaSemHora(GETDATE()) AS  DATA_PROCESSAMENTO  
, pa1.ID_PROCESSAMENTO   
, pa.ID_PROC  
, pa.MSGID  
, pa.CHAVE1  
, pa.CHAVE2  
, pa.CHAVE3  
, pa.CHAVE4  
, pa.CHAVE5  
, pa.CHAVE6  
, pa.CHAVE7  
, pa.CHAVE8  
, pa.CHAVE9  
, pa.CHAVE10  
, pa.MSG  
, pa.CAMPO  
FROM LY_PROC_ANDAMENTO_LOG PA  
join (SELECT ID_PROC, max(id_processamento) as id_processamento FROM LYCEUMINTEGRACAO..FTC_ARGYROS_LY_PROC_ANDAMENTO group by ID_PROC) pa1  
 on pa1.ID_PROC = PA.ID_PROC  
WHERE 1 = 1  
and exists (SELECT top 1 1 FROM LY_PROC_ANDAMENTO   
   WHERE NOME_PROC = 'PROC_GERA_MOV_CONTAB'  
   and ID_PROC = pa.ID_PROC)  
AND NOT EXISTS (SELECT TOP 1 1 FROM LYCEUMINTEGRACAO..FTC_ARGYROS_LY_PROC_ANDAMENTO_LOG  
    WHERE ID_PROC = PA.ID_PROC  
    and id_processamento = pa1.id_processamento)  
ORDER BY ID_PROC, MSGID  
  
--## FIM - 30/03/2017 - RAUL - Rotina para após o processamento do argyros, copiar o log para as tabelas de backup na base lyceum integracao  
    
    
set nocount off    
RETURN    