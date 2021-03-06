USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_Relat_ContasEmAberto'))
   exec('CREATE PROCEDURE [dbo].[FTC_Relat_ContasEmAberto] AS BEGIN SET NOCOUNT OFF; END')
GO 

--EXEC FTC_Relat_ContasEmAberto  '04',NULL,'722',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'0'


 ALTER PROCEDURE dbo.FTC_Relat_ContasEmAberto
(        
  @p_unidade VARCHAR(MAX)  
, @p_tipo VARCHAR(20)    
, @p_curso  VARCHAR(20)
, @p_codigo_lanc VARCHAR(MAX)
, @p_database DATETIME
, @p_dataref_ini DATETIME
, @p_dataref_fim DATETIME  
, @p_datavenc_ini DATETIME
, @p_datavenc_fim DATETIME 
, @p_aluno VARCHAR(11)
, @p_resp VARCHAR(11)
, @p_tipo_relatorio VARCHAR(1)

)        
AS    
BEGIN        
	/*

DECLARE @p_unidade VARCHAR(MAX)  
DECLARE  @p_tipo VARCHAR(20)    
DECLARE  @p_curso  VARCHAR(20)
DECLARE  @p_codigo_lanc VARCHAR(MAX)
DECLARE  @p_database DATETIME
DECLARE  @p_dataref_ini DATETIME
DECLARE  @p_dataref_fim DATETIME  
DECLARE  @p_datavenc_ini DATETIME
DECLARE  @p_datavenc_fim DATETIME 
DECLARE @p_aluno VARCHAR(11)
DECLARE @p_resp VARCHAR(11)
DECLARE  @p_tipo_relatorio VARCHAR(1)


SET @p_unidade = '07'
SET  @p_tipo = NULL
SET  @p_curso = NULL
SET  @p_codigo_lanc = NULL
SET  @p_database = NULL
SET  @p_dataref_ini = NULL
SET  @p_dataref_fim = NULL
SET  @p_datavenc_ini = NULL
SET  @p_datavenc_fim = NULL
SET @p_aluno = NULL
SET @p_resp = NULL
SET  @p_tipo_relatorio = '1'
 */

	 DECLARE @v_todos_cod_lanc VARCHAR(1)  
	 DECLARE @v_todos_unidade_ens VARCHAR(1)  
  
 IF NOT EXISTS ( SELECT 1  
     FROM LY_COD_LANC  
     WHERE NOT EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @p_codigo_lanc, ',') WHERE LY_COD_LANC.CODIGO_LANC = ValorIni ) )  
 BEGIN  
   SET @v_todos_cod_lanc = 'S'  
 END  
 ELSE  
 BEGIN  
   SET @v_todos_cod_lanc = 'N'  
 END  


  IF NOT EXISTS ( SELECT 1  
     FROM LY_UNIDADE_ENSINO  
     WHERE NOT EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @p_unidade, ',') WHERE LY_UNIDADE_ENSINO.UNIDADE_ENS = ValorIni ) )  
 BEGIN  
   SET @v_todos_unidade_ens = 'S'  
 END  
 ELSE  
 BEGIN  
   SET @v_todos_unidade_ens = 'N'  
 END  

SET NOCOUNT ON 

CREATE TABLE #TEMP_RELATORIO (
	COD_UNIDADE VARCHAR(20)
	,NOME_UNIDADE VARCHAR(150)
	,TIPO_CURSO VARCHAR(50)
	,COD_CENTROCUSTO VARCHAR(20)
	,DESCR_CENTROCUSTO VARCHAR(100)
	,COD_CURSO VARCHAR(20)
	,NOME_CURSO VARCHAR(200)
	,ALUNO VARCHAR(20)
	,NOME_COMPL VARCHAR(200)
	,COBRANCA NUMERIC
	,TIPO_COBRANCA VARCHAR(30)
	,CODIGO_LANC VARCHAR(20)
	,PRINCIP_COD_LANC VARCHAR(20)
	,DT_GERACAO_COB DATE
	,RESP VARCHAR(20)
	,TITULAR VARCHAR(200)
	,CPF_TITULAR VARCHAR(20)
	,CPF_ALUNO VARCHAR(20)
	,DATACONTAB DATE
	,VALOR_TOTAL_COBRANCA NUMERIC(10,2)
	,VALOR_ESTORNOS NUMERIC(10,2)
	,VALOR_BOLSA_FIES NUMERIC(10,2)
	,VALOR_BOLSA_PROUNI NUMERIC(10,2)
	,VALOR_OUTRAS_BOLSAS NUMERIC(10,2)
	,VALOR_DESCONTOS NUMERIC(10,2)
	,VALOR_CANCELAMENTOS NUMERIC(10,2)
	,VALOR_PAGAMENTOS NUMERIC(10,2)
	,VALOR_ENCARGOS NUMERIC(10,2)
	,SALDO NUMERIC(10,2)
	,DATA_DE_VENCIMENTO DATE
	,DATA_DE_VENCIMENTO_ORIG DATE
	,DATAREF DATE
	,VENCIDO30 DECIMAL(10,2)
	,VENCIDO60 DECIMAL(10,2)
	,VENCIDO90 DECIMAL(10,2)
	,VENCIDO120 DECIMAL(10,2)
	,VENCIDO180 DECIMAL(10,2)
	,VENCIDO365 DECIMAL(10,2)
	,VENCIDO366 DECIMAL(10,2)
	,TOTALVENCIDO DECIMAL(10,2)
	,AVENCER30 DECIMAL(10,2)
	,AVENCER60 DECIMAL(10,2)
	,AVENCER90 DECIMAL(10,2)
	,AVENCER120 DECIMAL(10,2)
	,AVENCER180 DECIMAL(10,2)
	,AVENCER365 DECIMAL(10,2)
	,AVENCER366 DECIMAL(10,2)
	,TOTALAVENCER DECIMAL(10,2)
	,BOLSA_GOVERNO VARCHAR(1)
	,VALOR_COBRANCA_ATUAL NUMERIC(10,2)
	,VALOR_BOLSAS NUMERIC(10,2)

)
	INSERT INTO #TEMP_RELATORIO
	SELECT	DISTINCT
			 A.UNIDADE_FISICA AS COD_UNIDADE
			,UE.NOME_COMP AS NOME_UNIDADE
			,C.TIPO AS TIPO_CURSO
			,ISNULL(RA.CENTRO_DE_CUSTO,'') AS COD_CENTROCUSTO
			,ISNULL(TI.DESCR,'') AS DESCR_CENTROCUSTO
			,C.CURSO AS COD_CURSO
			,C.NOME AS NOME_CURSO
			,A.ALUNO
			,A.NOME_COMPL
			,CO.COBRANCA
			,CASE co.NUM_COBRANCA  
			 WHEN 1 THEN 'MENSALIDADE'  
             WHEN 2 THEN 'SERVICO'  
             WHEN 3 THEN 'ACORDO'  
             WHEN 4 THEN 'OUTROS'  
             WHEN 5 THEN 'CHEQUE DEVOLVIDO'  
             ELSE '' END AS TIPO_COBRANCA  
			,RA.CODIGO_LANC
			,RA.PRINCIP_COD_LANC
			,CONVERT(DATE,RA.DT_GERACAO_COB,103)
			--,RA.EVENTO_DESCR
			,CO.RESP
			,RF.TITULAR
			,RF.CPF_TITULAR
			,P.CPF AS CPF_ALUNO
			,(SELECT TOP 1 CONVERT(DATE,DATACONTAB,103) FROM AY_RESUMO_ATO WHERE COBRANCA = CO.COBRANCA AND DATACONTAB <= ISNULL(@p_database,GETDATE()) ORDER BY 1) AS DATACONTAB
			,(SELECT ISNULL(SUM(RA2.VALOR),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA.CODIGO_LANC = RA2.CODIGO_LANC AND RA2.EVENTO_NUM IN (1,4,28,30,31,32) AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE())) AS VALOR_TOTAL_COBRANCA
			,(SELECT ISNULL(SUM(RA2.VALOR_SINAL),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA.CODIGO_LANC = RA2.CODIGO_LANC AND RA2.EVENTO_NUM IN (1001,1004,1028,1030,1031,1032) AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE()) ) AS VALOR_ESTORNOS
			,(SELECT ISNULL(SUM(RA2.VALOR_SINAL),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA.CODIGO_LANC = RA2.CODIGO_LANC AND RA2.TIPO_BOLSA IN ('FIES_TEMP','FIES','FIESGERAL','FIES100','FIESFNDE','FIESTA') AND RA2.EVENTO_NUM IN (2,1002) AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE())) AS VALOR_BOLSA_FIES
			,(SELECT ISNULL(SUM(RA2.VALOR_SINAL),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA.CODIGO_LANC = RA2.CODIGO_LANC AND RA2.TIPO_BOLSA IN ('PROUNI R','PROUNI_100','PROUNI_50','PROUNI100','PROUNI50') AND RA2.EVENTO_NUM IN (2,1002) AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE())) AS VALOR_BOLSA_PROUNI
			,(SELECT ISNULL(SUM(RA2.VALOR_SINAL),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA.CODIGO_LANC = RA2.CODIGO_LANC AND (RA2.TIPO_BOLSA NOT IN ('PROUNI R','PROUNI_100','PROUNI_50','PROUNI100','PROUNI50','FIES_TEMP','FIES','FIESGERAL','FIES100','FIESFNDE','FIESTA') OR RA2.TIPO_BOLSA IS NULL) AND EVENTO_NUM IN (2,1002,63,1063) AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE())) AS VALOR_OUTRAS_BOLSAS
			,(SELECT ISNULL(SUM(RA2.VALOR_SINAL),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA.CODIGO_LANC = RA2.CODIGO_LANC AND RA2.EVENTO_NUM IN (33,1033) AND MOTIVO_DESCONTO <> 'PlanoPagamento' AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE()) ) AS VALOR_DESCONTOS
			,(SELECT ISNULL(SUM(RA2.VALOR_SINAL),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA.CODIGO_LANC = RA2.CODIGO_LANC AND RA2.EVENTO_NUM IN (33,1033) AND MOTIVO_DESCONTO = 'PlanoPagamento' AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE())) AS VALOR_CANCELAMENTOS 
			,(SELECT ISNULL(SUM(RA2.VALOR_SINAL),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA2.EVENTO_NUM IN (12,16,17,18,23,24,50,51,1012,1016,1017,1018,1023,1024,1050,1051) AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE())) AS VALOR_PAGAMENTOS
			,(SELECT ISNULL(SUM(RA2.VALOR_SINAL),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA2.EVENTO_NUM IN (54,59,1054,1059) AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE())) AS VALOR_ENCARGOS
			,(SELECT ISNULL(SUM(RA2.VALOR_SINAL),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA2.EVENTO_NUM NOT IN (49,1049) AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE())) AS SALDO
			,CONVERT(DATE,CO.DATA_DE_VENCIMENTO,103)
			,CONVERT(DATE,CO.DATA_DE_VENCIMENTO_ORIG,103)
			,CONVERT(DATE, '01/' + STR(RA.MES_REF) + '/' + STR(RA.ANO_REF), 103) AS DATAREF
			,CONVERT(DECIMAL(10,2),0.00) AS VENCIDO30, CONVERT(DECIMAL(10,2),0.00) AS VENCIDO60, CONVERT(DECIMAL(10,2),0.00) AS VENCIDO90, CONVERT(DECIMAL(10,2),0.00) AS VENCIDO120, CONVERT(DECIMAL(10,2),0.00) AS VENCIDO180, CONVERT(DECIMAL(10,2),0.00) AS VENCIDO365, CONVERT(DECIMAL(10,2),0.00) AS VENCIDO366, CONVERT(DECIMAL(10,2),0.00) AS TOTALVENCIDO
			,CONVERT(DECIMAL(10,2),0.00) AS AVENCER30, CONVERT(DECIMAL(10,2),0.00) AS AVENCER60, CONVERT(DECIMAL(10,2),0.00) AS AVENCER90, CONVERT(DECIMAL(10,2),0.00) AS AVENCER120, CONVERT(DECIMAL(10,2),0.00) AS AVENCER180, CONVERT(DECIMAL(10,2),0.00) AS AVENCER365, CONVERT(DECIMAL(10,2),0.00) AS AVENCER366, CONVERT(DECIMAL(10,2),0.00) AS TOTALAVENCER
			,'N' AS BOLSA_GOVERNO
			,0.00 AS VALOR_COBRANCA_ATUAL
			,0.00 AS VALOR_BOLSAS
	FROM LY_COBRANCA CO
	JOIN LY_ALUNO A ON A.ALUNO = CO.ALUNO
	JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA
	JOIN LY_PLANO_PGTO_PERIODO PPP ON PPP.ALUNO = A.ALUNO AND PPP.RESP = CO.RESP
	JOIN LY_RESP_FINAN RF ON RF.RESP = PPP.RESP
	JOIN LY_CURSO C ON C.CURSO = A.CURSO
	JOIN AY_RESUMO_ATO RA ON RA.COBRANCA = CO.COBRANCA
	JOIN AY_EXPORTA_MOV_CONTAB EMC ON EMC.NUM = RA.ATO_ID --JOIN PARA CONSIDERAR APENAS INTEGRACAO PARA O PROTHEUS
	LEFT JOIN HD_TABELAITEM TI ON TI.ITEM = RA.CENTRO_DE_CUSTO AND TABELA = 'CentroCusto'
	JOIN LY_UNIDADE_ENSINO UE ON UE.UNIDADE_ENS = C.FACULDADE
	WHERE RA.EVENTO_NUM IN (1,4,28,30,31,32) AND (CO.ESTORNO = 'N' OR CO.DT_ESTORNO IS NULL)
	AND (SELECT ISNULL(SUM(RA2.VALOR_SINAL),0) FROM AY_RESUMO_ATO RA2 WHERE RA2.COBRANCA = CO.COBRANCA AND RA2.EVENTO_NUM NOT IN (49,1049) AND RA2.DATACONTAB <= ISNULL(@p_database,GETDATE())) <> 0
	AND ( @p_unidade IS NULL OR @v_todos_unidade_ens = 'S' OR EXISTS (SELECT 1
																		FROM LY_CURSO C
																		WHERE C.FACULDADE = RA.UNIDADE
																		AND EXISTS (SELECT 1 FROM dbo.fnMultiValue('I', @p_unidade, ',') WHERE ValorIni = C.FACULDADE ) ) )   
	AND ( @p_tipo IS NULL OR (@p_tipo IS NOT NULL AND c.TIPO = @p_tipo) )    
	AND ( @p_curso IS NULL OR (@p_curso IS NOT NULL AND c.CURSO = @p_curso) )    
	AND ( @p_dataref_ini IS NULL OR (@p_dataref_ini IS NOT NULL AND CONVERT(DATETIME, '01/' + STR(RA.MES_REF) + '/' + STR(RA.ANO_REF), 103)  >= @p_dataref_ini) )    
	AND ( @p_dataref_fim IS NULL OR (@p_dataref_fim IS NOT NULL AND CONVERT(DATETIME, '01/' + STR(RA.MES_REF) + '/' + STR(RA.ANO_REF), 103)  <= @p_dataref_fim) )    
	AND ( @p_datavenc_ini IS NULL OR (@p_datavenc_ini IS NOT NULL AND CO.DATA_DE_VENCIMENTO  >= @p_datavenc_ini) )    
	AND ( @p_datavenc_fim IS NULL OR (@p_datavenc_fim IS NOT NULL AND CO.DATA_DE_VENCIMENTO  <= @p_datavenc_fim) )    
	AND ( @p_database IS NULL OR (@p_database IS NOT NULL AND RA.DATACONTAB  <= ISNULL(@p_database,GETDATE())) )  
	AND ( @p_aluno IS NULL OR (@p_aluno IS NOT NULL AND co.ALUNO = @p_aluno) )    
	AND ( @p_resp IS NULL OR (@p_resp IS NOT NULL AND co.RESP = @p_resp) )    
    AND ( @p_codigo_lanc IS NULL OR @v_todos_cod_lanc = 'S' OR EXISTS ( SELECT 1  
                                                                       FROM AY_RESUMO_ATO ra2  
                                                                       WHERE ra2.COBRANCA = co.COBRANCA  
                                                                         AND EXISTS ( SELECT 1 FROM dbo.fnMultiValue('I', @p_codigo_lanc, ',') WHERE ValorIni = ra2.CODIGO_LANC ) ) )  
	

	INSERT INTO #TEMP_RELATORIO
	SELECT  TOP 1 '' AS COD_UNIDADE, '' AS NOME_UNIDADE, '' AS TIPO_CURSO,'' AS COD_CENTROCUSTO,'' AS DESCR_CENTROCUSTO,'' AS COD_CURSO,'' AS NOME_CURSO, '' AS ALUNO
			,'' AS NOME_COMPL,0 AS COBRANCA, '' AS TIPO_COBRANCA, '' AS CODIGO_LANC,'' AS PRINCIP_COD_LANC,'' AS DT_GERACAO_COB, '' AS RESP ,'' AS TITULAR, '' AS CPF_TITULAR,'' AS CPF_ALUNO, '' AS DATACONTAB
			,0.00 AS VALOR_TOTAL_COBRANCA, 0.00 AS VALOR_ESTORNOS, 0.00 AS VALOR_BOLSA_FIES, 0.00 AS VALOR_BOLSA_PROUNI, 0.00 AS VALOR_OUTRAS_BOLSAS, 0.00 AS VALOR_DESCONTOS, 0.00 AS VALOR_CANCELAMENTOS,0.00 AS VALOR_PAGAMENTOS
			,0 AS VALOR_ENCARGOS,0.00 AS SALDO, '' AS DATA_DE_VENCIMENTO, '' AS DATA_DE_VENCIMENTO_ORIG, '' AS DATAREF
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN -30 AND -1)		AS VENCIDO30
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN -60 AND -31)	AS VENCIDO60
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN -90 AND -61)	AS VENCIDO90
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN -120 AND -91)	AS VENCIDO120
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN -180 AND -121)	AS VENCIDO180
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN -365 AND -181)	AS VENCIDO365
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) < -365)					AS VENCIDO366
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) < 0)					AS TOTALVENCIDO
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN 0 AND 30)		AS AVENCER30
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN 31 AND 60)		AS AVENCER60
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN 61 AND 90)		AS AVENCER90
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN 91 AND 120)		AS AVENCER120
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN 121 AND 180)	AS AVENCER180
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) BETWEEN 181 AND 365)	AS AVENCER365
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) > 365)					AS AVENCER366
			,(SELECT ISNULL(SUM(SALDO),0) FROM #TEMP_RELATORIO WHERE DATEDIFF(DAY,ISNULL(@p_database,GETDATE()),DATA_DE_VENCIMENTO) >= 0)					AS TOTALAVENCER
			,'N' AS BOLSA_GOVERNO
			,0.00 AS VALOR_COBRANCA_ATUAL
			,0.00 AS VALOR_BOLSAS

--AGLUTINANDO CAMPOS CONFORME SOLICITADO
	UPDATE #TEMP_RELATORIO SET VALOR_BOLSAS = VALOR_BOLSA_FIES + VALOR_BOLSA_PROUNI + VALOR_OUTRAS_BOLSAS
	UPDATE #TEMP_RELATORIO SET VALOR_COBRANCA_ATUAL = VALOR_TOTAL_COBRANCA + VALOR_ESTORNOS + VALOR_DESCONTOS + VALOR_CANCELAMENTOS
	UPDATE #TEMP_RELATORIO SET BOLSA_GOVERNO = 'S' WHERE VALOR_BOLSA_FIES > 0 OR VALOR_BOLSA_PROUNI > 0
	UPDATE #TEMP_RELATORIO SET VALOR_PAGAMENTOS = 0.00, SALDO = 0.00 WHERE PRINCIP_COD_LANC <> CODIGO_LANC


IF @p_tipo_relatorio = '0'
BEGIN
	
	SELECT	DISTINCT
			COD_UNIDADE
			,TIPO_COBRANCA
			,TIPO_CURSO
			,CODIGO_LANC
			,PRINCIP_COD_LANC
			,SUM(SALDO) AS SALDO
	FROM #TEMP_RELATORIO
	WHERE COD_UNIDADE NOT IN ('')
	GROUP BY  COD_UNIDADE, TIPO_COBRANCA, TIPO_CURSO,CODIGO_LANC,PRINCIP_COD_LANC
	HAVING SUM(SALDO) <> 0
	ORDER BY 1,2,3,4,5

END

IF @p_tipo_relatorio = '1'
BEGIN

	SELECT	COD_UNIDADE,
			NOME_UNIDADE,
			TIPO_CURSO,
			COD_CENTROCUSTO,
			DESCR_CENTROCUSTO,
			COD_CURSO,
			NOME_CURSO,
			ALUNO,
			NOME_COMPL,
			COBRANCA,
			TIPO_COBRANCA,
			CODIGO_LANC,
			PRINCIP_COD_LANC,
			RESP,
			TITULAR,
			CPF_TITULAR,
			CPF_ALUNO,
			VALOR_COBRANCA_ATUAL,
			VALOR_BOLSAS,
			VALOR_PAGAMENTOS,
			SALDO,
			BOLSA_GOVERNO,
			DATACONTAB,
			DT_GERACAO_COB,
			DATA_DE_VENCIMENTO,
			DATA_DE_VENCIMENTO_ORIG,
			DATAREF
	FROM #TEMP_RELATORIO
	WHERE COD_UNIDADE NOT IN ('')
	ORDER BY 1,4,6,8
END
	
IF @p_tipo_relatorio = '2'
	BEGIN
		
		SELECT	VENCIDO30
				,VENCIDO60
				,VENCIDO90
				,VENCIDO120
				,VENCIDO180
				,VENCIDO365
				,VENCIDO366
				,TOTALVENCIDO
				,AVENCER30
				,AVENCER60
				,AVENCER90
				,AVENCER120
				,AVENCER180
				,AVENCER365
				,AVENCER366
				,TOTALAVENCER
		FROM #TEMP_RELATORIO
		WHERE COD_UNIDADE = ''
	
	END

	--DROP TABLE #TEMP_RELATORIO

SET NOCOUNT OFF
END
GO

delete from LY_CUSTOM_CLIENTE
where NOME = 'FTC_Relat_ContasEmAberto'
and IDENTIFICACAO_CODIGO = '0002'
go

INSERT INTO LY_CUSTOM_CLIENTE
(NOME, IDENTIFICACAO_CODIGO, AUTOR, DATA_CRIACAO, OBJETIVO, SOLICITADO_POR, ATIVO, TIPOCOMPONENTE, TIPO, CLIENTE)
SELECT
  'FTC_Relat_ContasEmAberto' NOME
, '0002' IDENTIFICAO_CODIGO
, 'Lucas Trindade' AUTOR
, '2018-11-20' DATA_CRIACAO
, 'Relat�rio - Contas em Aberto - Corre��es e Melhorias' OBJETIVO
, 'Controladoria' SOLICITADO_POR
, 'S' ATIVO
, 'PROCEDURE' TIPOCOMPONENTE
, 'CLIENTE' TIPO
, 'FTC' CLIENTE
GO  
