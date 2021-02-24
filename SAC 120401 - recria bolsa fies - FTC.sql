------------------------------------------------
-- CORRECAO DE BOLSA NÃO CADASTRADA PARA FIES --
------------------------------------------------
-- GERA TABELA PARA ARMAZENAR DADOS DOS CASOS A SEREM CORRIGIDOS
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'zz_SAC_120401_dados_alunos_contrato_fies')
BEGIN
	CREATE TABLE zz_SAC_120401_dados_alunos_contrato_fies (ALUNO T_CODIGO
											, ID_CONTRATO T_NUMERO
											, ID_CONTRATO_PERIODO T_NUMERO
											, stamp DATETIME)
END
GO
-- GERA TABELA PARA ARMAZENAR DADOS DAS BOLSA CADASTRADAS
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'zz_SAC_120401_dados_bolsas_cadastradas')
BEGIN
	CREATE TABLE zz_SAC_120401_dados_bolsas_cadastradas (ALUNO T_CODIGO
											, NUM_BOLSA T_NUMERO
											, TIPO_BOLSA T_CODIGO
											, ANOINI T_ANO
											, ANOFIM T_ANO
											, MESINI T_MES
											, MESFIM T_MES
											, PERC_VALOR T_TIPO_TAXA
											, VALOR T_DECIMAL_MEDIO_PRECISO6
											, MOTIVO T_ALFAMEDIUM
											, stamp DATETIME)
END
GO
-- VARIAVEIS DE EXECUCAO
DECLARE @aluno				T_CODIGO
DECLARE @num_bolsa			T_NUMERO
DECLARE @tipo_bolsa			T_CODIGO
DECLARE @ano_ini			T_ANO
DECLARE @ano_fim			T_ANO
DECLARE @mes_ini			T_MES
DECLARE @mes_fim			T_MES
DECLARE @perc_valor			T_TIPO_TAXA
DECLARE @valor				T_DECIMAL_MEDIO_PRECISO6
DECLARE @motivo				T_ALFAMEDIUM
DECLARE @a_parcela			T_NUMERO_PEQUENO
DECLARE @a_soma_mes_parcela T_MES
DECLARE @msg				VARCHAR(MAX)
-- REGISTRA DATA DA OPERACAO
DECLARE @stamp DATETIME SET @stamp = GETDATE()
-- INICIA NOVA TRANSACAO
SET @msg = ''
BEGIN TRANSACTION correcao_sac_120401
-- ARMAZENA TODOS OS CASOS A SEREM CORRIGIDOS
INSERT INTO zz_SAC_120401_dados_alunos_contrato_fies (ALUNO, ID_CONTRATO, ID_CONTRATO_PERIODO, stamp)
	SELECT cf.aluno as ALUNO
		,cf.id_contrato as ID_CONTRATO
		,cfp.id_contrato_periodo as ID_CONTRATO_PERIODO
		,@stamp as stamp 
		from LY_ALUNO oa 
			inner join ly_contrato_fies cf on oa.aluno = cf.aluno 
			inner join ly_contrato_fies_periodo cfp on cf.id_contrato = cfp.id_contrato
		where not exists (select 1 from ly_bolsa ib where ib.aluno = oa.aluno and ib.num_bolsa = cfp.num_bolsa) order by oa.aluno
-- INSERE A BOLSA PARA CADA ALUNO DO CASO
DECLARE casos CURSOR FOR SELECT aluno FROM zz_SAC_120401_dados_alunos_contrato_fies
OPEN casos
FETCH NEXT FROM casos INTO @aluno
WHILE @@FETCH_STATUS = 0
BEGIN
	-- COLETA DADOS DA NOVA BOLSA DE LY_CONTRATO_FIES E LY_CONTRATO_FIES_PERIODO
	SELECT @num_bolsa = cfp.num_bolsa, @ano_ini = cfp.ano_inicio, @mes_ini = cfp.mes_inicio, @perc_valor = 'Valor'
				, @valor = cfp.valor_mensal, @motivo = 'Contrato FIES: ' + convert(varchar(max),@num_bolsa), @a_parcela = cfp.parcelas  
		FROM ly_contrato_fies cf INNER JOIN ly_contrato_fies_periodo cfp ON cf.id_contrato = cfp.id_contrato 
		WHERE cf.aluno = @aluno AND NOT EXISTS (SELECT 1 FROM ly_bolsa b WHERE b.aluno = cf.aluno AND b.num_bolsa = cfp.num_bolsa)
	-- COLETA O TIPO DE BOLSA
	DECLARE @a_chave T_NUMERO
	SELECT @a_chave = cfg.CHAVE FROM LY_CONFIGURACAO cfg WHERE cfg.CONFIGURACAO = 'FIES' ORDER BY cfg.CHAVE ASC  
	SELECT @tipo_bolsa = VALOR_TEXTO FROM LY_PARAM_CONFIGURACAO WHERE CHAVE = @a_chave
	-- CALCULA ANO FINAL E MES FINAL
	SET @ano_fim = @ano_ini								-- MARCA O ANO FINAL
	SET @a_soma_mes_parcela = @mes_ini + @a_parcela - 1	-- CALCULA O MES FINAL
	SET @mes_fim = @a_soma_mes_parcela					-- MARCA O MES FINAL
	IF @mes_fim > 12									-- SE O MES FINAL EXCEDE OS 12 MESES, AJUSTA O ANO E O MES FINAIS
	BEGIN
		SET @ano_ini = @ano_ini + 1						-- AJUSTA ANO
		SET @mes_fim = @mes_fim - 12					-- AJUSTA MES
	END
	BEGIN TRY
		-- CADASTRA NOVA BOLSA
		INSERT INTO ly_bolsa (ALUNO, NUM_BOLSA, TIPO_BOLSA, ANOINI, ANOFIM, MESINI, MESFIM, PERC_VALOR, VALOR, MOTIVO) 
			VALUES (@aluno, @num_bolsa, @tipo_bolsa, @ano_ini, @ano_fim, @mes_ini, @mes_fim, @perc_valor, @valor, @motivo)
	END TRY
	BEGIN CATCH
		SET @msg = 'Erro ao tentar cadastrar bolsa ['+convert(varchar(max),@num_bolsa)+'] para aluno ['+convert(varchar(max),@aluno)+'].'
		GOTO falha
	END CATCH
	BEGIN TRY
		-- REGISTRA DADOS DA NOVA BOLSA GERADA
		INSERT INTO zz_SAC_120401_dados_bolsas_cadastradas (ALUNO, NUM_BOLSA, TIPO_BOLSA, ANOINI, ANOFIM, MESINI, MESFIM, PERC_VALOR, VALOR, MOTIVO, stamp) 
			VALUES (@aluno, @num_bolsa, @tipo_bolsa, @ano_ini, @ano_fim, @mes_ini, @mes_fim, @perc_valor, @valor, @motivo, @stamp)
	END TRY
	BEGIN CATCH
		SET @msg = 'Erro ao tentar registrar bolsa ['+convert(varchar(max),@num_bolsa)+'] cadastrada para aluno ['+convert(varchar(max),@aluno)+'].'
		GOTO falha
	END CATCH	
	FETCH NEXT FROM casos INTO @aluno
END
CLOSE casos
DEALLOCATE casos
-- CHEGANDO ATE AQUI, AS CORRECOES FORAM APLICADAS
GOTO sucesso
-- LABEL FALHA
falha:
	ROLLBACK TRANSACTION correcao_sac_120401
	GOTO fim
-- LABEL SUCESSO
sucesso:
	COMMIT TRANSACTION correcao_sac_120401
	GOTO fim
-- LABEL FIM
fim:
	IF @msg <> ''
	BEGIN SELECT @msg as RESULTADO END
	ELSE
	BEGIN SELECT 'Correções aplicadas com sucesso.' as RESULTADO END
------------------------------------------------
------------------------------------------------