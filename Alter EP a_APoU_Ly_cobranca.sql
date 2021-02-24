-- EP PROGRAMADO
ALTER PROCEDURE a_APoU_Ly_cobranca
  @erro VARCHAR(1024) OUTPUT,
  @oldCobranca NUMERIC(10), @oldAluno VARCHAR(20), @oldResp VARCHAR(20), @oldAno NUMERIC(4), 
  @oldMes NUMERIC(2), @oldNum_cobranca NUMERIC(3), @oldData_de_vencimento DATETIME, 
  @oldData_de_geracao DATETIME, @oldData_de_faturamento DATETIME, @oldLote NUMERIC(10), 
  @oldApenas_cobranca VARCHAR(1), @oldProtesto VARCHAR(1), @oldUltimo_item NUMERIC(10), 
  @oldUltimo_desc NUMERIC(10), @oldUltimo_encargo NUMERIC(10), @oldData_de_protesto DATETIME, 
  @oldData_canc_protesto DATETIME, @oldIdent_contabil VARCHAR(100), @oldTipo_doc VARCHAR(20), 
  @oldNum_doc VARCHAR(20), @oldDt_geracao_doc DATETIME, @oldDt_emissao_doc DATETIME, 
  @oldGera_doc VARCHAR(1), @oldData_cob_judicial DATETIME, @oldData_canc_cob_jud DATETIME, 
  @oldCobr_judicial VARCHAR(1), @oldCurso VARCHAR(20), @oldTurno VARCHAR(20), @oldCurriculo VARCHAR(20), 
  @oldUnid_fisica VARCHAR(20), @oldData_de_vencimento_orig DATETIME, @oldFl_field_01 VARCHAR(2000), 
  @oldEstorno VARCHAR(1), @oldDt_estorno DATETIME, @oldFl_field_02 VARCHAR(2000), @oldFl_field_03 VARCHAR(2000), 
  @oldFl_field_04 VARCHAR(2000), @oldFl_field_05 VARCHAR(2000), @oldFl_field_06 VARCHAR(2000), 
  @oldFl_field_07 VARCHAR(2000), @oldFl_field_08 VARCHAR(2000), @oldFl_field_09 VARCHAR(2000), 
  @oldFl_field_10 VARCHAR(2000), @oldFl_field_11 VARCHAR(2000), @oldFl_field_12 VARCHAR(2000), 
  @oldFl_field_13 VARCHAR(2000), @oldFl_field_14 VARCHAR(2000), @oldFl_field_15 VARCHAR(2000), 
  @oldFl_field_16 VARCHAR(2000), @oldFl_field_17 VARCHAR(2000), @oldFl_field_18 VARCHAR(2000), 
  @oldFl_field_19 VARCHAR(2000), @oldFl_field_20 VARCHAR(2000), @oldAr VARCHAR(1),
  @cobranca NUMERIC(10), @aluno VARCHAR(20), @resp VARCHAR(20), @ano NUMERIC(4), @mes NUMERIC(2), 
  @num_cobranca NUMERIC(3), @data_de_vencimento DATETIME, @data_de_geracao DATETIME, 
  @data_de_faturamento DATETIME, @lote NUMERIC(10), @apenas_cobranca VARCHAR(1), @protesto VARCHAR(1), 
  @ultimo_item NUMERIC(10), @ultimo_desc NUMERIC(10), @ultimo_encargo NUMERIC(10), 
  @data_de_protesto DATETIME, @data_canc_protesto DATETIME, @ident_contabil VARCHAR(100), 
  @tipo_doc VARCHAR(20), @num_doc VARCHAR(20), @dt_geracao_doc DATETIME, @dt_emissao_doc DATETIME, 
  @gera_doc VARCHAR(1), @data_cob_judicial DATETIME, @data_canc_cob_jud DATETIME, @cobr_judicial VARCHAR(1), 
  @curso VARCHAR(20), @turno VARCHAR(20), @curriculo VARCHAR(20), @unid_fisica VARCHAR(20), 
  @data_de_vencimento_orig DATETIME, @fl_field_01 VARCHAR(2000), @estorno VARCHAR(1), 
  @dt_estorno DATETIME, @fl_field_02 VARCHAR(2000), @fl_field_03 VARCHAR(2000), @fl_field_04 VARCHAR(2000), 
  @fl_field_05 VARCHAR(2000), @fl_field_06 VARCHAR(2000), @fl_field_07 VARCHAR(2000), 
  @fl_field_08 VARCHAR(2000), @fl_field_09 VARCHAR(2000), @fl_field_10 VARCHAR(2000), 
  @fl_field_11 VARCHAR(2000), @fl_field_12 VARCHAR(2000), @fl_field_13 VARCHAR(2000), 
  @fl_field_14 VARCHAR(2000), @fl_field_15 VARCHAR(2000), @fl_field_16 VARCHAR(2000), 
  @fl_field_17 VARCHAR(2000), @fl_field_18 VARCHAR(2000), @fl_field_19 VARCHAR(2000), 
  @fl_field_20 VARCHAR(2000), @ar VARCHAR(1)
AS
BEGIN
-- [INÍCIO] Customização - Não escreva código antes desta linha
SET @erro = NULL  

	-- Se tinha data de faturamento e agora nao vai ter mais (esta DESFATURANDO a cobranca)
	IF @oldData_de_faturamento IS NOT NULL AND @data_de_faturamento IS NULL
	BEGIN

		DECLARE @qtd_contab INT  

		-- Verifica se existe algum item ja contabilizado
		SET @qtd_contab = 0  

		SELECT @qtd_contab = ISNULL(COUNT(*),0)
		FROM LY_ITEM_LANC   
		WHERE COBRANCA = @cobranca
		AND DT_ENVIO_CONTAB IS NOT NULL  
		
		-- Se ainda nao tem nenhum item contabilizado, 
		-- pode tirar da LY_MOVIMENTO_TEMPORAL mas antes....
		IF @qtd_contab = 0
		BEGIN

			-- Tem que remover os itens da LY_CAR
			DELETE FROM LY_CAR
			WHERE COBRANCA = @cobranca
			
			-- Tem que remover os itens da LY_SOBRA_CRED_COBRANCA
			DELETE FROM LY_SOBRA_CRED_COBRANCA 
			WHERE COBRANCA = @cobranca
			
			-- Tem que remover os itens da LY_APROP_QUITACAO
			DELETE FROM LY_APROP_QUITACAO 
			WHERE COBRANCA = @cobranca

			-- Finalmente retira da LY_MOVIMENTO_TEMPORAL
			DELETE FROM LY_MOVIMENTO_TEMPORAL
			WHERE ENTIDADE = 'Ly_Item_Lanc'
			AND ID1 = @cobranca
			
			--## incluido em 04/08/2016 pois verificamos que faltava este tratamento -> enviado pelo Henrico
			-- Tira tambem eventuais alteracoes de vencimento dessa cobranca na LY_MOVIMENTO_TEMPORAL
			DELETE FROM LY_MOVIMENTO_TEMPORAL
			WHERE ENTIDADE = 'Ly_Cobranca_Alt_Venc'
			AND ID1 in (SELECT ID FROM LY_COBRANCA_ALT_VENC WHERE COBRANCA = @cobranca)
			
		END
		-- ELSE: Se ja tem algum item contabilizado a procedure que chamou
		-- esse entrypoint (APrU_Ly_cobranca) vai gerar um erro que irá impedir 
		-- o desfaturamento
		ELSE
		BEGIN
			SET @erro = 'FTC - A cobrança ' + CONVERT(VARCHAR,@cobranca) + ' já possui itens contabilizados e não pode ser desfaturada'
			RETURN
		END

	END

-- [FIM] Customização - Não escreva código após esta linha
END
GO