USE FTC_DATAMART
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.BI_ATIVOS_POS'))
   exec('CREATE PROCEDURE [dbo].[BI_ATIVOS_POS] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE dbo.BI_ATIVOS_POS

AS
--DROP TABLE #TEMP
BEGIN

CREATE TABLE #TEMP

(
	UNIDADE_FISICA VARCHAR(20),
	NOME_COMP VARCHAR(200),
	CURSO VARCHAR(20),
	NOME VARCHAR(200),
	ANO_INGRESSO VARCHAR(4),
	SEM_INGRESSO VARCHAR(2),
	TIPO_ALUNO VARCHAR(20),
	CPF VARCHAR(20),
	ALUNO VARCHAR(20),
	NOME_COMPL VARCHAR(200),
	PAGO VARCHAR(1),
	QTD_PARCELAS_TOTAL SMALLINT,
	QTD_PARCELAS_AVENCER SMALLINT
)

INSERT INTO #TEMP
SELECT	A.UNIDADE_FISICA
		, UF.NOME_COMP
		, A.CURSO
		, C.NOME
		, A.ANO_INGRESSO
		, A.SEM_INGRESSO
		, CASE CONCAT(A.ANO_INGRESSO,A.SEM_INGRESSO)
			WHEN '20190' THEN 'CALOURO' ELSE 'VETERANO' END AS TIPO_ALUNO
		, P.CPF
		, A.ALUNO
		, A.NOME_COMPL
		, ISNULL((SELECT TOP 1 'S' 
				FROM VW_COBRANCA VW 
				JOIN LY_COBRANCA C ON C.COBRANCA = VW.COBRANCA
				JOIN LY_ITEM_LANC IL ON IL.COBRANCA = C.COBRANCA
				JOIN LY_LANC_DEBITO LD ON LD.LANC_DEB = IL.LANC_DEB
				WHERE VW.ALUNO = A.ALUNO AND VW.VALOR <=0
				AND C.NUM_COBRANCA IN (1,2)
				AND C.ESTORNO = 'N' AND C.DT_ESTORNO IS NULL),'N') AS  PAGO
		, ISNULL((SELECT COUNT(DISTINCT C.COBRANCA) 
				FROM VW_COBRANCA VW 
				JOIN LY_COBRANCA C ON C.COBRANCA = VW.COBRANCA
				JOIN LY_ITEM_LANC IL ON IL.COBRANCA = C.COBRANCA
				JOIN LY_LANC_DEBITO LD ON LD.LANC_DEB = IL.LANC_DEB
				WHERE VW.ALUNO = A.ALUNO 
				AND C.NUM_COBRANCA IN (1,2)
				AND C.ESTORNO = 'N' AND C.DT_ESTORNO IS NULL),0) AS QTD_PARCELAS_TOTAL
		, ISNULL((SELECT COUNT(DISTINCT C.COBRANCA) 
				FROM VW_COBRANCA VW 
				JOIN LY_COBRANCA C ON C.COBRANCA = VW.COBRANCA
				JOIN LY_ITEM_LANC IL ON IL.COBRANCA = C.COBRANCA
				JOIN LY_LANC_DEBITO LD ON LD.LANC_DEB = IL.LANC_DEB
				WHERE VW.ALUNO = A.ALUNO 
				AND C.NUM_COBRANCA IN (1,2)
				AND C.ESTORNO = 'N' AND C.DT_ESTORNO IS NULL
				AND C.DATA_DE_VENCIMENTO > GETDATE()),0) AS QTD_PARCELAS_AVENCER
FROM LY_ALUNO A
JOIN LY_PESSOA P ON P.PESSOA = A.PESSOA 
JOIN LY_CURSO C ON C.CURSO = A.CURSO AND C.TIPO = 'POS-GRADUACAO'
JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = A.UNIDADE_FISICA
WHERE A.SIT_ALUNO = 'Ativo'
AND EXISTS (SELECT TOP 1 1 FROM VW_MATRICULA_E_PRE_MATRICULA VW WHERE VW.ALUNO = A.ALUNO AND VW.SIT_MATRICULA NOT IN ('Cancelado','Trancado','Dispensado'))

END