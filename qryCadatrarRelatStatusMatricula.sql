USE LYCEUM
GO

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_StatusMatricula' AND GRUPORELAT = 'AcademicoNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AcademicoNG','FTC_Relat_StatusMatricula','Acompanhamento Matr�cula','/Lyceum/Academico/FTC_Relat_StatusMatricula','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'AcademicoNG'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_StatusMatricula'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AcademicoNG','FTC_Relat_StatusMatricula','p_ano','1','5','Ano:','S',NULL,'SP: Relat_P_AnoLetivo()','CODIGO','DESCR','Ano, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_StatusMatricula','p_semestre','2','5','Semestre:','S',NULL,'SP: Relat_P_PeriodoLetivo(@p_ano@)','CODIGO','DESCR','Semestre, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_StatusMatricula','p_unidade','3','5','Unidade de Ensino:','N',NULL,'SP: Relat_P_UnidadeEnsino()','CODIGO','DESCR','Unidade Ensino, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_StatusMatricula','p_tipo','4','5','Tipo de Curso:','N',NULL,'SP: Relat_P_TipoCurso()','CODIGO','DESCR','Tipo, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_StatusMatricula','p_curso','5','5','Curso:','N',NULL,'SP: Relat_P_Curso(@p_tipo@, @p_unidade@)','CODIGO','DESCR','Curso, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_StatusMatricula','p_turno','6','5','Turno:','N',NULL,'SP: Relat_P_Turno()','CODIGO','DESCR','Turno, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_StatusMatricula','p_ano_ingresso','7','5','Ano Ingresso:','N',NULL,'SP: Relat_P_AnoLetivo()','CODIGO','DESCR','Ano, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_StatusMatricula','p_sem_ingresso','8','5','Semestre Ingresso:','N',NULL,'SP: Relat_P_PeriodoLetivo(@p_ano_ingresso@)','CODIGO','DESCR','Semestre, Descri��o','N')
,('Lyceum','AcademicoNG','FTC_Relat_StatusMatricula','p_tipo_relatorio','9','5','Tipo de Relat�rio:','S',NULL,'SELECT ''0'' AS CODIGO, ''Sint�tico'' AS DESCR UNION SELECT ''1'' AS CODIGO, ''An�litico'' AS DESCR ','CODIGO','DESCR','C�digo, Descri��o','N')

GO
