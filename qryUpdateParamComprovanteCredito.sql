USE LYCEUM
GO

UPDATE HD_PARAMETRO_RELATORIO
SET OBRIGATORIO = 'S', VALOR = 0
WHERE PARAMETRO = 'p_maquina'
AND RELATORIO = 'ComprovanteCredito'
AND GRUPORELAT = 'FinanceiroNG'
GO

--SELECT * FROM HD_PARAMETRO_RELATORIO WHERE RELATORIO = 'ComprovanteCredito'