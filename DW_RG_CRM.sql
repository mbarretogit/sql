USE DW_DATAMART
GO

SELECT	I.DATA_INSCRICAO AS DATA,
		CO.NOME AS CONCURSO,
		I.NUMERO_INSCRICAO,
		C.NOME AS CLIENTE_POTENCIAL,
		REPLACE(REPLACE(C.CPF,'.',''),'-','') AS CPF_CLIENTE,
		O.CURSO AS OFERTA,
		O.TURNO AS TURNO_OFERTADO,
		I.SIT_MATRICULA AS SITUACAO_CONCURSO,
		I.CONSULTOR AS CODIGO_CONSULTOR,
		C.CELULAR,
		C.EMAIL,
		I.MATRICULA_CANCELADA,
		I.CRC AS CODIGO_CRC,
		I.CONTEUDO_CAMPANHA, 
		I.MIDIA_CAMPANHA,
		I.NOME_CAMPANHA,
		I.DATE_SITUACAO_CHAMADA AS DATA_SITUACAO_CHAMADA,
		I.SCROREBRG AS SCORE_BRG,
		CO.TIPO_CONCURSO,
		CONCAT(CO.ANO,'.',CO.SEMESTRE) AS INTAKE,
		O.UNIDADE AS SEDE
FROM FAT_DY_INSCRICAO I
JOIN DIM_DY_CANDIDATO C ON C.ID_CANDIDATO = I.ID_CANDIDATO
JOIN DIM_DY_OFERTAS O ON O.ID_OFERTAS = I.ID_OFERTAS
JOIN DIM_DY_CONCURSO CO ON CO.ID_CONCURSO = I.ID_CONCURSO
WHERE 1=1
AND CONCAT(CO.ANO,CO.SEMESTRE) >= '20192'
ORDER BY 2,6

