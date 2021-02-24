USE LYCEUM
GO

--DELETE FROM HD_PADREL WHERE RELATORIO = 'FTC_ValidaTurmas'
--DELETE FROM HD_RELATORIO WHERE RELATORIO= 'FTC_ValidaTurmas'


DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_Turmas_Curso' AND GRUPORELAT = 'AcademicoNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','FTC_Relat_Turmas_Curso','FTC_Relat_Turmas_Curso','Relatório de Turmas por Unidade e Curso','/Lyceum/Academico/FTC_Relat_Turmas_Curso','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'CurriculoGradeNG' AND RELATORIO = 'FTC_ValidaTurmas'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_Turmas_Curso'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES

('Lyceum','AcademicoNG','FTC_Relat_Turmas_Curso','p_ano','1','6','Ano:','S',NULL,NULL,NULL,NULL,'Ano, Descrição','N')
,('Lyceum','AcademicoNG','FTC_Relat_Turmas_Curso','p_semestre','2','6','Semestre:','S',NULL,NULL,NULL,NULL,'Semestre, Descrição','N')
,('Lyceum','AcademicoNG','FTC_Relat_Turmas_Curso','p_unidade','3','5','Unidade de Ensino:','N',NULL,'SP: Relat_P_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descrição','N')
,('Lyceum','AcademicoNG','FTC_Relat_Turmas_Curso','p_tipo_curso','4','5','Tipo de Curso:','N',NULL,'SP: Relat_P_TipoCurso()','CODIGO','DESCR','Tipo de Curso, Descrição','N')
,('Lyceum','AcademicoNG','FTC_Relat_Turmas_Curso','p_curso','5','5','Tipo de Curso:','N',NULL,'SP: Relat_P_Curso()','CODIGO','DESCR','Tipo de Curso, Descrição','N')
GO
