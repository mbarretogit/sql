USE HADES
GO
INSERT INTO HD_RELATORIO VALUES ('Lyceum','Financeiro','FTCFinFechamentoCaixa','Fechamento de Caixa','FTC_FinFechamentoCaixa.rpt','N',NULL,NULL)
GO

INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Financeiro','FTCFinFechamentoCaixa','Usuário',1,5,NULL,'S',NULL,'select usuario, nomeusuario from usuario','usuario','nomeusuario','usuario, nomeusuario','N')
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Financeiro','FTCFinFechamentoCaixa','Data de abertura',2,7,NULL,'S',NULL,NULL,NULL,NULL,NULL,'N')
INSERT INTO HD_PARAMETRO_RELATORIO VALUES ('Lyceum','Financeiro','FTCFinFechamentoCaixa','Hora de abertura',3,5,NULL,'N','00:00',NULL,NULL,NULL,NULL,'N')
GO
--SELECT * FROM HD_RELATORIO hr WHERE hr.RELATORIO = 'FinFechamentoCaixa'
--SELECT * FROM HD_PARAMETRO_RELATORIO hr WHERE hr.RELATORIO = 'FinFechamentoCaixa'