USE LYCEUM
GO

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Institucional' AND GRUPORELAT = 'AcademicoNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AcademicoNG','FTC_Relat_Avaliacao_Institucional','Resultado Avalia��o Institucional','/Lyceum/Academico/FTC_Relat_Avaliacao_Institucional','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'AcademicoNG' AND PARAMETRO LIKE '%tipo%'

DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Institucional'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AcademicoNG','FTC_Relat_Avaliacao_Institucional','p_avaliacaoq','1','5','Avalia��o:','S',NULL,'SP: Relat_P_AvaliacaoI()','CODIGO','DESCR','Avalia��o, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_Avaliacao_Institucional','p_aplicacao','2','5','Aplica��o:','S',NULL,'SP: Relat_P_AplicacaoD(@p_avaliacaoq@)','CODIGO','DESCR','Aplica��o, Data','N')
,('Lyceum','AcademicoNG','FTC_Relat_Avaliacao_Institucional','p_unidade','3','5','Unidade de Ensino:','S',NULL,'SP: Relat_P_A_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_Avaliacao_Institucional','p_tiporelatorio','8','5','Tipo de Relat�rio:','S',NULL,'SELECT ''0'' AS CODIGO, ''Sint�tico'' AS DESCR UNION SELECT ''1'' AS CODIGO, ''An�litico'' AS DESCR','CODIGO','DESCR',NULL,'N')

GO
