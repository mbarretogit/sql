USE LYCEUM
GO

DELETE FROM HD_RELATORIO WHERE GRUPORELAT = 'FinanceiroNG' AND RELATORIO = 'FTC_Relat_SomatorioDividasPeriodoLetivo'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','FinanceiroNG','FTC_Relat_SomatorioDividasPeriodoLetivo','Relatório de Somatório de Dívidas de Mensalidade no Período','/Lyceum/Financeiro/FTC_Relat_SomatorioDividasPeriodoLetivo','N',NULL,'sqlserver')
GO

--select * from HD_PARAMETRO_RELATORIO where GRUPORELAT = 'FinanceiroNG' AND  RELATORIO = 'AlunosIngressantes'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_SomatorioDividasPeriodoLetivo'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','FinanceiroNG','FTC_Relat_SomatorioDividasPeriodoLetivo','p_ano','1','5','Ano:','S',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_SomatorioDividasPeriodoLetivo','p_semestre','2','5','Semestre:','S',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_SomatorioDividasPeriodoLetivo','p_unidade','3','5','Unidade de Ensino:','N',NULL,'SP: Relat_P_UnidadeEnsino()','CODIGO','DESCR','Código, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_Relat_SomatorioDividasPeriodoLetivo','p_curso','4','5','Curso','N',NULL,'SP: Relat_P_Curso(@null@, @p_unidade@)','CODIGO','DESCR','Curso, Nome','N')
GO