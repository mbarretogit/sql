USE FTC_DATAMART
GO

DECLARE @p_ano VARCHAR(4)
DECLARE @p_semestre VARCHAR(2)

SET @p_ano = '2019'
SET @p_semestre = '2'



IF EXISTS (SELECT * FROM sys.tables WHERE type = 'U' AND OBJECT_ID = OBJECT_ID('dbo.BI_DMP'))   
BEGIN
	DELETE FROM BI_DMP WHERE ANO = @p_ano AND SEMESTRE = @p_semestre
END

ELSE 

CREATE TABLE BI_DMP --DROP TABLE BI_DMP
(
	ANO VARCHAR(4),
	SEMESTRE VARCHAR(2),
	UNIDADE_FISICA VARCHAR(20),
	UNIDADE_ENSINO VARCHAR(20),
	CURSO VARCHAR(20),
	NOME_CURSO VARCHAR(200),
	TURNO VARCHAR(1),
	ALUNO VARCHAR(20),
	TIPO_FINAN VARCHAR(30),
	TIPO_ALUNO VARCHAR(30),
	TIPO_INGRESSO VARCHAR(30),
	DATA_PERIODO VARCHAR(10),
	DATA_MATRICULA VARCHAR(10),
	DIA_CAMPANHA INT,
	VALOR_DIVIDA DECIMAL(10,2),
	VALOR_BOLSA DECIMAL(10,2),
	VALOR_BOLSA_SEM_ISENCAO DECIMAL(10,2),
	DMP DECIMAL(10,2),
	DMP_SEM_ISENCAO DECIMAL(10,2)
	 
)


INSERT INTO BI_DMP
SELECT	R.ANO,
		R.SEMESTRE,
		UNIDADE_FISICA_ALUNO,
		UNIDADE_ENSINO_ALUNO,
		CURSO,
		NOME_CURSO,
		TURNO,
		ALUNO,
		TIPO_FINAN,
		TIPO_ALUNO,
		TIPO_INGRESSO,
		DATA_PERIODO,
		DATA_MATRICULA,
		DATEDIFF(DAY,CONVERT(DATETIME,A.DATA_INI_CAMPANHA,103),CONVERT(DATETIME,DATA_MATRICULA,103))+1 AS DIA_CAMPANHA,
		0.00 AS VALOR_DIVIDA,
		0.00 AS VALOR_BOLSA,
		0.00 AS VALOR_BOLSA_SEM_ISENCAO,
		0.00 AS DMP,
		0.00 AS DMP_SEM_ISENCAO
FROM BI_REMATRICULA R
JOIN BI_AUX_DMP_DIA_CAMPANHA  A ON A.ANO = R.ANO AND A.SEMESTRE = R.SEMESTRE
WHERE R.ANO = @p_ano
AND R.SEMESTRE = @p_semestre
AND TIPO_ALUNO IN ('CALOURO','REINGRESSO')
AND STATUS_FTC IN ('MATRICULADO PAGO','MATRICULADO NAO-PAGO','PRE-MATRICULADO PAGO')


UPDATE B SET B.VALOR_DIVIDA = (SELECT ISNULL(SUM(IL.VALOR),0.00) 
					FROM LYCEUM..LY_ITEM_LANC IL
					WHERE IL.LANC_DEB IN (SELECT LD.lanc_deb 
					FROM LYCEUM..LY_LANC_DEBITO LD
					WHERE LD.ALUNO = B.ALUNO
					AND LD.ANO_REF = B.ANO
					AND LD.PERIODO_REF = B.SEMESTRE
					AND ITEM_ESTORNADO IS NULL AND NUM_BOLSA IS NULL
					AND LD.CODIGO_LANC IN ('MS','SM')))
FROM BI_DMP B
WHERE B.ANO = @p_ano
AND B.SEMESTRE = @p_semestre

UPDATE B SET B.VALOR_BOLSA = (SELECT ISNULL(SUM(IL.VALOR),0.00)
					FROM LYCEUM..LY_ITEM_LANC IL
					WHERE IL.LANC_DEB IN (SELECT LD.lanc_deb 
					FROM LYCEUM..LY_LANC_DEBITO LD
					WHERE LD.ALUNO = B.ALUNO
					AND LD.ANO_REF = B.ANO
					AND LD.PERIODO_REF = B.SEMESTRE
					AND IL.ITEM_ESTORNADO IS NULL
					AND IL.NUM_BOLSA IS NOT NULL
					AND LD.CODIGO_LANC IN ('MS','SM')))
FROM BI_DMP B
WHERE B.ANO = @p_ano
AND B.SEMESTRE = @p_semestre


UPDATE B SET B.VALOR_BOLSA_SEM_ISENCAO =	(	SELECT ISNULL(SUM(IL.VALOR),0.00)
					FROM LYCEUM..LY_ITEM_LANC IL
					JOIN LYCEUM..VW_BOLSA BO ON BO.COBRANCA = IL.COBRANCA AND BO.ITEMCOBRANCA = IL.ITEMCOBRANCA
					WHERE 1=1
					AND CONCAT(BO.ANO_INI_BOLSA,BO.MES_INI_BOLSA) <> CONCAT(ISNULL(BO.ANO_FIM_BOLSA,0),ISNULL(BO.MES_FIM_BOLSA,0))
					AND BO.DATA_CANCEL IS NULL
					AND B.TIPO_FINAN = 'PAGANTES'
					AND IL.LANC_DEB IN		(	SELECT LD.LANC_DEB 
					FROM LYCEUM..LY_LANC_DEBITO LD
					WHERE LD.ALUNO = B.ALUNO
					AND B.ANO = LD.ANO_REF
					AND B.SEMESTRE = LD.PERIODO_REF
					AND IL.ITEM_ESTORNADO IS NULL
					AND IL.NUM_BOLSA IS NOT NULL
					AND LD.CODIGO_LANC IN ('MS','SM')
					
												)
											)
FROM BI_DMP B
WHERE B.ANO = @p_ano
AND B.SEMESTRE = @p_semestre


UPDATE B SET B.DMP_SEM_ISENCAO = B.DMP, B.VALOR_BOLSA_SEM_ISENCAO = B.VALOR_BOLSA
FROM BI_DMP B
WHERE 1=1
AND B.ANO = @p_ano
AND B.SEMESTRE = @p_semestre
AND TIPO_FINAN <> 'PAGANTES'



UPDATE B SET B.DMP = B.VALOR_BOLSA/B.VALOR_DIVIDA
FROM BI_DMP B
WHERE 1=1
AND B.VALOR_DIVIDA > 0.00
AND B.ANO = @p_ano
AND B.SEMESTRE = @p_semestre

UPDATE B SET B.DMP_SEM_ISENCAO = B.VALOR_BOLSA_SEM_ISENCAO/B.VALOR_DIVIDA
FROM BI_DMP B
WHERE 1=1
AND B.VALOR_DIVIDA > 0.00
AND B.ANO = @p_ano
AND B.SEMESTRE = @p_semestre


UPDATE B SET B.DMP = 0.00
FROM BI_DMP B
WHERE 1=1
AND (B.VALOR_DIVIDA = 0.00 OR B.VALOR_BOLSA = 0.00)
AND B.ANO = @p_ano
AND B.SEMESTRE = @p_semestre

UPDATE B SET B.DMP_SEM_ISENCAO = 0.00
FROM BI_DMP B
WHERE 1=1
AND (B.VALOR_BOLSA_SEM_ISENCAO = 0.00 OR VALOR_DIVIDA = 0.00)
AND B.ANO = @p_ano
AND B.SEMESTRE = @p_semestre

UPDATE BI_DMP SET DIA_CAMPANHA = 1
WHERE DIA_CAMPANHA < 1
AND ANO = @p_ano
AND SEMESTRE = @p_semestre

UPDATE BI_DMP SET DATA_MATRICULA = DATA_PERIODO
WHERE DATA_MATRICULA IS NULL
AND ANO = @p_ano
AND SEMESTRE = @p_semestre


SELECT * FROM BI_DMP 
ORDER BY 1,2,4,5