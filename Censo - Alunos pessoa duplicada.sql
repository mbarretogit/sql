
select COUNT(pessoa) QTD_PESSOA, CPF, NomeAluno,UnidadeEnsino 
INTO #TEMP_PESSOA
from VW_ALUNOS_CENSO 
group by CPF, NomeAluno, UnidadeEnsino
having COUNT(pessoa) > 1

SELECT PESSOA, T.CPF, NomeAluno, UnidadeEnsino 
INTO #TEMP_ALUNO
FROM LY_PESSOA P
JOIN #TEMP_PESSOA T ON T.CPF = P.CPF WHERE P.CPF <> '00000000000'
ORDER BY 2

select UNIDADE_FISICA, PESSOA, ALUNO, NOME_COMPL, SIT_ALUNO  from LY_ALUNO WHERE PESSOA IN (SELECT DISTINCT PESSOA FROM #TEMP_ALUNO)