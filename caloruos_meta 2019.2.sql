SELECT DISTINCT ANO, SEMESTRE, NOME_UNIDADE_ENSINO_ALUNO, TIPO_CURSO,  NOME_CURSO, TIPO_ALUNO, TIPO_INGRESSO, ALUNO, NOME_ALUNO, MIN(DATA_MATRICULA) DATA_MATRICULA, SIT_MATRICULA, PAGO
FROM BI_ACOMP_MATR_HIST
WHERE 1=1
AND DATA_HIST > '2019-10-04'
AND DATA_HIST < '2019-10-05'
AND ANO = 2019 AND SEMESTRE = 2
AND SIT_MATRICULA IN  ('Matriculado','Pre-Matric')
AND PAGO = 1
AND TIPO_FINAN IN ('FIES','PAGANTES')
AND TIPO_ALUNO IN ('CALOURO','REINGRESSO')
AND TIPO_INGRESSO NOT IN ('TransferenciaInterna','Ouvinte')
AND TIPO_CURSO IN ('GRADUACAO','TECNOLOGO','GRADUACAO-SP','GRADUACAO-EAD')
AND (DATA_CANCELAMENTO > '2019-09-19' OR DATA_CANCELAMENTO IS NULL)
GROUP BY ANO, SEMESTRE, NOME_UNIDADE_ENSINO_ALUNO, NOME_CURSO, ALUNO, NOME_ALUNO, SIT_MATRICULA, PAGO,TIPO_ALUNO,TIPO_CURSO,TIPO_INGRESSO
ORDER BY ALUNO

SELECT DISTINCT TIPO_INGRESSO
FROM BI_ACOMP_MATR_HIST
WHERE 1=1




SELECT DISTINCT DATA_HIST FROM BI_ACOMP_MATR_HIST WHERE ANO = 2019 AND SEMESTRE = 2 ORDER BY 1