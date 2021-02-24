USE LYCEUM
GO

--DELETE FROM HD_PADREL WHERE RELATORIO = 'FTC_Relat_Avaliacao_Docente'

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Docente_2018' AND GRUPORELAT = 'AvaliacaoAcademicaNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2018','Resultado Avalia��o Docente - Per�odos a partir de 2018','/Lyceum/AvaliacaoAcademicaNG/FTC_Relat_Avaliacao_Docente_2018','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'AcademicoNG' AND PARAMETRO LIKE '%tipo%'

DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Docente_2018'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2018','p_avaliacaoq','1','5','Avalia��o:','S',NULL,'SP: Relat_P_AvaliacaoR()','CODIGO','DESCR','Avalia��o, Descri��o','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2018','p_aplicacao','2','5','Aplica��o:','S',NULL,'SP: Relat_P_AplicacaoDNOVO(@p_avaliacaoq@)','CODIGO','DESCR','Aplica��o, Data','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2018','p_unidade','3','5','Unidade de Ensino:','S',NULL,'SP: Relat_P_A_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descri��o','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2018','p_curso','4','5','Curso:','N',NULL,'SP: Relat_P_A_Curso(@p_tipo@, @p_unidade@)','CODIGO','DESCR',NULL,'N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2018','p_docente','5','5','Docente:','N',NULL,'SP: Relat_P_A_Docente(@p_aplicacao@,@p_avaliacaoq@,@p_curso@)','CODIGO','DESCR','Docente, Descri��o','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2018','p_disciplina','6','5','Disciplina','N',NULL,'SP: Relat_P_A_Disciplina(@p_unidade@,@p_avaliacaoq@,@p_aplicacao@)','CODIGO','DESCR','Disciplina, Descri��o','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2018','p_turma','7','5','Turma:','N',NULL,'SP: Relat_P_A_Turma(@p_avaliacaoq@,@p_aplicacao@,@p_unidade@,@p_disciplina@)','CODIGO','DESCR',NULL,'N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2018','p_tipo_relatorio','8','5','Tipo de Relat�rio:','S',NULL,'SELECT ''0'' AS CODIGO, ''Sint�tico'' AS DESCR UNION SELECT ''1'' AS CODIGO, ''An�litico'' AS DESCR','CODIGO','DESCR',NULL,'N')

GO
