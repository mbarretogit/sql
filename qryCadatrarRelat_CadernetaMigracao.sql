USE LYCEUM
GO

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_CadernetaMigracao' AND GRUPORELAT = 'AcademicoNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AcademicoNG','FTC_Relat_CadernetaMigracao','Caderneta de Notas por Disciplina - Migra��o','/Lyceum/Academico/FTC_Relat_CadernetaMigracao','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'AcademicoNG'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_CadernetaMigracao'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AcademicoNG','FTC_Relat_CadernetaMigracao','p_ano','1','5','Ano:','S',NULL,'SP: Relat_P_AnoLetivo()','CODIGO','DESCR','Ano, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_CadernetaMigracao','p_semestre','2','5','Semestre:','S',NULL,'SP: Relat_P_PeriodoLetivo(@p_ano@)','CODIGO','DESCR','Semestre, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_CadernetaMigracao','p_unidade','3','5','Unidade de Ensino:','S',NULL,'SP: Relat_P_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_CadernetaMigracao','p_tipo','4','5','Tipo de Curso:','S',NULL,'SP: Relat_P_TipoCurso()','CODIGO','DESCR','Tipo, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_CadernetaMigracao','p_curso','5','5','Curso:','S',NULL,'SP: Relat_P_Curso(@p_tipo@, @p_unidade@)','CODIGO','DESCR','Curso, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_CadernetaMigracao','p_disciplina','6','5','Disciplina:','S',NULL,'SP: Relat_P_Disciplina(@p_unidade@)','CODIGO','DESCR','Disciplina, Descri��o','N')
GO
