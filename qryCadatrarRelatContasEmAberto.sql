USE LYCEUM
GO

--DELETE FROM HD_PADREL WHERE RELATORIO = 'FTC_Relat_ContasEmAberto'
--DELETE FROM HD_RELATORIO WHERE RELATORIO= 'FTC_Relat_ContasEmAberto'


DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_CobrancasEmAberto' AND GRUPORELAT = 'FinanceiroNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','Relatório de Cobranças em Aberto','/Lyceum/Financeiro/FTC_Relat_CobrancasEmAberto','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'FinanceiroNG' AND RELATORIO = 'FTC_Faturamento'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_CobrancasEmAberto'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','tp_relatorio','1','5','Tipo de Relatório:','S',NULL,'SP: Relat_P_TipoRelatorio_CB_FTC()','COD','TIPO',NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_unidade','2','5','Unidade de Ensino:','S',NULL,'SP: Relat_P_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descrição','S')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_tipo','3','5','Tipo de Curso:','N',NULL,'SP: Relat_P_TipoCurso()','CODIGO','DESCR','Nível do Curso, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_curso','4','5','Curso:','N',NULL,'SP: Relat_P_Curso(@p_tipo@, @p_unidade@)','CODIGO','DESCR',NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_codigo_lanc','5','5','Código de Lançamento:','S',NULL,'SP: Relat_P_CodigoLancamento_CB_FTC(@tp_relatorio@)','CODIGO','DESCR','Código de Lançamento, Descrição','S')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_database','6','7','Data Base:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_dataref_ini','7','7','Data Referência de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_dataref_fim','8','7','Data Referência até:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_datavenc_ini','9','7','Data Vencimento de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_datavenc_fim','10','7','Data Vencimento até:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_aluno','11','5','Aluno:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_resp','12','5','Responsável Financeiro:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_CobrancasEmAberto','p_tipo_relatorio','13','5','Tipo de Relatório:','S',NULL,'SELECT ''0'' AS CODIGO, ''Sintético'' AS DESCR UNION SELECT ''1'' AS CODIGO, ''Análitico'' AS DESCR','CODIGO','DESCR','Código, Descrição','N')

GO
