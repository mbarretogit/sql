--ALUNOS ATIVOS Q NAO POSSUEM PRE-MATRICULA

--select DISTINCT ALUNO from LY_ALUNO where CURSO in ('3261') and SIT_ALUNO = 'Ativo' 
select DISTINCT ALUNO, NOME_COMPL, CURSO, SIT_ALUNO from LY_ALUNO where CURSO in ('3261') and SIT_ALUNO = 'Ativo' 

except

select DISTINCT A.ALUNO, A.NOME_COMPL, A.CURSO, A.SIT_ALUNO, VW.SIT_MATRICULA from VW_MATRICULA_E_PRE_MATRICULA VW
JOIN LY_ALUNO A ON A.ALUNO = VW.ALUNO where A.ALUNO in (select aluno from LY_ALUNO where A.CURSO in ('3261') and A.SIT_ALUNO = 'Ativo')


--VERIFICANDO SE AS TURMAS POSSUEM DOCENTES ASSOCIADOS

select DISTINCT VW.TURMA,VW.DISCIPLINA,VW.ANO,VW.SEMESTRE from VW_MATRICULA_E_PRE_MATRICULA VW
JOIN LY_ALUNO A ON A.ALUNO = VW.ALUNO where A.ALUNO in (select aluno from LY_ALUNO where A.CURSO in ('3261') and A.SIT_ALUNO = 'Ativo')

SELECT DISTINCT T.DISCIPLINA,T.NUM_FUNC, T.TURMA, T.ANO, T.SEMESTRE  
FROM LY_TURMA T, VW_MATRICULA_E_PRE_MATRICULA M, LY_CURSO C   
WHERE T.ANO = M.ANO  AND T.SEMESTRE = M.SEMESTRE   AND T.DISCIPLINA = M.DISCIPLINA   AND T.TURMA = M.TURMA
AND M.SIT_MATRICULA NOT IN ('Cancelado','Trancado')   
AND T.NUM_FUNC NOT IN ('1','388','825')  AND T.CURSO = C.CURSO  AND C.CURSO = '3261'  AND M.ALUNO = '%%CHAVE1'

SELECT DISTINCT T.ANO, T.SEMESTRE,T.TURMA,T.DISCIPLINA, DI.NOME,T.NUM_FUNC, D.NOME_COMPL
--SELECT DISTINCT A.ALUNO, A.NOME_COMPL, A.CURSO, A.SIT_ALUNO, M.SIT_MATRICULA
FROM LY_TURMA T, VW_MATRICULA_E_PRE_MATRICULA M, LY_CURSO C, LY_DOCENTE D, LY_DISCIPLINA DI, LY_ALUNO A
WHERE T.ANO = M.ANO  AND T.SEMESTRE = M.SEMESTRE   AND T.DISCIPLINA = M.DISCIPLINA   AND T.TURMA = M.TURMA   AND D.NUM_FUNC = T.NUM_FUNC AND DI.DISCIPLINA = T.DISCIPLINA AND A.ALUNO = M.ALUNO
AND T.NUM_FUNC NOT IN ('1','388','825')  AND T.CURSO = C.CURSO  AND C.CURSO = '3261'  --AND M.ALUNO = '%%CHAVE1'
ORDER BY 1

--COORDENADOR DO CURSO

SELECT * FROM LY_COORDENACAO WHERE CURSO IN ('3261')
SELECT * FROM LY_DOCENTE WHERE NUM_FUNC = '253'

--ALUNOS ATIVOS DE METRADO: FILTRO DE CURSO

select DISTINCT CURSO from LY_ALUNO 
where CURSO in ('3261') 
and SIT_ALUNO = 'Ativo' 
AND ALUNO = '170040150'


--ALUNOS FTC QUE EST�O ATIVOS
SELECT DISTINCT A.ALUNO  
FROM LY_ALUNO A JOIN LY_CURSO C ON C.CURSO = a.CURSO 
WHERE A.SIT_ALUNO = 'Ativo' AND C.TIPO IN ('GRADUACAO','TECNOLOGO') 
AND EXISTS (SELECT 1 FROM LY_MATRICULA VW WHERE VW.ALUNO = A.ALUNO AND VW.SIT_MATRICULA NOT IN ('Cancelado','Trancado'))
AND ALUNO = '161050531'

--DOCENTES QUE LECIONAM PARA O ALUNO
SELECT DISTINCT T.DISCIPLINA,T.NUM_FUNC, T.TURMA, T.ANO, T.SEMESTRE  
FROM LY_TURMA T, LY_MATRICULA M, LY_CURSO C   
WHERE T.ANO = M.ANO  AND T.SEMESTRE = M.SEMESTRE   AND T.DISCIPLINA = M.DISCIPLINA  
 AND T.TURMA = M.TURMA   AND T.NUM_FUNC NOT IN ('1','388','825')  
 AND T.CURSO = C.CURSO  AND C.TIPO IN ('GRADUACAO','TECNOLOGO')  AND M.ALUNO = '161050531'

 SELECT * FROM LY_PARTICIPACAO_QUEST WHERE CODIGO = '161050531'

    SELECT 
	DISTINCT PQ.APLICACAO,   
     UF.UNIDADE_FIS AS COD_UNIDADE,  
     UF.NOME_COMP AS NOME_UNIDADE,  
     COUNT(DISTINCT PQ.CODIGO) AS QTD_APLICADOS,   
     COUNT(DISTINCT PQ2.CODIGO) AS QTD_RESPONDIDOS  
   FROM LY_PARTICIPACAO_QUEST PQ  
   JOIN LY_QUESTAO_APLICADA QA ON QA.APLICACAO = PQ.APLICACAO AND QA.TIPO_QUESTIONARIO = PQ.TIPO_QUESTIONARIO AND QA.PAR_TIPO_OBJETO = PQ.TIPO_OBJETO AND QA.PAR_CODIGO = PQ.CODIGO  
   JOIN LY_TURMA T ON PQ.CODIGO = T.NUM_FUNC  
   JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = T.FACULDADE  
   JOIN LY_CURSO C ON C.CURSO = T.CURSO  
   LEFT JOIN LY_PARTICIPACAO_QUEST PQ2 ON PQ2.CODIGO = PQ.CODIGO AND PQ2.APLICACAO = PQ.APLICACAO AND PQ2.DATA_PART IS NOT NULL  
   WHERE 1=1   
     AND C.TIPO IN ('GRADUACAO','TECNOLOGO')   
     AND T.ANO = '2017'   
     AND T.SEMESTRE = '2'  
     AND PQ.APLICACAO IN ('AVALDOCENTE2_20172')  
   GROUP BY PQ.APLICACAO,UF.UNIDADE_FIS,UF.NOME_COMP  
   ORDER BY 2,4  



   
   SELECT DISTINCT C.CURSO,PQ.*
     --PQ.APLICACAO,   
     --UF.UNIDADE_FIS AS COD_UNIDADE,  
     --UF.NOME_COMP AS NOME_UNIDADE,  
     --C.CURSO AS COD_CURSO,   
     --C.NOME AS NOME_CURSO,   
     --COUNT(DISTINCT PQ.CODIGO) AS QTD_APLICADOS,   
     --COUNT(DISTINCT PQ2.CODIGO) AS QTD_RESPONDIDOS  
   FROM LY_PARTICIPACAO_QUEST PQ  
   JOIN LY_QUESTAO_APLICADA QA ON QA.APLICACAO = PQ.APLICACAO AND QA.TIPO_QUESTIONARIO = PQ.TIPO_QUESTIONARIO AND QA.PAR_TIPO_OBJETO = PQ.TIPO_OBJETO AND QA.PAR_CODIGO = PQ.CODIGO  
   JOIN LY_TURMA T ON PQ.CODIGO = T.NUM_FUNC  
   JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = T.FACULDADE  
   JOIN LY_CURSO C ON C.CURSO = T.CURSO  
   LEFT JOIN LY_PARTICIPACAO_QUEST PQ2 ON PQ2.CODIGO = PQ.CODIGO AND PQ2.APLICACAO = PQ.APLICACAO AND PQ2.DATA_PART IS NOT NULL  
   WHERE 1=1   
     AND C.TIPO IN ('GRADUACAO','TECNOLOGO')  
     AND T.ANO = '2017'   
     AND T.SEMESTRE = '2'  
     AND PQ.APLICACAO IN ('AVALDOCENTE2_20172')  
     --AND (C.CURSO = ISNULL(@p_curso,C.CURSO) OR @p_curso = '')  
     AND C.FACULDADE = '04' 
   --GROUP BY PQ.APLICACAO,UF.UNIDADE_FIS,UF.NOME_COMP,C.CURSO,C.NOME  
   ORDER BY 3