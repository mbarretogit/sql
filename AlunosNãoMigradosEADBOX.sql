 USE EADBOX
 GO
 
 SELECT A.UNIDADE_FISICA
		, A.CURSO
		, C.NOME
		, VW.DISCIPLINA
		, D.NOME AS NOME_DISCIPLINA
		, A.ALUNO AS MATRICULA_LYCEUM
		, U.CPF
		, U.eadboxid
		, VW.SIT_MATRICULA
		, M.dt_criacao
		, M.dt_integracao
		, DATEDIFF(day,M.dt_criacao,M.dt_integracao) AS DIAS_PROCESSADOS
 FROM Matricula M
 JOIN LYCEUM..VW_MATRICULA_E_PRE_MATRICULA VW 
		ON VW.ALUNO = M.aluno 
		AND VW.ANO = M.ano 
		AND VW.SEMESTRE = M.semestre 
		AND VW.DISCIPLINA = M.disciplina 
		AND VW.TURMA = M.turma
JOIN LYCEUM..LY_ALUNO A 
		ON A.ALUNO = M.aluno
JOIN LYCEUM..LY_DISCIPLINA D 
		ON D.DISCIPLINA = VW.DISCIPLINA
JOIN LYCEUM..LY_CURSO C 
		ON C.CURSO = A.CURSO
JOIN Usuario U
		ON U.PESSOA = A.PESSOA
 WHERE 1=1
 AND M.ano = 2018
 AND M.semestre = 1
 --AND M.dt_criacao > '2018-03-26'
 --AND M.dt_integracao >= '2018-03-23'
 and A.SIT_ALUNO = 'Ativo'
 AND A.UNIDADE_FISICA NOT IN ('OTE-JUA','OTE-PET', 'OTE-SP')
 AND M.disciplina IN ('143699','143921','143922','143924','146632','147912','UDI412')
 --AND (DATEDIFF(DD,m.dt_criacao,m.dt_integracao) >= 0 OR m.dt_integracao IS NULL)
and  m.dt_integracao IS NULL
 --AND DATEDIFF(DD,m.dt_criacao,m.dt_integracao) > 0
 --and U.cpf = '00069909598'
 --and a.aluno = '162060143'
 
 
  order by 10 desc,1,2,4

 