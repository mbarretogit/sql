SELECT	R2.TIPO_QUESTIONARIO, 
		R2.QUESTIONARIO, 
		R2.APLICACAO, 
		QA.PAR_TIPO_OBJETO AS AVALIADOR,
		QA.PAR_CODIGO AS COD_AVALIADOR,
		QA.TIPO_OBJETO AS AVALIADO,
		QA.CODIGO AS COD_AVALIADO, 
		Q.QUESTAO, 
		Q.QUESTAO_OBJETIVA, 
		R2.RESPOSTA , 
		CQ.VALOR, 
		CQ.DESCRICAO   
FROM LY_RESPOSTA R2
INNER JOIN LY_CONCEITO_RESPOSTA CR2 ON R2.TIPO_QUESTIONARIO = CR2.TIPO_QUESTIONARIO 
			AND R2.APLICACAO = CR2.APLICACAO 
			AND R2.QUESTAO = CR2.QUESTAO 
			AND R2.RESPOSTA = CR2.RESPOSTA 
			AND R2.CHAVE_RESP = CR2.CHAVE_RESP 
			AND CR2.QUESTIONARIO = R2.QUESTIONARIO
INNER JOIN LY_APLIC_QUESTIONARIO AQ2 ON AQ2.TIPO_QUESTIONARIO = R2.TIPO_QUESTIONARIO 
			AND AQ2.APLICACAO = R2.APLICACAO 
			AND AQ2.QUESTIONARIO = R2.QUESTIONARIO
INNER JOIN LY_QUESTAO Q ON Q.TIPO_QUESTIONARIO = R2.TIPO_QUESTIONARIO 
			AND Q.QUESTIONARIO = R2.QUESTIONARIO 
			AND Q.QUESTAO = R2.QUESTAO
INNER JOIN LY_PARTICIPACAO_QUEST PQ ON PQ.TIPO_OBJETO = R2.TIPO_OBJETO
			AND PQ.TIPO_QUESTIONARIO = R2.TIPO_QUESTIONARIO
			AND PQ.QUESTIONARIO = R2.QUESTIONARIO
			AND PQ.APLICACAO = R2.APLICACAO
INNER JOIN LY_QUESTAO_APLICADA QA ON QA.TIPO_QUESTIONARIO = R2.TIPO_QUESTIONARIO
			AND QA.TIPO_QUESTIONARIO = PQ.TIPO_QUESTIONARIO
			AND QA.QUESTIONARIO = R2.QUESTIONARIO
			AND QA.QUESTIONARIO = PQ.QUESTIONARIO
			AND QA.APLICACAO = R2.APLICACAO
			AND QA.APLICACAO = PQ.APLICACAO
			AND QA.TIPO_OBJETO = R2.TIPO_OBJETO
			AND QA.CODIGO = R2.CODIGO
			AND QA.PAR_TIPO_OBJETO = PQ.TIPO_OBJETO
			AND QA.PAR_CODIGO = PQ.CODIGO
INNER JOIN LY_CONCEITOS_QUEST CQ ON CQ.TIPO = Q.TIPO
			AND CQ.VALOR = R2.RESPOSTA		
--WHERE R2.TIPO_QUESTIONARIO = 'Avalia��o Docente I'