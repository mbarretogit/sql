USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_SP_csvInconsistenciaBancaria'))
   exec('CREATE PROCEDURE [dbo].[FTC_SP_csvInconsistenciaBancaria] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE dbo.FTC_SP_csvInconsistenciaBancaria     
(      
	@P_DATA_VENC_INI VARCHAR(10),
	@P_DATA_VENC_FIM VARCHAR(10),
	@P_DATA_GER_INI VARCHAR(10),
	@P_DATA_GER_FIM VARCHAR(10),
	@P_NOSSO_NUMERO VARCHAR(50)
	
)      
AS      
-- [IN�CIO]              
BEGIN      
  
SET NOCOUNT ON  

SELECT BL.RESP,
		CO.ALUNO,
		EM.NOSSO_NUMERO,
		BL.BOLETO,
		CONVERT(VARCHAR(10),EM.DT_INSERCAO,103) AS DT_GERACAO,
		CONVERT(VARCHAR(10),CO.DATA_DE_VENCIMENTO,103) AS DT_VENCIMENTO,
		CO.COBRANCA,
		EM.VALOR_PAGO,
		EM.AGENCIA,
		EM.CONTA_BANCO
FROM LY_ERRO_MOVIMENTO EM
JOIN LY_BOLETO BL	ON EM.NOSSO_NUMERO = BL.NOSSO_NUMERO 
					AND EM.BANCO = BL.BANCO
					AND EM.AGENCIA = BL.AGENCIA
					AND EM.CONTA_BANCO = BL.CONTA_BANCO
					AND EM.CONVENIO =  BL.CONVENIO
JOIN VW_COBRANCA CO ON BL.RESP = CO.RESP  
LEFT JOIN (SELECT DISTINCT BOLETO,COBRANCA FROM LY_ITEM_LANC) IL ON CO.COBRANCA = IL.COBRANCA
LEFT JOIN (SELECT DISTINCT BOLETO,COBRANCA FROM LY_ITEM_LANC) IL2 ON EM.BOLETO = IL2.BOLETO
WHERE CO.VALOR > 0
AND EM.VALOR_PAGO >= CO.VALOR
AND NOT EXISTS(SELECT TOP 1 1 FROM  LY_ERRO_MOV_PAGAMENTO WHERE ERRO_MOV = EM.ERRO_MOV)
AND ((@P_NOSSO_NUMERO IS NOT NULL AND EM.NOSSO_NUMERO = @P_NOSSO_NUMERO) OR (@P_NOSSO_NUMERO IS NULL) OR @P_NOSSO_NUMERO = '')
AND ((CO.DATA_DE_VENCIMENTO >= @P_DATA_VENC_INI AND @P_DATA_VENC_INI IS NOT NULL) OR @P_DATA_VENC_INI IS NULL)
AND ((CO.DATA_DE_VENCIMENTO <= @P_DATA_VENC_FIM AND @P_DATA_VENC_FIM IS NOT NULL) OR @P_DATA_VENC_FIM IS NULL)
AND ((EM.DT_INSERCAO >= @P_DATA_GER_INI AND @P_DATA_GER_INI IS NOT NULL) OR @P_DATA_GER_INI IS NULL)
AND ((EM.DT_INSERCAO <= @P_DATA_GER_FIM AND @P_DATA_GER_FIM IS NOT NULL) OR @P_DATA_GER_FIM IS NULL)
ORDER BY 3,2
  
  
SET NOCOUNT OFF  
  
END              
GO
-- [FIM]      



--##
--## PARAMETRIZA��O/CADASTRO DA LISTA NO LYCEUM
--##

DECLARE @V_CONSULTA_DINAMICA INT
DECLARE @V_NOME_CONSULTA_DINAMICA varchar(100)

-- Colocar nome da lista (que ser� apresentada no combo)
set @V_NOME_CONSULTA_DINAMICA ='FTC - Inconsist�ncias Banc�rias'

-- Consulta ID da Lista
SELECT @V_CONSULTA_DINAMICA = ID FROM LY_CONSULTA_DINAMICA WHERE TITULO = @V_NOME_CONSULTA_DINAMICA

-- armazena padr�es de acesso
SELECT PADACES
INTO #TEMP_CONSULTA_DINAMICA
FROM LY_CONSULTA_DINAMICA_PADACES WHERE ID = @V_CONSULTA_DINAMICA


DELETE LY_CONSULTA_DINAMICA_PADACES WHERE ID_CONSULTA_DINAMICA = @V_CONSULTA_DINAMICA
DELETE LY_CONSULTA_DINAMICA_PARAMETROS WHERE ID_CONSULTA_DINAMICA = @V_CONSULTA_DINAMICA
DELETE LY_CONSULTA_DINAMICA WHERE ID = @V_CONSULTA_DINAMICA

BEGIN

IF NOT EXISTS(SELECT 1 FROM LY_CONSULTA_DINAMICA C WHERE C.TITULO = @V_NOME_CONSULTA_DINAMICA)
INSERT INTO LY_CONSULTA_DINAMICA(TITULO, TIPO, STORED_PROCEDURE)
VALUES(@V_NOME_CONSULTA_DINAMICA,'CSV','sp:FTC_SP_csvInconsistenciaBancaria(@P_DATA_VENC_INI@,@P_DATA_VENC_FIM@,@P_DATA_GER_INI@,@P_DATA_GER_FIM@,@P_NOSSO_NUMERO@)')

SET @V_CONSULTA_DINAMICA = @@IDENTITY

-- Insere padr�es de acesso
INSERT INTO LY_CONSULTA_DINAMICA_PADACES (ID_CONSULTA_DINAMICA, PADACES)
SELECT @V_CONSULTA_DINAMICA, PADACES FROM #TEMP_CONSULTA_DINAMICA

-- Insere parametros

	--@p_ano				T_ANO,
	--@p_semestre			T_Semestre2,
	--@p_unidade_ensino	T_codigo,
	--@p_tipo_curso		T_codigo,
	--@p_curso			T_codigo,
	--@p_turno			T_codigo,
	--@p_curriculo		T_codigo,	
	--@p_sit_matricula	T_codigo,
	--@p_tem_turma		varchar(1)

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 1, 'P_DATA_VENC_INI', 5, 'Data de Vencimento Inicial (AAAA-MM-DD)', 'N', NULL, 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 2, 'P_DATA_VENC_FIM', 5, 'Data de Vencimento Final (AAAA-MM-DD)', 'N', NULL, 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 3, 'P_DATA_GER_INI', 5, 'Data de Gera��o Inicial (AAAA-MM-DD)', 'N', NULL, 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 4, 'P_DATA_GER_FIM', 5, 'Data de Gera��o Final (AAAA-MM-DD)', 'N', NULL, 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 5, 'P_NOSSO_NUMERO', 5, 'Nosso Numero', 'N', NULL, 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

--SELECT * FROM LY_CONSULTA_DINAMICA WHERE ID = @V_CONSULTA_DINAMICA
--SELECT * FROM LY_CONSULTA_DINAMICA_PARAMETROS WHERE ID_CONSULTA_DINAMICA = @V_CONSULTA_DINAMICA

drop table  #TEMP_CONSULTA_DINAMICA

END
GO

delete from LY_CUSTOM_CLIENTE
where NOME = 'FTC_SP_csvInconsistenciaBancaria'
and IDENTIFICACAO_CODIGO = '0001'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_SP_csvInconsistenciaBancaria' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2015-05-02' DATA_CRIACAO
, 'ListaNG - Inconsist�ncias Banc�rias' OBJETIVO
, 'Nelson Albuquerque' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO 