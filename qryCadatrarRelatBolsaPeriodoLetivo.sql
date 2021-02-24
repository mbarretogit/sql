USE LYCEUM
GO

--DELETE FROM HD_PADREL WHERE RELATORIO = 'FTC_Relat_BolsasAlunoPeriodoLetivo'

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_BolsasAlunoPeriodoLetivo' AND GRUPORELAT = 'FinanceiroNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','FinanceiroNG','FTC_Relat_BolsasAlunoPeriodoLetivo','Bolsas Lançadas no Período Letivo','/Lyceum/Financeiro/FTC_Relat_BolsasAlunoPeriodoLetivo','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'FinanceiroNG' AND PARAMETRO LIKE '%curso%'

DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_BolsasAlunoPeriodoLetivo'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','FinanceiroNG','FTC_Relat_BolsasAlunoPeriodoLetivo','p_ano','1','5','Ano:','S',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_BolsasAlunoPeriodoLetivo','p_semestre','2','5','Semestre:','S',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_BolsasAlunoPeriodoLetivo','p_faculdade','3','5','Unidade de Ensino:','S',NULL,'SP: Relat_P_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descrição','S')
,('Lyceum','FinanceiroNG','FTC_Relat_BolsasAlunoPeriodoLetivo','p_tipo','4','5','Tipo de Curso:','N',NULL,'SP: Relat_P_TipoCurso()','CODIGO','DESCR',NULL,'S')
,('Lyceum','FinanceiroNG','FTC_Relat_BolsasAlunoPeriodoLetivo','p_curso','5','5','Curso:','N',NULL,'SP: Relat_P_Curso(@p_faculdade@, @p_unid_resp@)','CODIGO','DESCR','Docente, Descrição','N')
,('Lyceum','FinanceiroNG','FTC_Relat_BolsasAlunoPeriodoLetivo','p_ano_ingresso','6','5','Ano de Ingresso:','N',NULL,NULL,NULL,NULL,NULL,'N')
,('Lyceum','FinanceiroNG','FTC_Relat_BolsasAlunoPeriodoLetivo','p_sem_ingresso','7','5','Semestre de Ingresso:','N',NULL,NULL,NULL,NULL,NULL,'N')
GO
