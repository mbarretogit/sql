USE LYCEUM
GO
  
ALTER PROCEDURE FTC_PR_Relat_FechamentoCaixa      
(        
  @p_data_caixa DATETIME  
, @p_usuario_caixa VARCHAR(20)      
)        
AS        
        
-- [INÍCIO]                  
BEGIN      
      
 SELECT mc.VALOR_ABERTURA,      
     mc.DATA_FECHAMENTO,      
     mc.USUARIO_LYC,      
     mc.DATA_ABERTURA,      
     mc.TIPO_PAGAMENTO,      
     mc.ALUNO,      
     mc.NOME_COMPL,      
     mc.RESP,      
     mc.TITULAR,      
     mc.COBRANCA,      
     mc.BOLETO,      
     mc.VALOR,      
     mc.TIPO_CRED,      
     mc.HORA_ABERTURA,      
     mc.HORA_FECHAMENTO      
 FROM VW_MOVIMENTO_CAIXA mc      
 WHERE (@p_data_caixa is not null and @p_data_caixa = mc.DATA_ABERTURA)
	--AND (@p_data_caixa is not null and @p_data_caixa <= mc.DATA_FECHAMENTO)
    AND mc.USUARIO_LYC = @p_usuario_caixa      
 ORDER BY mc.TIPO_PAGAMENTO      
      
END      
-- [FIM]      