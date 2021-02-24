USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.VALIDA_PAGAMENTO'))
   exec('CREATE PROCEDURE [dbo].[VALIDA_PAGAMENTO] AS BEGIN SET NOCOUNT OFF; END')
GO 

  
--## 6.2.1-HF14   
ALTER PROCEDURE VALIDA_PAGAMENTO    
  @p_SESSAO_ID as varchar(40),    
  @p_COBRANCA T_NUMERO,    
  @p_tipo_pagamento T_ALFASMALL,    
  @p_RETORNO VARCHAR(255) output    
AS    
  DECLARE @v_count INTEGER    
  
--## INICIO - RAUL - 14/12/2015 - 0001 - Tratamento para n�o pemitir baixar boletos registrados com baixa diferente de banco    
    
  If exists (  
              select top 1 1   
              from VW_COBRANCA_BOLETO cb  
              join LY_BOLETO b  
                on cb.BOLETO        = b.BOLETO  
              join LY_OPCOES_BOLETO ob  
                on ob.BANCO         = b.BANCO  
                and ob.CONTA_BANCO  = b.CONTA_BANCO  
                and ob.AGENCIA      = b.AGENCIA  
                and ob.CARTEIRA     = b.CARTEIRA  
              where 1 = 1  
              and ob.ARQUIVO_COBRANCA = 'Registrada'  
              and cb.COBRANCA         = @p_COBRANCA   -- filtra boleto da cobranca  
     and b.enviado     = 'S'     -- 09/06/2016 - inclui so valida se j� tiver sido enviada, pois se n�o, apos o pagamento, n�o vai na remessa.  
            )  
   and @p_tipo_pagamento in ('Dinheiro','Cheque','Cartao','Especial')  --09/06/2016 - alterei de <> BAnco  para in ('Dinheiro','Cheque','Cartao','Especial')  
    Begin  
      SET @p_RETORNO = 'CUSTOM - N�o � permitido realizar pagamento de cobran�as com boleto registrado vinculado, remova o boleto.'    
      RETURN    
    End    
    
--## FIM - RAUL - 14/12/2015 - 0001 - Tratamento para n�o pemitir baixar boletos registrados com baixa diferente de banco    

--## INICIO - MIGUEL - 09/10/2017 - 0002 - Tratamento para n�o pemitir baixar de cobran�as geradas para o RESPONSAVEL FINANCEIRO FIES
    
  --If exists (  
  --            select top 1 1   
  --            from VW_COBRANCA cb  
  --            where 1 = 1  
  --            and cb.RESP = 'FIES'
  --            and cb.COBRANCA = @p_COBRANCA 
  --          )  
  --  Begin  
  --    SET @p_RETORNO = 'CUSTOM - S� � permitido realizar pagamento de cobran�as do respons�vel financeiro FIES atrav�s do Processo ''Importa��o de Recebimentos FIES''.'
  --    RETURN    
  --  End    
    
--## FIM - MIGUEL - 09/10/2017 - 0002 - Tratamento para n�o pemitir baixar de cobran�as geradas para o RESPONSAVEL FINANCEIRO FIES
    
  SET @p_RETORNO = ''    
  RETURN    

