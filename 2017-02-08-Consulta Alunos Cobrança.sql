--ALUNOS ATIVOS SEM COBRAN�A GERADA
SELECT DISTINCT 
UF.UNIDADE_FIS,
UF.NOME_COMP,
CU.CURSO,
CU.NOME,
A.ALUNO,
A.NOME_COMPL,
VW.SIT_MATRICULA
FROM LY_ALUNO A
JOIN VW_matricula_e_pre_matricula VW ON VW.aluno = A.ALUNO
JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = A.UNIDADE_FISICA
JOIN LY_CURSO CU ON CU.CURSO = A.CURSO
WHERE 1 = 1 
AND NOT EXISTS (SELECT 1 FROM LY_COBRANCA C WHERE C.ALUNO = A.ALUNO)
AND A.SIT_ALUNO = 'ATIVO'
ORDER BY 1,3,6

--ALUNOS ATIVOS COM COBRAN�A GERADA
SELECT DISTINCT 
UF.UNIDADE_FIS,
UF.NOME_COMP,
CU.CURSO,
CU.NOME,
A.ALUNO,
A.NOME_COMPL,
VW.SIT_MATRICULA,
C.COBRANCA,
ISNULL(C.DATA_DE_FATURAMENTO,'') AS DATA_DE_FATURAMENTO,
ISNULL((SELECT TOP 1 'S' FROM LY_ITEM_LANC IL WHERE IL.COBRANCA = C.COBRANCA AND IL.BOLETO IS NOT NULL),'N') AS BOLETO
FROM LY_ALUNO A
JOIN VW_matricula_e_pre_matricula VW ON VW.aluno = A.ALUNO
JOIN LY_COBRANCA C ON C.ALUNO = A.ALUNO
JOIN LY_UNIDADE_FISICA UF ON UF.UNIDADE_FIS = A.UNIDADE_FISICA
JOIN LY_CURSO CU ON CU.CURSO = A.CURSO
WHERE 1 = 1 
AND A.SIT_ALUNO = 'ATIVO'
AND VW.ANO = 2017 AND VW.SEMESTRE = 1 AND A.UNIDADE_FISICA = 'FCS'
ORDER BY 1,3,6