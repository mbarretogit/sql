USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.a_APrI_Ly_lanc_credito'))
   exec('CREATE PROCEDURE [dbo].[a_APrI_Ly_lanc_credito] AS BEGIN SET NOCOUNT OFF; END')
GO 
    
-- ----------------------------------------------------------------------------------------------------    
-- ENTRY-POINT PROGRAMADO    
-- ----------------------------------------------------------------------------------------------------    
ALTER PROCEDURE a_APrI_Ly_lanc_credito    
               @erro VARCHAR(1024) OUTPUT,    
               @lanc_cred NUMERIC(20, 10) , @tipo_cred VARCHAR(200) , @boleto NUMERIC(20, 10) ,     
               @resp VARCHAR(200) , @dt_credito DATETIME , @tipo_pagamento VARCHAR(200) ,     
               @data DATETIME , @lote NUMERIC(20, 10) , @descricao VARCHAR(200) ,     
               @valido_apos_comp VARCHAR(200) , @autenticacao VARCHAR(200) , @nosso_numero NUMERIC(25, 10) ,     
               @banco_cob NUMERIC(20, 10) , @agencia_cob VARCHAR(200) , @banco NUMERIC(20, 10) ,     
               @agencia VARCHAR(200) , @conta_banco VARCHAR(200) , @serie VARCHAR(200) ,     
               @numero VARCHAR(200) , @bco_deb NUMERIC(20, 10) , @ag_deb VARCHAR(200) ,     
               @conta_deb VARCHAR(200) , @dv_conta_deb VARCHAR(200) , @dt_deposito DATETIME ,     
               @banco_deposito NUMERIC(20, 10) , @agencia_deposito VARCHAR(200) , @conta_banco_deposito VARCHAR(200) ,     
               @id_abertura NUMERIC(20, 10) , @acordo NUMERIC(20, 10)     
AS    
-- [INÍCIO] Customização - Não escreva código antes desta linha    
    
    DECLARE @V_USUARIO          T_CODIGO,    
            @V_RETURN_BUSCA_U   T_SIMNAO,    
            @V_MSG_BUSCA_U      VARCHAR(2000),    
            @V_NOME_USUARIO     VARCHAR(100)    
    
    
    
      -- MODIFICADO POR JULIANO ARMENTANO EM 04/01/2017   
    --## INICIO - 01/06/2016 - RAUL - 0001 - Tratar para não preencher dt_deposito quando o tipo pagamento = cheque    
    --If @tipo_pagamento in ('Cheque')   --## 14/06/2016 - retirei Cartao pois estava travando a baixa quando eram multiplas cobrancas, chamado aberto no suporte    
    --   and @dt_deposito is not null    
    --Begin    
    --    Set @erro = 'Custom'+CHAR(10)+CHAR(13)+    
    --                'Não deve preencher a DATA DE DEPOSITO quando o tipo de pagamento for CHEQUE.'    
    --    Return    
    --End    
    ----## FIM - 01/06/2016 - RAUL - 0001 - Tratar para não preencher dt_deposito quando o tipo pagamento = cheque    
    --ELSE    
    --BEGIN    
    --## INICIO - 01/06/2016 - RENATO - Tratamento para bloquear utilização do tipo pagamento = Especial    
        IF @tipo_pagamento = 'Especial'    
        BEGIN    
            SELECT @V_USUARIO = NULL    
    
            EXEC BUSCA_USUARIO    
                    @p_usuario      = @V_USUARIO output,    
                    @p_return       = @V_RETURN_BUSCA_U output,    
                    @p_mensagem     = @V_MSG_BUSCA_U output    
    
            IF NOT EXISTS (SELECT TOP 1 1 FROM PADUSUARIO P WHERE USUARIO = @V_USUARIO AND PADACES = 'GpoLibPgEspec')    
            BEGIN    
                SELECT @V_NOME_USUARIO  = UPPER(USUARIO) + ' - '+ NOMEUSUARIO FROM USUARIO WHERE USUARIO = @V_USUARIO    
                SET @erro = CHAR(10)+CHAR(13)+'Custom '+CHAR(10)+CHAR(13)+    
                            'Caro colaborador '+    
                            ISNULL((SELECT UPPER(USUARIO) + ' - '+ NOMEUSUARIO FROM USUARIO WHERE USUARIO = @V_USUARIO),'VAZIO')+ ','+CHAR(10)+CHAR(13)+    
                            'Você está sem permissão para utilizar o tipo de pagamento "Especial".'+CHAR(10)+CHAR(13)+    
                            'Somente usuários do padrão de acesso ''GpoLibPgEspec'', podem utilizar o tipo de pagamento "Especial".'    
                RETURN    
            END -- IF NOT EXISTS (SELECT TOP 1 1 FROM PADUSUARIO P WHERE USUARIO = @V_USUARIO AND PADACES = 'GpoLibPgEspec')    
        END -- IF @tipo_pagamento = 'Especial'    
    --## FIM - 16/06/2016 - RENATO - Tratamento para bloquear utilização do tipo pagamento = Especial    
   -- END -- ELSE DO If @tipo_pagamento in ('Cheque')    

	
       --## INICIO - 24/10/2017 - MIGUEL - Tratamento para bloquear Baixa FIES sem utilização do processo
        IF (@descricao not like 'Processamento de Recebimento FIES em %' or @descricao is null) AND @resp = 'FIES'
        BEGIN    
                SET @erro = 'Caro colaborador, não é possível realizar baixa manual de cobranças de responsável financeiro FIES. Só é permitido a baixa dessas cobranças através do processo ''Impotação Recebimento FIES''. Procure a Secretaria Geral - Contas a Receber'
        RETURN    
        END --IF @descricao not like 'Processamento de Recebimento FIES em%' AND @resp = 'FIES'
    --## FIM - 24/10/2017 - MIGUEL - Tratamento para bloquear utilização do tipo pagamento = Especial    
   -- END -- ELSE DO If @tipo_pagamento in ('Cheque')    

    
    RETURN    
-- [FIM] Customização - Não escreva código após esta linha    
  
  DELETE FROM LY_CUSTOM_CLIENTE    
where NOME = 'a_APrI_Ly_lanc_credito'    
and IDENTIFICACAO_CODIGO = '0003' 
GO

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'a_APrI_Ly_lanc_credito' NOME
, '0003' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2018-02-19' DATA_CRIACAO
, 'EP - Tratar para bloquear baixa individual de cobranças de responsável financeiro FIES' OBJETIVO
, 'Naijórgia / Nelson' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO 