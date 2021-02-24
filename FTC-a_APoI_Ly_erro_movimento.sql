  
--## 6.2.1-HF14  
  
ALTER PROCEDURE dbo.a_APoI_Ly_erro_movimento  
  @erro VARCHAR(1024) OUTPUT,  
  @erro_mov NUMERIC(10), @banco NUMERIC(3), @ident_emp VARCHAR(15), @data_pagto DATETIME,   
  @valor_pago NUMERIC(10, 2), @motivo VARCHAR(50), @dt_insercao DATETIME, @aluno VARCHAR(20),   
  @boleto NUMERIC(10), @data_cred DATETIME, @data_baixa DATETIME, @tipo_pagamento VARCHAR(15),   
  @nosso_numero VARCHAR(15), @nome_arq VARCHAR(100), @resp VARCHAR(20), @titular VARCHAR(50),   
  @numero_rps NUMERIC(12), @numero_nfe NUMERIC(12), @situacao VARCHAR(50), @agencia VARCHAR(15),   
  @conta_banco VARCHAR(15), @carteira VARCHAR(15), @convenio VARCHAR(20), @usuario VARCHAR(20),   
  @lote NUMERIC(10), @e_lyceum varchar(1)  
AS  
BEGIN  
-- [INÍCIO] Customização - Não escreva código antes desta linha  
  
--## INICIO - Techne - 0000 - Tratamentos do Argyros  
--## INICIO - RAUL - 0001 - Tratar para não gravar registros com data de 1899-12-31 da movimento temporal - registros de erro. Tratar para marcar o E_LYCEUM como N nestes casos.  
  
 If @data_cred = '1899-12-30 00:00:00.000'  
  Begin  
   -- Altera valor do campo e_lyceum para N  
   Update Ly_erro_movimento   
   set e_lyceum = 'N'  
   where erro_mov = @erro_mov  
   and data_cred = '1899-12-30 00:00:00.000'  
     
   -- Sai da rotina para não inserir na movimento temporal  
   return  
  End  
  
--## Fim - RAUL - 0001 - Tratar para não gravar registros com data de 1899-12-31 da movimento temporal - registros de erro. Tratar para marcar o E_LYCEUM como N nestes casos.  
  
   -- ----------------------------------------------  
   -- Populando a tabela LY_MOVIMENTO_TEMPORAL  
   -- -----------------------------------------------  
   -- Pega a data de hoje sem a hora  
   DECLARE @HOJE DATETIME  
   SELECT @HOJE = GETDATE()  
   SELECT @HOJE = DATEADD(DD,0, DATEDIFF(DD,0, @HOJE))     
     
   DECLARE @v_MovimentoID T_NUMERO  
   
   if @valor_pago <> 0 
	BEGIN 
		EXEC Ly_Movimento_Temporal_Insert @v_MovimentoID OUTPUT,  -- id_movimento_temporal   
             @HOJE,     -- data  
             'Ly_Erro_Movimento',   -- entidade  
             @erro_mov,    -- id1  
             NULL,       -- id2  
             NULL,      -- id3  
             NULL,      -- id4  
             NULL,      -- id5  
             NULL,      -- dt_envio_contab  
             NULL,      -- lote_contabil  
             @HOJE,      -- dt_car_aprop  
             @data_cred    -- dt_contabil  
  END
--## Fim - Techne - 0000 - Tratamentos do Argyros  
  
-- [FIM] Customização - Não escreva código após esta linha  
RETURN  
END  