UPDATE A SET A.TIPO_ALUNO = 'REINGRESSO'
FROM BI_ACOMP_MATR A
JOIN BI_REMATRICULA B ON B.ALUNO = A.ALUNO AND B.ANO = A.ANO AND B.SEMESTRE = A.SEMESTRE
WHERE B.TIPO_ALUNO = 'REINGRESSO'