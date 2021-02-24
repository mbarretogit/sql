USE LYCEUM
GO

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Docente_2017' AND GRUPORELAT = 'AvaliacaoAcademicaNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2017','Resultado Avaliação Docente - Períodos de 2017','/Lyceum/AvaliacaoAcademicaNG/FTC_Relat_Avaliacao_Docente_2017','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'AcademicoNG' AND PARAMETRO LIKE '%tipo%'

DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_Avaliacao_Docente_2017'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2017','p_avaliacaoq','1','5','Avaliação:','S',NULL,'SP: Relat_P_AvaliacaoR()','CODIGO','DESCR','Avaliação, Descrição','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2017','p_aplicacao','2','5','Aplicação:','S',NULL,'SP: Relat_P_AplicacaoD(@p_avaliacaoq@)','CODIGO','DESCR','Aplicação, Data','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2017','p_unidade','3','5','Unidade de Ensino:','S',NULL,'SP: Relat_P_A_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descrição','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2017','p_curso','4','5','Curso:','N',NULL,'SP: Relat_P_A_Curso(@p_tipo@, @p_unidade@)','CODIGO','DESCR',NULL,'N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2017','p_docente','5','5','Docente:','N',NULL,'SP: Relat_P_A_Docente(@p_aplicacao@,@p_avaliacaoq@,@p_curso@)','CODIGO','DESCR','Docente, Descrição','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2017','p_disciplina','6','5','Disciplina','N',NULL,'SP: Relat_P_A_Disciplina(@p_unidade@,@p_avaliacaoq@,@p_aplicacao@)','CODIGO','DESCR','Disciplina, Descrição','N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2017','p_turma','7','5','Turma:','N',NULL,'SP: Relat_P_A_Turma(@p_avaliacaoq@,@p_aplicacao@,@p_unidade@,@p_disciplina@)','CODIGO','DESCR',NULL,'N')
,('Lyceum','AvaliacaoAcademicaNG','FTC_Relat_Avaliacao_Docente_2017','p_tiporelatorio','8','5','Tipo de Relatório:','S',NULL,'SELECT ''0'' AS CODIGO, ''Sintético'' AS DESCR UNION SELECT ''1'' AS CODIGO, ''Análitico'' AS DESCR','CODIGO','DESCR',NULL,'N')

GO
