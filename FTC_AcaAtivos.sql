USE HADES
GO
--Inser��o do Relat�rio na Lista de Relat�rios
INSERT INTO HD_RELATORIO VALUES ('Lyceum','Academico','FTC_AcaAtivos','Rela��o Geral de Alunos Ativos com Contatos do Respons�vel','FTC_AcaAtivos.rpt','N',NULL,NULL)
GO

--Cria��o dos par�metros
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Academico','FTC_AcaAtivos','Ano Ingresso',1,5,NULL,'N',NULL,NULL,NULL,NULL,NULL,'N')
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Academico','FTC_AcaAtivos','Per. Ingresso',2,5,NULL,'N',NULL,'select distinct ano,periodo,id_reduzida from vw_periodo_letivo order by ano desc, periodo asc','periodo',NULL,'Ano,Per�odo,Abreviatura','N')
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Academico','FTC_AcaAtivos','Unidade',3,5,NULL,'S',NULL,'select faculdade, nome_comp from VW_UNIDADE_ENSINO ORDER BY FACULDADE','faculdade','nome_comp','C�digo, Unidade','N')
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Academico','FTC_AcaAtivos','Curso',4,5,NULL,'N',NULL,'select curso, nome from vw_curso','curso','nome','C�digo, Curso','N')
GO

--
INSERT INTO HD_PADREL VALUES ('DomSecGeral','Lyceum','Academico','FTC_AcaAtivos')
INSERT INTO HD_PADREL VALUES ('DomSecret','Lyceum','Academico','FTC_AcaAtivos')
--SELECT * FROM HD_PADACES