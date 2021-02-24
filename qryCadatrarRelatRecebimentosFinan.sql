USE LYCEUM
GO

--DELETE FROM HD_PADREL WHERE RELATORIO = 'FTC_Relat_RecebimentosFinan'
--DELETE FROM HD_RELATORIO WHERE RELATORIO= 'FTC_Relat_RecebimentosFinan'
--DELETE FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'FinanceiroNG' AND RELATORIO = 'FTC_Relat_RecebimentosFinan'


DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_RecebimentosFinan' AND GRUPORELAT = 'FinanceiroNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','Relatório de Recebimentos - Financeiro','/Lyceum/Financeiro/FTC_Recebimento_Financeiro','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'FinanceiroNG' AND RELATORIO = 'FTC_Recebimento_Argyros'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_RecebimentosFinan'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','p_unidade','1','5','Unidade Física:','N',NULL,'SP: Relat_P_UnidadeFisica()','CODIGO','DESCR','Unidade Ensino, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','p_curso','2','5','Curso:','N',NULL,'SP: Relat_P_Curso(@f:null@, @p_unidade@)','CODIGO','DESCR',NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','p_estorno','3','5','Exibe Estornadas:','S',NULL,'LOV: S,N',NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','p_codigo_lanc','4','5','Código de Lançamento:','S',NULL,'SP: Relat_P_CodigoLancamento()','CODIGO','DESCR','Código de Lançamento, Descrição','S')
,('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','p_databaixa_ini','5','7','Periodo Baixa de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','p_databaixa_fim','6','7','Periodo Baixa até:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','p_dataref_ini','7','7','Data Referência de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','p_dataref_fim','8','7','Data Referência até:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','p_datavenc_ini','9','7','Data Vencimento de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_RecebimentosFinan','p_datavenc_fim','10','7','Data Vencimento até:','N',NULL,NULL,NULL,NULL,NULL,'N')

GO
