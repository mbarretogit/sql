  SELECT A.aluno,A.nome_compl, a.UNIDADE_FISICA AS UNIDADE_ALUNO, t.disciplina, t.turma,t.ano,t.semestre,t.FACULDADE AS UNIDADE_TURMA
  FROM ly_aluno a
  JOIN LY_PRE_MATRICULA pm ON pm.ALUNO = a.ALUNO
  JOIN ly_turma t ON t.TURMA = pm.TURMA AND t.DISCIPLINA = pm.DISCIPLINA AND t.ANO = pm.ano AND t.SEMESTRE = pm.SEMESTRE
  WHERE t.faculdade <> a.UNIDADE_FISICA
  AND t.ANO = 2017
  AND t.SEMESTRE = 1
  ORDER BY 1