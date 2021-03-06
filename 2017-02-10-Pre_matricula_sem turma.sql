
SELECT PM.ANO, PM.SEMESTRE, A.UNIDADE_FISICA, UF.NOME_COMP, A.CURSO, A.TURNO, A.CURRICULO, C.NOME,PM.ALUNO, PM.DISCIPLINA, PM.MENS_ERRO
  FROM LY_PRE_MATRICULA PM
JOIN LY_ALUNO A ON A.ALUNO = PM.ALUNO
JOIN LY_CURSO C ON C.CURSO = A.CURSO
JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = A.UNIDADE_FISICA
WHERE TURMA IS NULL
AND ANO = 2017
AND SEMESTRE = 1
ORDER BY 3,5,7