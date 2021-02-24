USE LYCEUM
GO


DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Mestrado_Docente' AND GRUPORELAT = 'AvaliacaoAcademicaNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Mestrado_Docente','Resultado Avalia��o Mestrado: Aluno Avalia Docente','/Lyceum/AvaliacaoAcademicaNG/FTC_Relat_Avaliacao_Mestrado_Docente','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'AcademicoNG' AND PARAMETRO LIKE '%tipo%'

DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Mestrado_Docente'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Mestrado_Docente','p_avaliacaoq','1','5','Avalia��o:','S',NULL,'SELECT ''Av Docente M II'' AS CODIGO, ''Avaliacao Mestrado 2'' AS DESCR','CODIGO','DESCR','Avalia��o, Descri��o','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Mestrado_Docente','p_aplicacao','2','5','Aplica��o:','S',NULL,'SELECT ''AVALDOCM2_20172'' AS CODIGO, ''Aplica��o 2017.2'' AS DESCR UNION SELECT ''AVALDOCM2_20181'' AS CODIGO, ''Aplica��o 2018.1'' AS DESCR','CODIGO','DESCR','Aplica��o, Data','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Mestrado_Docente','p_unidade','3','5','Unidade de Ensino:','S',NULL,'SELECT ''04'' AS CODIGO, ''FTC Salvador'' AS DESCR','CODIGO','DESCR','Unidade Ensino, Descri��o','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Mestrado_Docente','p_tiporelatorio','4','5','Tipo de Relat�rio:','S',NULL,'SELECT ''0'' AS CODIGO, ''Sint�tico'' AS DESCR UNION SELECT ''1'' AS CODIGO, ''An�litico'' AS DESCR','CODIGO','DESCR',NULL,'N')

GO
