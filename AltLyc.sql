-- --------------------------------------------------
-- TABLE: LY_FLEX_FIELDS
-- --------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM LY_FLEX_FIELDS WHERE TABELA = 'LY_OFERTA_CURSO' AND FLEX_FIELD = 'FL_FIELD_01')
BEGIN
	UPDATE LY_FLEX_FIELDS
	SET ORDEM_TELA = '01'
		, DESCRICAO_TELA = 'Código da Oferta do CRM'
		, TIPO_DADO = 'Texto'
		, TAMANHO = '2000'
	WHERE TABELA = 'LY_OFERTA_CURSO'
	AND FLEX_FIELD = 'FL_FIELD_01'
END
GO

-- --------------------------------------------------
-- TABLE: LY_INTEGRACAO_LOG
-- --------------------------------------------------
IF dbo.fn_ExisteTabela('LY_INTEGRACAO_LOG') = 'N'
  BEGIN
	CREATE TABLE LY_INTEGRACAO_LOG ( 
		ID_INTEGRACAO_LOG T_NUMERO_GRANDE IDENTITY(1,1) NOT NULL,
		TIME_INI T_HORA NOT NULL,
		TIME_ULT T_HORA NOT NULL,
		NOME_INTEGRACAO T_ALFA_HUGE NOT NULL,
		ESTADO T_ALFALARGE NOT NULL
	)
  END 
GO

IF dbo.fn_ExisteChave('PK_LY_INTEGRACAO_LOG') = 'N'
  BEGIN
	ALTER TABLE LY_INTEGRACAO_LOG ADD CONSTRAINT PK_LY_INTEGRACAO_LOG 
	PRIMARY KEY CLUSTERED (ID_INTEGRACAO_LOG)
  END 
GO

IF dbo.fn_ExisteCheck('CK_LY_INTEGRACAO_LOG') = 'N'
  BEGIN
	ALTER TABLE LY_INTEGRACAO_LOG ADD CONSTRAINT CK_LY_INTEGRACAO_LOG 
	CHECK ([ESTADO] = 'Em Execução' or ([ESTADO] = 'Finalizada com Sucesso' or [ESTADO] = 'Finalizada com Erro(s)'))
  END 
GO

IF dbo.fn_ExisteIndice('IX_SNE_LY_INTEGRACAO_LOG') = 'N'
 BEGIN
	CREATE INDEX IX_SNE_LY_INTEGRACAO_LOG ON LY_INTEGRACAO_LOG (NOME_INTEGRACAO ASC, ESTADO ASC)
 END
GO

-- --------------------------------------------------
-- TABLE: LY_INTEGRACAO_ANDAMENTO_LOG
-- --------------------------------------------------
IF dbo.fn_ExisteTabela('LY_INTEGRACAO_ANDAMENTO_LOG') = 'N'
  BEGIN
	CREATE TABLE LY_INTEGRACAO_ANDAMENTO_LOG ( 
		ID_INTEGRACAO_LOG T_NUMERO_GRANDE NOT NULL,
		ID_INTEGRACAO_ANDAMENTO_LOG T_NUMERO_GRANDE IDENTITY(1,1) NOT NULL,
		PROCESSO T_ALFA_HUGE NOT NULL,
		OBJETO T_ALFA_HUGE NOT NULL,
		DATA T_DATA NOT NULL DEFAULT(GETDATE()),			
		PARAMETROS_EXECUCAO T_ALFA7000 NULL,
		MSG T_ALFA7000 NOT NULL,
		ERRO T_SIMNAO NOT NULL DEFAULT('N')
	)
  END 
GO

IF dbo.fn_ExisteChave('PK_LY_INTEGRACAO_ANDAMENTO_LOG') = 'N'
  BEGIN
	ALTER TABLE LY_INTEGRACAO_ANDAMENTO_LOG ADD CONSTRAINT PK_LY_INTEGRACAO_ANDAMENTO_LOG 
	PRIMARY KEY CLUSTERED (ID_INTEGRACAO_ANDAMENTO_LOG)
  END 
GO

IF dbo.fn_ExisteChave('UQ_LY_INTEGRACAO_ANDAMENTO_LOG') = 'N'
  BEGIN
	ALTER TABLE LY_INTEGRACAO_ANDAMENTO_LOG
	ADD CONSTRAINT UQ_LY_INTEGRACAO_ANDAMENTO_LOG UNIQUE (ID_INTEGRACAO_LOG, ID_INTEGRACAO_ANDAMENTO_LOG)
 END
GO

IF dbo.fn_ExisteIndice('IX_DATA_LY_INTEGRACAO_ANDAMENTO_LOG') = 'N'
 BEGIN
	CREATE INDEX IX_DATA_LY_INTEGRACAO_ANDAMENTO_LOG ON LY_INTEGRACAO_ANDAMENTO_LOG (ID_INTEGRACAO_LOG ASC, ID_INTEGRACAO_ANDAMENTO_LOG ASC)
 END
GO

-- --------------------------------------------------
-- TABLE: C_INTEGRA_CRM_LYCEUM
-- --------------------------------------------------
IF dbo.fn_ExisteTabela('C_INTEGRA_CRM_LYCEUM') = 'N'
  BEGIN
	CREATE TABLE C_INTEGRA_CRM_LYCEUM
	(
		Inscricao		VARCHAR(20)			NOT NULL
		, Candidato		VARCHAR(20)			NOT NULL
		, Pessoa		T_NUMERO			NOT NULL
		, Concurso		T_CODIGO			NOT NULL
		, Data			DATETIME DEFAULT GETDATE()
	)
  END
GO

IF DBO.fn_ExisteChave('PK_C_INTEGRA_CRM_LYCEUM') = 'N'
  BEGIN
	ALTER TABLE C_INTEGRA_CRM_LYCEUM ADD CONSTRAINT PK_C_INTEGRA_CRM_LYCEUM PRIMARY KEY(Candidato, Concurso)
  END
GO

IF DBO.fn_ExisteChave('UQ_C_INTEGRA_CRM_LYCEUM_INSCRICAO') = 'N'
  BEGIN
	ALTER TABLE C_INTEGRA_CRM_LYCEUM ADD CONSTRAINT UQ_C_INTEGRA_CRM_LYCEUM_INSCRICAO UNIQUE(Inscricao)
  END
GO

IF DBO.fn_ExisteChave('UQ_C_INTEGRA_CRM_LYCEUM_CANDIDATO') = 'N'
  BEGIN
	ALTER TABLE C_INTEGRA_CRM_LYCEUM ADD CONSTRAINT UQ_C_INTEGRA_CRM_LYCEUM_CANDIDATO UNIQUE(Candidato)
  END
GO

-- --------------------------------------------------
-- TABLE: C_INTEGRA_CRM_LYCEUM_VEST
-- --------------------------------------------------
IF dbo.fn_ExisteTabela('C_INTEGRA_CRM_LYCEUM_VEST') = 'N'
  BEGIN
	CREATE TABLE C_INTEGRA_CRM_LYCEUM_VEST
	(
		IdConvocacao		INT IDENTITY(1,1)			NOT NULL
		, Candidato			VARCHAR(20)					NOT NULL
		, Concurso			VARCHAR(20)					NOT NULL
		, Oferta_de_curso	VARCHAR(100)				NOT NULL
		, Chamada			INT							NOT NULL
		, Ordem				INT							NOT NULL
		, Data				DATETIME DEFAULT GETDATE()	NOT NULL
		, Ano				INT							NULL
		, Periodo			INT							NULL
		, CodCampus			INT							NULL
		, CodCurriculo		INT							NULL
		, CodCurso			INT							NULL
		, CodEscola			INT							NULL
		, CodTurno			INT							NULL
		, Regime			INT							NULL
		, SituacaoConcurso	VARCHAR(50)					NULL

	)
  END
  
IF DBO.fn_ExisteChave('PK_C_INTEGRA_CRM_LYCEUM_VEST') = 'N'
  BEGIN
	ALTER TABLE C_INTEGRA_CRM_LYCEUM_VEST ADD CONSTRAINT PK_C_INTEGRA_CRM_LYCEUM_VEST PRIMARY KEY(IdConvocacao)
  END
GO   

IF DBO.fn_ExisteChave('UQ_C_INTEGRA_CRM_LYCEUM_VEST_CANDIDATO_CONCURSO_OFERTA_DE_CURSO_CURSO_CHAMADA_ORDEM') = 'N'
  BEGIN
	ALTER TABLE C_INTEGRA_CRM_LYCEUM_VEST ADD CONSTRAINT UQ_C_INTEGRA_CRM_LYCEUM_VEST_CANDIDATO_CONCURSO_OFERTA_DE_CURSO_CURSO_CHAMADA_ORDEM UNIQUE(Candidato, Oferta_de_curso, Chamada, Ordem)
  END
GO

IF DBO.fn_ExisteChave('FK_C_INTEGRA_CRM_LYCEUM_VEST_CANDIDATO_CONCURSO') = 'N'
  BEGIN
	ALTER TABLE C_INTEGRA_CRM_LYCEUM_VEST ADD CONSTRAINT FK_C_INTEGRA_CRM_LYCEUM_VEST_CANDIDATO_CONCURSO FOREIGN KEY (Candidato, Concurso) REFERENCES C_INTEGRA_CRM_LYCEUM (Candidato, Concurso)
  END
GO

-- --------------------------------------------------
-- TABLE: LY_INTEGRACAO_FILA_EVENTOS
-- --------------------------------------------------
IF dbo.fn_ExisteTabela('LY_INTEGRACAO_FILA_EVENTOS') = 'N'
  BEGIN
	CREATE TABLE LY_INTEGRACAO_FILA_EVENTOS (
		ID_FILA_EVENTOS T_NUMERO_GRANDE IDENTITY NOT NULL ,
		DATA_INCLUSAO T_DATA NOT NULL,
		SISTEMA_DESTINO	T_ALFALARGE NOT NULL,
		OBJETO T_ALFALARGE NOT NULL,
		OPERACAO VARCHAR(1) NOT NULL,
		CHAVE_1	T_ALFAMEDIUM NOT NULL,
		CHAVE_2	T_ALFAMEDIUM,
		CHAVE_3	T_ALFAMEDIUM,
		CHAVE_4	T_ALFAMEDIUM,
		CHAVE_5	T_ALFAMEDIUM,
		CHAVE_6	T_ALFAMEDIUM,
		CHAVE_7	T_ALFAMEDIUM,
		CHAVE_8	T_ALFAMEDIUM,
		CHAVE_9	T_ALFAMEDIUM,
		CHAVE_10 T_ALFAMEDIUM,
		DATA_INTEGRACAO	T_DATA,
		DATA_ERRO T_DATA,
		MSG_ERRO T_ALFAEXTRALARGE,
		IGNORAR	T_SIMNAO
	)
  END
GO
  
IF dbo.fn_ExisteChave('PK_LY_INTEGRACAO_FILA_EVENTOS') = 'N'
  BEGIN
	ALTER TABLE LY_INTEGRACAO_FILA_EVENTOS ADD CONSTRAINT PK_LY_INTEGRACAO_FILA_EVENTOS PRIMARY KEY (ID_FILA_EVENTOS)
  END
GO

-- --------------------------------------------------
-- Tabela Geral: Cadastra Depara Turno CRM
-- --------------------------------------------------
IF NOT EXISTS (SELECT TOP 1 1 FROM TABELA WHERE TAB = 'DeparaTurnoCrm' AND SIS = 'Lyceum')
BEGIN
	INSERT INTO TABELA (TAB, SIS, DESCR) VALUES ('DeparaTurnoCrm', 'Lyceum', 'Depara do Turno - Integração Lyceum x CRM')
END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaTurnoCrm' AND ITEM = 'M')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaTurnoCrm', 'M', '1')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaTurnoCrm' AND ITEM = 'V')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaTurnoCrm', 'V', '2')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaTurnoCrm' AND ITEM = 'N')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaTurnoCrm', 'N', '3')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaTurnoCrm' AND ITEM = 'I')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaTurnoCrm', 'I', '4')
  END
GO


-- --------------------------------------------------
-- Tabela Geral: Cadastra Depara Polo CRM
-- --------------------------------------------------
IF NOT EXISTS (SELECT TOP 1 1 FROM TABELA WHERE TAB = 'DeparaPoloCrm' AND SIS = 'Lyceum')
BEGIN
	INSERT INTO TABELA (TAB, SIS, DESCR) VALUES ('DeparaPoloCrm', 'Lyceum', 'Depara do Polo - Integração Lyceum x CRM')
END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaPoloCrm' AND ITEM = '3')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaPoloCrm', '3', 'POLO-FSA')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaPoloCrm' AND ITEM = '4')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaPoloCrm', '4', 'POLO-PAR')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaPoloCrm' AND ITEM = '5')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaPoloCrm', '5', 'POLO-VIC')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaPoloCrm' AND ITEM = '6')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaPoloCrm', '6', 'POLO-JEQ')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaPoloCrm' AND ITEM = '7')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaPoloCrm', '7', 'POLO-ITA')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaPoloCrm' AND ITEM = '20')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaPoloCrm', '20', 'POLO-SP')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaPoloCrm' AND ITEM = '21')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaPoloCrm', '21', 'POLO-JUA')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaPoloCrm' AND ITEM = '22')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaPoloCrm', '22', 'POLO-PET')
  END
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM ITEMTABELA WHERE TAB = 'DeparaPoloCrm' AND ITEM = '29')
  BEGIN
	INSERT INTO ITEMTABELA VALUES ('DeparaPoloCrm', '29', 'POLO-CEN')
  END
GO

-- --------------------------------------------------
-- Procedure: C_PR_INTEGRA_CRM_CONCURSO
-- --------------------------------------------------
IF DBO.fn_ExisteProcedure('C_PR_INTEGRA_CRM_CONCURSO') = 'S'
  BEGIN
	DROP PROCEDURE C_PR_INTEGRA_CRM_CONCURSO
  END
GO
CREATE PROCEDURE C_PR_INTEGRA_CRM_CONCURSO
(
	@P_CONCURSO VARCHAR(20)
	, @P_DESCRICAO VARCHAR(100)
	, @P_ANO INT
	, @P_SEMESTRE INT
	, @P_DATA_PROVA_CONCURSO DATETIME
	, @TIPO_CONCURSO VARCHAR(100)
)
AS
BEGIN
SET NOCOUNT ON 
BEGIN TRY
	BEGIN TRANSACTION
	 
	DECLARE @v_MSG_ERRO VARCHAR(MAX) 

	--Verifica se existe periodo letivo cadastrado
	IF NOT EXISTS (SELECT TOP 1 1 FROM LY_PERIODO_LETIVO WHERE ANO = @P_ANO AND PERIODO = @P_SEMESTRE)
	BEGIN
		SET @v_MSG_ERRO = 'Periodo letivo ' + ISNULL(CONVERT(VARCHAR(4), @P_ANO), '') + '/' + ISNULL(CONVERT(VARCHAR(4), @P_SEMESTRE), '') + ' não casdastrado'
		RAISERROR(@v_MSG_ERRO, 11, 1)
	END

	--Limpa a tabela de erros
	DELETE ZZCRO_ERROS
	WHERE SPID = @@SPID
	
	--Realiza o cadastro da Area na LY_AREA
	IF NOT EXISTS(SELECT TOP 1 1 FROM LY_AREA WHERE AREA = 'GERAL')
	BEGIN
		--Realiza o cadastro da Area
		EXEC Ly_area_Insert
			@area = 'GERAL'
			, @descricao = 'GERAL'

		--Busca os erros gerados
		EXEC GetErros 
			@v_MSG_ERRO OUTPUT

		--Verificar se houve algum erro
		IF @v_MSG_ERRO IS NOT NULL AND RTRIM(@v_MSG_ERRO) <> ''
		BEGIN
			RAISERROR(@v_MSG_ERRO, 11,1)
		END
	END
	
	--Realiza o cadastro da Area do Concurso
	IF NOT EXISTS(SELECT TOP 1 1 FROM LY_CONCURSO WHERE CONCURSO = @P_CONCURSO)
	BEGIN
		--Realiza o cadastro da Area do Concurso
		EXEC Ly_concurso_Insert	
			  @CONCURSO = @P_CONCURSO
			, @DESCRICAO = @P_DESCRICAO
			, @STATUS = 'Ativo'
			, @NUM_MAX_OPCOES = '1'
			, @ANO = @P_ANO
			, @SEMESTRE = @P_SEMESTRE
			, @TIPO_CLASSIFICACAO = 'Total de Pontos'
			, @CHAMADA_ATUAL = NULL
			, @TEM_BOLETO = 'N'
			, @BOLETO_BANCO = NULL
			, @BOLETO_AGENCIA = NULL
			, @BOLETO_CONTA_BANCO = NULL
			, @BOLETO_INSTRUCOES = NULL
			, @BOLETO_DIA_VENCIMENTO = NULL
			, @BOLETO_CARTEIRA = NULL
			, @BOLETO_ESPECIE_DOC = NULL
			, @BOLETO_ACEITE = NULL
			, @BOLETO_VALOR = '0'
			, @BOLETO_ESPECIE = NULL
			, @INSCR_ABERTA = 'N'
			, @PUBLIC_RESULT = 'N'
			, @PUBLIC_PROVA = 'N'
			, @DT_INICIO = NULL
			, @DT_FIM = NULL
			, @PUBLIC_SALA = 'N'
			, @ENTREGA_DOCS = 'N'
			, @INSTRUCOES_CONCURSO = NULL
			, @N_DIAS_VENC_BOL = NULL
			, @IGNORA_ORDEM_CHAMADA = 'S'
			, @NUM_DIG_COD = '1'
			, @BOLETO_CONVENIO = NULL
			, @RESTRINGE_LOCAL_PROVA = 'N'
			, @DT_VEST = @P_DATA_PROVA_CONCURSO
			, @EXIGIR_RESP_FINAN = 'N'
			, @INGR_MENS = NULL
			, @INGR_DTINI = NULL
			, @INGR_DTFIM = NULL
			, @INGR_BOL_DT_VENC = NULL
			, @DISPONIVEL_WEB = 'S'
			, @SIMULADO = 'N'
			, @UTILIZA_ENEM_VESTIB = 'N'
			, @TEM_PRE_INSCRICAO = 'N'
			, @AGENDADO = 'N'
			, @N_DIAS_VENC_BOL_MATR = NULL
			, @MATRICULA_AVULSA = 'N'
			, @PLANOPAG = NULL
			, @GRUPO_ENCARGO = NULL
			, @GRUPO_DESCONTO = NULL
			, @TEM_VAGA_REMANESC = 'N'
			, @GERA_COD_LOCALINSC = 'N'
			, @MIN_TOTPONTOS = NULL
			, @LASTNUMCAND = 0
			, @COLABORADOR_META = NULL
			, @TIPO_CONCURSO = NULL
			, @EXIGE_DOCINGRESSO = 'N'
			, @IMPRIMIR_REQUERIMENTO = 'N'
			, @MODELO_BOLETO =  NULL
			, @IDADE_MINIMA = NULL
			, @MSN_ENTREVISTA = NULL
			, @INGR_ENTURMA_PRE_MATR = 'N'
			, @EXIGE_LOCAL_PROVA = 'N'
			, @INGR_ESCOLHE_PLANO = 'N'
			, @INGR_MAX_RESP_FINAN = NULL
			, @AGENDAMENTO_MESMO_DIA = 'N'
			, @UNIDADE_RESPONSAVEL = NULL
			, @FACULDADE = NULL
			, @SUBPERIODO = NULL
			, @INGR_EXIGE_RESP_LEGAL = 'N'
			, @TIPO_QUESTIONARIO = NULL
			, @QUESTIONARIO = NULL
			, @APLICACAO = NULL
			, @INGR_VER_FINAN = 'N'
			, @TIPO_INGRESSO = 'Vestibular'
			, @AGENDAMENTO_PROVA = 'N'
			, @CONV_MANUAL_OUTRO_CURSO = 'N'
			, @PERMITE_TREINEIRO = 'N'
			, @EXIGE_NecEsp = 'N'
			, @PERMITE_RESP_ESTRANG = 'N'
			, @INSTRUCOES_VIA_EMAIL = NULL
			, @FL_FIELD_01 = @TIPO_CONCURSO
			, @FL_FIELD_02 = NULL
			, @FL_FIELD_03 = NULL
			, @FL_FIELD_04 = NULL
			, @FL_FIELD_05 = NULL
			, @FL_FIELD_06 = NULL
			, @FL_FIELD_07 = NULL
			, @FL_FIELD_08 = NULL
			, @FL_FIELD_09 = NULL
			, @FL_FIELD_10 = NULL
			, @MENSAGEM_CANDIDATO = NULL

		--Busca os erros gerados
		EXEC GetErros 
			@v_MSG_ERRO OUTPUT

		--Verificar se houve algum erro
		IF @v_MSG_ERRO IS NOT NULL AND RTRIM(@v_MSG_ERRO) <> ''
		BEGIN
			RAISERROR(@v_MSG_ERRO, 11,1)
		END
	END

	--Realiza o cadastro da Area Concurso
	IF NOT EXISTS(SELECT TOP 1 1 FROM LY_AREA_CONCURSO WHERE CONCURSO = @P_CONCURSO AND AREA = 'GERAL')
	BEGIN
		--Realiza o cadastro da Area Concurso
		EXEC LY_AREA_CONCURSO_INSERT
			@CONCURSO = @P_CONCURSO
			, @AREA = 'GERAL'

		--Busca os erros gerados
		EXEC GetErros 
			@v_MSG_ERRO OUTPUT

		--Verificar se houve algum erro
		IF @v_MSG_ERRO IS NOT NULL AND RTRIM(@v_MSG_ERRO) <> ''
		BEGIN
			RAISERROR(@v_MSG_ERRO, 11,1)
		END
	END
	
    --Realiza o cadastro do grupo de oferta
	IF NOT EXISTS(SELECT TOP 1 1 FROM LY_GRUPO_OFERTA WHERE GRUPO_OFERTA = 'PSeletivo')
	BEGIN
		EXEC Ly_grupo_oferta_Insert
			@GRUPO_OFERTA = 'PSeletivo'
			, @DESCRICAO = 'Grupo utilizado no Processo Seletivo'

		--Busca os erros gerados
		EXEC GetErros 
			@v_MSG_ERRO OUTPUT

		--Verificar se houve algum erro
		IF @v_MSG_ERRO IS NOT NULL AND RTRIM(@v_MSG_ERRO) <> ''
		BEGIN
			RAISERROR(@v_MSG_ERRO, 11,1)
		END
	END

    --Realiza o cadastro do sub grupo de oferta
	IF NOT EXISTS (
                   SELECT TOP 1 1 
                   FROM LY_SUB_GRUPO_OFERTA 
                   WHERE GRUPO_OFERTA = 'PSeletivo' 
                   AND ID_SUB_GRUPO_OFERTA = 1
                   AND SUB_GRUPO = 'PSeletivo'
                  )
    BEGIN
		--Realiza o cadastro do sub grupo de oferta
		SET IDENTITY_INSERT LY_SUB_GRUPO_OFERTA ON
		INSERT INTO LY_SUB_GRUPO_OFERTA 
		(
		ID_SUB_GRUPO_OFERTA, GRUPO_OFERTA, SUB_GRUPO, DESCRICAO, MSG_APROVACAO, MSG_DESCLASSIF_NOTA
		, MSG_DESCLASSIF_FALTA, MSG_LISTAESPERA, MSG_MATRICULA, LINK_MATRICULA, EXIGE_SENHA
		)     
		SELECT 1, 'PSeletivo', 'PSeletivo', 'Sub-Grupo utilizado no Processo Seletivo', NULL, NULL
		, NULL, NULL, NULL, NULL, NULL
		SET IDENTITY_INSERT LY_SUB_GRUPO_OFERTA OFF
    END
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF XACT_STATE() <> 0
	BEGIN
		ROLLBACK TRANSACTION;
	END;

	DECLARE 
		@ErrorMessage NVARCHAR(MAX)
		, @ErrorState INT
		, @ErrorSeverity INT

	SELECT 
		@ErrorMessage = ERROR_MESSAGE()
		, @ErrorState = ERROR_STATE()
		, @ErrorSeverity = ERROR_SEVERITY()

	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
SET NOCOUNT OFF
END
GO

-- --------------------------------------------------
-- Procedure: C_PR_INTEGRA_CRM_OFERTA
-- --------------------------------------------------
IF DBO.fn_ExisteProcedure('C_PR_INTEGRA_CRM_OFERTA') = 'S'
DROP PROCEDURE C_PR_INTEGRA_CRM_OFERTA
GO
CREATE PROCEDURE C_PR_INTEGRA_CRM_OFERTA
(
	@P_CONCURSO VARCHAR(20)
	, @P_OFERTA VARCHAR(200)
	, @P_CURSO VARCHAR(20)
	, @P_TURNO VARCHAR(20)
	, @P_CURRICULO VARCHAR(20)
	, @P_UNIDADE_FISICA VARCHAR(20)
	, @P_VAGAS INT
	, @P_ANO VARCHAR(100)
	, @P_PERIODO VARCHAR(100)
)
AS
BEGIN
SET NOCOUNT ON 
BEGIN TRY
	BEGIN TRANSACTION	
	DECLARE 
		@MsgErro VARCHAR(4000)
		, @DESCRICAO_ABREV T_ALFALARGE
		, @DESCRICAO_COMPL T_ALFAEXTRALARGE
		, @OFERTA T_NUMERO
		, @UNIDADE_FISICA T_CODIGO
		, @ANO T_ANO
		, @PERIODO T_SEMESTRE2

	IF (@P_ANO IS NOT NULL OR @P_PERIODO IS NOT NULL)
	BEGIN
		IF @P_ANO IS NULL
		BEGIN
			RAISERROR('Ano Letivo não pode ser nulo.', 11, 1)
		END
		ELSE IF @P_PERIODO IS NULL
		BEGIN
			RAISERROR('Periodo Letivo não pode ser nulo.', 11, 1)
		END
		ELSE IF NOT EXISTS
			(
				SELECT TOP 1 1 
				FROM LY_PERIODO_LETIVO
				WHERE CONVERT(VARCHAR(100), ANO) = @P_ANO
				AND CONVERT(VARCHAR(100), PERIODO) = @P_PERIODO
			)
		BEGIN
			RAISERROR('Ano|Periodo Letivo não cadastrado.', 11, 1)
		END
		ELSE 
		BEGIN
			SET @ANO = @P_ANO
			SET @PERIODO = @P_PERIODO
		END
	END

	--Depara do Turno
	SELECT @P_TURNO = ITEM
	FROM ITEMTABELA
	WHERE TAB = 'DeparaTurnoCrm'
	AND DESCR = @P_TURNO

	--Depara da unidade fisica
	DECLARE @TIPO_CURSO VARCHAR(40)
	
	SELECT @TIPO_CURSO = TIPO
	FROM LY_CURSO
	WHERE CURSO = @P_CURSO

	IF @TIPO_CURSO = 'GRADUACAO-EAD' AND @P_UNIDADE_FISICA = '30'
	BEGIN
	
	SELECT @UNIDADE_FISICA = DESCR
	FROM ITEMTABELA
	WHERE TAB = 'DeparaPoloCrm'
	AND ITEM = SUBSTRING(@P_CURSO,3,2)

	END	IF @TIPO_CURSO = 'GRADUACAO-SP' AND @P_UNIDADE_FISICA = '30'
	BEGIN

	SELECT @UNIDADE_FISICA = DESCR
	FROM ITEMTABELA
	WHERE TAB = 'DeparaPoloCrm'
	AND ITEM = SUBSTRING(@P_CURSO,4,2)

	END
	ELSE IF @P_UNIDADE_FISICA NOT IN ('30')
	BEGIN

	SELECT @UNIDADE_FISICA = UNIDADE_FIS
	FROM LY_UNIDADE_FISICA
	WHERE FL_FIELD_01 = @P_UNIDADE_FISICA

	END

	IF @P_TURNO IS NULL AND @P_TURNO IS NOT NULL
	BEGIN
		RAISERROR('Turno não encontrada.', 11, 1)
	END
	ELSE IF @UNIDADE_FISICA IS NULL AND @P_UNIDADE_FISICA IS NOT NULL
	BEGIN
		RAISERROR('Unidade Fisica não encontrada.', 11, 1)
	END
	ELSE IF NOT EXISTS (SELECT TOP 1 1 FROM LY_CURSO WHERE CURSO = @P_CURSO)
	BEGIN
		RAISERROR('Curso não encontrado.', 11, 1)
	END
					
	--Caso não exista Oferta de curso cadastradas
	IF NOT EXISTS(SELECT TOP 1 1 FROM LY_OFERTA_CURSO WHERE CONCURSO = @P_CONCURSO AND FL_FIELD_01 = @P_OFERTA AND ANO_INGRESSO = @ANO AND PER_INGRESSO = @PERIODO)
	BEGIN		
		SELECT 
			@DESCRICAO_ABREV = (SELECT NOME FROM LY_CURSO WHERE CURSO = @P_CURSO)
			, @DESCRICAO_COMPL = (SELECT NOME FROM LY_CURSO WHERE CURSO = @P_CURSO)

		IF @DESCRICAO_ABREV IS NULL
		BEGIN
			RAISERROR('Descrição abreviada do curso não encontrado.', 11, 1)
		END 
		ELSE IF @DESCRICAO_COMPL IS NULL
		BEGIN
			RAISERROR('Descrição completa do curso não encontrado.', 11, 1)
		END

		--Limpa a tabela de erros
		DELETE ZZCRO_ERROS
		WHERE SPID = @@SPID

		SELECT 
			@OFERTA = ISNULL((SELECT MAX(OFERTA_DE_CURSO) FROM LY_OFERTA_CURSO), 0) + 1

		--Cadastra a oferta de curso
		EXEC LY_OFERTA_CURSO_INSERT
		    @OFERTA_DE_CURSO = @OFERTA
			, @ID_SUB_GRUPO_OFERTA = 1
			, @CURSO = @P_CURSO
			, @TURNO = @P_TURNO
			, @CURRICULO = @P_CURRICULO
			, @ANO_INGRESSO = @ANO
			, @PER_INGRESSO = @PERIODO
			, @DTINI = NULL
			, @DTFIM = NULL
			, @DESCRICAO_ABREV = @DESCRICAO_ABREV
			, @DESCRICAO_COMPL = @DESCRICAO_COMPL
			, @CONCURSO = @P_CONCURSO
			, @CURSO_OFERTADO = @P_CURSO
			, @AREA = 'GERAL'
			, @VAGAS = @P_VAGAS
			, @MIN_GRUPO = NULL
			, @PERC_AJUSTE_VAGAS = NULL
			, @TIPO_PROC_SELETIVO = NULL
			, @TIPOOFERTA = NULL
			, @ULTIMA_CHAMADA = NULL
			, @SERIE = NULL
			, @VAGAS_REMANESC = NULL
			, @UNIDADE_FISICA = @UNIDADE_FISICA
			, @EXIBE_GRADE = 'N'
			, @MENSAGEM = NULL
			, @MAX_RESP_FINAN = NULL
			, @VALOR_INSCRICAO = NULL
			, @FACULDADE_CONVENIADA = NULL
			, @DTINI_INTERESSE = NULL
			, @DTFIM_INTERESSE = NULL
			, @MATRIC_TODAS_OPCOES = 'N'
			, @NAO_REALIZA_PRE_MATR = 'N'
			, @VALOR_A_VISTA_ESTIMADO = NULL
			, @SENHA = NULL
			, @MINIMO_INSCRICOES = NULL
			, @DISCIPLINA = NULL
			, @TURMA = NULL
			, @TURMA_PREF = NULL
			, @FL_FIELD_01 = @P_OFERTA
	
		--Busca os erros gerados
		EXEC GetErros 
			@MsgErro OUTPUT

		--Verificar se houve algum erro
		IF @MsgErro IS NOT NULL AND RTRIM(@MsgErro) <> ''
		BEGIN
			RAISERROR(@MsgErro, 11,1)
		END
	END		
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF XACT_STATE() <> 0
	BEGIN
		ROLLBACK TRANSACTION;
	END;

	DECLARE 
		@ErrorMessage NVARCHAR(MAX)
		, @ErrorState INT
		, @ErrorSeverity INT

	SELECT 
		@ErrorMessage = ERROR_MESSAGE()
		, @ErrorState = ERROR_STATE()
		, @ErrorSeverity = ERROR_SEVERITY()

	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
SET NOCOUNT OFF
END
GO

-- --------------------------------------------------
-- Procedure: C_PR_INTEGRA_CRM_CANDIDATO
-- --------------------------------------------------
IF DBO.fn_ExisteProcedure('C_PR_INTEGRA_CRM_CANDIDATO') = 'S'
DROP PROCEDURE C_PR_INTEGRA_CRM_CANDIDATO
GO
CREATE PROCEDURE C_PR_INTEGRA_CRM_CANDIDATO
 @p_Inscricao VARCHAR(20)
, @p_LinguaEstrangeira VARCHAR(20)
, @p_Trainee VARCHAR(100)
, @p_DataProva DATETIME
, @p_HoraProva VARCHAR(20)
, @p_SalaProva VARCHAR(100)
, @p_UnidadeProva VARCHAR(100)
, @p_CodConcurso VARCHAR(20)
, @p_NomeConcurso VARCHAR(100)
, @p_DesejaInformacoesSobreBolsas VARCHAR(20)
, @p_NecessidadesEspeciais VARCHAR(20)
, @p_NomeCompleto VARCHAR(100)
, @p_Cpf VARCHAR(14)
, @p_Email VARCHAR(100)
, @p_Celular VARCHAR(20)
, @p_Cep VARCHAR(20)
, @p_Endereco VARCHAR(50)
, @p_NumEndereco VARCHAR(20)
, @p_Bairro VARCHAR(50)
, @p_Cidade VARCHAR(50)
, @p_Uf VARCHAR(2)
, @p_VantagemAmiga VARCHAR(20)
AS
BEGIN
BEGIN TRY
	BEGIN TRANSACTION

	DECLARE 
		@MsgErro VARCHAR(4000)
		, @Pessoa NUMERIC(10,0)
		, @Candidato VARCHAR(20)
		, @nome_abrev VARCHAR(50) = SUBSTRING(@p_NomeCompleto, 1, 50)
		, @senha_tac VARCHAR(40)
		, @end_municipio varchar(10)
		, @end_compl varchar(200)

	SET @p_Cpf = RTRIM(REPLACE(REPLACE(@p_Cpf, '.', ''), '-', ''))
	SET @senha_tac = SUBSTRING(@p_Cpf,1,9)
	SET @p_Cep = RTRIM(REPLACE(REPLACE(@p_Cep, '.', ''), '-', ''))
	
	IF @p_Cep IS NULL OR @p_Cep = '' OR LEN(@p_Cep) > 8
	BEGIN
		SET @p_Cep = '00000000'
	END

	IF @p_Endereco IS NULL OR @p_Endereco = '' 
	BEGIN
		SET @p_Endereco = '[Não informado]'
	END
	
	IF @p_NumEndereco IS NULL
	BEGIN
		SET @p_NumEndereco = '00'
	END
	ELSE IF LEN(@p_NumEndereco) > 15
	BEGIN
		SET @end_compl = @p_NumEndereco
		SET @p_NumEndereco = '00'
	END

	SELECT 
		@Pessoa = Pessoa
		, @Candidato = Candidato
	FROM C_INTEGRA_CRM_LYCEUM
	WHERE Inscricao = @p_Inscricao

	--Busca o municipio do endereco
	SELECT @end_municipio = MUNICIPIO
	FROM HD_MUNICIPIO HD
	WHERE UF = @p_Uf
	AND NOME = @p_Cidade

	--Insere o Municipio default caso não exista cadastrado no Lyceum
	IF @end_municipio IS NULL
	BEGIN
		SELECT @end_municipio = MUNICIPIO
		FROM HD_MUNICIPIO HD
		WHERE MUNICIPIO = '00000'
	END		

	--Busca pessoa por CPF
	IF @Pessoa IS NULL
	BEGIN		
		SELECT @Pessoa = PESSOA
		FROM LY_PESSOA
		WHERE CPF = @p_Cpf
	END

	--Busca candidato
	IF @Candidato IS NULL
	BEGIN
		SELECT @Candidato = CANDIDATO
		FROM LY_CANDIDATO
		WHERE CANDIDATO = @p_Inscricao
	END
	
	--Limpa a tabela de erros
	DELETE ZZCRO_ERROS
	WHERE SPID = @@SPID

	--Cria pessoa caso não exista
	IF @Pessoa IS NULL
	BEGIN
		--Gera o id da pessoa
		SELECT
			 @Pessoa = ISNULL(MAX(PESSOA), 0) + 1 
		FROM LY_PESSOA WITH(NOLOCK)

		--Executa a procedure de insert
		EXEC Ly_pessoa_Insert
			@pessoa = @Pessoa
			, @nome_compl = @p_NomeCompleto
			, @nome_abrev = @nome_abrev
			, @end_correto = 'S'
			, @sexo = 'M'
			, @endereco = @p_Endereco
			, @end_num = @p_NumEndereco
			, @end_compl = @end_compl
			, @bairro = @p_Bairro
			, @end_municipio = @end_municipio
			, @cep = @p_Cep
			, @fone = @p_Celular
			, @cpf = @p_Cpf
			, @e_mail = @p_Email
			, @obs = @p_Inscricao
			, @senha_tac = @senha_tac
			, @celular = @p_Celular		
			, @divida_biblio = 'N'

		--Busca os erros gerados
		EXEC GetErros 
			@MsgErro OUTPUT

		--Verificar se houve algum erro
		IF @MsgErro IS NOT NULL AND RTRIM(@MsgErro) <> ''
		BEGIN
			RAISERROR(@MsgErro, 11,1)
		END
	END

	IF @Candidato IS NULL
	BEGIN
		--Realiza o cadastro caso a lingua não estaja cadastradas
		IF @p_LinguaEstrangeira IS NOT NULL 
		AND NOT EXISTS
			(
				SELECT TOP 1 1
				FROM LY_LINGUA_VEST
				WHERE LINGUA = @p_LinguaEstrangeira
			)
		BEGIN
			EXEC Ly_lingua_vest_Insert
				@lingua = @p_LinguaEstrangeira
				, @descricao = @p_LinguaEstrangeira

			--Busca os erros gerados
			EXEC GetErros 
				@MsgErro OUTPUT

			--Verificar se houve algum erro
			IF @MsgErro IS NOT NULL AND RTRIM(@MsgErro) <> ''
			BEGIN
				RAISERROR(@MsgErro, 11,1)
			END
		END
			
		SET @Candidato = @p_Inscricao
		
		--Executa a procedure de insert
		EXEC LY_CANDIDATO_INSERT
			@concurso = @p_CodConcurso
			, @candidato = @p_Inscricao
			, @lingua = @p_LinguaEstrangeira
			, @area = 'GERAL'
			, @nome_compl = @p_NomeCompleto
			, @nome_abrev = @nome_abrev
			, @sexo = 'M'
			, @estado_civil = 'Não informado'
			, @endereco = @p_Endereco
			, @end_num = @p_NumEndereco
			, @end_compl = @end_compl
			, @bairro = @p_Bairro
			, @municipio = @end_municipio
			, @cep = @p_Cep
			, @fone = @p_Celular
			, @curso_superior='N'
			, @fumante='N'
			, @canhoto='N'
			, @e_mail = @p_Email
			, @inscr_internet='N'
			, @sit_candidato_vest = 'Confirmado'
			, @senha_web = @senha_tac
			, @boleto_pago = 'N'
			, @cpf = @p_CPF
			, @necessidade_especial = @p_NecessidadesEspeciais
			, @obs = @p_Inscricao
			, @cpf_proprio = 'S'
			, @tipo_ingresso = 'Vestibular'
			, @doc_entregue = 'N'
			, @isento = 'N'
			, @pessoa = @Pessoa

		--Busca os erros gerados
		EXEC GetErros 
			@MsgErro OUTPUT

		--Verificar se houve algum erro
		IF @MsgErro IS NOT NULL AND RTRIM(@MsgErro) <> ''
		BEGIN
			RAISERROR(@MsgErro, 11,1)
		END
	END

	IF @Candidato IS NULL
	BEGIN
		RAISERROR('Não foi possivel gerar o candidato.', 11, 1)
	END
	ELSE IF @Pessoa IS NULL
	BEGIN
		RAISERROR('Não foi possivel gerar a pessoa.', 11, 1)
	END
	ELSE IF NOT EXISTS
		(
			SELECT TOP 1 1
			FROM C_INTEGRA_CRM_LYCEUM
			WHERE Inscricao = @p_Inscricao
		)	
	BEGIN
		INSERT INTO C_INTEGRA_CRM_LYCEUM (Inscricao, Candidato, Pessoa, Concurso) VALUES (@p_Inscricao, @Candidato, @Pessoa, @p_CodConcurso)
	END
	
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF XACT_STATE() <> 0
	BEGIN
		ROLLBACK TRANSACTION;
	END;

	DECLARE 
		@ErrorMessage NVARCHAR(MAX)
		, @ErrorState INT
		, @ErrorSeverity INT

	SELECT 
		@ErrorMessage = ERROR_MESSAGE()
		, @ErrorState = ERROR_STATE()
		, @ErrorSeverity = ERROR_SEVERITY()

	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
END
GO

-- --------------------------------------------------
-- Procedure: C_PR_INTEGRA_CRM_CONVOCADOS_VEST
-- --------------------------------------------------
IF DBO.fn_ExisteProcedure('C_PR_INTEGRA_CRM_CONVOCADOS_VEST') = 'S'
DROP PROCEDURE C_PR_INTEGRA_CRM_CONVOCADOS_VEST
GO
CREATE PROCEDURE C_PR_INTEGRA_CRM_CONVOCADOS_VEST
(
	@Inscricao T_CODIGO
	, @SituacaoConcurso T_ALFALARGE
	, @Concurso T_CODIGO
	, @Ordem INT
	, @Ano T_ANO
	, @Periodo T_SEMESTRE2
	, @CategoriaNome T_ALFALARGE
	, @CodCampus T_ALFALARGE
	, @CodCurriculo T_ALFALARGE
	, @CodCurso T_ALFALARGE
	, @CodEscola T_ALFALARGE
	, @CodFormaIngr T_ALFALARGE
	, @CodSubFormaIngr T_ALFALARGE
	, @CodTurno T_ALFALARGE
	, @CurrEquiv T_ALFALARGE
	, @DataFinal T_DATA
	, @DataInicial T_DATA
	, @IdOferta T_ALFALARGE
	, @MinimoDeVagasPreenchidas INT
	, @Nome T_ALFALARGE
	, @NomeConcurso T_ALFALARGE
	, @QuantidadeVagas INT
	, @Regime T_ALFALARGE
	, @VagasDisponiveis INT
	, @VagasDisponiveisSGA INT
	, @numChamada INT
)
AS
SET NOCOUNT ON
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @MsgErro VARCHAR(4000)
		DECLARE @IdConvocacao INT
		DECLARE @v_CONCURSO T_CODIGO
		DECLARE @v_CURSO T_CODIGO
		DECLARE @v_OFERTA_CURSO T_NUMERO

		SELECT 
			@v_CONCURSO = CONCURSO
			, @v_CURSO = CURSO_OFERTADO
			, @v_OFERTA_CURSO = OFERTA_DE_CURSO
		FROM LY_OFERTA_CURSO
		WHERE FL_FIELD_01 = @IdOferta

		IF @v_OFERTA_CURSO IS NULL
		BEGIN
			--Gera erro
			RAISERROR('Oferta de curso não encontrada.', 11, 1)
		END
		ELSE IF @v_CURSO IS NULL
		BEGIN
			--Gera erro
			RAISERROR('Curso não encontrado.', 11, 1)
		END
		ELSE IF @v_CONCURSO IS NULL
		BEGIN
			--Gera erro
			RAISERROR('Concurso não encontrado.', 11, 1)
		END
		
		--Só será utilizado a primeira opcao do candidato, o candidato não esteja matriculado e a situacao seja igual a aprovado e convocado
		IF @Ordem = 1 
		AND NOT EXISTS
			(
				SELECT  TOP 1 1
				FROM LY_CONVOCADOS_VEST C				
				WHERE C.CANDIDATO = @Inscricao
				AND MATRICULADO = 'S'
			)
		AND @SituacaoConcurso in ('Aprovado', 'Convocado')
		BEGIN
			--Limpa a tabela de erros
			DELETE ZZCRO_ERROS
			WHERE SPID = @@SPID
		
			--Caso não exista a opcao do candidato no curso
			IF NOT EXISTS
				(
					SELECT TOP 1 1
					FROM LY_OPCOES_PROC_SELETIVO OP
					WHERE OP.OFERTA_DE_CURSO = @v_OFERTA_CURSO
					AND OP.CANDIDATO = @Inscricao
					AND OP.ORDEM = @Ordem
				)		
			BEGIN
				--Insere dados da opcao do processo seletivo
				EXEC LY_OPCOES_PROC_SELETIVO_INSERT
					@id_opcoes_p_seletivo = NULL
					, @oferta_de_curso = @v_OFERTA_CURSO
					, @concurso = @v_CONCURSO
					, @candidato = @Inscricao
					, @ordem = @Ordem

				--Busca os erros gerados
				EXEC GetErros 
					@MsgErro OUTPUT

				--Verificar se houve algum erro
				IF @MsgErro IS NOT NULL AND RTRIM(@MsgErro) <> ''
				BEGIN
					--Gera erro
					RAISERROR(@MsgErro, 11,1)
				END			
			END
			
			--Caso ja exista convocacao para outro curso deve-se remover os registros
			IF EXISTS
				(
					SELECT TOP 1 1
					FROM LY_CONVOCADOS_VEST C				
					WHERE C.CANDIDATO = @Inscricao
					AND (C.CURSO_VEST <> @v_CURSO OR C.CONCURSO <> @v_CONCURSO OR C.CHAMADA <> @numChamada)
				)
			BEGIN
				--Remove os dados de convocacao
				DELETE C
				FROM LY_CONVOCADOS_VEST C
				WHERE C.CANDIDATO = @Inscricao
			END

			IF NOT EXISTS
				(
					SELECT TOP 1 1
					FROM LY_CONVOCADOS_VEST C				
					WHERE C.CANDIDATO = @Inscricao
				)
			BEGIN
				--Executa cadastro da convocacao do vestibular
				EXEC LY_CONVOCADOS_VEST_INSERT
					@concurso = @v_CONCURSO
					, @curso_vest = @v_CURSO
					, @candidato = @Inscricao
					, @chamada = @numChamada
					, @matriculado = 'N'
					, @ordem = @Ordem
					, @ajuste_vagas = 'N'

				--Busca os erros gerados
				EXEC GetErros 
					@MsgErro OUTPUT

				--Verificar se houve algum erro
				IF @MsgErro IS NOT NULL AND RTRIM(@MsgErro) <> ''
				BEGIN
					--Gera erro
					RAISERROR(@MsgErro, 11,1)
				END
			END

			--Verifica se o existe dados na tabela integracao de controle de convocacao
			SELECT 
				@IdConvocacao = IdConvocacao
			FROM C_INTEGRA_CRM_LYCEUM_VEST
			WHERE Candidato = @Inscricao
			AND Oferta_de_curso = @v_OFERTA_CURSO
			AND Chamada = @numChamada
			AND Ordem = @Ordem

			--Caso não exista dados na tabela integracao de controle de convocacao
			IF @IdConvocacao IS NULL
			BEGIN
				--Insere dados na tabela integracao de controle de convocacao
				INSERT INTO C_INTEGRA_CRM_LYCEUM_VEST (Candidato, Concurso, Oferta_de_curso, Chamada, Ordem
					, Ano, Periodo, CodCampus, CodCurriculo, CodCurso, CodEscola, CodTurno, Regime, SituacaoConcurso) VALUES
				(@Inscricao, @v_CONCURSO, @v_OFERTA_CURSO, @numChamada, @Ordem, @Ano, @Periodo, @CodCampus, @CodCurriculo
					, @CodCurso, @CodEscola, @CodTurno, @Regime, @SituacaoConcurso)
			END
		END

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		DECLARE 
			@ErrorMessage NVARCHAR(MAX)
			, @ErrorState INT
			, @ErrorSeverity INT

		SELECT 
			@ErrorMessage = ERROR_MESSAGE()
			, @ErrorState = ERROR_STATE()
			, @ErrorSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
	END CATCH
END
GO

-- --------------------------------------------------
-- Trigger: C_TG_CAP_EVENTO_LY_CONVOCADOS_VEST
-- --------------------------------------------------
IF DBO.fn_ExisteTrigger('C_TG_CAP_EVENTO_LY_CONVOCADOS_VEST') = 'S'
  BEGIN
	DROP TRIGGER C_TG_CAP_EVENTO_LY_CONVOCADOS_VEST
  END
GO
CREATE TRIGGER C_TG_CAP_EVENTO_LY_CONVOCADOS_VEST ON LY_CONVOCADOS_VEST AFTER UPDATE
AS
BEGIN
	-- Variaveis
	DECLARE @ACAO VARCHAR(1)
	DECLARE @CHAVE_OBJETO_1 varchar(30)
	DECLARE @CHAVE_OBJETO_2 varchar(30)
	DECLARE @CHAVE_OBJETO_3 varchar(30)
	DECLARE @CHAVE_OBJETO_4 varchar(30)
	DECLARE @CHAVE_OBJETO_5 varchar(30)

	-- Definindo a operacao que foi feita
	SELECT @ACAO = 'U'

	-- Buscando valores da chave da tabela	
	SELECT 
		@CHAVE_OBJETO_1 = CONCURSO,
		@CHAVE_OBJETO_2 = CURSO_VEST,
		@CHAVE_OBJETO_3 = CANDIDATO,
		@CHAVE_OBJETO_4 = MATRICULADO
	FROM INSERTED

	--Somente deve inserir na tabela de integracao os candidatos matriculados
	IF @CHAVE_OBJETO_4 = 'S'
	AND NOT EXISTS (SELECT TOP 1 1 FROM LY_INTEGRACAO_FILA_EVENTOS WHERE @CHAVE_OBJETO_1 = CHAVE_1 AND SISTEMA_DESTINO = 'FTC - CRM' AND SISTEMA_DESTINO = 'LY_CONVOCADOS_VEST')
	AND EXISTS (SELECT TOP 1 1 FROM C_INTEGRA_CRM_LYCEUM WHERE Candidato = @CHAVE_OBJETO_3)
	BEGIN
		-- Gravando na tabela de integracao	
		INSERT INTO LY_INTEGRACAO_FILA_EVENTOS (DATA_INCLUSAO, SISTEMA_DESTINO, OBJETO, OPERACAO, CHAVE_1, CHAVE_2, CHAVE_3, CHAVE_4)
		VALUES (GETDATE(), 'FTC - CRM', 'LY_CONVOCADOS_VEST', @ACAO, @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4)
	END
END
GO

-- --------------------------------------------------
-- Trigger: C_TG_CAP_EVENTO_LY_PRE_MATRICULA
-- --------------------------------------------------
IF DBO.fn_ExisteTrigger('C_TG_CAP_EVENTO_LY_PRE_MATRICULA') = 'S'
BEGIN
	DROP TRIGGER C_TG_CAP_EVENTO_LY_PRE_MATRICULA
END
GO

-- Trigger: C_TG_CAP_EVENTO_LY_PRE_MATRICULA
-- Data de Criação: Dezembro de 2017
-- Descrição: Esta trigger tem como objetivo preencher a LY_INTEGRACAO_FILA_EVENTOS.
--			  Ao preencher esta tabela, os dados serão utilizados na integração com outros sistemas
CREATE TRIGGER C_TG_CAP_EVENTO_LY_PRE_MATRICULA ON LY_PRE_MATRICULA 
AFTER INSERT  
AS  
BEGIN  
	-- Variaveis  
	DECLARE @ACAO                          VARCHAR(1)  
	DECLARE @CHAVE_OBJETO_1                VARCHAR(30)  
	DECLARE @CHAVE_OBJETO_2                VARCHAR(30)  
	DECLARE @CHAVE_OBJETO_3                VARCHAR(30)  
	DECLARE @CHAVE_OBJETO_4                VARCHAR(30)  
	DECLARE @CHAVE_OBJETO_5                VARCHAR(30)  
	DECLARE @EXISTE_CANDIDATO_PREMATRICULA INT
	DECLARE @EXISTE_PREMATRICULA_FILA      INT

	IF (EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED))
	BEGIN
		SET @ACAO = 'U'  
	END
	ELSE IF (EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED))
	BEGIN
		SET @ACAO = 'I'  
	END
	ELSE IF (NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED))
	BEGIN
		SET @ACAO = 'D' 
	END	
	 
	-- Buscando valores da chave da tabela   
	SELECT @CHAVE_OBJETO_1 = ALUNO  
	     , @CHAVE_OBJETO_2 = DISCIPLINA  
	     , @CHAVE_OBJETO_3 = ANO  
	     , @CHAVE_OBJETO_4 = SEMESTRE  
	     , @CHAVE_OBJETO_5 = CHAVE  
	FROM INSERTED  
	 
	--Somente deve inserir na tabela de integracao os candidatos matriculados  

	SELECT DISTINCT @EXISTE_CANDIDATO_PREMATRICULA = COUNT(1)
	FROM LY_PRE_MATRICULA pm 
	INNER JOIN LY_ALUNO a ON pm.ALUNO = a.ALUNO
	WHERE pm.ALUNO = @CHAVE_OBJETO_1
	AND   pm.DISCIPLINA = @CHAVE_OBJETO_2
	AND   pm.ANO = @CHAVE_OBJETO_3
	AND   pm.SEMESTRE = @CHAVE_OBJETO_4
	AND   pm.CHAVE = @CHAVE_OBJETO_5
	AND   a.CANDIDATO IS NOT NULL

	IF (@EXISTE_CANDIDATO_PREMATRICULA > 0)
	BEGIN  
		-- Gravando na tabela de integração   
		SELECT DISTINCT @EXISTE_PREMATRICULA_FILA = COUNT(1)
	    FROM LY_INTEGRACAO_FILA_EVENTOS ife 
	    WHERE ife.CHAVE_1 = @CHAVE_OBJETO_1
	  --  AND   ife.CHAVE_2 = @CHAVE_OBJETO_2
	    AND   ife.CHAVE_3 = @CHAVE_OBJETO_3
	    AND   ife.CHAVE_4 = @CHAVE_OBJETO_4
	 --   AND   ife.CHAVE_5 = @CHAVE_OBJETO_5
	    AND   SISTEMA_DESTINO = 'FTC - CRM' 
	    AND   OBJETO = 'LY_PRE_MATRICULA'

		IF (@EXISTE_PREMATRICULA_FILA = 0)
		BEGIN  
			-- Gravando na tabela de integração   
			INSERT INTO LY_INTEGRACAO_FILA_EVENTOS (DATA_INCLUSAO, SISTEMA_DESTINO, OBJETO, OPERACAO, CHAVE_1, CHAVE_2, CHAVE_3, CHAVE_4, CHAVE_5)  
			VALUES (GETDATE(), 'FTC - CRM', 'LY_PRE_MATRICULA', @ACAO, @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4, @CHAVE_OBJETO_5)  
		END  
	END
END  
GO

-- --------------------------------------------------
-- Trigger: C_TG_CAP_EVENTO_LY_ITEM_CRED
-- --------------------------------------------------
IF DBO.fn_ExisteTrigger('C_TG_CAP_EVENTO_LY_ITEM_CRED') = 'S'
BEGIN
	DROP TRIGGER C_TG_CAP_EVENTO_LY_ITEM_CRED
END
GO

-- Trigger: C_TG_CAP_EVENTO_LY_ITEM_CRED
-- Data de Criação: Dezembro de 2017
-- Descrição: Esta trigger tem como objetivo preencher a LY_INTEGRACAO_FILA_EVENTOS.
--			  Ao preencher esta tabela, os dados serão utilizados na integração com outros sistemas
CREATE TRIGGER C_TG_CAP_EVENTO_LY_ITEM_CRED ON LY_ITEM_CRED 
AFTER INSERT  
AS  
BEGIN  
	-- Variaveis  
	DECLARE @ACAO                         VARCHAR(1)  
	DECLARE @CHAVE_OBJETO_1               VARCHAR(30)  
	DECLARE @CHAVE_OBJETO_2               VARCHAR(30) 
	DECLARE @CHAVE_OBJETO_3               VARCHAR(30) 
	DECLARE @CHAVE_OBJETO_4               VARCHAR(30) 
	DECLARE @LANC_CRED                    VARCHAR(30) 
	DECLARE @ITEMCRED                     VARCHAR(30) 
	DECLARE @PRIMEIRA_PARCELA_E_CANDIDATO INT
	DECLARE @EXISTE_ITEM_CRED_FILA        INT 
	DECLARE @ALUNO                        VARCHAR(30) 
	DECLARE @COBRANCA                     NUMERIC(10,2)
	DECLARE @LANC_DEB                     NUMERIC(10,2)
	DECLARE @ALUNO_PRE_MATRICULADO        INT
	 
	-- Definindo a operacao que foi feita  
	SELECT @ACAO = 'I'  
	 
	-- Buscando valores da chave da tabela   
	SELECT @COBRANCA = COBRANCA
	FROM INSERTED

	--Cobrança paga
	SELECT DISTINCT @ALUNO = ALUNO
	FROM VW_COBRANCA c
	WHERE c.COBRANCA = @COBRANCA
	AND   VALOR = 0
	

	IF (@ALUNO IS NOT NULL) 
	BEGIN
		--
		SELECT DISTINCT @LANC_DEB = LANC_DEB
		FROM LY_ITEM_LANC
		WHERE COBRANCA = @COBRANCA

		
		SELECT @ALUNO_PRE_MATRICULADO = COUNT(1)
		FROM LY_PRE_MATRICULA pm
		WHERE pm.ALUNO = @ALUNO
		AND   pm.LANC_DEB = @LANC_DEB

		IF (@ALUNO_PRE_MATRICULADO > 0)
		BEGIN
			--Ficou acordado entre o Raul e a Instituição que os códigos de aluno do CRM devem ser os mesmos códigos do Lyceum
			SELECT DISTINCT @CHAVE_OBJETO_1 = iclv.CONCURSO
						  , @CHAVE_OBJETO_2 = iclv.CODCURSO
						  , @CHAVE_OBJETO_3 = iclv.CANDIDATO
						  , @CHAVE_OBJETO_4 = iclv.CHAMADA
			FROM LY_ALUNO a
			INNER JOIN C_INTEGRA_CRM_LYCEUM_VEST iclv ON a.CONCURSO = iclv.CONCURSO AND a.CANDIDATO = iclv.CANDIDATO --AND a.CURSO = iclv.CODCURSO		
			WHERE a.ALUNO = @ALUNO


			--Candidato pré-matriculado com a primeira parcela paga
			IF (@CHAVE_OBJETO_1 IS NOT NULL AND @CHAVE_OBJETO_2 IS NOT NULL AND @CHAVE_OBJETO_3 IS NOT NULL AND @CHAVE_OBJETO_4 IS NOT NULL) 
			BEGIN
				SELECT DISTINCT @EXISTE_ITEM_CRED_FILA = COUNT(1)
				FROM LY_INTEGRACAO_FILA_EVENTOS ife 
				WHERE ife.CHAVE_1 = @CHAVE_OBJETO_1
				AND   ife.CHAVE_2 = @CHAVE_OBJETO_2
				AND   ife.CHAVE_3 = @CHAVE_OBJETO_3
				AND   ife.CHAVE_4 = @CHAVE_OBJETO_4
				AND   ife.SISTEMA_DESTINO = 'FTC - CRM' 
				AND   ife.OBJETO = 'LY_ITEM_CRED'

				IF (@EXISTE_ITEM_CRED_FILA = 0)
				BEGIN  
					-- Gravando na tabela de integração   
					INSERT INTO LY_INTEGRACAO_FILA_EVENTOS (DATA_INCLUSAO, SISTEMA_DESTINO, OBJETO, OPERACAO, CHAVE_1, CHAVE_2, CHAVE_3, CHAVE_4)  
					VALUES (GETDATE(), 'FTC - CRM', 'LY_ITEM_CRED', @ACAO, @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4)  
				END  
			END
		END
	END
END  
GO
ALTER TABLE [dbo].[LY_ITEM_CRED] ENABLE TRIGGER [C_TG_CAP_EVENTO_LY_ITEM_CRED]
GO


-- Trigger: C_TG_CAP_EVENTO_LY_COBRANCA
-- Data de Criação: Maio de 2018
-- Descrição: Esta trigger tem como objetivo preencher a LY_INTEGRACAO_FILA_EVENTOS.
--			  Ao preencher esta tabela, os dados serão utilizados na integração com outros sistemas
CREATE TRIGGER C_TG_CAP_EVENTO_LY_COBRANCA
   ON  LY_COBRANCA 
   AFTER UPDATE
AS 
BEGIN

	-- Variaveis  
	DECLARE @ACAO                         VARCHAR(1)  
	DECLARE @CHAVE_OBJETO_1               VARCHAR(30)  
	DECLARE @CHAVE_OBJETO_2               VARCHAR(30) 
	DECLARE @CHAVE_OBJETO_3               VARCHAR(30) 
	DECLARE @CHAVE_OBJETO_4               VARCHAR(30) 
	DECLARE @PRIMEIRA_PARCELA_E_CANDIDATO INT
	DECLARE @EXISTE_COBRANCA_FILA         INT 
	DECLARE @ALUNO                        VARCHAR(30) 
	DECLARE @COBRANCA                     NUMERIC(10,2)
	DECLARE @LANC_DEB                     NUMERIC(10,2)
	DECLARE @ALUNO_PRE_MATRICULADO        INT
	DECLARE @DT_FATURAMENTO_OLD			  T_DATA
	DECLARE @DT_FATURAMENTO				  T_DATA

	SELECT @DT_FATURAMENTO_OLD = DATA_DE_FATURAMENTO
	FROM DELETED
	
	SELECT @DT_FATURAMENTO = DATA_DE_FATURAMENTO
	FROM INSERTED
	 
	IF @DT_FATURAMENTO_OLD IS NULL AND @DT_FATURAMENTO IS NOT NULL
	BEGIN
	-- Definindo a operacao que foi feita  
		SELECT @ACAO = 'U'  
	 
		-- Buscando valores da chave da tabela   
		SELECT @COBRANCA = COBRANCA
		FROM INSERTED

		-- Se ao faturar a cobrança já estiver paga (valor a pagar = 0 ) o CRM deverá receber o aviso de matricula
		-- Isso vai ocorrer, por exemplo, quando o aluno possuir uma bolsa de 100%
		-- Quando a cobrança não estiver paga (valor a pagar > 0 ) o CRM só receberá o aviso de matricula no pagamento da cobrança (LY_ITEM_CRED).
		SELECT DISTINCT @ALUNO = ALUNO
		FROM VW_COBRANCA c
		WHERE c.COBRANCA = @COBRANCA
		AND   VALOR <= 0
	
		IF (@ALUNO IS NOT NULL) 
		BEGIN
			--
			SELECT DISTINCT @LANC_DEB = LANC_DEB
			FROM LY_ITEM_LANC
			WHERE COBRANCA = @COBRANCA

		
			SELECT @ALUNO_PRE_MATRICULADO = COUNT(1)
			FROM LY_PRE_MATRICULA pm
			WHERE pm.ALUNO = @ALUNO
			AND   pm.LANC_DEB = @LANC_DEB

			IF (@ALUNO_PRE_MATRICULADO > 0)
			BEGIN
				--Ficou acordado entre o Raul e a Instituição que os códigos de aluno do CRM devem ser os mesmos códigos do Lyceum
				SELECT DISTINCT @CHAVE_OBJETO_1 = iclv.CONCURSO
							  , @CHAVE_OBJETO_2 = iclv.CODCURSO
							  , @CHAVE_OBJETO_3 = iclv.CANDIDATO
							  , @CHAVE_OBJETO_4 = iclv.CHAMADA
				FROM LY_ALUNO a
				INNER JOIN C_INTEGRA_CRM_LYCEUM_VEST iclv ON a.CONCURSO = iclv.CONCURSO AND a.CANDIDATO = iclv.CANDIDATO --AND a.CURSO = iclv.CODCURSO		
				WHERE a.ALUNO = @ALUNO


				--Candidato pré-matriculado com a primeira parcela paga
				IF (@CHAVE_OBJETO_1 IS NOT NULL AND @CHAVE_OBJETO_2 IS NOT NULL AND @CHAVE_OBJETO_3 IS NOT NULL AND @CHAVE_OBJETO_4 IS NOT NULL) 
				BEGIN
					SELECT DISTINCT @EXISTE_COBRANCA_FILA = COUNT(1)
					FROM LY_INTEGRACAO_FILA_EVENTOS ife 
					WHERE ife.CHAVE_1 = @CHAVE_OBJETO_1
					AND   ife.CHAVE_2 = @CHAVE_OBJETO_2
					AND   ife.CHAVE_3 = @CHAVE_OBJETO_3
					AND   ife.CHAVE_4 = @CHAVE_OBJETO_4
					AND   ife.SISTEMA_DESTINO = 'FTC - CRM' 
					AND   ife.OBJETO = 'LY_COBRANCA'

					IF (@EXISTE_COBRANCA_FILA = 0)
					BEGIN  
						-- Gravando na tabela de integração   
						INSERT INTO LY_INTEGRACAO_FILA_EVENTOS (DATA_INCLUSAO, SISTEMA_DESTINO, OBJETO, OPERACAO, CHAVE_1, CHAVE_2, CHAVE_3, CHAVE_4)  
						VALUES (GETDATE(), 'FTC - CRM', 'LY_COBRANCA', @ACAO, @CHAVE_OBJETO_1, @CHAVE_OBJETO_2, @CHAVE_OBJETO_3, @CHAVE_OBJETO_4)  
					END  
				END
			END
		END
	END
END
GO
ALTER TABLE [dbo].[LY_COBRANCA] ENABLE TRIGGER C_TG_CAP_EVENTO_LY_COBRANCA
GO


-- --------------------------------------------------
-- View: C_VW_INTEG_CRM_CONVOCAMATR
-- --------------------------------------------------
IF DBO.fn_ExisteView('C_VW_INTEG_CRM_CONVOCAMATR') = 'S'
  BEGIN
	DROP VIEW C_VW_INTEG_CRM_CONVOCAMATR
  END
GO
CREATE VIEW C_VW_INTEG_CRM_CONVOCAMATR
AS
SELECT 
	I.ID_FILA_EVENTOS
	, L.Candidato														AS Inscricao
	, I.DATA_INCLUSAO													AS DataMatricula
	, L.CodEscola														AS CodEscola
	, L.Ano																AS Ano
	, L.Regime															AS Regime
	, L.Periodo															AS Periodo
	, L.CodCurso														AS Curso
	, L.CodCurriculo													AS Curriculo
	, L.CodCampus														AS CodCampus
	, L.CodTurno														AS CodTurno
	, (SELECT TOP 1 1 FROM LY_BOLSA B WHERE B.ALUNO = A.ALUNO)			AS Bolsa
FROM LY_INTEGRACAO_FILA_EVENTOS I
INNER JOIN C_INTEGRA_CRM_LYCEUM_VEST L
	ON L.Candidato = I.CHAVE_3
	AND L.CodCurso = I.CHAVE_2
	AND L.Concurso = I.CHAVE_1
LEFT JOIN LY_ALUNO A
	ON A.CANDIDATO = L.Candidato
WHERE I.SISTEMA_DESTINO = 'FTC - CRM'
AND I.OBJETO = 'LY_CONVOCADOS_VEST'
AND I.DATA_INTEGRACAO IS NULL
AND I.DATA_ERRO IS NULL
AND ISNULL(I.IGNORAR, 'N') = 'N'
GO

-- --------------------------------------------------
-- View: C_VW_INTEG_CRM_AVISAPREMATR
-- --------------------------------------------------
IF DBO.fn_ExisteView('C_VW_INTEG_CRM_AVISAPREMATR') = 'S'
  BEGIN
	DROP VIEW C_VW_INTEG_CRM_AVISAPREMATR
  END
GO
CREATE VIEW C_VW_INTEG_CRM_AVISAPREMATR
AS
	SELECT ife.ID_FILA_EVENTOS  
	     , a.CANDIDATO AS Inscricao  
	FROM LY_INTEGRACAO_FILA_EVENTOS ife  
	INNER JOIN LY_PRE_MATRICULA pm ON ife.CHAVE_1 = pm.ALUNO AND ife.CHAVE_2 = pm.DISCIPLINA AND ife.CHAVE_3 = CAST(pm.ANO AS VARCHAR(50)) AND ife.CHAVE_4 = CAST(pm.SEMESTRE AS VARCHAR(50)) AND ife.CHAVE_5 = CAST(pm.CHAVE AS VARCHAR(50))
	INNER JOIN LY_ALUNO a ON pm.ALUNO = a.ALUNO  
	WHERE ife.SISTEMA_DESTINO = 'FTC - CRM'  
	AND   ife.OBJETO = 'LY_PRE_MATRICULA'  
	AND   ife.DATA_INTEGRACAO IS NULL  
	AND   ife.DATA_ERRO IS NULL  
	AND   ISNULL(ife.IGNORAR, 'N') = 'N'
GO


-- --------------------------------------------------
-- View: C_VW_INTEG_CRM_ITEMCRED
-- --------------------------------------------------
IF DBO.fn_ExisteView('C_VW_INTEG_CRM_ITEMCRED') = 'S'
  BEGIN
	DROP VIEW C_VW_INTEG_CRM_ITEMCRED
  END
GO

CREATE VIEW C_VW_INTEG_CRM_ITEMCRED  
AS  
	SELECT ife.ID_FILA_EVENTOS  
	     , iclv.CANDIDATO AS Inscricao  
	     , ife.DATA_INCLUSAO AS DataMatricula  
	     , iclv.CodEscola AS CodEscola  
	     , iclv.ANO AS Ano 
	     , iclv.PERIODO AS Periodo   
	     , iclv.REGIME AS Regime  
	     , iclv.CODCURSO AS Curso   
	     , iclv.CODTURNO AS CodTurno  
	     , iclv.CODCURRICULO AS Curriculo  
	     , iclv.CODCAMPUS AS CodCampus 
	     , (SELECT TOP 1 1 FROM LY_BOLSA B WHERE B.ALUNO = A.ALUNO) AS Bolsa  
	FROM LY_INTEGRACAO_FILA_EVENTOS ife  
	INNER JOIN C_INTEGRA_CRM_LYCEUM_VEST iclv ON ife.CHAVE_1 = iclv.CONCURSO 
	                                         AND ife.CHAVE_2 = iclv.CODCURSO 
	                                         AND ife.CHAVE_3 = iclv.CANDIDATO 
	LEFT OUTER JOIN LY_ALUNO a on iclv.CANDIDATO = a.CANDIDATO
	WHERE ife.SISTEMA_DESTINO = 'FTC - CRM'  
	AND   (ife.OBJETO = 'LY_ITEM_CRED' OR ife.OBJETO = 'LY_COBRANCA' )
	AND   ife.DATA_INTEGRACAO IS NULL  
	AND   ife.DATA_ERRO IS NULL  
	AND   ISNULL(ife.IGNORAR, 'N') = 'N'
GO
