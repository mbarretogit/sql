USE BI_DATAMART
GO

SELECT *
FROM DW_RG_CRM 
WHERE NUMERO_INSCRICAO IN ('CAN-402991-FTC','CAN-402504-FTC')



SELECT TOP 10 * FROM DW_RG_CRM ORDER BY DATA DESC

SELECT DISTINCT CODIGO_CRC FROM DW_RG_CRM ORDER BY 1

SELECT * FROM DW_RG_CRM WHERE SEDE = 'FTC DE CAMA�ARI'