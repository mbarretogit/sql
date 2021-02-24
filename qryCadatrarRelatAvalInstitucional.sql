USE LYCEUM
GO

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Institucional' AND GRUPORELAT = 'AcademicoNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AcademicoNG','FTC_Relat_Avaliacao_Institucional','Resultado Avaliação Institucional','/Lyceum/Academico/FTC_Relat_Avaliacao_Institucional','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'AcademicoNG' AND PARAMETRO LIKE '%tipo%'

DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Institucional'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AcademicoNG','FTC_Relat_Avaliacao_Institucional','p_avaliacaoq','1','5','Avaliação:','S',NULL,'SP: Relat_P_AvaliacaoI()','CODIGO','DESCR','Avaliação, Descrição','N')
,('Lyceum','AcademicoNG','FTC_Relat_Avaliacao_Institucional','p_aplicacao','2','5','Aplicação:','S',NULL,'SP: Relat_P_AplicacaoD(@p_avaliacaoq@)','CODIGO','DESCR','Aplicação, Data','N')
,('Lyceum','AcademicoNG','FTC_Relat_Avaliacao_Institucional','p_unidade','3','5','Unidade de Ensino:','S',NULL,'SP: Relat_P_A_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descrição','N')
,('Lyceum','AcademicoNG','FTC_Relat_Avaliacao_Institucional','p_tiporelatorio','8','5','Tipo de Relatório:','S',NULL,'SELECT ''0'' AS CODIGO, ''Sintético'' AS DESCR UNION SELECT ''1'' AS CODIGO, ''Análitico'' AS DESCR','CODIGO','DESCR',NULL,'N')

GO
