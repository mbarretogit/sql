USE LYCEUM
GO

DELETE FROM HD_RELATORIO WHERE RELATORIO = 'FTC_Relat_AlunosAtivosPos' AND GRUPORELAT = 'AcademicoNG'
INSERT INTO HD_RELATORIO
VALUES('Lyceum','AcademicoNG','FTC_Relat_AlunosAtivosPos','P�s-gradua��o: Alunos Ativos com Cobran�as em Aberto','/Lyceum/Academico/FTC_Relat_AlunosAtivosPos','N',NULL,'sqlserver')
GO


--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE GRUPORELAT = 'AcademicoNG' and PARAMETRO LIKE '%sit%'
--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE PARAMETRO LIKE '%ini'
DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_Relat_AlunosAtivosPos'
INSERT INTO HD_PARAMETRO_RELATORIO
VALUES
('Lyceum','AcademicoNG','FTC_Relat_AlunosAtivosPos','p_unidade','1','5','Unidade de Ensino:','N',NULL,'SP: FTC_Relat_P_UnidadeEnsinoPos()','CODIGO','DESCR','Unidade, Descri��o','N')

GO
