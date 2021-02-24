
--21.0 MEDIA PERCENTUAL de BOLSA

CREATE TABLE TEMP_PERC_BOLSA (
	ANO VARCHAR(4),
	SEMESTRE VARCHAR(2),
	ALUNO VARCHAR(20),
	VALOR_SEMESTRALIDADE DECIMAL(10,2),
	MEDIA_PERC_BOLSA DECIMAL(10,2)
	)

INSERT INTO TEMP_PERC_BOLSA
SELECT ANO, SEMESTRE, ALUNO, VALOR_SEMESTRALIDADE, 0.00 AS MEDIA_PERC_BOLSA
FROM TEMP_REMATRICULA
WHERE STATUS_FTC IN ('EVADIDO','CANCELADO','TRANCADO','TRANSFERIDO') AND VALOR_SEMESTRALIDADE > 0



UPDATE B SET B.VALOR_SEMESTRALIDADE = (SELECT SUM(IL.VALOR) 
					FROM LYCEUM..LY_ITEM_LANC IL
					WHERE IL.LANC_DEB IN (SELECT LD.lanc_deb 
					FROM LYCEUM..LY_LANC_DEBITO LD
					WHERE LD.ALUNO = B.ALUNO
					AND LD.ANO_REF = CASE B.SEMESTRE WHEN '1' THEN B.ANO-1 WHEN '2' THEN B.ANO WHEN '11' THEN B.ANO-1 WHEN '22' THEN B.ANO ELSE B.ANO END 
					AND LD.PERIODO_REF = CASE B.SEMESTRE WHEN '1' THEN '2' WHEN '2' THEN '1' WHEN '22' THEN '1' WHEN '11' THEN '2' ELSE B.SEMESTRE END
					AND ITEM_ESTORNADO IS NULL AND NUM_BOLSA IS NULL
					AND LD.CODIGO_LANC = 'MS'))
FROM TEMP_PERC_BOLSA B



UPDATE B SET B.MEDIA_PERC_BOLSA = (SELECT SUM(IL.VALOR) 
					FROM LYCEUM..LY_ITEM_LANC IL
					WHERE IL.LANC_DEB IN (SELECT LD.lanc_deb 
					FROM LYCEUM..LY_LANC_DEBITO LD
					WHERE LD.ALUNO = B.ALUNO
					AND LD.ANO_REF = CASE B.SEMESTRE WHEN '1' THEN B.ANO-1 WHEN '2' THEN B.ANO WHEN '11' THEN B.ANO-1 WHEN '22' THEN B.ANO ELSE B.ANO END 
					AND LD.PERIODO_REF = CASE B.SEMESTRE WHEN '1' THEN '2' WHEN '2' THEN '1' WHEN '22' THEN '1' WHEN '11' THEN '2' ELSE B.SEMESTRE END
					AND ITEM_ESTORNADO IS NULL
					AND LD.CODIGO_LANC = 'MS'))/B.VALOR_SEMESTRALIDADE
FROM TEMP_PERC_BOLSA B
WHERE B.VALOR_SEMESTRALIDADE > 0



UPDATE BI SET BI.MEDIA_PERC_BOLSA = B.MEDIA_PERC_BOLSA, BI.VALOR_SEMESTRALIDADE = B.VALOR_SEMESTRALIDADE
FROM TEMP_REMATRICULA BI
JOIN TEMP_PERC_BOLSA B ON B.ALUNO = BI.ALUNO AND B.ANO = BI.ANO AND B.SEMESTRE = BI.SEMESTRE


SELECT SUM(IL.VALOR) 
					FROM LYCEUM..LY_ITEM_LANC IL
					WHERE IL.LANC_DEB IN (SELECT LD.lanc_deb 
					FROM LYCEUM..LY_LANC_DEBITO LD
					WHERE LD.ALUNO = '172070080'
					AND LD.ANO_REF = 2018--CASE B.SEMESTRE WHEN '1' THEN B.ANO-1 WHEN '2' THEN B.ANO WHEN '11' THEN B.ANO-1 WHEN '22' THEN B.ANO ELSE B.ANO END 
					AND LD.PERIODO_REF = 2--CASE B.SEMESTRE WHEN '1' THEN '2' WHEN '2' THEN '1' WHEN '22' THEN '1' WHEN '11' THEN '2' ELSE B.SEMESTRE END
					AND ITEM_ESTORNADO IS NULL
					AND LD.CODIGO_LANC = 'MS')

/*

SELECT * FROM LYCEUM..LY_LANC_DEBITO WHERE ALUNO = '161030736' AND ANO_REF = 2018 AND PERIODO_REF = 2 AND CODIGO_LANC = 'MS'
SELECT SUM(VALOR) FROM LYCEUM..LY_ITEM_LANC WHERE ALUNO = '161030736' AND CODIGO_LANC = 'MS' AND ITEM_ESTORNADO IS NULL
SELECT * FROM LYCEUM..LY_ITEM_LANC WHERE ALUNO = '161030736' AND CODIGO_LANC = 'MS' AND ITEM_ESTORNADO IS NULL
SELECT SUM(VALOR) FROM LYCEUM..LY_ITEM_LANC WHERE ALUNO = '182030581' AND NUM_BOLSA IS NULL AND ITEM_ESTORNADO IS NULL AND CODIGO_LANC = 'MS'
SELECT * FROM LYCEUM..LY_ITEM_LANC WHERE ALUNO = '161030736'

*/