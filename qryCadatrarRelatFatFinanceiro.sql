USE LYCEUM
GO

--DELETE FROM HD_PADREL WHERE RELATORIO = 'FTC_ValidaTurmas'
--DELETE FROM HD_RELATORIO WHERE RELATORIO= 'FTC_ValidaTurmas'


DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_FaturamentoFinanceiro' AND GRUPORELAT = 'FinanceiroNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','Relat�rio de Faturamento Financeiro','/Lyceum/Financeiro/FTC_FaturamentoFinanceiro','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'FinanceiroNG' AND RELATORIO = 'FTC_Faturamento'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_FaturamentoFinanceiro'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
 ('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_unidade','1','5','Unidade de Ensino:','N',NULL,'SP: Relat_P_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descri��o','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_unid_fisica','2','5','Unidade F�sica:','N',NULL,'SP: Relat_P_UnidadeFisica()','CODIGO','DESCR','Unidade F�sica, Descri��o','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_tipo','3','5','Tipo de Curso:','N',NULL,'SP: Relat_P_TipoCurso()','CODIGO','DESCR','Tipo, Descri��o','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_curso','4','5','Curso:','N',NULL,'SP: Relat_P_Curso(@f:null@, @p_unidade@)','CODIGO','DESCR','Curso, Descri��o','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_cpfoucnpj_resp','5','5','CPF/CNPJ Respons�vel:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_codigo_lanc','6','5','C�digo de Lan�amento:','N',NULL,'SP: Relat_P_CodigoLancamento()','CODIGO','DESCR','CODLANC, Descri��o','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_num_cobranca','7','5','Tipo de Cobran�a:','N',NULL,'SP: Relat_P_TipoCobranca()','CODIGO','DESCR','C�digo, Descri��o','N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_exibe_estornadas','8','5','Exibe Estornadas?','S',NULL,'LOV: S, N',NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_datageracao_ini','9','7','Data Gera��o de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_datageracao_fim','10','7','Data Gera��o at�:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_datavenc_ini','11','7','Data Vencimento de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_datavenc_fim','12','7','Data Vencimento at�:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_dataref_ini','13','7','Data Refer�ncia de:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_FaturamentoFinanceiro','p_dataref_fim','14','7','Data Refer�ncia at�:','N',NULL,NULL,NULL,NULL,NULL,'N')

GO
