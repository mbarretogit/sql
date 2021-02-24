CREATE PROCEDURE FTC_AVALIACAO_DOCENTE_PERIODO (@ANO VARCHAR(10), @SEMESTRE VARCHAR(3),@NUM_FUNC VARCHAR(20)) AS

--DECLARE @ANO VARCHAR(10),@SEMESTRE VARCHAR(3),@NUM_FUNC VARCHAR(20)

--SET @ANO = '2017'
--SET @SEMESTRE = '1'
--SET @NUM_FUNC = '1302'

SET NOCOUNT ON

--CONSOLIDANDO RESPOSTAS
SELECT CONVERT(VARCHAR,AQ2.DT_INICIO,103) AS DATA_APLICACAO,DO.NOME_COMPL AS DOCENTE,D.DISCIPLINA AS DISCIPLINA,D.NOME AS NOME_DISCIPLINA,C2.CURSO,C2.NOME AS NOME_CURSO,
CASE 
	WHEN Q.QUESTAO_OBJETIVA IS NOT NULL THEN Q.QUESTAO_OBJETIVA
	ELSE Q.QUESTAO_SUBJETIVA
END AS TITULO_QUESTAO,
AQ2.TITULO,R2.QUESTAO,T2.TURMA,CR2.CONCEITO-- INTO #TEMP
FROM 
	LY_RESPOSTA R2
	INNER JOIN LY_CONCEITO_RESPOSTA CR2 ON R2.TIPO_QUESTIONARIO = CR2.TIPO_QUESTIONARIO AND R2.APLICACAO = CR2.APLICACAO AND R2.QUESTAO = CR2.QUESTAO AND R2.RESPOSTA = CR2.RESPOSTA AND R2.CHAVE_RESP = CR2.CHAVE_RESP AND CR2.QUESTIONARIO = R2.QUESTIONARIO
	INNER JOIN LY_TURMA T2 ON CR2.CODIGO2 = T2.DISCIPLINA AND CR2.CODIGO3 = T2.TURMA
	INNER JOIN LY_CURSO C2 ON T2.CURSO = C2.CURSO
	INNER JOIN LY_DISCIPLINA D ON D.DISCIPLINA = T2.DISCIPLINA
	INNER JOIN LY_APLIC_QUESTIONARIO AQ2 ON AQ2.TIPO_QUESTIONARIO = R2.TIPO_QUESTIONARIO AND AQ2.APLICACAO = R2.APLICACAO AND AQ2.QUESTIONARIO = R2.QUESTIONARIO
	INNER JOIN LY_QUESTAO Q ON Q.TIPO_QUESTIONARIO = R2.TIPO_QUESTIONARIO AND Q.QUESTIONARIO = R2.QUESTIONARIO AND Q.QUESTAO = R2.QUESTAO	
	INNER JOIN LY_DOCENTE DO ON DO.NUM_FUNC = T2.NUM_FUNC
WHERE T2.NUM_FUNC = @NUM_FUNC
AND T2.ANO = @ANO  
AND T2.SEMESTRE = @SEMESTRE
AND DATEPART(YEAR,AQ2.DT_INICIO) = @ANO
AND ((1 = @SEMESTRE AND (DATEPART(MONTH,AQ2.DT_INICIO) >= 1 AND DATEPART(MONTH,AQ2.DT_INICIO) < 6))
OR (2 = @SEMESTRE AND (DATEPART(MONTH,AQ2.DT_INICIO) >= 6 AND DATEPART(MONTH,AQ2.DT_INICIO) <= 12)))  
AND EXISTS (SELECT 1 FROM LY_PARTICIPACAO_QUEST PQ10  
	 WHERE PQ10.TIPO_QUESTIONARIO = R2.TIPO_QUESTIONARIO  
	 AND PQ10.APLICACAO = R2.APLICACAO  
	 AND PQ10.DATA_PART IS NOT NULL  
	 AND PQ10.CODIGO = R2.AVA_CODIGO)
ORDER BY AQ2.TITULO,C2.CURSO,D.DISCIPLINA,T2.TURMA,R2.QUESTAO,CR2.CONCEITO

--TRAZENDO MEDIANA
SELECT T.titulo,T.curso,T.disciplina,T.questao,T.turma,
(SELECT
((SELECT MAX(CONCEITO) FROM (SELECT TOP 50 PERCENT CONCEITO FROM #TEMP T1 WHERE T1.TITULO = T.TITULO AND T1.CURSO = T.CURSO AND T1.DISCIPLINA = T.DISCIPLINA AND T1.TURMA = T.TURMA AND T1.QUESTAO = T.QUESTAO ORDER BY CONCEITO) AS BottomHalf)
 +
 (SELECT MIN(CONCEITO) FROM (SELECT TOP 50 PERCENT CONCEITO FROM #TEMP T1 WHERE T1.TITULO = T.TITULO AND T1.CURSO = T.CURSO AND T1.DISCIPLINA = T.DISCIPLINA AND T1.TURMA = T.TURMA AND T1.QUESTAO = T.QUESTAO ORDER BY CONCEITO DESC) AS TopHalf)) 
/ 2) AS MEDIANA INTO #TEMPMEDIANA
FROM #TEMP T
GROUP BY T.titulo,T.curso,T.disciplina,T.TURMA,T.QUESTAO
order by T.titulo,T.curso,T.disciplina,T.turma,T.questao

SELECT DISTINCT T.TITULO,T.curso,T.nome_curso,T.disciplina,T.nome_disciplina,T.turma,T.questao,T.TITULO_QUESTAO,TM.MEDIANA
FROM #TEMP T 
	INNER JOIN #TEMPMEDIANA TM ON T.CURSO = TM.CURSO 
								AND T.DISCIPLINA = TM.DISCIPLINA 
								AND T.TURMA = TM.TURMA 
								AND T.QUESTAO = TM.QUESTAO 
								AND T.TITULO = TM.TITULO
order by T.titulo,T.curso,T.disciplina,T.turma,T.questao

DROP TABLE #TEMPMEDIANA
DROP TABLE #TEMP

SET NOCOUNT OFF