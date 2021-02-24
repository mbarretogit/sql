  
CREATE FUNCTION [dbo].[fn_VW_Receita_Liquida]  
  
(  
  @p_cobranca NUMERIC(10),  
  @p_dt_ini DATETIME,  
  @p_dt_fim DATETIME  
)  
  
RETURNS NUMERIC(12,2)  
  
AS  
BEGIN  
  
DECLARE @p_resultado NUMERIC(12,2)  
SET @p_resultado = 0  
  
SELECT @p_resultado = ISNULL(SUM(rl.VALOR),0)  
FROM VW_Receita_Liquida rl  
WHERE rl.COBRANCA = @p_cobranca AND  
      rl.DT_RECEBIMENTO >= CASE WHEN @p_dt_ini IS NULL THEN rl.DT_RECEBIMENTO ELSE @p_dt_ini END AND  
      rl.DT_RECEBIMENTO <= CASE WHEN @p_dt_fim IS NULL THEN rl.DT_RECEBIMENTO ELSE @p_dt_fim END  
  
RETURN @p_resultado  
  
END  
  