alter table UNIFTC_ONE.DBO.AGENDAMENTO_EVENTO add PERIODO_LETIVO VARCHAR(10)

use LYCEUMINTEGRACAO
go
ALTER PROCEDURE FTC_LISTA_DOCENTES_AGENDAMENTO  
AS         
BEGIN       
 SELECT   
  NUM_FUNC  
  , NOME_COMPL  
  , ATIVO  
  , DT_DEMISSAO  
  , CPF  
 FROM LYCEUM.DBO.LY_DOCENTE   
 WHERE   
  ATIVO = 'S'   
  AND DT_DEMISSAO IS NULL   
  AND CPF <> '00000000000'   
  AND CPF <> '12345678901'      
 ORDER BY 2 ASC  
END