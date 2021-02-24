USE HADES
GO
--Inserção do Relatório na Lista de Relatórios
INSERT INTO HD_RELATORIO VALUES ('Lyceum','Academico','FTC_AcaAtivos','Relação Geral de Alunos Ativos com Contatos do Responsável','FTC_AcaAtivos.rpt','N',NULL,NULL)
GO

--Criação dos parâmetros
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Academico','FTC_AcaAtivos','Ano Ingresso',1,5,NULL,'N',NULL,NULL,NULL,NULL,NULL,'N')
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Academico','FTC_AcaAtivos','Per. Ingresso',2,5,NULL,'N',NULL,'select distinct ano,periodo,id_reduzida from vw_periodo_letivo order by ano desc, periodo asc','periodo',NULL,'Ano,Período,Abreviatura','N')
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Academico','FTC_AcaAtivos','Unidade',3,5,NULL,'S',NULL,'select faculdade, nome_comp from VW_UNIDADE_ENSINO ORDER BY FACULDADE','faculdade','nome_comp','Código, Unidade','N')
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Academico','FTC_AcaAtivos','Curso',4,5,NULL,'N',NULL,'select curso, nome from vw_curso','curso','nome','Código, Curso','N')
GO

--
INSERT INTO HD_PADREL VALUES ('DomSecGeral','Lyceum','Academico','FTC_AcaAtivos')
INSERT INTO HD_PADREL VALUES ('DomSecret','Lyceum','Academico','FTC_AcaAtivos')
--SELECT * FROM HD_PADACES