USE LYCEUM
GO

update AQ SET RESPOSTA_OBRIGATORIA = 'S' 
FROM LY_APLIC_QUESTIONARIO AQ 
WHERE AQ.DT_INICIO >= '2018-10-15' AND AQ.ATIVO = 'S'
GO