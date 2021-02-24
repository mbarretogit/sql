  
  
--## Versão 6.2.1 - HF14  
  
CREATE PROCEDURE a_APrI_Ly_resp_finan     
  
  @erro VARCHAR(1024) OUTPUT,    
  
  @resp VARCHAR(200) OUTPUT, @banco NUMERIC(20, 10) OUTPUT, @agencia VARCHAR(200) OUTPUT,     
  
  @conta_banco VARCHAR(200) OUTPUT, @titular VARCHAR(200) OUTPUT, @cpf_titular VARCHAR(200) OUTPUT,     
  
  @cgc_titular VARCHAR(200) OUTPUT, @dtini_deb_auto DATETIME OUTPUT, @dtfim_deb_auto DATETIME OUTPUT,     
  
  @endereco VARCHAR(200) OUTPUT, @end_num VARCHAR(200) OUTPUT, @end_compl VARCHAR(200) OUTPUT,     
  
  @bairro VARCHAR(200) OUTPUT, @end_municipio VARCHAR(200) OUTPUT, @cep VARCHAR(200) OUTPUT,     
  
  @obs VARCHAR(4100) OUTPUT, @operacao NUMERIC(20, 10) OUTPUT, @dv_agencia VARCHAR(200) OUTPUT,     
  
  @dv_conta VARCHAR(200) OUTPUT, @dv_agencia_conta VARCHAR(200) OUTPUT, @boleto_unico VARCHAR(200) OUTPUT,     
  
  @pessoa NUMERIC(20, 10) OUTPUT, @apenas_faturamento VARCHAR(200) OUTPUT, @concede_credito VARCHAR(200) OUTPUT,     
  
  @ccm VARCHAR(200) OUTPUT, @credito_educativo VARCHAR(200) OUTPUT, @bol_unico_pessoa VARCHAR(200) OUTPUT,     
  
  @empresa VARCHAR(200) OUTPUT, @ativo VARCHAR(200) OUTPUT, @ver_inadimplencia VARCHAR(200) OUTPUT,     
  
  @dda VARCHAR(200) OUTPUT, @ver_aluno_restit VARCHAR(200) OUTPUT, @e_mail VARCHAR(200) OUTPUT    
  
AS        
  
BEGIN        
  
  -- [INÍCIO] Customização - Não escreva código antes desta linha      
  
   
  
--## INICIO - RAUL - 08/12/2015 - 0001 - Tratamento para não permitir cadastrar responsável financeiro sem estar vinculado a pessoa ou empresa  
  
  
  
  IF (@pessoa IS NULL AND @empresa IS NULL)    
  
  BEGIN    
  
    EXEC SetErro 'CUSTOM - O Responsável Financeiro precisa estar vinculado a pelo menos uma Pessoa ou Empresa','PESSOA'    
  
    RETURN    
  
  END    
  
  
  
--## FIM - RAUL - 08/12/2015 - 0001 - Tratamento para não permitir cadastrar responsável financeiro sem estar vinculado a pessoa ou empresa  
  
  
  
--## INICIO - RAUL - 08/12/2015 - 0002 - Código do responsável deve ser o CPF ou CGC do titular  
  
  
  
  IF @cpf_titular IS NOT NULL  
  
  and not exists (select 1 from ly_resp_finan where resp = @cpf_titular) --## 23/11/2016 - Raul - Incluido para validar se existe o resp como cpf para não atribuir novamente  
  
  BEGIN    
  
    set @resp = @cpf_titular  
  
  END      
  
  
  
  IF @cgc_titular IS NOT NULL  
  
  and not exists (select 1 from ly_resp_finan where resp = @cgc_titular) --## 23/11/2016 - Raul - Incluido para validar se existe o resp como CNPJ para não atribuir novamente  
  
  BEGIN    
  
    set @resp = @cgc_titular   
  
  END   
  
  
  
--## FIM - RAUL - 08/12/2015 - 0002 - Código do responsável deve ser o CPF ou CGC do titular  
  
  
  
  
  
--## INICIO - RAUL - 08/12/2015 - 0003 - Setar como padrão para as pessoas o APENAS FATURAMENTO = 'N'  
  
  
  
--# Comentado em 13/04/2016 - Solicitado por André em 13/04/2016  
  
   --IF @apenas_faturamento = 'S'   
  
   --and @pessoa is not null  
  
   --   SET @apenas_faturamento = 'N'  
  
  
  
--# Incluido em 13/04/2016 - para que os alunos ingressantes so gere cobrança sem boleto. - Solicitado por André em 13/04/2016  
  
--# Este tratamento é temporario.  
  
   IF @apenas_faturamento = 'N'   
  
   and @pessoa is not null  
  
      SET @apenas_faturamento = 'S'  
  
  
  
--## FIM - RAUL - 08/12/2015 - 0003 - Setar como padrão para as pessoas o APENAS FATURAMENTO = 'N'  
  
  
  
  
  
--## INICIO - RAUL - 08/12/2015 - 0004 - Setar como padrão para as pessoas o BOL_UNICO_PESSOA = 'S'  
  
  
  
   IF ISNULL(@BOL_UNICO_PESSOA,'N') = 'N'  AND  @PESSOA IS NOT NULL  AND @BOLETO_UNICO = 'N'    
  
         SET @bol_unico_pessoa = 'S'  
  
  
  
--## FIM - RAUL - 08/12/2015 - 0004 - Setar como padrão para as pessoas o BOL_UNICO_PESSOA = 'S'  
  
  
  
--## INICIO - RAUL - 21/03/2016 - 0005 - Setar como padrão para os responsáveis o VER_INADIMPLENCIA = 'S'  
  
  
  
   IF ISNULL(@ver_inadimplencia,'N') = 'N'   
  
      SET @ver_inadimplencia = 'S'  
  
  
  
--## FIM - RAUL - 21/03/2016 - 0005 - Setar como padrão para os responsáveis o VER_INADIMPLENCIA = 'S'  
  
  
  
    
  
  -- [FIM] Customização - Não escreva código após esta linha      
  
  RETURN         
  
END  