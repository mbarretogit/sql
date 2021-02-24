USE LYCEUM
GO

--DELETE FROM HD_PADREL WHERE RELATORIO = 'FTC_Relat_CobrancasEmAbertoFinan'
--DELETE FROM HD_RELATORIO WHERE RELATORIO= 'FTC_Relat_CobrancasEmAbertoFinan'
--DELETE FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'FinanceiroNG' AND RELATORIO = 'FTC_Relat_CobrancasEmAbertoFinan'


DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_ContasEmAbertoFinan' AND GRUPORELAT = 'FinanceiroNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','Relat�rio de Cobran�as em Aberto - Financeiro','/Lyceum/Financeiro/FTC_Relat_CobrancasEmAbertoFinan','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'FinanceiroNG' AND RELATORIO = 'FTC_Faturamento'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_ContasEmAbertoFinan'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','tp_relatorio','1','5','Tipo de Relat�rio:','S',NULL,'SP: Relat_P_TipoRelatorio_CB_FTC()','COD','TIPO',NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_unidade','2','5','Unidade de Ensino:','S',NULL,'SP: Relat_P_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descri��o','S')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_tipo','3','5','Tipo de Curso:','N',NULL,'SP: Relat_P_TipoCurso()','CODIGO','DESCR','N�vel do Curso, Descri��o','N')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_curso','4','5','Curso:','N',NULL,'SP: Relat_P_Curso(@p_tipo@, @p_unidade@)','CODIGO','DESCR',NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_codigo_lanc','5','5','C�digo de Lan�amento:','S',NULL,'SP: Relat_P_CodigoLancamento_CB_FTC(@tp_relatorio@)','CODIGO','DESCR','C�digo de Lan�amento, Descri��o','S')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_database','6','7','Data Base:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_dataref_ini','7','7','Data Refer�ncia de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_dataref_fim','8','7','Data Refer�ncia at�:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_datavenc_ini','9','7','Data Vencimento de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_datavenc_fim','10','7','Data Vencimento at�:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_aluno','11','5','Aluno:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_resp','12','5','Respons�vel Financeiro:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_ContasEmAbertoFinan','p_tipo_relatorio','13','5','Tipo de Relat�rio:','S',NULL,'SELECT ''0'' AS CODIGO, ''Sint�tico'' AS DESCR UNION SELECT ''1'' AS CODIGO, ''An�litico'' AS DESCR','CODIGO','DESCR','C�digo, Descri��o','N')

GO
