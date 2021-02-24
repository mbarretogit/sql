USE HADES
GO
--Inser��o do Relat�rio na Lista de Relat�rios
INSERT INTO HD_RELATORIO VALUES ('Lyceum','Financeiro','FTC_RELACAO_CHEQUES','Lista Cadastro de Cheques','FTC_RELACAO_CHEQUES.rpt','N',NULL,NULL)
GO

--Cria��o dos par�metros
--DELETE FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'FTC_RELACAO_CHEQUES'
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Financeiro','FTC_RELACAO_CHEQUES','Unidade',1,5,NULL,'S',NULL,'select faculdade, nome_comp from VW_UNIDADE_ENSINO ORDER BY FACULDADE','faculdade','nome_comp','C�digo, Unidade','N')
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Financeiro','FTC_RELACAO_CHEQUES','DataRecebimento',2,7,NULL,'S','','','','','','N')

GO

--
INSERT INTO HD_PADREL VALUES ('DomSecGeral','Lyceum','Financeiro','FTC_RELACAO_CHEQUES')
INSERT INTO HD_PADREL VALUES ('DomSecret','Lyceum','Financeiro','FTC_RELACAO_CHEQUES')
--SELECT * FROM HD_PADACES