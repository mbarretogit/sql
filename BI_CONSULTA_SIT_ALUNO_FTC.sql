DROP TABLE TEMP_SIT_ALUNO_LYCEUM 

SELECT DISTINCT
			(SELECT MAX(CONCAT(ANO,'/',SEMESTRE)) FROM BI_REMATRICULA WHERE ALUNO = A.ALUNO) AS PERIODO_LETIVO,
			STATUS_FTC,
			SIT_MATRICULA,
			A.SIT_ALUNO,
			UNIDADE_ENSINO_ALUNO,
			NOME_UNIDADE_ENSINO_ALUNO,
			UNIDADE_FISICA_ALUNO,
			TIPO_CURSO,
			BI.CURSO,
			NOME_CURSO,
			--BI.CURRICULO,
			BI.TURNO,
			--BI.SERIE,
			--BI.SERIE_CALCULADA,
			BI.TIPO_ALUNO,
			BI.TIPO_INGRESSO,
			BI.ANO_INGRESSO,
			BI.SEM_INGRESSO,
			BI.ALUNO,
			A.CONCURSO,
			A.CANDIDATO,
			CPF,
			NOME_ALUNO,
			--E_MAIL,
			--DDD,
			--FONE,
			--CELULAR,
			--CEP,
			--MUNICIPIO,
			--PAGO,
			--NAO_PAGO,
			TIPO_FINAN,
			FINAN,
			--DATA_PERIODO,
			--INDICE_REPROVACAO,
			--QTD_INADIMP,
			--PERC_FALTAS,
			DATA_INGRESSO,
			DATA_MATRICULA,
			--ANTECIP_FINAN,
			--DT_ANTECIP,
			--TIPO_ANTECIP,
			--VALOR_ATENCIP,
			--PERFIL_EVASAO,
			ULTIMA_MATRICULA,
			--SOLICITOU_PLANO,
			--SOLICITOU_HIST,
			--TIPO_TRANSF,
			--VALOR_MENSALIDADE,
			--VALOR_SEMESTRALIDADE,
			DT_ENCERRAMENTO
			--BOLSISTA,
			--DATA_PAGAMENTO,
			--TIPO_PAGAMENTO
			--MEDIA_PERC_BOLSA
			INTO TEMP_SIT_ALUNO_LYCEUM
FROM BI_REMATRICULA BI
JOIN LYCEUM..LY_ALUNO A ON A.ALUNO = BI.ALUNO
WHERE 1=1
AND CONCAT(BI.ANO,'/',BI.SEMESTRE) = (SELECT MAX(CONCAT(BI2.ANO,'/',BI2.SEMESTRE)) FROM BI_REMATRICULA BI2 WHERE BI2.ALUNO = BI.ALUNO)

ORDER BY 4,8

UPDATE TEMP_SIT_ALUNO_LYCEUM SET PERIODO_LETIVO = '', STATUS_FTC = '', SIT_MATRICULA = 'Sem-Matr�cula', FINAN = '', DATA_MATRICULA = ''
WHERE PERIODO_LETIVO <> '2020/1'

UPDATE T SET T.PERIODO_LETIVO = (SELECT MAX(CONCAT(BI2.ANO,'/',BI2.SEMESTRE))
								FROM BI_REMATRICULA BI2 
								WHERE BI2.ALUNO = T.ALUNO 
								)
FROM TEMP_SIT_ALUNO_LYCEUM T

UPDATE T SET T.ULTIMA_MATRICULA = T.PERIODO_LETIVO
FROM TEMP_SIT_ALUNO_LYCEUM T
WHERE T.ULTIMA_MATRICULA IS NULL OR T.ULTIMA_MATRICULA = ''

SELECT * FROM TEMP_SIT_ALUNO_LYCEUM

