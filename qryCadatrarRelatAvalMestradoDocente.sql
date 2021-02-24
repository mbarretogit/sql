USE LYCEUM
GO


DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Mestrado_Docente' AND GRUPORELAT = 'AvaliacaoAcademicaNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Mestrado_Docente','Resultado Avaliação Mestrado: Aluno Avalia Docente','/Lyceum/AvaliacaoAcademicaNG/FTC_Relat_Avaliacao_Mestrado_Docente','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'AcademicoNG' AND PARAMETRO LIKE '%tipo%'

DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Mestrado_Docente'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Mestrado_Docente','p_avaliacaoq','1','5','Avaliação:','S',NULL,'SELECT ''Av Docente M II'' AS CODIGO, ''Avaliacao Mestrado 2'' AS DESCR','CODIGO','DESCR','Avaliação, Descrição','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Mestrado_Docente','p_aplicacao','2','5','Aplicação:','S',NULL,'SELECT ''AVALDOCM2_20172'' AS CODIGO, ''Aplicação 2017.2'' AS DESCR UNION SELECT ''AVALDOCM2_20181'' AS CODIGO, ''Aplicação 2018.1'' AS DESCR','CODIGO','DESCR','Aplicação, Data','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Mestrado_Docente','p_unidade','3','5','Unidade de Ensino:','S',NULL,'SELECT ''04'' AS CODIGO, ''FTC Salvador'' AS DESCR','CODIGO','DESCR','Unidade Ensino, Descrição','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Mestrado_Docente','p_tiporelatorio','4','5','Tipo de Relatório:','S',NULL,'SELECT ''0'' AS CODIGO, ''Sintético'' AS DESCR UNION SELECT ''1'' AS CODIGO, ''Análitico'' AS DESCR','CODIGO','DESCR',NULL,'N')

GO
