USE LYCEUM
GO

SELECT REPLACE(EL.MENSAGEM,'http://aluno-redeftc.sistemalyceum.com.br:80/AOnline','') AS MSG_NOVA, EL.MENSAGEM AS MSG_VELHA 
--UPDATE EL SET EL.MENSAGEM = REPLACE(EL.MENSAGEM,'http://aluno-redeftc.sistemalyceum.com.br:80/AOnline','')
FROM LY_EMAIL_LOTE EL
WHERE 1=1
AND EL.MENSAGEM LIKE '%http://aluno-redeftc.sistemalyceum.com.br:80/AOnline%'
GO

