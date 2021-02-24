USE LYCEUM
GO

--DELETE FROM HD_PADREL WHERE RELATORIO = 'FTC_ValidaTurmas'
--DELETE FROM HD_RELATORIO WHERE RELATORIO= 'FTC_ValidaTurmas'


DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_FaturamentoFinanceiro' AND GRUPORELAT = 'FinanceiroNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','Relatório de Faturamento Financeiro','/Lyceum/Financeiro/FTC_FaturamentoFinanceiro','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'FinanceiroNG' AND RELATORIO = 'FTC_Faturamento'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_FaturamentoFinanceiro'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
 ('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_unidade','1','5','Unidade de Ensino:','N',NULL,'SP: Relat_P_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_unid_fisica','2','5','Unidade Física:','N',NULL,'SP: Relat_P_UnidadeFisica()','CODIGO','DESCR','Unidade Física, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_tipo','3','5','Tipo de Curso:','N',NULL,'SP: Relat_P_TipoCurso()','CODIGO','DESCR','Tipo, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_curso','4','5','Curso:','N',NULL,'SP: Relat_P_Curso(@f:null@, @p_unidade@)','CODIGO','DESCR','Curso, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_cpfoucnpj_resp','5','5','CPF/CNPJ Responsável:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_codigo_lanc','6','5','Código de Lançamento:','N',NULL,'SP: Relat_P_CodigoLancamento()','CODIGO','DESCR','CODLANC, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_num_cobranca','7','5','Tipo de Cobrança:','N',NULL,'SP: Relat_P_TipoCobranca()','CODIGO','DESCR','Código, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_exibe_estornadas','8','5','Exibe Estornadas?','S',NULL,'LOV: S, N',NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_datageracao_ini','9','7','Data Geração de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_datageracao_fim','10','7','Data Geração até:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_datavenc_ini','11','7','Data Vencimento de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_datavenc_fim','12','7','Data Vencimento até:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_dataref_ini','13','7','Data Referência de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_dataref_fim','14','7','Data Referência até:','N',NULL,NULL,NULL,NULL,NULL,'N')

GO
