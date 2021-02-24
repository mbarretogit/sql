
select COUNT(pessoa) QTD_PESSOA, CPF, NomeAluno,UnidadeEnsino 
INTO #TEMP_PESSOA
from VW_ALUNOS_CENSO 
group by CPF, NomeAluno, UnidadeEnsino
having COUNT(pessoa) > 1

SELECT V.PESSOA, T.CPF, V.Aluno, V.NomeAluno, V.UnidadeEnsino,  A.SIT_ALUNO
--SELECT DISTINCT V.NOMEALUNO
--INTO #TEMP_ALUNO
FROM VW_ALUNOS_CENSO V
JOIN #TEMP_PESSOA T ON T.CPF = V.CPF 
JOIN LY_ALUNO A ON A.ALUNO = V.Aluno
ORDER BY 5,2