USE LYCEUM
GO

--DELETE FROM HD_PADREL WHERE RELATORIO = 'FTC_Relat_ContasEmAberto'
--DELETE FROM HD_RELATORIO WHERE RELATORIO= 'FTC_Relat_ContasEmAberto'


DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Inadimplentes' AND GRUPORELAT = 'FinanceiroNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','FinanceiroNG','FTC_Inadimplentes','Relatório de Inadimplentes','/Lyceum/Financeiro/FTC_Inadimplentes','N',NULL,'sqlserver')
GO

--SELECT 'Mensalidades e Serviços' DESCR, 'MS' CODIGO UNION SELECT 'Acordos' DESCR, 'A' CODIGO ORDER BY CODIGO
--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'FinanceiroNG' AND PARAMETRO LIKE '%resp%' AND RELATORIO = 'Inadimplentes'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Inadimplentes' and GRUPORELAT = 'FinanceiroNG'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','FinanceiroNG','FTC_Inadimplentes','p_unidade','1','5','Unidade de Ensino:','S',NULL,'SP: Relat_P_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_Inadimplentes','p_unidade_fisica','2','5','Unidade Física:','N',NULL,'SP: Relat_P_UnidadeFisica()','CODIGO','DESCR','Nível do Curso, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_Inadimplentes','p_curso','3','5','Curso:','N',NULL,'SP: Relat_P_Curso(@f:null@, @p_unid_resp@)','CODIGO','DESCR',NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Inadimplentes','p_resp','4','5','Código do Responsável:','N',NULL,NULL,'CODIGO','DESCR',NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Inadimplentes','p_aluno','5','5','Aluno:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Inadimplentes','p_codigo_lanc','6','5','Código de Lançamento:','S',NULL,'SP: Relat_P_CodigoLancamento()','CODIGO','DESCR','Código de Lançamento, Descrição','S')
,('Lyceum','FinanceiroNG','FTC_Inadimplentes','p_datavenc_ini','7','7','Data Vencimento de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Inadimplentes','p_datavenc_fim','8','7','Data Vencimento até:','N',NULL,NULL,NULL,NULL,NULL,'N')

GO
