USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_csv_Avaliacao_BRUTO'))
   exec('CREATE PROCEDURE [dbo].[FTC_csv_Avaliacao_BRUTO] AS BEGIN SET NOCOUNT OFF; END')
GO 


--EXEC FTC_csv_Avaliacao_BRUTO 'Avalia��o DocenteIII','AVALDOCENTE03_20171','04'

ALTER PROCEDURE FTC_csv_Avaliacao_BRUTO
	@P_AVALIACAOQ VARCHAR(30)  
	,@P_APLICACAO VARCHAR(30)  
	,@P_UNIDADE VARCHAR(15)  

AS
BEGIN
SET NOCOUNT ON
	IF @P_AVALIACAOQ IN ('Avalia��o Docente II','Avalia��o DocenteIII','Avalia��o DocenteIV')
	BEGIN
		IF @P_APLICACAO LIKE '%2017%'
		BEGIN
			EXEC FTC_Relat_Avaliacao_Coordenador_NG @P_AVALIACAOQ, @P_APLICACAO, @P_UNIDADE,NULL,NULL,NULL,NULL
			RETURN
		END
		IF @P_APLICACAO LIKE '%2018%'
		BEGIN
			EXEC FTC_Relat_Avaliacao_Coordenador_2018_NG @P_AVALIACAOQ, @P_APLICACAO, @P_UNIDADE,NULL,NULL,NULL,NULL
			RETURN
		END
	END
	IF @P_AVALIACAOQ = 'Avalia��o Docente I'
	BEGIN
		IF @P_APLICACAO LIKE '%2017%'
		BEGIN
			EXEC FTC_Relat_Avaliacao_Docente_NG @P_AVALIACAOQ, @P_APLICACAO, @P_UNIDADE,NULL,NULL,NULL,NULL,'1'
			RETURN
		END
		IF @P_APLICACAO LIKE '%2018%'
		BEGIN
			EXEC FTC_Relat_Avaliacao_Docente_2018_NG @P_AVALIACAOQ, @P_APLICACAO, @P_UNIDADE,NULL,NULL,NULL,NULL,'1'
			RETURN
		END
	END
	IF @P_AVALIACAOQ IN ('Av Institucional I','Av Institucional II','Av Institucional III')
	BEGIN
		EXEC FTC_Relat_Avaliacao_Institucional_NG @P_AVALIACAOQ, @P_APLICACAO, @P_UNIDADE
		RETURN
	END
	IF @P_AVALIACAOQ = 'Av Docente M I'
	BEGIN
		EXEC FTC_Relat_Avaliacao_Mestrado_Curso_NG @P_AVALIACAOQ, @P_APLICACAO, @P_UNIDADE,NULL,NULL,NULL,NULL
		RETURN
	END
	IF @P_AVALIACAOQ = 'Av Docente M II'
	BEGIN
		EXEC FTC_Relat_Avaliacao_Mestrado_NG @P_AVALIACAOQ, @P_APLICACAO, @P_UNIDADE,NULL,NULL,NULL,NULL
		RETURN
	END

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
set @V_NOME_CONSULTA_DINAMICA ='Custom - Resultado da Avalia��o Docente (BRUTO)'

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
VALUES(@V_NOME_CONSULTA_DINAMICA,'CSV','sp:FTC_csv_Avaliacao_BRUTO(@P_AVALIACAOQ@,@P_APLICACAO@,@P_UNIDADE@)')

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
SELECT @V_CONSULTA_DINAMICA, 1, 'P_AVALIACAOQ', 5, 'Avalia��o:', 'S', 'select TIPO_QUESTIONARIO AS CODIGO, DESCRICAO FROM LY_TIPO_QUESTIONARIO', 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 2, 'P_APLICACAO', 5, 'Aplica��o:', 'S', 'SELECT APLICACAO AS CODIGO, CONCAT(CONVERT(VARCHAR(10),DT_INICIO,103),''-'',TITULO) AS DESCRICAO FROM LY_APLIC_QUESTIONARIO WHERE TIPO_QUESTIONARIO = @P_AVALIACAOQ@ ORDER BY DT_INICIO', 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

INSERT INTO LY_CONSULTA_DINAMICA_PARAMETROS(ID_CONSULTA_DINAMICA,ORDEM,PARAMETRO,TIPO,DESCRICAO,OBRIGATORIO,SQL_TEXTO,COL_VALOR,COL_DESCR)
SELECT @V_CONSULTA_DINAMICA, 3, 'P_UNIDADE', 5, 'Unidade Ensino', 'N', 'SELECT UNIDADE_ENS AS CODIGO, NOME_COMP AS DESCRICAO FROM LY_UNIDADE_ENSINO WHERE UNIDADE_ENS BETWEEN ''03'' AND ''29''', 'CODIGO' COL_VALOR, 'DESCRICAO' COL_DESCR

--SELECT * FROM LY_CONSULTA_DINAMICA WHERE ID = @V_CONSULTA_DINAMICA
--SELECT * FROM LY_CONSULTA_DINAMICA_PARAMETROS WHERE ID_CONSULTA_DINAMICA = @V_CONSULTA_DINAMICA

DROP TABLE  #TEMP_CONSULTA_DINAMICA

END
GO

delete from LY_CUSTOM_CLIENTE
where NOME = 'FTC_csv_Avaliacao_BRUTO'
and IDENTIFICACAO_CODIGO = '0001'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_csv_Avaliacao_BRUTO' NOME
, '0001' IDENTIFICAO_CODIGO
, 'Miguel' AUTOR
, '2018-08-23' DATA_CRIACAO
, 'ListaNG - Avalia��o Docente (BRUTO)' OBJETIVO
, 'Dayse Ackerman' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO 
