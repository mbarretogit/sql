SELECT distinct 
SUBSTRING(CONVERT(VARCHAR(10), DATA),1,4) ANO,
SUBSTRING(CONVERT(VARCHAR(10), DATA),6,2) MES,
SUBSTRING(CONVERT(VARCHAR(10), DATA),9,2) DIA 
FROM TBL_HISTORICO th
ORDER BY 3 desc