USE FTC_DATAMART
GO

SELECT BI.UNIDADE_FISICA_ALUNO, BI.NOME_CURSO, BI.TURNO, BI.ALUNO, BI.CPF, TIPO_TRANSF
--INTO #TEMP
FROM BI_REMATRICULA BI
WHERE BI.TIPO_ALUNO IN ('CALOURO','CALOURO-CONCLUINTE')
--AND BI.PAGO =1
AND BI.ANO= 2020 AND BI.SEMESTRE = 1
--AND UNIDADE_FISICA_ALUNO IN ('FTC-LAPA','FCS')
AND BI.TIPO_TRANSF IS NOT NULL
AND EXISTS (SELECT TOP 1 1 FROM BI_REMATRICULA BI2
			WHERE BI2.CPF = BI.CPF AND BI2.UNIDADE_FISICA_ALUNO IN ('FTC-LAPA','FCS')
			AND BI2.TIPO_TRANSF IN ( 'SAIDA UNIDADE','SAIDA CURSO') AND BI2.ANO = 2020 AND BI2.SEMESTRE = 1
			AND TIPO_ALUNO IN ('CALOURO','CALOURO-CONCLUINTE')
)
--AND CPF = '06573263561'
ORDER BY CPF

SELECT * FROM BI_REMATRICULA WHERE CPF = '06573263561'