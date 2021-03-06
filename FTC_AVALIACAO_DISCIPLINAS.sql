USE LYCEUM
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.FTC_Relat_Avaliacao_Docente_2018'))
   exec('CREATE PROCEDURE [dbo].[FTC_Relat_Avaliacao_Docente_2018] AS BEGIN SET NOCOUNT OFF; END')
GO 
  
ALTER PROCEDURE FTC_Relat_Avaliacao_Docente_2018  
  @p_avaliacaoq VARCHAR(30)  
 ,@p_aplicacao VARCHAR(30)  
 ,@p_unidade VARCHAR(15)  
 ,@p_curso VARCHAR(20)  
 ,@p_docente VARCHAR(15)   
 ,@p_turma VARCHAR (30)  
 ,@p_disciplina VARCHAR(20)
 ,@p_tipo_relatorio NUMERIC(1)  
AS  
BEGIN  
/*  
Autor: Miguel Barreto  
Atualizado em: 13/07/2017  
*/  
-- Teste:  
--EXEC FTC_Relat_Avaliacao_Docente_2018 'Avalia��o Docente I', 'AVALDOCENTE1_20171', '05', NULL, NULL, NULL,NULL,'1'
  
--PARAMETROS PARA TESTE DA PROCEDURE  
/*
DECLARE  

  
  @p_avaliacaoq VARCHAR(30)  
 ,@p_aplicacao VARCHAR(30)
 ,@p_unidade VARCHAR(15) 
 ,@p_curso VARCHAR(30)  
 ,@p_docente NUMERIC(15)  
 ,@p_turma VARCHAR (20)  
 ,@p_disciplina VARCHAR(20)  
  
 SET @p_avaliacaoq = 'Avalia��o DocenteIV'
 SET @p_aplicacao = 'AVALDOCENTE4_20172'
 SET @p_unidade = '04'
 SET @p_curso = NULL 
 SET @p_docente = NULL
 SET @p_turma = NULL  
 SET @p_disciplina = NULL  
 
  
  */
  
-- TABELA #TEMP_SUM_MEDIACURSOGERAL  
  SELECT   
   R.TIPO_QUESTIONARIO  
   ,R.APLICACAO  
   ,R.QUESTAO  
   ,T.FACULDADE  
   ,C.CURSO  
   ,SUM(CONVERT(DECIMAL(10,2),CR.CONCEITO)) AS SOMA  
   ,COUNT(CR.CONCEITO) AS QUANTIDADE  
   INTO #TEMP_SUM_MEDIACURSOGERAL --DROP TABLE #TEMP_SUM_MEDIACURSOGERAL  
  FROM LY_APLIC_QUESTIONARIO AS AQ  
  INNER JOIN LY_RESPOSTA AS R ON R.QUESTIONARIO = AQ.QUESTIONARIO  
   AND R.TIPO_QUESTIONARIO = AQ.TIPO_QUESTIONARIO  
   AND R.APLICACAO = AQ.APLICACAO  
  INNER JOIN LY_CONCEITO_RESPOSTA AS CR ON CR.TIPO_QUESTIONARIO = R.TIPO_QUESTIONARIO  
   AND CR.QUESTIONARIO = R.QUESTIONARIO  
   AND CR.APLICACAO = R.APLICACAO  
   AND CR.QUESTAO = R.QUESTAO  
   AND CR.RESPOSTA = R.RESPOSTA  
   AND CR.CHAVE_RESP = R.CHAVE_RESP  
  INNER JOIN LY_TURMA AS T ON T.DISCIPLINA = CR.CODIGO2  
   AND T.TURMA = CR.CODIGO3 AND T.ANO = CR.CODIGO AND T.SEMESTRE = CR.CODIGO1 AND T.NUM_FUNC = CR.CODIGO4  
  INNER JOIN LY_CURSO AS C ON T.CURSO = C.CURSO  AND C.TIPO IN ('GRADUACAO','TECNOLOGO')
  WHERE 1 = 1  
   AND T.UNIDADE_RESPONSAVEL = ISNULL(@p_unidade,T.UNIDADE_RESPONSAVEL)  
   --AND T.ANO = '2017'
   --AND T.SEMESTRE = '2'
   AND T.TURMA = ISNULL(@p_turma, T.TURMA)  
   AND T.CURSO = ISNULL(@p_curso, T.CURSO)
   AND T.NUM_FUNC = ISNULL(@p_docente, T.NUM_FUNC)  
   AND T.DISCIPLINA = ISNULL(@p_disciplina, T.DISCIPLINA)  
   AND AQ.TIPO_QUESTIONARIO = @p_avaliacaoq  
   AND R.APLICACAO = @p_aplicacao  
   AND ISNULL(R.AVA_CODIGO1,'') = ISNULL(CR.CODIGO1,'')  
   AND ISNULL(R.AVA_CODIGO2,'') = ISNULL(CR.CODIGO2,'')  
   AND ISNULL(R.AVA_CODIGO3,'') = ISNULL(CR.CODIGO3,'')  
   AND ISNULL(R.AVA_CODIGO4,'') = ISNULL(CR.CODIGO4,'')  
  GROUP BY  
   R.TIPO_QUESTIONARIO  
   ,R.APLICACAO  
   ,R.QUESTAO  
   ,T.FACULDADE  
   ,C.CURSO  
 
  
-- TABELA #TEMP_RELATORIO_ALUNO1  
SELECT  
 AQ.TIPO_QUESTIONARIO AS TIPO_QUESTIONARIO  
 ,AQ.APLICACAO AS APLICACAO  
 ,AQ.QUESTIONARIO AS QUESTIONARIO  
 ,R.QUESTAO AS QUESTAO  
 ,CAST(NULL AS INT) AS ORDEM  
 ,CAST(NULL AS VARCHAR(500)) AS PERGUNTA  
 ,D.NOME_COMPL AS PROFESSOR  
 ,C.CURSO AS CODIGO_CURSO  
 ,C.NOME AS CURSO  
 ,T.FACULDADE AS CODIGO_UNIDADE_FISICA  
 ,UF.NOME_COMP AS UNIDADE_FISICA  
 ,R.AVA_CODIGO3 AS TURMA  
 ,T.DISCIPLINA AS CODIGO_DISCIPLINA  
 ,DISC.NOME_COMPL AS DISCIPLINA  
 ,T.ANO AS ANO  
 ,T.SEMESTRE AS SEMESTRE  
 ,CAST(NULL AS INT) AS QTDTURMA  
 ,CAST(NULL AS NUMERIC(10,2)) AS MEDIACURSOGERAL  
 ,CAST(SUM(CR.CONCEITO) AS DECIMAL(10,2)) AS MEDIAPROFESSOR  
 ,SUM(  
  CASE CR.CONCEITO  
   WHEN 1 THEN 1.00  
   ELSE 0.00  
  END  
 ) AS SEMPRE  
 ,SUM(  
  CASE CR.CONCEITO  
   WHEN 2 THEN 1.00  
   ELSE 0.00  
  END  
 ) AS EVENTUALMENTE  
 ,SUM(  
  CASE CR.CONCEITO  
   WHEN 3 THEN 1.00  
   ELSE 0.00  
  END  
 ) AS RARAMENTE  
 ,SUM(  
  CASE CR.CONCEITO  
   WHEN 4 THEN 1.00  
   ELSE 0.00  
  END  
 ) AS NUNCA  
 ,COUNT(DISTINCT R.AVA_CODIGO) AS NUMERO  
 INTO #TEMP_RELATORIO_ALUNO1 --DROP TABLE #TEMP_RELATORIO_ALUNO1  
FROM LY_APLIC_QUESTIONARIO AS AQ  
INNER JOIN LY_RESPOSTA AS R ON R.QUESTIONARIO = AQ.QUESTIONARIO  
 AND R.TIPO_QUESTIONARIO = AQ.TIPO_QUESTIONARIO  
 AND R.APLICACAO = AQ.APLICACAO  
INNER JOIN LY_CONCEITO_RESPOSTA AS CR ON CR.TIPO_QUESTIONARIO = R.TIPO_QUESTIONARIO  
 AND CR.QUESTIONARIO = R.QUESTIONARIO  
 AND CR.APLICACAO = R.APLICACAO  
 AND CR.QUESTAO = R.QUESTAO  
 AND CR.RESPOSTA = R.RESPOSTA  
 AND CR.CHAVE_RESP = R.CHAVE_RESP  
INNER JOIN LY_TURMA AS T ON T.DISCIPLINA = R.AVA_CODIGO2  
 AND T.TURMA = R.AVA_CODIGO3 AND T.ANO = CR.CODIGO AND T.SEMESTRE = CR.CODIGO1 AND T.NUM_FUNC = CR.CODIGO4  
INNER JOIN LY_DISCIPLINA AS DISC ON DISC.DISCIPLINA = T.DISCIPLINA  
INNER JOIN LY_DOCENTE AS D ON D.NUM_FUNC = T.NUM_FUNC  
INNER JOIN LY_UNIDADE_FISICA AS UF ON UF.UNIDADE_FIS = T.FACULDADE  
--INNER JOIN LY_PARTICIPACAO_QUEST AS PQ ON PQ.TIPO_QUESTIONARIO = R.TIPO_QUESTIONARIO  
-- AND PQ.APLICACAO = R.APLICACAO  
-- AND PQ.CODIGO = R.AVA_CODIGO  
INNER JOIN LY_CURSO AS C ON C.CURSO = T.CURSO AND C.TIPO IN ('GRADUACAO','TECNOLOGO') 
WHERE 1 = 1  
	AND T.UNIDADE_RESPONSAVEL = ISNULL(@p_unidade,T.UNIDADE_RESPONSAVEL)  
 AND AQ.TIPO_QUESTIONARIO = @p_avaliacaoq  
 AND R.APLICACAO = @p_aplicacao  
 --AND T.ANO = ISNULL(@p_ano,T.ANO)
 --AND T.SEMESTRE = ISNULL(@p_semestre,T.SEMESTRE)
 AND T.CURSO = ISNULL(@p_curso, T.CURSO)
 AND T.NUM_FUNC = ISNULL(@p_docente, T.NUM_FUNC)  
 AND T.DISCIPLINA = ISNULL(@p_disciplina, T.DISCIPLINA)  
 AND T.TURMA = ISNULL(@p_turma, T.TURMA)  
GROUP BY  
 AQ.TIPO_QUESTIONARIO  
 ,AQ.APLICACAO  
 ,AQ.QUESTIONARIO  
 ,R.QUESTAO  
 ,D.NOME_COMPL  
 ,C.CURSO  
 ,C.NOME  
 ,T.FACULDADE  
 ,UF.NOME_COMP  
 ,R.AVA_CODIGO3  
 ,T.DISCIPLINA  
 ,DISC.NOME_COMPL  
 ,T.ANO  
 ,T.SEMESTRE  
  
  
-- UPDATE ORDEM E PERGUNTA  
UPDATE #TEMP_RELATORIO_ALUNO1 SET  
 ORDEM = Q.ORDEM  
 ,PERGUNTA = Q.QUESTAO_OBJETIVA  
FROM LY_QUESTAO AS Q  
INNER JOIN #TEMP_RELATORIO_ALUNO1 AS TRA ON TRA.QUESTIONARIO = Q.QUESTIONARIO  
 AND TRA.TIPO_QUESTIONARIO = Q.TIPO_QUESTIONARIO  
 AND TRA.QUESTAO = Q.QUESTAO  
  
  
-- TABELA #TEMP_RELATORIO_ALUNO2  
SELECT  
 TIPO_QUESTIONARIO  
 ,APLICACAO  
 ,QUESTIONARIO  
 ,QUESTAO  
 ,ORDEM  
 ,PERGUNTA  
 ,PROFESSOR  
 ,CODIGO_CURSO  
 ,CURSO  
 ,CODIGO_UNIDADE_FISICA  
 ,UNIDADE_FISICA  
 ,TURMA  
 ,CODIGO_DISCIPLINA  
 ,DISCIPLINA  
 ,ANO  
 ,SEMESTRE  
 ,QTDTURMA  
 ,MEDIACURSOGERAL  
 ,MEDIAPROFESSOR  
 ,SEMPRE  
 ,EVENTUALMENTE  
 ,RARAMENTE  
 ,NUNCA  
 --,NUMERO  
 ,SUM(SEMPRE + EVENTUALMENTE + RARAMENTE + NUNCA) AS NUMERO --SUBSTITUIR O NUMERO (DE PARTICIPANTES)  
 INTO #TEMP_RELATORIO_ALUNO2 --DROP TABLE #TEMP_RELATORIO_ALUNO2  
FROM #TEMP_RELATORIO_ALUNO1  
GROUP BY  
 TIPO_QUESTIONARIO  
 ,APLICACAO  
 ,QUESTIONARIO  
 ,QUESTAO  
 ,ORDEM  
 ,PERGUNTA  
 ,PROFESSOR  
 ,CODIGO_CURSO  
 ,CURSO  
 ,CODIGO_UNIDADE_FISICA  
 ,UNIDADE_FISICA  
 ,TURMA  
 ,CODIGO_DISCIPLINA  
 ,DISCIPLINA  
 ,ANO  
 ,SEMESTRE  
 ,QTDTURMA  
 ,MEDIACURSOGERAL  
 ,MEDIAPROFESSOR  
 ,SEMPRE  
 ,EVENTUALMENTE  
 ,RARAMENTE  
 ,NUNCA  
 ,NUMERO  
  
  
-- UPDATE PERCENTUAIS DE RESPOSTA  
UPDATE #TEMP_RELATORIO_ALUNO2 SET  
 MEDIAPROFESSOR = (MEDIAPROFESSOR / NUMERO)  
UPDATE #TEMP_RELATORIO_ALUNO2 SET  
 SEMPRE = (SEMPRE / NUMERO) * 100  
UPDATE #TEMP_RELATORIO_ALUNO2 SET  
 EVENTUALMENTE = (EVENTUALMENTE / NUMERO) * 100  
UPDATE #TEMP_RELATORIO_ALUNO2 SET  
 RARAMENTE = (RARAMENTE / NUMERO) * 100  
UPDATE #TEMP_RELATORIO_ALUNO2 SET  
 NUNCA = (NUNCA / NUMERO) * 100  
 
 IF @p_tipo_relatorio = '0'
 BEGIN

 DECLARE @V_NUMERO INT   
 SET @V_NUMERO = dbo.fn_AvalDocQtdPartic(@p_avaliacaoq, @p_aplicacao, @p_unidade, @p_curso)  
 
 UPDATE #TEMP_RELATORIO_ALUNO2 SET  
 NUMERO = @V_NUMERO
 
 END
 
  
-- VERFICACAO DO PERCENTUAL:  
/*  
SELECT  
 TIPO_QUESTIONARIO  
 ,APLICACAO  
 ,QUESTIONARIO  
 ,QUESTAO  
 ,ORDEM  
 ,PERGUNTA  
 ,PROFESSOR  
 ,CODIGO_CURSO  
 ,CURSO  
 ,CODIGO_UNIDADE_FISICA  
 ,UNIDADE_FISICA  
 ,TURMA  
 ,CODIGO_DISCIPLINA  
 ,DISCIPLINA  
 ,ANO  
 ,SEMESTRE  
 ,QTDTURMA  
 ,MEDIACURSOGERAL  
 ,MEDIAPROFESSOR  
 ,SEMPRE  
 ,EVENTUALMENTE  
 ,RARAMENTE  
 ,NUNCA  
 ,NUMERO  
 ,(SEMPRE + EVENTUALMENTE + RARAMENTE + NUNCA) AS SOMA  
FROM #TEMP_RELATORIO_ALUNO2  
ORDER BY  
 SOMA  
*/  
  
  
-- ATUALIZANDO QTDTURMA  
/*
UPDATE #TEMP_RELATORIO_ALUNO2 SET  
 QTDTURMA =  
 (  
  SELECT  
   COUNT(DISTINCT MATRIC.ALUNO)  
  FROM LY_HISTMATRICULA AS MATRIC  
  WHERE 1 = 1  
   AND MATRIC.DISCIPLINA = #TEMP_RELATORIO_ALUNO2.CODIGO_DISCIPLINA  
   AND MATRIC.TURMA = #TEMP_RELATORIO_ALUNO2.TURMA  
   AND MATRIC.ANO = #TEMP_RELATORIO_ALUNO2.ANO  
   AND MATRIC.SEMESTRE = #TEMP_RELATORIO_ALUNO2.SEMESTRE  
   --AND MATRIC.SIT_MATRICULA NOT IN ('CANCELADO', 'DISPENSADO', 'TRANCADO')  
 )  
 +  
 (  
  SELECT  
   COUNT(DISTINCT MATRIC.ALUNO)  
  FROM LY_HISTMATRICULA AS MATRIC  
  WHERE 1 = 1  
   AND MATRIC.DISCIPLINA = #TEMP_RELATORIO_ALUNO2.CODIGO_DISCIPLINA  
   AND MATRIC.SUBTURMA1 = #TEMP_RELATORIO_ALUNO2.TURMA  
   AND MATRIC.ANO = #TEMP_RELATORIO_ALUNO2.ANO  
   AND MATRIC.SEMESTRE = #TEMP_RELATORIO_ALUNO2.SEMESTRE  
   --AND MATRIC.SIT_MATRICULA NOT IN ('CANCELADO', 'DISPENSADO', 'TRANCADO')  
 )  
 +  
 (  
  SELECT  
   COUNT(DISTINCT MATRIC.ALUNO)  
  FROM LY_MATRICULA AS MATRIC  
  WHERE 1 = 1  
   AND MATRIC.DISCIPLINA = #TEMP_RELATORIO_ALUNO2.CODIGO_DISCIPLINA  
   AND MATRIC.TURMA = #TEMP_RELATORIO_ALUNO2.TURMA  
   AND MATRIC.ANO = #TEMP_RELATORIO_ALUNO2.ANO  
   AND MATRIC.SEMESTRE = #TEMP_RELATORIO_ALUNO2.SEMESTRE  
   --AND MATRIC.SIT_MATRICULA NOT IN ('CANCELADO', 'DISPENSADO', 'TRANCADO')  
 )  
 +  
 (  
  SELECT  
   COUNT(DISTINCT MATRIC.ALUNO)  
  FROM LY_MATRICULA AS MATRIC  
  WHERE 1 = 1  
   AND MATRIC.DISCIPLINA = #TEMP_RELATORIO_ALUNO2.CODIGO_DISCIPLINA  
   AND MATRIC.SUBTURMA1 = #TEMP_RELATORIO_ALUNO2.TURMA  
   AND MATRIC.ANO = #TEMP_RELATORIO_ALUNO2.ANO  
   AND MATRIC.SEMESTRE = #TEMP_RELATORIO_ALUNO2.SEMESTRE  
   --AND MATRIC.SIT_MATRICULA NOT IN ('CANCELADO', 'DISPENSADO', 'TRANCADO')  
 )  
  
  
-- UPDATE MEDIACURSOGERAL
  
UPDATE #TEMP_RELATORIO_ALUNO2 SET  
 MEDIACURSOGERAL = CAST(TMPSUM.SOMA / TMPSUM.QUANTIDADE AS VARCHAR(10))  
FROM #TEMP_SUM_MEDIACURSOGERAL AS TMPSUM  
WHERE 1 = 1  
 AND #TEMP_RELATORIO_ALUNO2.TIPO_QUESTIONARIO = TMPSUM.TIPO_QUESTIONARIO    
 AND #TEMP_RELATORIO_ALUNO2.APLICACAO = TMPSUM.APLICACAO    
 AND #TEMP_RELATORIO_ALUNO2.ORDEM = TMPSUM.QUESTAO    
 AND #TEMP_RELATORIO_ALUNO2.CODIGO_CURSO = TMPSUM.CURSO    
 AND #TEMP_RELATORIO_ALUNO2.CODIGO_UNIDADE_FISICA = TMPSUM.FACULDADE    
  */
  
-- RELATORIO FINAL  
SELECT  
 *  
FROM #TEMP_RELATORIO_ALUNO2  
WHERE 1=1  
ORDER BY  
 PROFESSOR  
 ,TURMA  
 ,DISCIPLINA  
 ,APLICACAO  
 ,ORDEM  
  
  
-- APAGA TABELAS  
  
 DROP TABLE #TEMP_SUM_MEDIACURSOGERAL;  
  
 DROP TABLE #TEMP_RELATORIO_ALUNO1;  
  
 DROP TABLE #TEMP_RELATORIO_ALUNO2;  
  
END  
  
