USE LYCEUM
GO
      
CREATE PROCEDURE [dbo].[Relat_P_AplicacaoDNOVO]       
    
 @p_avaliacaoq VARCHAR(25)     
        
AS        
BEGIN        
        
SELECT APLICACAO AS CODIGO    
  , APLICACAO+' - '+CONVERT(VARCHAR(10),DT_INICIO,103) AS DESCR     
FROM LY_APLIC_QUESTIONARIO    
WHERE TIPO_QUESTIONARIO = @p_avaliacaoq  
--AND ATIVO = 'S' 
AND  DT_INICIO > '2017-12-31'
ORDER BY 1        
        
END;     