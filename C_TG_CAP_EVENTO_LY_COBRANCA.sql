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
	
	-- Verifica se a cobrança está sendo faturada
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