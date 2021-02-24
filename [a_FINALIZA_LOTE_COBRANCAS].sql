  
-- EP PROGRAMADO  
ALTER PROCEDURE [dbo].[a_FINALIZA_LOTE_COBRANCAS]       
  @p_Resp         T_CODIGO,      
  @p_Ano          T_ANO,      
  @p_Mes          T_MES,      
  @p_Cobranca     T_NUMERO,      
  @p_Data_venc    T_DATA      
AS      
-- [INÍCIO]      
  
--## INICIO - Raul - 07/04/2017 - 0001 - Tratar para remover encargos das cobrancas do responsável FIES - FIES  
-- Solicitado por Rose por e-mail.  
   
 If @p_resp = 'FIES' -- Responsavel financeiro FIES.  
  Begin  
   Delete from LY_ENCARGOS_COB_GERADO   
   where cobranca = @p_Cobranca  
  End  
  
--## FIM - Raul - 07/04/2017 - 0001 - Tratar para remover encargos das cobrancas do responsável FIES - FIES  
  
-- Alteração para armazenar no campo flex as disciplinas vinculadas ao aluno no momento da geração da cobrança  
 if exists(select top 1 1 from ly_cobranca where cobranca = @p_Cobranca and NUM_COBRANCA = 1)  
 begin  
	
	declare @v_Cobranca VARCHAR(2000)

	SET @v_Cobranca = (SELECT dbo.FTC_FN_DisciplinaCobranca(@p_Cobranca))

	  UPDATE C   
	  SET FL_FIELD_02 = @v_Cobranca
	  FROM LY_COBRANCA C with (NOLOCK)  
	  WHERE c.COBRANCA = @p_Cobranca  
 end  
  
  RETURN     
-- [FIM]      
  