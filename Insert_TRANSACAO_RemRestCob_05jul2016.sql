USE LYCEUM
GO

INSERT INTO TRANSACAO (SIS,TRANS,PUBLICATRANS,FORMTRANS,ITEMMENU,LOGGING) VALUES ('Lyceum','Remove Restituicao Cobranca','N','a','Remove Restituicao Cobranca','N')
INSERT INTO TRANSPADACES (PADACES,SIS,TRANS,PODEALT) VALUES ('LY_ADM', 'Lyceum', 'Remove Restituicao Cobranca', 'S' )
GO

--INSERT INTO TRANSACAO (SIS,TRANS,PUBLICATRANS,FORMTRANS,ITEMMENU,LOGGING) VALUES ('Lyceum','Remove Devolucao Cobranca','N','a','Remove Devolucao Cobranca','N')
--INSERT INTO TRANSPADACES (PADACES,SIS,TRANS,PODEALT) VALUES ('LY_ADM', 'Lyceum', 'Remove Devolucao Cobranca', 'S' )
--GO