USE FTC_DATAMART
GO

--EXEC BI_LANCAMENTOS_CONTABEIS_JOB 20190101,20200531
--DROP TABLE BI_LANCAMENTOS_CONTABEIS
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.BI_LANCAMENTOS_CONTABEIS_JOB'))
   exec('CREATE PROCEDURE [dbo].[BI_LANCAMENTOS_CONTABEIS_JOB] AS BEGIN SET NOCOUNT OFF; END')
GO 

ALTER PROCEDURE dbo.BI_LANCAMENTOS_CONTABEIS_JOB
(				
  @p_data_base_ini VARCHAR(8)      
, @p_data_base_fim VARCHAR(8)      

)            
AS            
-- [IN�CIO]                    
BEGIN  


IF EXISTS (SELECT * FROM sys.tables WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.BI_LANCAMENTOS_CONTABEIS'))   
BEGIN
	DELETE FROM BI_LANCAMENTOS_CONTABEIS WHERE DATA BETWEEN @p_data_base_ini AND @p_data_base_fim
END

ELSE 

CREATE TABLE BI_LANCAMENTOS_CONTABEIS (
	
	FILIAL VARCHAR(2),
	DATA   VARCHAR(8),
	LOTE   VARCHAR(6),
	SBLOTE VARCHAR(3),
	DOCUMENTO    VARCHAR(6),
	LINHA  VARCHAR(3),
	CT2_DC     VARCHAR(1),
	DEBITO     VARCHAR(20),
	DESC_DEB   VARCHAR(40),
	CREDITO    VARCHAR(20),
	DESC_CRED  VARCHAR(40),
	VALOR		DECIMAL(20,2),
	HISTORICO   VARCHAR(40),
	CCUSTO_DEB    VARCHAR(13),
	DESC_CCUSTO_D   VARCHAR(40),
	CCUSTOC_CRED   VARCHAR(13),
	DESC_CCUSTO_C   VARCHAR(40),
	ITEM_DEBITO      VARCHAR(13),
	DESC_ITEM_D VARCHAR(40),
	ITEM_CREDITO      VARCHAR(13),
	DESC_ITEM_C VARCHAR(40),
	SEQUENCIA VARCHAR(3),
	EMPRESA_ORIGEM VARCHAR(2),
	FILIAL_ORIGEM VARCHAR(2),
	COD_FORN VARCHAR(20),
	RAZAO_SOCIAL VARCHAR(20),
	CT2_AT02CR VARCHAR(20),
	CONTROLE   VARCHAR(10)
	
)
END


EXECUTE ('BEGIN SIGA.P_FTC_LCTOS_CONTABEIS_BI(''20191201'',''20191231''); END; ') AT [DBRM];

DELETE FROM BI_LANCAMENTOS_CONTABEIS WHERE DATA BETWEEN '20191201' AND '20191231'

INSERT INTO BI_LANCAMENTOS_CONTABEIS
select * from openquery(DBRM,'select * from siga.ftc_lctos_contabeis');


select distinct substring(data,0,5) ANO, SUBSTRING(DATA,5,2) MES from BI_LANCAMENTOS_CONTABEIS ORDER BY 1,2