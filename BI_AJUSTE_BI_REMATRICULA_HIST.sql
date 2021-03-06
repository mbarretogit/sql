USE FTC_DATAMART
GO

--DELETE FROM BI_REMATRICULA WHERE ANO = 2018 AND SEMESTRE = 1

		INSERT INTO BI_REMATRICULA
		SELECT DISTINCT
			ANO,
			SEMESTRE, 
			STATUS_FTC,
			UNIDADE_ENSINO_ALUNO,
			NOME_UNIDADE_ENSINO_ALUNO,
			UNIDADE_FISICA_ALUNO,
			TIPO_CURSO,
			CURSO,
			NOME_CURSO,
			CURRICULO,
			TURNO,
			SERIE,
			SERIE_CALCULADA,
			TIPO_ALUNO,
			TIPO_INGRESSO,
			ANO_INGRESSO,
			SEM_INGRESSO,
			ALUNO,
			CPF,
			NOME_ALUNO,
			E_MAIL,
			DDD,
			FONE,
			CELULAR,
			CEP,
			MUNICIPIO,
			SIT_MATRICULA,
			PAGO,
			NAO_PAGO,
			TIPO_FINAN,
			FINAN,
			DATA_PERIODO,
			INDICE_REPROVACAO,
			QTD_INADIMP,
			PERC_FALTAS,
			DATA_MATRICULA,
			ANTECIP_FINAN,
			DT_ANTECIP,
			TIPO_ANTECIP,
			VALOR_ATENCIP,
			PERFIL_EVASAO,
			ULTIMA_MATRICULA,
			SOLICITOU_PLANO,
			SOLICITOU_HIST,
			TIPO_TRANSF,
			VALOR_MENSALIDADE,
			VALOR_SEMESTRALIDADE,
			DT_ENCERRAMENTO,
			BOLSISTA,
			MEDIA_PERC_BOLSA,
			SIT_MATRICULA_ANTERIOR,
			PROFISSAO,
			CARGO,
			ESPECIALIDADE,
			EMPRESA,
			AREA,
			DEPARTAMENTO,
			BAIRRO_COMERCIAL,
			PAIS_COMERCIAL,
			COD_MUNICIPIO_COMERCIAL,
			MUNICIPIO_COMERCIAL,
			NECESSIDADE_ESPECIAL,
			COR_RACA,
			RENDA,
			CONTRIBUI_RENDA_FAMILIAR,
			RELIGIAO,
			FORMACAO_ANTERIOR,
			TIPO_FORMACAO_ANTERIOR,
			ORIGEM_FORMACAO_ANTERIOR,
			ANO_CONCL_FORMACAO_ANTERIOR,
			PAIS_FORMACAO_ANTERIOR,
			COD_MUNICIPIO_FORMACAO_ANTERIOR,
			MUNICIPIO_FORMACAO_ANTERIOR,
			UF_FORMACAO_ANTERIOR,
			SEXO,
			DATA_NASCIMENTO,
			ESTADO_CIVIL,
			NACIONALIDADE,
			PAIS_NASCIMENTO,
			COD_MUNICIPIO_RESIDENCIAL,
			MUNICIPIO_RESIDENCIAL,
			UF_RESIDENCIAL,
			PAIS_RESIDENCIAL,
			END_CORRETO,
			BAIRRO,
			DATA_INGRESSO,
			DATA_PAGAMENTO,
			TIPO_PAGAMENTO,
			TEM_NOTA,
			TIPO_FINAN_ANTERIOR,
			DIA_CAMPANHA
FROM BI_REMATRICULA_HIST
WHERE DATA_HIST BETWEEN '2020-02-17' AND '2020-02-18'
AND ANO = 2018 AND SEMESTRE = 2